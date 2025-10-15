# 🚀 Kubernetes Deployment for Resume Evaluator

This directory contains Kubernetes manifests and deployment scripts for the Resume Evaluator application.

## 📂 File Structure

```
k8s/
├── namespace.yaml              # Kubernetes namespace
├── configmap-secrets.yaml     # Configuration and secrets
├── backend.yaml               # Backend deployment & service
├── frontend.yaml              # Frontend deployment & service
├── ingress.yaml               # Ingress for external access
├── hpa.yaml                   # Horizontal Pod Autoscaler
├── deploy.sh                  # Deployment script
├── cleanup.sh                 # Cleanup script
└── README.md                  # This file
```

## 🎯 Key Features

- **🔄 Zero-Downtime Deployments**: Rolling updates with health checks
- **📈 Auto-Scaling**: HPA based on CPU/Memory usage
- **🌐 Load Balancing**: Multiple replicas with service load balancing
- **🔒 Security**: Non-root containers, resource limits, secrets management
- **📊 Monitoring**: Built-in health checks and readiness probes
- **🎛️ Configuration**: Centralized config via ConfigMaps and Secrets

## 🚀 Quick Start

### Prerequisites

1. **Kubernetes cluster** (minikube, kind, or cloud provider)
2. **kubectl** configured to access your cluster
3. **Docker** for building images
4. **Ingress controller** (nginx-ingress recommended)

### Deploy to Kubernetes

```bash
# Option 1: One-click deployment
./k8s/deploy.sh

# Option 2: Manual deployment
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap-secrets.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml
```

### Access the Application

```bash
# Get ingress IP
kubectl get ingress -n resume-evaluator

# Add to /etc/hosts (replace <INGRESS_IP> with actual IP)
echo "<INGRESS_IP> resume-evaluator.local" >> /etc/hosts

# Access the application
open http://resume-evaluator.local
```

### Monitor the Deployment

```bash
# Check pod status
kubectl get pods -n resume-evaluator

# Check services
kubectl get services -n resume-evaluator

# Check logs
kubectl logs -f deployment/backend-deployment -n resume-evaluator
kubectl logs -f deployment/frontend-deployment -n resume-evaluator

# Check HPA status
kubectl get hpa -n resume-evaluator
```

## 🔧 Configuration

### Environment Variables

The Kubernetes setup exactly mirrors your Docker Compose environment configuration:

**Docker Compose approach:**
```yaml
services:
  backend:
    environment:
      - HOST=0.0.0.0
      - PORT=8000
      - ENVIRONMENT=production
    env_file:
      - ./backend/.env
```

**Kubernetes equivalent:**
- **Explicit environment variables** → ConfigMap (`resume-evaluator-config`)
- **env_file contents** → Secrets (`backend-env-secret`, `frontend-env-secret`)

**Setup your environment:**
```bash
# 1. Ensure your .env files exist with actual values
cp backend/.env.example backend/.env
cp frontend/.env.example frontend/.env

# 2. Edit with your actual values
vim backend/.env    # Add GEMINI_API_KEY, etc.
vim frontend/.env   # Add any frontend-specific vars

# 3. Setup script will create Kubernetes secrets from .env files
./k8s/setup-env.sh
```

### Resource Limits

Adjust resource requests/limits in deployment files:

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Scaling Configuration

Modify HPA settings in `hpa.yaml`:

```yaml
spec:
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Environment Variable Mapping

| Docker Compose | Kubernetes | Description |
|---------------|------------|-------------|
| `environment:` | `ConfigMap` | Explicit env vars (HOST, PORT, etc.) |
| `env_file: ./backend/.env` | `Secret: backend-env-secret` | Backend .env file contents |
| `env_file: ./frontend/.env` | `Secret: frontend-env-secret` | Frontend .env file contents |

## 🔄 Docker Compose vs Kubernetes

| Feature | Docker Compose | Kubernetes |
|---------|----------------|------------|
| **Local Development** | ✅ Perfect | ⚠️ Overkill |
| **Production Scale** | ⚠️ Limited | ✅ Excellent |
| **Auto-Scaling** | ❌ No | ✅ Yes |
| **Load Balancing** | ⚠️ Basic | ✅ Advanced |
| **Health Checks** | ✅ Basic | ✅ Advanced |
| **Rolling Updates** | ❌ No | ✅ Yes |
| **Resource Management** | ⚠️ Limited | ✅ Advanced |
| **Multi-Host** | ❌ No | ✅ Yes |

## 🛠️ Useful Commands

```bash
# Scale deployments manually
kubectl scale deployment backend-deployment --replicas=5 -n resume-evaluator

# Update image (rolling update)
kubectl set image deployment/backend-deployment backend=resume-evaluator-backend:v2 -n resume-evaluator

# Port forward for testing
kubectl port-forward service/backend-service 8000:8000 -n resume-evaluator
kubectl port-forward service/frontend-service 3000:3000 -n resume-evaluator

# Get detailed pod information
kubectl describe pod <pod-name> -n resume-evaluator

# Execute into pod for debugging
kubectl exec -it <pod-name> -n resume-evaluator -- /bin/bash
```

## 🧹 Cleanup

```bash
# Remove everything
./k8s/cleanup.sh

# Or manually
kubectl delete namespace resume-evaluator
```

## 🚀 CI/CD Integration

To integrate with your existing Jenkins/Ansible pipeline:

1. **Jenkins Stage**: Build and push Docker images to registry
2. **Ansible Playbook**: Deploy to Kubernetes cluster
3. **Health Checks**: Verify deployment success

Example Jenkins pipeline stage:

```groovy
stage('Deploy to Kubernetes') {
    steps {
        sh '''
            ./k8s/deploy.sh
            kubectl wait --for=condition=available deployment/backend-deployment -n resume-evaluator
        '''
    }
}
```

## 📊 Monitoring & Observability

Consider adding:

- **Prometheus** for metrics collection
- **Grafana** for visualization
- **Jaeger** for distributed tracing
- **ELK Stack** for centralized logging

## 🔐 Security Best Practices

- ✅ Non-root containers
- ✅ Resource limits
- ✅ Network policies (add if needed)
- ✅ Secret management
- ✅ Image scanning (add to CI/CD)
- ✅ Pod security contexts

## 🎯 Next Steps

1. **Set up monitoring** with Prometheus/Grafana
2. **Add network policies** for better security
3. **Implement GitOps** with ArgoCD
4. **Add backup strategies** for persistent data
5. **Set up disaster recovery** procedures