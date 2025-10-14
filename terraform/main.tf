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

  tags = {
    Name = "Jenkins-Server"
  }
}

# ------------------------
# Resume-Evaluator
# ------------------------
resource "aws_instance" "resume_evaluator" {
  ami                    = "ami-043339ea831b48099"
  instance_type          = "t3.micro"
  key_name               = "ResumeEvaluator"
  subnet_id              = "subnet-0d4dd138cb92009ae"
  vpc_security_group_ids = ["sg-023534ffa2f011bb9"]

  tags = {
    Name = "Resume-Evaluator"
  }
}
