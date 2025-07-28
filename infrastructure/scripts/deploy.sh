#!/bin/bash

# DevOps CI/CD Demo - Infrastructure Deployment Script
# This script deploys the AWS infrastructure using Terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${ENVIRONMENT:-"production"}
AWS_REGION=${AWS_REGION:-"us-east-1"}
TERRAFORM_DIR="infrastructure/terraform"

echo -e "${GREEN}Starting infrastructure deployment...${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}AWS Region: ${AWS_REGION}${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform is not installed. Please install it first.${NC}"
    exit 1
fi

# Check AWS credentials
echo -e "${YELLOW}Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}AWS credentials not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

# Navigate to Terraform directory
cd $TERRAFORM_DIR

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
terraform init

# Plan the deployment
echo -e "${YELLOW}Planning deployment...${NC}"
terraform plan \
    -var="environment=${ENVIRONMENT}" \
    -var="aws_region=${AWS_REGION}" \
    -out=tfplan

# Ask for confirmation
echo -e "${YELLOW}Do you want to apply this plan? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}Applying Terraform plan...${NC}"
    terraform apply tfplan
    
    # Get outputs
    echo -e "${GREEN}Deployment completed successfully!${NC}"
    echo -e "${YELLOW}Infrastructure outputs:${NC}"
    terraform output
    
    # Clean up plan file
    rm -f tfplan
    
    echo -e "${GREEN}Infrastructure deployment completed!${NC}"
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Configure GitHub Secrets with AWS credentials"
    echo -e "2. Push code to GitHub to trigger CI/CD pipeline"
    echo -e "3. Monitor deployment in AWS Console"
else
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    rm -f tfplan
    exit 0
fi 