# Jenkins + Terraform CI/CD Setup Guide

## Overview
This guide sets up Jenkins on EC2 to manage your Resume Evaluator infrastructure using Terraform and deploy applications with Ansible.

## Architecture
```
Jenkins EC2 → Terraform → Resume Evaluator EC2 → Ansible Deployment
```

## Prerequisites
- AWS Account with appropriate permissions
- EC2 Key Pair (`ResumeEvaluator.pem`)
- Security Groups configured for Jenkins (port 8080) and Resume Evaluator (ports 3000, 8000)

## Step 1: Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This creates:
- Jenkins Server EC2 instance (with auto-setup)
- Resume Evaluator EC2 instance
- Outputs for both instance IPs

## Step 2: Configure Jenkins Server

1. **Access Jenkins**:
   ```bash
   # Get Jenkins IP from Terraform output
   terraform output jenkins_server_public_ip
   
   # Access: http://<jenkins-ip>:8080
   ```

2. **Get Initial Password**:
   ```bash
   # SSH to Jenkins server
   ssh -i ResumeEvaluator.pem ec2-user@<jenkins-ip>
   
   # Get password
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```

3. **Install Required Plugins**:
   - Terraform Plugin
   - Ansible Plugin
   - SSH Agent Plugin
   - Git Plugin
   - Pipeline Plugin

## Step 3: Configure AWS Credentials

On Jenkins server:
```bash
sudo su - jenkins
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Region: eu-north-1
# Output format: json
```

## Step 4: Add SSH Key

```bash
# Copy your EC2 key to Jenkins server
sudo cp /path/to/ResumeEvaluator.pem /var/lib/jenkins/.ssh/
sudo chown jenkins:jenkins /var/lib/jenkins/.ssh/ResumeEvaluator.pem
sudo chmod 600 /var/lib/jenkins/.ssh/ResumeEvaluator.pem
```

## Step 5: Create Jenkins Credentials

In Jenkins UI:
1. Go to "Manage Jenkins" → "Manage Credentials"
2. Add SSH Username with private key:
   - ID: `jenkins-ec2-ssh`
   - Username: `ec2-user`
   - Private Key: Upload `ResumeEvaluator.pem`

## Step 6: Create Jenkins Pipeline Job

1. New Item → Pipeline
2. Pipeline script from SCM
3. Repository URL: `https://github.com/YasinSaleem/agentic-resume-evaluator.git`
4. Branch: `deployment`
5. Script Path: `Jenkinsfile`

## Step 7: Environment Variables

Set in Jenkins job configuration:
- `AWS_DEFAULT_REGION`: `eu-north-1`
- `TF_VAR_*`: Any Terraform variables needed

## Pipeline Flow

1. **Checkout**: Gets latest code from deployment branch
2. **Check Terraform Changes**: Detects if infrastructure needs updating
3. **Terraform Init/Plan/Apply**: Updates infrastructure if needed
4. **Update Inventory**: Updates Ansible inventory with new IPs
5. **Deploy Application**: Runs Ansible playbook to deploy app

## Terraform State Management

For production, consider:
- Remote state backend (S3 + DynamoDB)
- State locking
- Separate environments

Example backend configuration:
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "resume-evaluator/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "terraform-locks"
  }
}
```

## Security Best Practices

1. **IAM Roles**: Use IAM roles instead of access keys where possible
2. **Least Privilege**: Grant minimum required permissions
3. **Secrets Management**: Use Jenkins credentials store for sensitive data
4. **Network Security**: Restrict security group access
5. **Key Rotation**: Regularly rotate access keys and SSH keys

## Troubleshooting

### Common Issues:

1. **Terraform not found**:
   ```bash
   sudo ln -s /usr/local/bin/terraform /usr/bin/terraform
   ```

2. **Permission denied for SSH**:
   ```bash
   chmod 600 /var/lib/jenkins/.ssh/ResumeEvaluator.pem
   ```

3. **AWS credentials not found**:
   ```bash
   sudo su - jenkins
   aws configure list
   ```

4. **Ansible host key verification**:
   Add to `/var/lib/jenkins/.ssh/config`:
   ```
   Host *
       StrictHostKeyChecking no
       UserKnownHostsFile=/dev/null
   ```

## Monitoring

- Jenkins build logs
- AWS CloudWatch for EC2 metrics
- Application logs on target instances

## Next Steps

1. Set up notifications (Slack, email)
2. Add automated testing stages
3. Implement blue-green deployments
4. Add monitoring and alerting
5. Set up backup strategies