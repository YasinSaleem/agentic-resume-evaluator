pipeline {
    agent any

    environment {
        APP_BRANCH = "deployment"
        ANSIBLE_PLAYBOOK = "ansible/playbooks/deploy-resume-evaluator.yml"
        INVENTORY_FILE = "ansible/inventory/hosts.ini"
        SSH_CREDENTIAL_ID = "jenkins-ec2-ssh"
        TERRAFORM_CHANGED = 'false'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: "${APP_BRANCH}", url: 'https://github.com/YasinSaleem/agentic-resume-evaluator.git'
            }
        }

        stage('Check Terraform Changes') {
            steps {
                script {
                    echo "🔍 Checking if Terraform files changed..."
                    
                    def exitCode = sh(
                        script: '''
                            if [ "$GIT_PREVIOUS_COMMIT" = "" ]; then
                                echo "First build - checking for terraform directory"
                                if [ -d "terraform" ]; then
                                    exit 0
                                else
                                    exit 1
                                fi
                            else
                                git diff --name-only $GIT_PREVIOUS_COMMIT $GIT_COMMIT | grep "^terraform/" || exit 1
                            fi
                        ''',
                        returnStatus: true
                    )
                    
                    if (exitCode == 0) {
                        env.TERRAFORM_CHANGED = 'true'
                        currentBuild.displayName = "#${BUILD_NUMBER} - Infrastructure Update"
                        echo "✅ Terraform files changed - will run infrastructure update"
                    } else {
                        env.TERRAFORM_CHANGED = 'false'
                        currentBuild.displayName = "#${BUILD_NUMBER} - App Deploy Only"
                        echo "⏭️  No Terraform changes detected - skipping infrastructure stage"
                    }
                }
            }
        }

        stage('Terraform Init') {
            when {
                expression { return env.TERRAFORM_CHANGED == 'true' }
            }
            steps {
                dir('terraform') {
                    sh '''
                        echo "🔧 Initializing Terraform..."
                        terraform init
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            when {
                expression { return env.TERRAFORM_CHANGED == 'true' }
            }
            steps {
                dir('terraform') {
                    sh '''
                        echo "📋 Planning Terraform changes..."
                        terraform plan -out=tfplan
                        terraform show -no-color tfplan > tfplan.txt
                    '''
                    
                    archiveArtifacts artifacts: 'tfplan.txt', fingerprint: true
                    sh 'cat tfplan.txt'
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return env.TERRAFORM_CHANGED == 'true' }
            }
            steps {
                dir('terraform') {
                    sh '''
                        echo "🚀 Applying Terraform changes..."
                        terraform apply -auto-approve tfplan
                        
                        echo ""
                        echo "📊 Infrastructure Outputs:"
                        terraform output -json > outputs.json
                        terraform output
                    '''
                }
            }
        }

        stage('Update Ansible Inventory') {
            when {
                expression { return env.TERRAFORM_CHANGED == 'true' }
            }
            steps {
                sh '''
                    echo "📝 Updating Ansible inventory from Terraform outputs..."
                    bash scripts/update_inventory.sh
                    
                    echo ""
                    echo "✅ Updated Inventory:"
                    cat ansible/inventory/hosts.ini
                '''
            }
        }

        stage('Wait for Instances') {
            when {
                expression { return env.TERRAFORM_CHANGED == 'true' }
            }
            steps {
                script {
                    echo "⏳ Waiting for instances to be fully ready..."
                    sleep(time: 30, unit: 'SECONDS')
                }
            }
        }

        stage('Deploy Application with Ansible') {
            steps {
                sshagent([SSH_CREDENTIAL_ID]) {
                    sh """
                        echo "🚀 Deploying application..."
                        ansible-playbook ${ANSIBLE_PLAYBOOK} \
                        -i ${INVENTORY_FILE} \
                        --extra-vars "branch=${APP_BRANCH}" \
                        --become
                    """
                }
            }
        }
    }

    post {
        success {
            script {
                if (env.TERRAFORM_CHANGED == 'true') {
                    echo "✅ Infrastructure updated and application deployed successfully!"
                } else {
                    echo "✅ Application deployed successfully!"
                }
            }
        }
        failure {
            echo "❌ Pipeline failed! Check the console output for details."
        }
        always {
            dir('terraform') {
                sh 'rm -f tfplan tfplan.txt || true'
            }
        }
    }
}