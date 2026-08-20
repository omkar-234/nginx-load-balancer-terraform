# Nginx Load Balancer - Manual + Terraform Automated

## 📌 Project Overview
This project was built in phases - first manually, then automated using Terraform, and finally extended with Blue-Green deployment for zero-downtime releases.

## 🔹 Phase 1: Manual Setup
- Launched 2 backend servers (Flask apps) + 1 Nginx server on AWS EC2
- Configured Nginx as a load balancer using the `upstream` module - round-robin traffic distribution across both backend servers
- Set up systemd services for backend apps for production resilience - apps auto-restart and keep running even after SSH sessions close
- Tested failover - stopped one backend server, Nginx automatically routed all traffic to the healthy server - zero downtime confirmed

## 🔹 Phase 2: Terraform Automation
- Installed Terraform on the same Nginx server
- Wrote Infrastructure as Code (IaC) to automate Security Groups, 3 EC2 instances, Flask apps, and systemd services
- A single `terraform apply` command provisioned the entire infrastructure live within ~2 minutes (compared to ~20 minutes manually)

## 🔄 Phase 3: Blue-Green Deployment
- Deployed 2 versions simultaneously - Blue (port 5000, original) and Green (port 5001, updated), both managed via systemd
- Split Nginx config into `loadbalancer-blue` and `loadbalancer-green` files, controlled by a single symlink to determine which is active
- Switched traffic instantly from Blue to Green using symlink change - zero downtime
- Rollback capability - if any issue occurs, can revert to Blue within seconds by flipping the symlink back

## 🛠️ Tech Stack
- AWS EC2
- Nginx (reverse proxy / load balancer)
- Flask (Python)
- systemd
- Terraform (IaC)
- Git/GitHub

## 📂 Repo Structure
