# 🔐 Secret Management Examples

This document provides practical examples of how to implement secret management in our DevOps CI/CD pipeline project.

## 🎯 Overview

This guide shows how to properly store and use credentials in different environments, from development to production.

## 🚀 GitHub Secrets Implementation

### **1. Repository Secrets Setup**

#### **Required Secrets for our project:**
```bash
# AWS Credentials
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_DEFAULT_REGION=eu-north-1

# ECR Registry
ECR_REGISTRY=123456789.dkr.ecr.eu-north-1.amazonaws.com

# Application Secrets
APP_SECRET_KEY=your_app_secret_key
DATABASE_URL=postgresql://user:pass@host:port/db

# External Services
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
EMAIL_SMTP_PASSWORD=your_email_password
```

#### **How to add secrets in GitHub:**
1. Go to your repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with its value

### **2. Updated CI/CD Pipeline**

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  AWS_REGION: eu-north-1
  ECR_REPOSITORY: devops-cicd-demo

jobs:
  version-management:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
      build-metadata: ${{ steps.version.outputs.build-metadata }}
      git-commit: ${{ steps.version.outputs.git-commit }}
      git-branch: ${{ steps.version.outputs.git-branch }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Setup version management
        run: |
          chmod +x scripts/version.sh
      
      - name: Get version information
        id: version
        run: |
          VERSION=$(./scripts/version.sh get)
          BUILD_METADATA=$(./scripts/version.sh generate-build-metadata)
          GIT_COMMIT=$(git rev-parse --short HEAD)
          GIT_BRANCH=$(git branch --show-current)
          
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "build-metadata=$BUILD_METADATA" >> $GITHUB_OUTPUT
          echo "git-commit=$GIT_COMMIT" >> $GITHUB_OUTPUT
          echo "git-branch=$GIT_BRANCH" >> $GITHUB_OUTPUT
          
          echo "📋 Version Information:"
          echo "  Version: $VERSION"
          echo "  Build Metadata: $BUILD_METADATA"
          echo "  Git Commit: $GIT_COMMIT"
          echo "  Git Branch: $GIT_BRANCH"
      
      - name: Validate version
        run: |
          ./scripts/version.sh validate
          echo "✅ Version format is valid"

  test:
    runs-on: ubuntu-latest
    needs: version-management
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r code-quality/requirements.txt
      
      - name: Run quality checks
        run: |
          bash code-quality/scripts/run-quality-checks.sh
      
      - name: Run tests
        env:
          # Use secrets for test database if needed
          TEST_DATABASE_URL: ${{ secrets.TEST_DATABASE_URL }}
        run: |
          python -m pytest tests/ -v --cov=src --cov-report=xml --cov-report=html
      
      - name: Upload coverage reports
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          flags: unittests
          name: codecov-umbrella
          fail_ci_if_error: false

  build-and-push:
    runs-on: ubuntu-latest
    needs: [version-management, test]
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_DEFAULT_REGION }}
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2
      
      - name: Build Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          VERSION: ${{ needs.version-management.outputs.version }}
          BUILD_DATE: $(date -u +'%Y-%m-%dT%H:%M:%SZ')
          GIT_COMMIT: ${{ needs.version-management.outputs.git-commit }}
          GIT_BRANCH: ${{ needs.version-management.outputs.git-branch }}
        run: |
          echo "🔨 Building Docker image..."
          echo "  Version: $VERSION"
          echo "  Build Date: $BUILD_DATE"
          echo "  Git Commit: $GIT_COMMIT"
          
          docker build \
            --build-arg APP_VERSION=$VERSION \
            --build-arg BUILD_DATE=$BUILD_DATE \
            --build-arg VCS_REF=$GIT_COMMIT \
            --label "org.opencontainers.image.version=$VERSION" \
            --label "org.opencontainers.image.created=$BUILD_DATE" \
            --label "org.opencontainers.image.revision=$GIT_COMMIT" \
            --label "org.opencontainers.image.source=https://github.com/${{ github.repository }}" \
            --label "org.opencontainers.image.title=DevOps CI/CD Demo" \
            --label "org.opencontainers.image.description=DevOps CI/CD pipeline demonstration" \
            -t devops-cicd-demo:$VERSION .
          
          echo "✅ Docker image built successfully"
          echo "  Image: devops-cicd-demo:$VERSION"
      
      - name: Simulate Docker Image Signing
        env:
          VERSION: ${{ needs.version-management.outputs.version }}
          GIT_COMMIT: ${{ needs.version-management.outputs.git-commit }}
        run: |
          echo "🔐 STEP: Simulate Docker Image Signing"
          echo "   🔑 Generating signing key..."
          echo "   📝 Creating signature..."
          echo "   🏷️ Image: devops-cicd-demo:$VERSION"
          echo "   🔍 Signature: sha256:$(echo "devops-cicd-demo:$VERSION" | sha256sum | cut -d' ' -f1)"
          echo "   📋 Certificate: CN=Demo Signing Authority, O=DevOps Demo, C=US"
          echo "   📅 Valid Until: $(date -d '+1 year' -u +'%Y-%m-%dT%H:%M:%SZ')"
          echo "   ✅ Image signed successfully"
          
          # Generate simulated signing metadata
          SIGNATURE=$(echo "devops-cicd-demo:$VERSION" | sha256sum | cut -d' ' -f1)
          CERTIFICATE="CN=Demo Signing Authority, O=DevOps Demo, C=US"
          VALID_UNTIL=$(date -d '+1 year' -u +'%Y-%m-%dT%H:%M:%SZ')
          
          echo "📋 Signing Metadata:"
          echo "  Image: devops-cicd-demo:$VERSION"
          echo "  Signature: $SIGNATURE"
          echo "  Certificate: $CERTIFICATE"
          echo "  Valid Until: $VALID_UNTIL"
          echo "  Git Commit: $GIT_COMMIT"
      
      - name: Tag and Push to ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          VERSION: ${{ needs.version-management.outputs.version }}
          GIT_COMMIT: ${{ needs.version-management.outputs.git-commit }}
          GIT_BRANCH: ${{ needs.version-management.outputs.git-branch }}
        run: |
          echo "📤 Pushing to ECR Repository..."
          echo "  Registry: $ECR_REGISTRY"
          echo "  Repository: $ECR_REPOSITORY"
          
          # Tag for ECR with multiple tags
          docker tag devops-cicd-demo:$VERSION $ECR_REGISTRY/$ECR_REPOSITORY:$VERSION
          docker tag devops-cicd-demo:$VERSION $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker tag devops-cicd-demo:$VERSION $ECR_REGISTRY/$ECR_REPOSITORY:$GIT_BRANCH
          docker tag devops-cicd-demo:$VERSION $ECR_REGISTRY/$ECR_REPOSITORY:$GIT_COMMIT
          
          echo "🏷️ Tagged images:"
          echo "  $ECR_REGISTRY/$ECR_REPOSITORY:$VERSION"
          echo "  $ECR_REGISTRY/$ECR_REPOSITORY:latest"
          echo "  $ECR_REGISTRY/$ECR_REPOSITORY:$GIT_BRANCH"
          echo "  $ECR_REGISTRY/$ECR_REPOSITORY:$GIT_COMMIT"
          
          # Push all tags
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$VERSION
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$GIT_BRANCH
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$GIT_COMMIT
          
          echo "✅ All images pushed successfully to ECR"
      
      - name: Verify ECR Push
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          VERSION: ${{ needs.version-management.outputs.version }}
        run: |
          echo "🔍 Verifying ECR push..."
          
          # List images in ECR repository
          aws ecr describe-images \
            --repository-name $ECR_REPOSITORY \
            --region $AWS_REGION \
            --query 'imageDetails[?contains(imageTags, `'$VERSION'`)].{Tag: imageTags, PushedAt: imagePushedAt, Size: imageSizeInBytes}' \
            --output table
          
          echo "✅ ECR push verification completed"

  deploy:
    runs-on: ubuntu-latest
    needs: [version-management, build-and-push]
    if: github.ref == 'refs/heads/main'
    environment: production  # Use environment secrets
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_DEFAULT_REGION }}
      
      - name: Deploy to ECS
        env:
          VERSION: ${{ needs.version-management.outputs.version }}
          # Use environment-specific secrets
          PROD_DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
          PROD_API_KEY: ${{ secrets.PROD_API_KEY }}
        run: |
          echo "🚀 Deploying to production..."
          echo "  Version: $VERSION"
          echo "  Environment: Production"
          
          # Update ECS service
          aws ecs update-service \
            --cluster production-cluster \
            --service devops-cicd-demo \
            --force-new-deployment
          
          echo "✅ Deployment initiated"
      
      - name: Verify deployment
        env:
          VERSION: ${{ needs.version-management.outputs.version }}
        run: |
          echo "🔍 Verifying deployment..."
          
          # Wait for service to stabilize
          aws ecs wait services-stable \
            --cluster production-cluster \
            --services devops-cicd-demo
          
          # Get service status
          aws ecs describe-services \
            --cluster production-cluster \
            --services devops-cicd-demo \
            --query 'services[0].{Status: status, RunningCount: runningCount, DesiredCount: desiredCount}' \
            --output table
          
          echo "✅ Deployment verification completed"

  notify-deployment:
    runs-on: ubuntu-latest
    needs: [version-management, deploy]
    if: always()
    
    steps:
      - name: Notify deployment status
        env:
          VERSION: ${{ needs.version-management.outputs.version }}
          BUILD_METADATA: ${{ needs.version-management.outputs.build-metadata }}
          GIT_COMMIT: ${{ needs.version-management.outputs.git-commit }}
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        run: |
          if [ "${{ job.status }}" == "success" ]; then
            echo "✅ Deployment successful"
            echo "  Version: $VERSION"
            echo "  Build Metadata: $BUILD_METADATA"
            echo "  Git Commit: $GIT_COMMIT"
            echo "  Application URL: https://your-app-domain.com"
            echo "  Health Check: https://your-app-domain.com/health"
            echo "  Info Endpoint: https://your-app-domain.com/info"
          else
            echo "❌ Deployment failed"
            echo "  Version: $VERSION"
            echo "  Build Metadata: $BUILD_METADATA"
            echo "  Git Commit: $GIT_COMMIT"
          fi
```

## 🏗️ AWS Secrets Manager Integration

### **1. Create Secrets in AWS**

```bash
# Create application secrets
aws secretsmanager create-secret \
    --name "prod/devops-cicd-demo/database" \
    --description "Production database credentials" \
    --secret-string '{
        "username": "prod_user",
        "password": "prod_password",
        "host": "prod-db.example.com",
        "port": "5432",
        "database": "devops_cicd_demo"
    }'

# Create API keys
aws secretsmanager create-secret \
    --name "prod/devops-cicd-demo/api-keys" \
    --description "Production API keys" \
    --secret-string '{
        "jwt_secret": "your-jwt-secret-key",
        "api_key": "your-api-key",
        "external_service_key": "your-external-service-key"
    }'
```

### **2. Application Integration**

```python
# src/config.py
import boto3
import json
import os
from typing import Dict, Any

class SecretManager:
    def __init__(self, region_name: str = 'eu-north-1'):
        self.client = boto3.client('secretsmanager', region_name=region_name)
    
    def get_secret(self, secret_name: str) -> Dict[str, Any]:
        """Get secret from AWS Secrets Manager"""
        try:
            response = self.client.get_secret_value(SecretId=secret_name)
            return json.loads(response['SecretString'])
        except Exception as e:
            print(f"Error getting secret {secret_name}: {e}")
            return {}
    
    def get_database_config(self) -> Dict[str, str]:
        """Get database configuration"""
        secret = self.get_secret('prod/devops-cicd-demo/database')
        return {
            'username': secret.get('username', ''),
            'password': secret.get('password', ''),
            'host': secret.get('host', ''),
            'port': secret.get('port', '5432'),
            'database': secret.get('database', '')
        }
    
    def get_api_keys(self) -> Dict[str, str]:
        """Get API keys"""
        return self.get_secret('prod/devops-cicd-demo/api-keys')

# Initialize secret manager
secret_manager = SecretManager()

# Get configurations
db_config = secret_manager.get_database_config()
api_keys = secret_manager.get_api_keys()

# Build database URL
DATABASE_URL = f"postgresql://{db_config['username']}:{db_config['password']}@{db_config['host']}:{db_config['port']}/{db_config['database']}"

# Get API keys
JWT_SECRET = api_keys.get('jwt_secret', '')
API_KEY = api_keys.get('api_key', '')
EXTERNAL_SERVICE_KEY = api_keys.get('external_service_key', '')
```

### **3. Updated Application**

```python
# src/hello_world.py
#!/usr/bin/env python3
"""
Hello World Flask Application
A simple microservice for DevOps CI/CD demonstration
"""

import os
import datetime
from flask import Flask, jsonify, make_response
from config import secret_manager, DATABASE_URL, JWT_SECRET, API_KEY

app = Flask(__name__)

# Get version and build info from environment variables
APP_VERSION = os.getenv('APP_VERSION', '1.0.2')
BUILD_DATE = os.getenv('BUILD_DATE', datetime.datetime.now().isoformat())
VCS_REF = os.getenv('VCS_REF', 'latest')

@app.route('/')
def hello_world():
    """Main endpoint returning hello message"""
    try:
        response = make_response({
            'message': 'Hello from CI/CD!',
            'version': APP_VERSION,
            'build_date': BUILD_DATE,
            'vcs_ref': VCS_REF,
            'status': 'running',
            'deployment': os.getenv('DEPLOYMENT_MESSAGE', 'Production deployment'),
            'current_version_message': f'Version: {APP_VERSION}',
            'commit_message': os.getenv('COMMIT_MESSAGE', 'No commit message')
        })
        
        # Add security headers
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
        
        return response
    except Exception as e:
        return {'error': str(e)}, 500

@app.route('/health')
def health_check():
    """Health check endpoint"""
    try:
        return {
            'status': 'healthy',
            'timestamp': datetime.datetime.now().isoformat(),
            'version': APP_VERSION,
            'service': 'devops-cicd-demo',
            'database_connected': bool(DATABASE_URL)
        }
    except Exception as e:
        return {'error': str(e)}, 500

@app.route('/info')
def info():
    """Application information endpoint"""
    try:
        return {
            'application': 'devops-cicd-demo',
            'version': APP_VERSION,
            'build_date': BUILD_DATE,
            'vcs_ref': VCS_REF,
            'environment': os.getenv('ENVIRONMENT', 'production'),
            'region': os.getenv('AWS_REGION', 'eu-north-1'),
            'features': [
                'Flask microservice',
                'Docker containerization',
                'AWS ECS deployment',
                'CI/CD pipeline',
                'Health monitoring',
                'Version management',
                'Secret management',
                'Security headers'
            ],
            'security': {
                'jwt_enabled': bool(JWT_SECRET),
                'api_key_enabled': bool(API_KEY),
                'database_configured': bool(DATABASE_URL)
            }
        }
    except Exception as e:
        return {'error': str(e)}, 500

@app.errorhandler(404)
def not_found(error):
    return {'error': 'Resource not found'}, 404

@app.errorhandler(500)
def internal_error(error):
    return {'error': 'Internal server error'}, 500

@app.errorhandler(Exception)
def handle_exception(e):
    return {'error': str(e)}, 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
```

## 🔧 Environment-Specific Configuration

### **1. Development Environment**

```bash
# .env (local development)
AWS_ACCESS_KEY_ID=your_dev_access_key
AWS_SECRET_ACCESS_KEY=your_dev_secret_key
AWS_DEFAULT_REGION=eu-north-1
DATABASE_URL=postgresql://dev_user:dev_pass@localhost:5432/dev_db
JWT_SECRET=dev-jwt-secret
API_KEY=dev-api-key
ENVIRONMENT=development
```

### **2. Staging Environment**

```bash
# GitHub Secrets for staging
STAGING_AWS_ACCESS_KEY_ID=your_staging_access_key
STAGING_AWS_SECRET_ACCESS_KEY=your_staging_secret_key
STAGING_DATABASE_URL=postgresql://staging_user:staging_pass@staging_host:5432/staging_db
STAGING_JWT_SECRET=staging-jwt-secret
STAGING_API_KEY=staging-api-key
```

### **3. Production Environment**

```bash
# GitHub Secrets for production
PROD_AWS_ACCESS_KEY_ID=your_prod_access_key
PROD_AWS_SECRET_ACCESS_KEY=your_prod_secret_key
PROD_DATABASE_URL=postgresql://prod_user:prod_pass@prod_host:5432/prod_db
PROD_JWT_SECRET=prod-jwt-secret
PROD_API_KEY=prod-api-key
```

## 🔒 Security Best Practices

### **1. IAM Roles and Policies**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": [
        "arn:aws:secretsmanager:eu-north-1:123456789:secret:prod/devops-cicd-demo/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:UpdateService",
        "ecs:DescribeServices"
      ],
      "Resource": [
        "arn:aws:ecs:eu-north-1:123456789:service/production-cluster/devops-cicd-demo"
      ]
    }
  ]
}
```

### **2. Secret Rotation**

```bash
#!/bin/bash
# rotate-secrets.sh

# Rotate AWS credentials
aws iam create-access-key --user-name github-actions-ci

# Update GitHub secrets via API
curl -X PATCH \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/owner/repo/actions/secrets/AWS_ACCESS_KEY_ID \
  -d '{"encrypted_value":"new_encrypted_value"}'

# Delete old credentials
aws iam delete-access-key --user-name github-actions-ci --access-key-id OLD_KEY_ID
```

### **3. Monitoring and Alerting**

```python
# src/monitoring.py
import boto3
import logging
from datetime import datetime

def check_secret_expiry():
    """Check if secrets are about to expire"""
    client = boto3.client('secretsmanager')
    
    try:
        response = client.describe_secret(SecretId='prod/devops-cicd-demo/database')
        last_modified = response['LastModifiedDate']
        
        # Alert if secret is older than 90 days
        days_old = (datetime.now() - last_modified.replace(tzinfo=None)).days
        if days_old > 90:
            logging.warning(f"Secret is {days_old} days old - consider rotation")
            
    except Exception as e:
        logging.error(f"Error checking secret expiry: {e}")
```

## 📊 Summary

### **Recommended Setup for our project:**

1. **GitHub Secrets** for CI/CD pipeline
2. **AWS Secrets Manager** for production secrets
3. **Environment variables** for local development
4. **IAM roles** with minimal permissions
5. **Regular secret rotation**
6. **Monitoring and alerting**

### **Security Checklist:**

- [ ] Use GitHub Secrets for CI/CD
- [ ] Use AWS Secrets Manager for production
- [ ] Implement IAM roles with least privilege
- [ ] Enable secret rotation
- [ ] Add monitoring and alerting
- [ ] Use environment-specific secrets
- [ ] Never commit real credentials to git
- [ ] Use secure communication (HTTPS)
- [ ] Implement proper error handling
- [ ] Add security headers

This setup provides a secure, scalable, and maintainable approach to secret management in our DevOps CI/CD pipeline. 