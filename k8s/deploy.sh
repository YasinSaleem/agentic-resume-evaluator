#!/bin/bash

# Build and Deploy to Kubernetes Script
set -e

echo "🚀 Building and Deploying Resume Evaluator to Kubernetes..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"local"}
TAG=${TAG:-"latest"}
NAMESPACE="resume-evaluator"

echo -e "${YELLOW}📦 Building Docker Images...${NC}"

# Build backend image
echo "Building backend image..."
docker build -t ${DOCKER_REGISTRY}/resume-evaluator-backend:${TAG} ./backend/

# Build frontend image
echo "Building frontend image..."
docker build -t ${DOCKER_REGISTRY}/resume-evaluator-frontend:${TAG} ./frontend/

# If using a remote registry, push images
if [ "$DOCKER_REGISTRY" != "local" ]; then
    echo -e "${YELLOW}📤 Pushing images to registry...${NC}"
    docker push ${DOCKER_REGISTRY}/resume-evaluator-backend:${TAG}
    docker push ${DOCKER_REGISTRY}/resume-evaluator-frontend:${TAG}
fi

echo -e "${YELLOW}🔧 Setting up environment variables...${NC}"

# Setup environment variables from .env files
./k8s/setup-env.sh

echo -e "${YELLOW}☸️  Deploying to Kubernetes...${NC}"

# Apply Kubernetes manifests in order
kubectl apply -f k8s/namespace.yaml

# Wait for namespace to be ready
kubectl wait --for=condition=Ready namespace/${NAMESPACE} --timeout=30s

# Apply configuration (ConfigMap only, secrets are created by setup-env.sh)
kubectl apply -f k8s/configmap-secrets.yaml

# Apply deployments and services
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# Apply ingress
kubectl apply -f k8s/ingress.yaml

# Apply HPA (optional)
kubectl apply -f k8s/hpa.yaml

echo -e "${YELLOW}⏳ Waiting for deployments to be ready...${NC}"

# Wait for backend deployment
kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n ${NAMESPACE}

# Wait for frontend deployment
kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n ${NAMESPACE}

echo -e "${GREEN}✅ Deployment successful!${NC}"

# Show status
echo -e "${YELLOW}📊 Current status:${NC}"
kubectl get pods -n ${NAMESPACE}
kubectl get services -n ${NAMESPACE}
kubectl get ingress -n ${NAMESPACE}

# Get access information
echo -e "${GREEN}🌐 Access Information:${NC}"
echo "Internal Services:"
echo "  Backend: http://backend-service.${NAMESPACE}.svc.cluster.local:8000"
echo "  Frontend: http://frontend-service.${NAMESPACE}.svc.cluster.local:3000"
echo ""
echo "External Access (via Ingress):"
echo "  Add to /etc/hosts: <INGRESS_IP> resume-evaluator.local"
echo "  URL: http://resume-evaluator.local"
echo ""
echo "To get ingress IP:"
echo "  kubectl get ingress -n ${NAMESPACE}"

echo -e "${GREEN}🎉 Kubernetes deployment complete!${NC}"