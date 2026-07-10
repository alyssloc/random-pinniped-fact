from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import func
import random, json, os



app = Flask(__name__)
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
db_path = os.path.join(BASE_DIR, 'instance', 'pinniped_facts.db')

app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{db_path}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)


#defining db structure & helper function to return as a dict
class PinnipedFact(db.Model):
   id = db.Column(db.Integer, primary_key=True)
   fact_text = db.Column(db.String(500), nullable=False)
   image_url = db.Column(db.String(200), nullable=False)

   def __init__(self, fact_text, image_url):
       self.fact_text = fact_text
       self.image_url = image_url

   def to_dict(self):
      return {
            "id": self.id,
            "fact": self.fact_text,
            "image_url": self.image_url
        }

@app.route('/api/fact/random', methods=['GET'])
def random_fact():
   #selecting a random fact by shuffling and then selecting the first fact
   random_fact = PinnipedFact.query.order_by(func.random()).first()

   if not random_fact:
        return jsonify({"status": "error", "message": "No facts found"}), 404

   
   fact_data = random_fact.to_dict() 
   base_url = request.host_url.rstrip('/')

   #in db, image url is just the {seal name} part, appending path and file type
   seal_name = fact_data['image_url']
   fact_data['image_url'] = f"{base_url}/static/{seal_name}.jpg"
    
   return jsonify({
      "status": "success",
      "data": fact_data
    })
   
@app.cli.command("init-db")
def init_db():
    db.create_all()
   
@app.cli.command("seed-db")
def seed_db_command():
    seed_db()

def seed_db():
    db.create_all()
    seed_path = os.path.join(BASE_DIR, 'static', 'seed.json')

    if not os.path.exists(seed_path):
        print(f"Seed file not found at {seed_path}")
        return
    
    with open(seed_path, 'r', encoding='utf-8') as f:
        facts_list = json.load(f)
        
    for item in facts_list:
        json_fact_text = item['fact_text']
        json_image_url = item['image_url']
        
        exists = PinnipedFact.query.filter_by(fact_text=json_fact_text).first()
        if not exists:
            new_fact = PinnipedFact(
                fact_text=json_fact_text, 
                image_url=json_image_url
            )
            db.session.add(new_fact)
            
    db.session.commit()

with app.app_context():
    seed_db()

if __name__ == '__main__':
    app.run(debug=True, port=5000)