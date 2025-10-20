#!/bin/bash

# Jenkins Server Setup Script
# Run this on the Jenkins EC2 instance

set -e

echo "🚀 Setting up Jenkins server with Terraform and Ansible..."

# Update system
sudo yum update -y

# Install Java 11 (required for Jenkins)
sudo yum install -y java-11-amazon-corretto-headless

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Install Terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

# Install Ansible
sudo yum install -y python3-pip
sudo pip3 install ansible

# Install Git
sudo yum install -y git

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Create jenkins user directories
sudo mkdir -p /var/lib/jenkins/.ssh
sudo mkdir -p /var/lib/jenkins/.aws

# Set proper permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh
sudo chown -R jenkins:jenkins /var/lib/jenkins/.aws
sudo chmod 700 /var/lib/jenkins/.ssh

echo "✅ Jenkins server setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Get Jenkins initial password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
echo "2. Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "3. Configure AWS credentials: aws configure"
echo "4. Add SSH key for EC2 instances to /var/lib/jenkins/.ssh/"
echo "5. Install required Jenkins plugins: Terraform, Ansible, SSH Agent"