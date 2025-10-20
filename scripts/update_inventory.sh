#!/bin/bash

# Update Ansible inventory from Terraform outputs
cd terraform

# Get the public IP of the Resume Evaluator instance
RESUME_EVALUATOR_IP=$(terraform output -raw resume_evaluator_public_ip 2>/dev/null || echo "")

if [ -z "$RESUME_EVALUATOR_IP" ]; then
    echo "❌ Could not get Resume Evaluator IP from Terraform output"
    exit 1
fi

# Update the inventory file
cat > ../ansible/inventory/hosts.ini << EOF
[resume-evaluator]
Resume-Evaluator ansible_host=$RESUME_EVALUATOR_IP ansible_user=ec2-user ansible_ssh_private_key_file=/home/ubuntu/.ssh/ResumeEvaluator.pem
EOF

echo "✅ Updated inventory with Resume Evaluator IP: $RESUME_EVALUATOR_IP"