# 🐳 Docker Best Practices Guide

Our Dockerfile implements comprehensive best practices for secure and efficient containerization. This guide covers all aspects of Docker usage in our project.

## ✅ Implemented Best Practices

### Security First Approach
- **Multi-stage Build**: Reduces final image size and attack surface
- **Non-root User**: Security-first approach with dedicated user
- **Layer Optimization**: Efficient caching and smaller images
- **Health Checks**: Application monitoring and health verification
- **Security Scanning**: Vulnerability detection and prevention
- **Production Configuration**: Optimized Gunicorn settings
- **Version Support**: Build arguments for versioning and traceability

## 🔐 Secret Management for Docker

### 🔐 Secret Management Best Practices

#### 1. **GitHub Secrets (Recommended for CI/CD)**
Store sensitive credentials securely in GitHub repository secrets:
```bash
# Repository Settings → Secrets and variables → Actions
# Add the following secrets:
AWS_ACCESS_KEY_ID=your_access_key_here
AWS_SECRET_ACCESS_KEY=your_secret_key_here
AWS_DEFAULT_REGION=eu-north-1
ECR_REGISTRY=your_account.dkr.ecr.region.amazonaws.com
```

#### 2. **AWS Secrets Manager (Production)**
```bash
# Store secrets in AWS Secrets Manager
aws secretsmanager create-secret \
  --name "devops-cicd-demo/docker-credentials" \
  --description "Docker registry credentials" \
  --secret-string '{"username":"your_username","password":"your_password"}' \
  --region eu-north-1

# Retrieve secrets in CI/CD
aws secretsmanager get-secret-value \
  --secret-id "devops-cicd-demo/docker-credentials" \
  --region eu-north-1
```

#### 3. **Docker Secrets (Swarm Mode)**
```bash
# Create Docker secret
echo "your_secret_password" | docker secret create db_password -

# Use secret in service
docker service create \
  --secret db_password \
  --name myapp \
  your-image:latest
```

#### 4. **Environment-specific Configuration**
```bash
# Development
export DOCKER_REGISTRY=localhost:5000
export DOCKER_USERNAME=dev
export DOCKER_PASSWORD=dev_password

# Production
export DOCKER_REGISTRY=your_registry.com
export DOCKER_USERNAME=prod_user
export DOCKER_PASSWORD=prod_password
```

### 🔐 Security Features

### Non-root User Execution
```dockerfile
# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Switch to non-root user
USER appuser

# Proper file ownership
COPY --chown=appuser:appuser src/ ./src/
```

### Minimal Attack Surface
```dockerfile
# Install only necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Remove unnecessary files
RUN rm -rf /tmp/* /var/tmp/*
```

### Security Scanning
```dockerfile
# Multi-stage build for security scanning
FROM python:3.11-slim as security-scan
COPY requirements.txt .
RUN pip install safety bandit
RUN safety check -r requirements.txt
RUN bandit -r src/ -f json -o /tmp/bandit-report.json
```

## 📊 Performance Optimization

### Multi-stage Build
```dockerfile
# Build stage
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY src/ ./src/
```

### Layer Optimization
```dockerfile
# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code after dependencies
COPY src/ ./src/
COPY docker/ ./docker/
```

### Image Size Optimization
```dockerfile
# Use slim base image
FROM python:3.11-slim

# Remove unnecessary files
RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*
```

## 🧪 Health Monitoring

### Health Check Configuration
```dockerfile
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1
```

### Health Check Endpoint
```python
@app.route('/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.datetime.now().isoformat(),
        'version': VERSION
    }), 200
```

### Health Check Verification
```bash
# Check container health
docker ps

# Test health endpoint
curl http://localhost:5000/health

# Check health status
docker inspect --format='{{.State.Health.Status}}' container_name
```

## 🚀 Production Configuration

### Gunicorn Configuration
```dockerfile
CMD ["gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--timeout", "120", \
     "--max-requests", "1000", \
     "--max-requests-jitter", "100", \
     "--keep-alive", "2", \
     "--log-level", "info", \
     "src.hello_world:app"]
```

### Environment Variables
```dockerfile
# Build arguments
ARG APP_VERSION=1.0.0
ARG BUILD_DATE
ARG VCS_REF

# Environment variables
ENV APP_VERSION=$APP_VERSION \
    BUILD_DATE=$BUILD_DATE \
    VCS_REF=$VCS_REF \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
```

### Production Settings
```dockerfile
# Set production environment
ENV ENVIRONMENT=production

# Disable Python bytecode
ENV PYTHONDONTWRITEBYTECODE=1

# Unbuffered output
ENV PYTHONUNBUFFERED=1
```

## 🔧 Docker Commands

### Build Commands
```bash
# Build with version information
docker build -f docker/Dockerfile \
  --build-arg APP_VERSION=1.0.2 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  -t devops-cicd-demo:1.0.2 .

# Build for different environments
docker build -f docker/Dockerfile \
  --build-arg ENVIRONMENT=staging \
  -t devops-cicd-demo:staging .
```

### Run Commands
```bash
# Run container
docker run --rm -p 5000:5000 devops-cicd-demo:latest

# Run with environment variables
docker run --rm -p 5000:5000 \
  -e ENVIRONMENT=production \
  -e DEBUG=false \
  devops-cicd-demo:latest

# Run in detached mode
docker run -d --name app-container -p 5000:5000 devops-cicd-demo:latest
```

### Management Commands
```bash
# List containers
docker ps -a

# View logs
docker logs container_name

# Execute commands in container
docker exec -it container_name /bin/bash

# Stop and remove container
docker stop container_name && docker rm container_name
```

## 🔍 Security Scanning

### Vulnerability Scanning
```bash
# Scan for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image devops-cicd-demo:latest

# Scan with specific severity
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image --severity HIGH,CRITICAL devops-cicd-demo:latest
```

### Security Best Practices
```bash
# Check for secrets in image
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image --security-checks secret devops-cicd-demo:latest

# Scan configuration files
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy config .
```

## 📊 Image Optimization

### Image Size Analysis
```bash
# Analyze image layers
docker history devops-cicd-demo:latest

# Check image size
docker images devops-cicd-demo

# Optimize image
docker build --no-cache -f docker/Dockerfile -t devops-cicd-demo:optimized .
```

### Multi-stage Build Benefits
```dockerfile
# Development stage (includes dev dependencies)
FROM python:3.11-slim as development
COPY requirements-dev.txt .
RUN pip install -r requirements-dev.txt

# Production stage (minimal dependencies)
FROM python:3.11-slim as production
COPY --from=development /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY src/ ./src/
```

## 🚨 Troubleshooting

### Common Issues
1. **Permission Errors**: Ensure proper file ownership
2. **Port Conflicts**: Check if port 5000 is available
3. **Memory Issues**: Monitor container resource usage
4. **Health Check Failures**: Verify application endpoints

### Debug Commands
```bash
# Check container logs
docker logs container_name

# Inspect container
docker inspect container_name

# Check resource usage
docker stats container_name

# Execute debug shell
docker exec -it container_name /bin/bash
```

### Performance Monitoring
```bash
# Monitor container performance
docker stats

# Check disk usage
docker system df

# Clean up unused resources
docker system prune -a
```

## 🔄 CI/CD Integration

### GitHub Actions Integration
```yaml
- name: Build Docker image
  run: |
    docker build -f docker/Dockerfile \
      --build-arg APP_VERSION=$VERSION \
      --build-arg BUILD_DATE=$BUILD_DATE \
      --build-arg VCS_REF=$GIT_COMMIT \
      -t devops-cicd-demo:$VERSION .

- name: Push to ECR
  run: |
    aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY
    docker tag devops-cicd-demo:$VERSION $ECR_REGISTRY/devops-cicd-demo:$VERSION
    docker push $ECR_REGISTRY/devops-cicd-demo:$VERSION
```

### ECR Integration
```bash
# Login to ECR
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 485701710361.dkr.ecr.eu-north-1.amazonaws.com

# Tag for ECR
docker tag devops-cicd-demo:latest 485701710361.dkr.ecr.eu-north-1.amazonaws.com/devops-cicd-demo:latest

# Push to ECR
docker push 485701710361.dkr.ecr.eu-north-1.amazonaws.com/devops-cicd-demo:latest
```

## 📚 Related Documentation

- **[DOCKER_BEST_PRACTICES.md](DOCKER_BEST_PRACTICES.md)**: Detailed Docker best practices
- **[VERSIONING_GUIDE.md](VERSIONING_GUIDE.md)**: Version management with Docker
- **[SETUP.md](SETUP.md)**: Docker setup and configuration

---

**Note**: This Docker guide ensures secure, efficient, and production-ready containerization with comprehensive monitoring and optimization strategies. 