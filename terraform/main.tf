provider "aws" {
  region = "ap-south-1"
}

# Security Group - shared by Server 1 & Server 2 (backend)
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg-tf"
  description = "Allow SSH and port 5000 from Nginx"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask App"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group - Nginx
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg-tf"
  description = "Allow SSH, HTTP, HTTPS"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Backend Server 1
resource "aws_instance" "server1" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = "t3.micro"
  key_name               = "mumbaiPPK-key"
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y python3-pip python3-venv
              mkdir -p /home/ubuntu/app
              cd /home/ubuntu/app
              python3 -m venv venv
              /home/ubuntu/app/venv/bin/pip install flask
              cat << 'PYEOF' > /home/ubuntu/app/app.py
              from flask import Flask
              app = Flask(__name__)

              @app.route('/')
              def home():
                  return "Hello from Server 1 (Terraform) 🚀"

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=5000)
              PYEOF
              cat << 'SVCEOF' > /etc/systemd/system/flaskapp.service
              [Unit]
              Description=Flask App Server 1
              After=network.target

              [Service]
              User=ubuntu
              WorkingDirectory=/home/ubuntu/app
              ExecStart=/home/ubuntu/app/venv/bin/python3 /home/ubuntu/app/app.py
              Restart=always

              [Install]
              WantedBy=multi-user.target
              SVCEOF
              chown -R ubuntu:ubuntu /home/ubuntu/app
              systemctl daemon-reload
              systemctl enable flaskapp
              systemctl start flaskapp
              EOF

  tags = {
    Name = "Server1-Terraform"
  }
}

# Backend Server 2
resource "aws_instance" "server2" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = "t3.micro"
  key_name               = "mumbaiPPK-key"
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y python3-pip python3-venv
              mkdir -p /home/ubuntu/app
              cd /home/ubuntu/app
              python3 -m venv venv
              /home/ubuntu/app/venv/bin/pip install flask
              cat << 'PYEOF' > /home/ubuntu/app/app.py
              from flask import Flask
              app = Flask(__name__)

              @app.route('/')
              def home():
                  return "Hello from Server 2 (Terraform) 🚀"

              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=5000)
              PYEOF
              cat << 'SVCEOF' > /etc/systemd/system/flaskapp.service
              [Unit]
              Description=Flask App Server 2
              After=network.target

              [Service]
              User=ubuntu
              WorkingDirectory=/home/ubuntu/app
              ExecStart=/home/ubuntu/app/venv/bin/python3 /home/ubuntu/app/app.py
              Restart=always

              [Install]
              WantedBy=multi-user.target
              SVCEOF
              chown -R ubuntu:ubuntu /home/ubuntu/app
              systemctl daemon-reload
              systemctl enable flaskapp
              systemctl start flaskapp
              EOF

  tags = {
    Name = "Server2-Terraform"
  }
}

# Nginx Load Balancer
resource "aws_instance" "nginx" {
  ami                    = "ami-01a00762f46d584a1"
  instance_type          = "t3.micro"
  key_name               = "mumbaiPPK-key"
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]

  depends_on = [aws_instance.server1, aws_instance.server2]

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y nginx
              cat << 'CONFEOF' > /etc/nginx/sites-available/loadbalancer
              upstream backend_servers {
                  server ${aws_instance.server1.private_ip}:5000;
                  server ${aws_instance.server2.private_ip}:5000;
              }

              server {
                  listen 80;

                  location / {
                      proxy_pass http://backend_servers;
                      proxy_set_header Host $host;
                      proxy_set_header X-Real-IP $remote_addr;
                  }
              }
              CONFEOF
              ln -s /etc/nginx/sites-available/loadbalancer /etc/nginx/sites-enabled/
              rm -f /etc/nginx/sites-enabled/default
              systemctl restart nginx
              EOF

  tags = {
    Name = "Nginx-Terraform"
  }
}

# Outputs
output "nginx_public_ip" {
  value = aws_instance.nginx.public_ip
}

output "server1_public_ip" {
  value = aws_instance.server1.public_ip
}

output "server2_public_ip" {
  value = aws_instance.server2.public_ip
}
