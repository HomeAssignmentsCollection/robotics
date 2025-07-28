#!/bin/bash

# DevOps CI/CD Demo - Infrastructure Destruction Script
# This script destroys the AWS infrastructure using Terraform

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

echo -e "${RED}WARNING: This will destroy all infrastructure!${NC}"
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

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo -e "${YELLOW}No Terraform state found. Nothing to destroy.${NC}"
    exit 0
fi

# Ask for confirmation
echo -e "${RED}Are you sure you want to destroy all infrastructure? (yes/NO)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS])$ ]]; then
    echo -e "${YELLOW}Destroying infrastructure...${NC}"
    terraform destroy \
        -var="environment=${ENVIRONMENT}" \
        -var="aws_region=${AWS_REGION}" \
        -auto-approve
    
    echo -e "${GREEN}Infrastructure destruction completed!${NC}"
else
    echo -e "${YELLOW}Destruction cancelled.${NC}"
    exit 0
fi 