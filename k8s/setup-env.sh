#!/bin/bash

# Setup Environment Variables for Kubernetes
# This script converts your .env files to Kubernetes secrets
set -e

echo "🔧 Setting up environment variables for Kubernetes deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NAMESPACE="resume-evaluator"

# Check if .env files exist
BACKEND_ENV_FILE="./backend/.env"
FRONTEND_ENV_FILE="./frontend/.env"
BACKEND_EXAMPLE="./backend/.env.example"
FRONTEND_EXAMPLE="./frontend/.env.example"

echo -e "${BLUE}📋 Checking environment files...${NC}"

# Function to create .env from example if it doesn't exist
create_env_from_example() {
    local env_file=$1
    local example_file=$2
    local service_name=$3
    
    if [ ! -f "$env_file" ]; then
        if [ -f "$example_file" ]; then
            echo -e "${YELLOW}⚠️  $env_file not found. Creating from $example_file${NC}"
            cp "$example_file" "$env_file"
            echo -e "${RED}🚨 Please edit $env_file with your actual values before deploying!${NC}"
        else
            echo -e "${RED}❌ Neither $env_file nor $example_file found for $service_name${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Found $env_file${NC}"
    fi
}

# Check/create backend .env
create_env_from_example "$BACKEND_ENV_FILE" "$BACKEND_EXAMPLE" "backend"

# Check/create frontend .env
create_env_from_example "$FRONTEND_ENV_FILE" "$FRONTEND_EXAMPLE" "frontend"

echo -e "${BLUE}🔐 Creating Kubernetes secrets from .env files...${NC}"

# Create namespace if it doesn't exist
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Create backend secret from .env file
echo -e "${YELLOW}📦 Creating backend environment secret...${NC}"
kubectl create secret generic backend-env-secret \
    --from-env-file="$BACKEND_ENV_FILE" \
    --namespace="$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -

# Create frontend secret from .env file
echo -e "${YELLOW}📦 Creating frontend environment secret...${NC}"
kubectl create secret generic frontend-env-secret \
    --from-env-file="$FRONTEND_ENV_FILE" \
    --namespace="$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -

echo -e "${GREEN}✅ Environment secrets created successfully!${NC}"

# Show what was created
echo -e "${BLUE}📊 Created secrets:${NC}"
kubectl get secrets -n "$NAMESPACE" | grep env-secret

# Validate backend environment variables
echo -e "${BLUE}🔍 Backend environment variables:${NC}"
kubectl get secret backend-env-secret -n "$NAMESPACE" -o jsonpath='{.data}' | jq -r 'keys[]' | while read key; do
    echo "  - $key"
done

# Validate frontend environment variables
echo -e "${BLUE}🔍 Frontend environment variables:${NC}"
kubectl get secret frontend-env-secret -n "$NAMESPACE" -o jsonpath='{.data}' | jq -r 'keys[]' | while read key; do
    echo "  - $key"
done

echo ""
echo -e "${GREEN}🎉 Environment setup complete!${NC}"
echo -e "${YELLOW}💡 To update environment variables later:${NC}"
echo "   1. Edit your .env files"
echo "   2. Run this script again"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "   1. Verify your .env files have correct values"
echo "   2. Run: ./k8s/deploy.sh"

# Warning about sensitive data
echo ""
echo -e "${RED}🚨 SECURITY NOTE:${NC}"
echo -e "${RED}   Your .env files contain sensitive data (API keys, etc.)${NC}"
echo -e "${RED}   Make sure they are in .gitignore and not committed to git!${NC}"