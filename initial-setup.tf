# ========================================
# INITIAL SETUP - Complete Infrastructure
# ========================================
# Use this file to create everything from scratch
# Rename to main.tf when needed for initial deployment

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ========================================
# Variables
# ========================================
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "ResumeEvaluator"
}

variable "subnet_id" {
  description = "Subnet ID for instances"
  type        = string
  default     = "subnet-0d4dd138cb92009ae"
}

variable "jenkins_sg_id" {
  description = "Security Group ID for Jenkins server"
  type        = string
  default     = "sg-00dd88af33f2e9571"
}

variable "app_sg_id" {
  description = "Security Group ID for application server"
  type        = string
  default     = "sg-023534ffa2f011bb9"
}

# ========================================
# Data Sources
# ========================================
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ========================================
# Jenkins Server
# ========================================
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.jenkins_sg_id]

  user_data = base64encode(templatefile("${path.module}/scripts/jenkins-setup.sh", {
    region = var.aws_region
  }))

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "Jenkins-Server"
    Environment = "production"
    Purpose     = "CI/CD"
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# Resume Evaluator Server
# ========================================
resource "aws_instance" "resume_evaluator" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(templatefile("${path.module}/scripts/app-setup.sh", {
    region = var.aws_region
  }))

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "Resume-Evaluator"
    Environment = "production"
    Purpose     = "Application"
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ========================================
# Outputs
# ========================================
output "jenkins_server_public_ip" {
  description = "Public IP address of Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}

output "jenkins_server_private_ip" {
  description = "Private IP address of Jenkins server"
  value       = aws_instance.jenkins_server.private_ip
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "resume_evaluator_public_ip" {
  description = "Public IP address of Resume Evaluator instance"
  value       = aws_instance.resume_evaluator.public_ip
}

output "resume_evaluator_private_ip" {
  description = "Private IP address of Resume Evaluator instance"
  value       = aws_instance.resume_evaluator.private_ip
}

output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = {
    jenkins = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.jenkins_server.public_ip}"
    app     = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.resume_evaluator.public_ip}"
  }
}

output "next_steps" {
  description = "Next steps after deployment"
  value = [
    "1. Wait 5-10 minutes for user_data scripts to complete",
    "2. Get Jenkins password: ssh -i ${var.key_name}.pem ubuntu@${aws_instance.jenkins_server.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'",
    "3. Access Jenkins at: http://${aws_instance.jenkins_server.public_ip}:8080",
    "4. Configure AWS credentials on Jenkins server",
    "5. Add SSH key to Jenkins server",
    "6. Create pipeline job pointing to your GitHub repo"
  ]
}