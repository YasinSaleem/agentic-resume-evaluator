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
# User Data Scripts
# ------------------------

# Jenkins Server Setup Script
locals {
  jenkins_user_data = <<-EOF
    #!/bin/bash
    set -e
    
    echo "Starting Jenkins Server Setup..."
    
    # Update system
    apt-get update
    apt-get upgrade -y
    
    # Install Java (required for Jenkins)
    apt-get install -y openjdk-17-jdk
    
    # Install Jenkins
    wget -q -O /usr/share/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
      https://pkg.jenkins.io/debian-stable binary/ | \
      tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    apt-get update
    apt-get install -y jenkins
    
    # Start Jenkins
    systemctl enable jenkins
    systemctl start jenkins
    
    # Install Terraform
    wget -O- https://apt.releases.hashicorp.com/gpg | \
      gpg --dearmor | \
      tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
      tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update
    apt-get install -y terraform
    
    # Install Ansible
    apt-get install -y software-properties-common
    add-apt-repository --yes --update ppa:ansible/ansible
    apt-get install -y ansible
    
    # Install AWS CLI
    apt-get install -y awscli
    
    # Install Git
    apt-get install -y git
    
    # Install Python3 and pip
    apt-get install -y python3 python3-pip
    
    # Create directory for SSH keys
    mkdir -p /var/lib/jenkins/.ssh
    chown jenkins:jenkins /var/lib/jenkins/.ssh
    chmod 700 /var/lib/jenkins/.ssh
    
    # Configure AWS credentials directory
    mkdir -p /var/lib/jenkins/.aws
    chown jenkins:jenkins /var/lib/jenkins/.aws
    chmod 700 /var/lib/jenkins/.aws
    
    echo "Jenkins Server Setup Complete!"
    echo "Jenkins initial admin password:"
    sleep 30
    cat /var/lib/jenkins/secrets/initialAdminPassword || echo "Password not ready yet, wait a minute"
    
  EOF

  app_user_data = <<-EOF
    #!/bin/bash
    set -e
    
    echo "Starting Application Server Setup..."
    
    # Update system
    apt-get update
    apt-get upgrade -y
    
    # Install Docker
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
      gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Start Docker
    systemctl enable docker
    systemctl start docker
    
    # Install Python3 and pip
    apt-get install -y python3 python3-pip
    
    # Install Node.js and npm (for frontend)
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    
    # Install Git
    apt-get install -y git
    
    # Create app directory
    mkdir -p /opt/resume-evaluator
    chown ubuntu:ubuntu /opt/resume-evaluator
    
    # Create ubuntu user .ssh directory for Ansible
    mkdir -p /home/ubuntu/.ssh
    chown ubuntu:ubuntu /home/ubuntu/.ssh
    chmod 700 /home/ubuntu/.ssh
    
    echo "Application Server Setup Complete!"
    
  EOF
}

# ------------------------
# Jenkins Server
# ------------------------
resource "aws_instance" "jenkins_server" {
  ami                    = "ami-0a716d3f3b16d290c"
  instance_type          = "t3.micro"
  key_name               = "ResumeEvaluator"
  subnet_id              = "subnet-0d4dd138cb92009ae"
  vpc_security_group_ids = ["sg-00dd88af33f2e9571"]
  
  user_data = local.jenkins_user_data
  
  # Ensure we have enough storage
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  
  tags = {
    Name = "Jenkins-Server"
    ManagedBy = "Terraform"
  }
}

# ------------------------
# Resume Evaluator App Server
# ------------------------
resource "aws_instance" "resume_evaluator" {
  ami                    = "ami-043339ea831b48099"
  instance_type          = "t3.micro"
  key_name               = "ResumeEvaluator"
  subnet_id              = "subnet-0d4dd138cb92009ae"
  vpc_security_group_ids = ["sg-023534ffa2f011bb9"]
  
  user_data = local.app_user_data
  
  # Ensure we have enough storage
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }
  
  tags = {
    Name = "Resume-Evaluator"
    ManagedBy = "Terraform"
  }
}

# ------------------------
# Outputs
# ------------------------
output "jenkins_server_public_ip" {
  description = "Public IP of Jenkins Server"
  value       = aws_instance.jenkins_server.public_ip
}

output "jenkins_server_private_ip" {
  description = "Private IP of Jenkins Server"
  value       = aws_instance.jenkins_server.private_ip
}

output "app_server_public_ip" {
  description = "Public IP of Application Server"
  value       = aws_instance.resume_evaluator.public_ip
}

output "app_server_private_ip" {
  description = "Private IP of Application Server"
  value       = aws_instance.resume_evaluator.private_ip
}

output "jenkins_url" {
  description = "Jenkins Web UI URL"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "ansible_inventory" {
  description = "Ansible Inventory in INI format"
  value = <<-EOT
[jenkins]
jenkins-server ansible_host=${aws_instance.jenkins_server.public_ip} ansible_user=ubuntu ansible_become=yes

[app_servers]
app-server ansible_host=${aws_instance.resume_evaluator.public_ip} ansible_user=ubuntu ansible_become=yes

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT
}

output "jenkins_initial_password_command" {
  description = "Command to get Jenkins initial password"
  value       = "ssh -i ~/.ssh/ResumeEvaluator.pem ubuntu@${aws_instance.jenkins_server.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}