#1- setting starting enviornment
FROM python:3.11-slim

#2- setting up enviornment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

#3- setting working directory
WORKDIR /src

#4- installing compilation tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

#5- installing python dependenices
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

#6- copy application code
COPY . .

#6- data directory
RUN mkdir -p /src/instance/pinniped_facts

#7- creating user to run the app
RUN useradd -m appuser
RUN chown -R appuser:appuser /src
USER appuser

#8- running application
CMD exec gunicorn --bind 0.0.0.0:$PORT "app:app"

