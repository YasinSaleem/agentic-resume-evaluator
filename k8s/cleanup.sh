#!/bin/bash

# Kubernetes Cleanup Script
set -e

echo "🧹 Cleaning up Resume Evaluator from Kubernetes..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

NAMESPACE="resume-evaluator"

echo -e "${YELLOW}🗑️  Removing Kubernetes resources...${NC}"

# Delete in reverse order
kubectl delete -f k8s/hpa.yaml --ignore-not-found=true
kubectl delete -f k8s/ingress.yaml --ignore-not-found=true
kubectl delete -f k8s/frontend.yaml --ignore-not-found=true
kubectl delete -f k8s/backend.yaml --ignore-not-found=true
kubectl delete -f k8s/configmap-secrets.yaml --ignore-not-found=true

# Delete environment secrets
kubectl delete secret backend-env-secret --namespace=${NAMESPACE} --ignore-not-found=true
kubectl delete secret frontend-env-secret --namespace=${NAMESPACE} --ignore-not-found=true

# Wait a bit for pods to terminate
echo -e "${YELLOW}⏳ Waiting for pods to terminate...${NC}"
sleep 10

# Delete namespace (this will delete any remaining resources)
kubectl delete namespace ${NAMESPACE} --ignore-not-found=true

echo -e "${GREEN}✅ Cleanup complete!${NC}"

# Optional: Clean up Docker images
read -p "Do you want to remove local Docker images? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}🐳 Removing Docker images...${NC}"
    docker rmi resume-evaluator-backend:latest resume-evaluator-frontend:latest --force || true
    echo -e "${GREEN}✅ Docker images removed!${NC}"
fi

echo -e "${GREEN}🎉 Full cleanup complete!${NC}"