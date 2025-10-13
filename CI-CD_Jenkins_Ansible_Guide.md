# 🚀 CI/CD Pipeline Setup for Agentic Resume Evaluator

This document explains how to set up a **CI/CD pipeline using Jenkins, Ansible, and AWS EC2** for the **Agentic Resume Evaluator** project.

---

## 🧩 Project Overview

The project repository:  
🔗 [https://github.com/YasinSaleem/agentic-resume-evaluator/tree/final](https://github.com/YasinSaleem/agentic-resume-evaluator/tree/final)

**Stack used:**
- **Backend:** FastAPI (Python)
- **Deployment:** PM2 (for process management)
- **Configuration Management:** Ansible
- **CI/CD Tool:** Jenkins
- **Hosting:** AWS EC2 (Ubuntu)
- **Repository:** GitHub

---

## ⚙️ Architecture Flow

```
GitHub Repo  --->  Jenkins Server  --->  Ansible  --->  EC2 Instance
   |                  |                    |            |
   |                  |                    |            |
   |       Jenkins pulls latest code       |            |
   |       Runs Ansible Playbook ----------┘            |
   |                            EC2 deploys app via PM2 |
```

---

## 🖥️ Prerequisites

### On **EC2 Instance**
1. **Install dependencies:**
   ```bash
   sudo apt update
   sudo apt install python3 python3-pip git -y
   npm install pm2 -g
   ```

2. **Allow SSH access** from the Jenkins server’s IP (port `22`).

3. **Create a deploy directory:**
   ```bash
   mkdir -p ~/agentic-resume-evaluator
   ```

4. **Ensure PM2 starts on boot:**
   ```bash
   pm2 startup
   ```

---

### On **Jenkins Server**
1. Install necessary packages:
   ```bash
   sudo apt update
   sudo apt install ansible git python3-pip -y
   ```

2. Add SSH key to connect with EC2:
   ```bash
   ssh-keygen -t rsa -b 4096
   ssh-copy-id ubuntu@<EC2-IP>
   ```

3. Install Jenkins and plugins:
   - Git Plugin
   - Pipeline Plugin
   - Ansible Plugin

4. Add Jenkins to the `sudoers` file (optional but helpful for automation):
   ```bash
   sudo usermod -aG sudo jenkins
   ```

---

## 📁 Folder Structure (GitHub Repo)

```
agentic-resume-evaluator/
│
├── ansible/
│   ├── install_dependencies.yml
│   ├── deploy_app.yml
│   ├── inventory
│   └── group_vars/
│       └── all.yml
│
├── app/
│   ├── main.py
│   ├── requirements.txt
│   └── ...
│
├── .gitignore
├── README.md
└── ...
```

---

## ⚡ Ansible Playbooks

### `inventory`
```
[ec2]
<EC2-IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### `install_dependencies.yml`
```yaml
---
- hosts: ec2
  become: true
  tasks:
    - name: Install Python and pip
      apt:
        name: ["python3", "python3-pip"]
        state: present
        update_cache: yes

    - name: Install PM2 globally
      npm:
        name: pm2
        global: yes
```

### `deploy_app.yml`
```yaml
---
- hosts: ec2
  become: true
  tasks:
    - name: Copy application files
      synchronize:
        src: "{{ playbook_dir }}/../"
        dest: "/home/ubuntu/agentic-resume-evaluator"
        rsync_opts:
          - "--exclude=.git"
          - "--exclude=ansible"

    - name: Install Python dependencies
      pip:
        requirements: /home/ubuntu/agentic-resume-evaluator/app/requirements.txt
        executable: pip3

    - name: Restart FastAPI app using PM2
      shell: |
        cd /home/ubuntu/agentic-resume-evaluator/app
        pm2 delete fastapi-app || true
        pm2 start "uvicorn main:app --host 0.0.0.0 --port 8000" --name fastapi-app
        pm2 save
```

---

## 🔧 Jenkins Pipeline Setup

> The Jenkinsfile is **stored on the Jenkins server**, not in the GitHub repo.

### 1️⃣ Create a Pipeline Job in Jenkins

- **Type:** Pipeline  
- **SCM:** Git  
- **Repository URL:**  
  `https://github.com/YasinSaleem/agentic-resume-evaluator.git`  
- **Branch:** `final`

---

### 2️⃣ Jenkinsfile (in Jenkins server)

Create the Jenkinsfile at:  
`/var/lib/jenkins/workspace/<job-name>/Jenkinsfile`

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'final', url: 'https://github.com/YasinSaleem/agentic-resume-evaluator.git'
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sh '''
                ansible-playbook ansible/install_dependencies.yml -i ansible/inventory
                ansible-playbook ansible/deploy_app.yml -i ansible/inventory
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed."
        }
    }
}
```

---

## 🚀 Deploy Flow

1. Developer pushes code → GitHub  
2. Jenkins auto-triggers (webhook or manual run)  
3. Jenkins pulls latest code  
4. Jenkins runs Ansible playbooks:
   - Installs dependencies
   - Copies files to EC2
   - Restarts the FastAPI app via PM2  
5. The updated app is live on your EC2 instance 🎉

---

## ✅ Verification

Run this on EC2 to confirm:
```bash
pm2 list
```

Check your app:
```
http://<EC2-IP>:8000
```

---

## 🧹 Optional Improvements

- Add Jenkins webhook in GitHub for auto-trigger:
  - Settings → Webhooks → Add `http://<jenkins-server>:8080/github-webhook/`
- Add a health-check stage in Jenkins:
  ```groovy
  stage('Health Check') {
      steps {
          sh 'curl -f http://<EC2-IP>:8000/health || exit 1'
      }
  }
  ```
- Add notifications via Slack or Email.
