# Nginx Load Balancer - Manual + Terraform Automated

## 📌 Project Overview
Ha project 2 phases madhe kela ahe - pahile manually, mag Terraform vaparun automate kela.

## 🔹 Phase 1: Manual Setup
- 2 backend servers (Flask apps) + 1 Nginx server AWS EC2 var launch kele
- Nginx configure kela load balancer mhanun (upstream module) - round-robin traffic distribution
- systemd services banवल्या backend apps sathi (production-resilient, auto-restart)
- Failover test kela - ek backend server band kela, Nginx automatically dusऱ्या server kade traffic vaळla - zero downtime

## 🔹 Phase 2: Terraform Automation
- Same Nginx server var Terraform install kela
- Infrastructure as Code (IaC) lihila - Security Groups, 3 EC2 instances, Flask apps, systemd services, Nginx config - sagla automate kela via user_data scripts
- Ekach `terraform apply` command ne 2 minitात pura infra live zala

## 🛠️ Tech Stack
- AWS EC2
- Nginx (reverse proxy / load balancer)
- Flask (Python)
- systemd
- Terraform (IaC)

## 📂 Repo Structure
