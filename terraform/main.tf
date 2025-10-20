terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# ------------------------
# Jenkins-Server
# ------------------------
resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0a716d3f3b16d290c"
  instance_type          = "t3.micro"
  key_name               = "ResumeEvaluator"
  subnet_id              = "subnet-0d4dd138cb92009ae"
  vpc_security_group_ids = ["sg-00dd88af33f2e9571"]

  # Prevent accidental destruction of Jenkins server
  lifecycle {
    prevent_destroy = false
  }

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    
    # Install Java 11
    apt install -y openjdk-11-jdk
    
    # Install Jenkins
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | apt-key add -
    echo "deb https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
    apt update -y
    apt install -y jenkins
    systemctl start jenkins
    systemctl enable jenkins
    
    # Install Terraform
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt update -y
    apt install -y terraform
    
    # Install Ansible
    apt install -y python3-pip unzip
    pip3 install ansible
    
    # Install Git and AWS CLI
    apt install -y git
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
    
    # Setup jenkins directories
    mkdir -p /var/lib/jenkins/.ssh
    mkdir -p /var/lib/jenkins/.aws
    chown -R jenkins:jenkins /var/lib/jenkins/.ssh
    chown -R jenkins:jenkins /var/lib/jenkins/.aws
    chmod 700 /var/lib/jenkins/.ssh
  EOF

  tags = {
    Name = "Jenkins-Server"
  }
}

# ------------------------
# Resume-Evaluator
# ------------------------
resource "aws_instance" "resume_evaluator" {
  ami                    = "ami-043339ea831b48099"
  instance_type          = "t3.small"
  key_name               = "ResumeEvaluator"
  subnet_id              = "subnet-0d4dd138cb92009ae"
  vpc_security_group_ids = ["sg-023534ffa2f011bb9"]

  lifecycle {
    ignore_changes = [user_data]
  }

  tags = {
    Name = "Resume-Evaluator"
  }
}

# ------------------------
# Outputs
# ------------------------
output "jenkins_server_public_ip" {
  description = "Public IP address of Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}

output "jenkins_server_private_ip" {
  description = "Private IP address of Jenkins server"
  value       = aws_instance.jenkins_server.private_ip
}

output "resume_evaluator_public_ip" {
  description = "Public IP address of Resume Evaluator instance"
  value       = aws_instance.resume_evaluator.public_ip
}

output "resume_evaluator_private_ip" {
  description = "Private IP address of Resume Evaluator instance"
  value       = aws_instance.resume_evaluator.private_ip
}
