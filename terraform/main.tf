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
# Jenkins-Server (REMOVED from Terraform management)
# Jenkins server should be managed separately to avoid self-destruction
# ------------------------

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
# Jenkins server outputs removed - manage Jenkins separately

output "resume_evaluator_public_ip" {
  description = "Public IP address of Resume Evaluator instance"
  value       = aws_instance.resume_evaluator.public_ip
}

output "resume_evaluator_private_ip" {
  description = "Private IP address of Resume Evaluator instance"
  value       = aws_instance.resume_evaluator.private_ip
}