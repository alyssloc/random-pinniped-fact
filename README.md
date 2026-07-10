
# Pinniped Facts

Click on the link to see a random fun fact about a pinniped. The goal of this project was to gain more experience using IaC, creating containerized applications, deploying them via Google Cloud Platform, and setting up CI/CD pipelines. 


## Link

https://daily-pinniped-fact.aquaticdle.com/


## Tech Stack

**Backend:** Python, Flask, SQLAlchemy, SQLite, Gunicorn

**Infastructure:** Google Cloud Platform (Cloud Run, Compute Engine), Terraform, Docker

**Networking & Security:** Nginx (Reverse Proxy, SNI), Let's Encrypt (Certbot/SSL)

**CI/CD:** GitHub Actions, Google Workload Identity Federation


## Overview
**Containerized API**: The Flask backend is containerized using Docker and deployed to Google Cloud Run. The container is stateless but initializes and seeds a local SQLite database on startup. It has one endpoint, GET /api/fact/random, which returns a fact, an image url, and the fact's id. 

**Frontend Hosting**: The frontend is hosted on a GCP Compute Engine virtual machine. 

Infrastructure as Code: Base infrastructure, including VM provisioning and firewall configurations, is declared and managed using Terraform.



