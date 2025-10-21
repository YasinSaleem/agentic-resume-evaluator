#!/bin/bash

echo "🚀 Deploying Resume Evaluator to Kubernetes..."

# Apply all manifests
kubectl apply -f namespace.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml

echo ""
echo "📊 Checking deployment status..."
kubectl get pods -n resume-evaluator
kubectl get services -n resume-evaluator

echo ""
echo "✅ Deployment complete!"
echo "Access frontend: kubectl port-forward -n resume-evaluator service/frontend-service 3000:3000"