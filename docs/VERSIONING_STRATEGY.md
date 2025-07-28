# Versioning Strategy

This document outlines our comprehensive versioning strategy for the DevOps CI/CD demo project, covering application versioning, Docker image tagging, and CI/CD integration.

## 🎯 Overview

Our versioning strategy follows **Semantic Versioning (SemVer)** principles with automated version management through Git tags and CI/CD pipeline integration.

## 📋 Version Structure

### Semantic Versioning (Major.Minor.Patch)
```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

**Examples**:
- `1.0.0` - Initial release
- `1.0.1` - Bug fix
- `1.1.0` - New feature
- `2.0.0` - Breaking change
- `1.0.0-alpha.1` - Pre-release
- `1.0.0+20240115.123456` - Build metadata

### Version Components
- **MAJOR**: Breaking changes, incompatible API changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, backward compatible
- **PRERELEASE**: Alpha, beta, rc versions
- **BUILD**: Build timestamp, commit hash

## 🏗️ Version Storage Strategy

### 1. Primary Source: Git Tags
```bash
# Version is primarily stored in Git tags
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

### 2. Version File: VERSION
```bash
# Create version file for easy access
echo "1.0.0" > VERSION
```

### 3. Environment Variables
```bash
# Pass version to application via environment variables
APP_VERSION=1.0.0
BUILD_DATE=2024-01-15T12:34:56Z
```

### 4. Application Integration
```python
# In src/hello_world.py
VERSION = os.getenv('APP_VERSION', '1.0.0')
BUILD_DATE = os.getenv('BUILD_DATE', datetime.now().isoformat())
```

## 🔄 Version Management Workflow

### 1. Development Workflow
```bash
# Feature development
git checkout -b feature/new-feature
# ... make changes ...
git commit -m "feat: add new feature"
git push origin feature/new-feature

# Create pull request
# ... review and merge ...
```

### 2. Release Workflow
```bash
# Determine next version
./scripts/version.sh bump patch  # 1.0.0 -> 1.0.1
./scripts/version.sh bump minor  # 1.0.1 -> 1.1.0
./scripts/version.sh bump major  # 1.1.0 -> 2.0.0

# Create release
./scripts/version.sh release
```

### 3. CI/CD Integration
```yaml
# GitHub Actions workflow
- name: Get Version
  run: |
    VERSION=$(./scripts/version.sh get)
    echo "VERSION=$VERSION" >> $GITHUB_ENV

- name: Build and Tag Docker Image
  run: |
    docker build -t devops-cicd-demo:$VERSION .
    docker tag devops-cicd-demo:$VERSION devops-cicd-demo:latest
```

## 🐳 Docker Image Tagging Strategy

### Tagging Convention
```bash
# Format: registry/repository:version
devops-cicd-demo:1.0.0          # Specific version
devops-cicd-demo:latest          # Latest stable
devops-cicd-demo:main            # Latest from main branch
devops-cicd-demo:develop         # Latest from develop branch
devops-cicd-demo:pr-123          # Pull request builds
```

### ECR Tagging
```bash
# AWS ECR tagging
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin $ECR_REGISTRY
docker tag devops-cicd-demo:$VERSION $ECR_REGISTRY/devops-cicd-demo:$VERSION
docker tag devops-cicd-demo:$VERSION $ECR_REGISTRY/devops-cicd-demo:latest
docker push $ECR_REGISTRY/devops-cicd-demo:$VERSION
docker push $ECR_REGISTRY/devops-cicd-demo:latest
```

## 📝 Version Script Implementation

### scripts/version.sh Features
- **Version Management**: Get, bump, validate versions
- **Git Integration**: Create tags, track commits
- **Build Metadata**: Generate timestamps and commit hashes
- **CI/CD Support**: Environment variable export
- **Validation**: Semantic versioning format validation

### Key Commands
```bash
# Get current version
./scripts/version.sh get

# Bump version
./scripts/version.sh bump patch  # 1.0.0 -> 1.0.1
./scripts/version.sh bump minor  # 1.0.1 -> 1.1.0
./scripts/version.sh bump major  # 1.1.0 -> 2.0.0

# Create release
./scripts/version.sh release

# Show version info
./scripts/version.sh info

# Validate version format
./scripts/version.sh validate
```

## 🔄 CI/CD Integration

### GitHub Actions Workflow Integration
```yaml
# .github/workflows/ci-cd.yml
jobs:
  version-management:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
      build-metadata: ${{ steps.version.outputs.build-metadata }}
    
    steps:
      - name: Get version information
        id: version
        run: |
          VERSION=$(./scripts/version.sh get)
          BUILD_METADATA=$(./scripts/version.sh generate-build-metadata)
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "build-metadata=$BUILD_METADATA" >> $GITHUB_OUTPUT

  build-and-push:
    needs: version-management
    steps:
      - name: Build Docker image
        env:
          VERSION: ${{ needs.version-management.outputs.version }}
        run: |
          docker build -f docker/Dockerfile \
            --build-arg APP_VERSION=$VERSION \
            --build-arg BUILD_DATE=$BUILD_DATE \
            --build-arg VCS_REF=$GIT_COMMIT \
            -t devops-cicd-demo:$VERSION .
```

## 📊 Version Tracking

### Application Endpoints
```python
# /info endpoint returns version information
@app.route('/info')
def app_info():
    return jsonify({
        'name': 'devops-cicd-demo',
        'version': VERSION,
        'build_date': BUILD_DATE,
        'git_commit': os.getenv('GIT_COMMIT', 'unknown'),
        'environment': os.getenv('ENVIRONMENT', 'development')
    })
```

### Docker Labels
```dockerfile
# Add version labels to Docker image
LABEL maintainer="devops@example.com" \
      version="$APP_VERSION" \
      build-date="$BUILD_DATE" \
      description="DevOps CI/CD Demo Application"
```

## 🔍 Version Monitoring

### CloudWatch Metrics
```python
# Send version metrics to CloudWatch
import boto3

def send_version_metric():
    cloudwatch = boto3.client('cloudwatch')
    cloudwatch.put_metric_data(
        Namespace='DevOpsCICDDemo',
        MetricData=[
            {
                'MetricName': 'ApplicationVersion',
                'Value': 1,
                'Unit': 'Count',
                'Dimensions': [
                    {
                        'Name': 'Version',
                        'Value': VERSION
                    }
                ]
            }
        ]
    )
```

### Health Check Integration
```python
@app.route('/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'version': VERSION,
        'build_date': BUILD_DATE,
        'timestamp': datetime.now().isoformat()
    })
```

## 🚀 Release Process

### 1. Development
```bash
# Feature development
git checkout -b feature/new-feature
# ... make changes ...
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

### 2. Release Preparation
```bash
# Merge to main
git checkout main
git merge feature/new-feature

# Determine version bump type
./scripts/version.sh bump minor  # For new features
./scripts/version.sh bump patch  # For bug fixes
./scripts/version.sh bump major  # For breaking changes
```

### 3. Release Creation
```bash
# Create release
./scripts/version.sh release

# This will:
# 1. Create git tag
# 2. Generate build metadata
# 3. Trigger CI/CD pipeline
# 4. Build and deploy Docker image
# 5. Update ECS service
```

### 4. Verification
```bash
# Check deployed version
curl https://your-app.com/info

# Verify Docker image
docker pull your-registry/devops-cicd-demo:latest
docker run --rm your-registry/devops-cicd-demo:latest python -c "import os; print(os.getenv('APP_VERSION'))"
```

## 📋 Best Practices

### 1. Version Management
- ✅ Use semantic versioning
- ✅ Automate version bumping
- ✅ Tag releases in Git
- ✅ Include build metadata

### 2. Docker Tagging
- ✅ Tag with specific versions
- ✅ Maintain latest tag
- ✅ Use branch-based tags for development
- ✅ Include build metadata in tags

### 3. CI/CD Integration
- ✅ Automate version detection
- ✅ Pass version to build process
- ✅ Tag Docker images consistently
- ✅ Deploy with version tracking

### 4. Monitoring
- ✅ Track version in application
- ✅ Monitor version deployments
- ✅ Alert on version mismatches
- ✅ Log version information

## 🔧 Troubleshooting

### Common Issues
1. **Version not updating**: Check VERSION file and git tags
2. **Docker tag mismatch**: Verify build args and environment variables
3. **ECS deployment issues**: Check service update and task definition
4. **Git tag conflicts**: Ensure proper tag naming and pushing

### Debug Commands
```bash
# Check current version
./scripts/version.sh get

# Show version information
./scripts/version.sh info

# Validate version format
./scripts/version.sh validate

# Check Docker image version
docker run --rm devops-cicd-demo:latest python -c "import os; print(os.getenv('APP_VERSION'))"
```

## 📊 Version Examples

### Development Workflow
```bash
# Current version: 1.0.0
./scripts/version.sh get
# Output: 1.0.0

# Add new feature
./scripts/version.sh bump minor
# Output: Bumping version to: 1.1.0

# Fix bug
./scripts/version.sh bump patch
# Output: Bumping version to: 1.1.1

# Breaking change
./scripts/version.sh bump major
# Output: Bumping version to: 2.0.0
```

### CI/CD Pipeline
```bash
# Version information in pipeline
📋 Version Information:
  Version: 1.1.0
  Build Metadata: 20240115.123456.abc123
  Git Commit: abc123
  Git Branch: main

# Docker image tags
🔨 Building Docker image...
  Version: 1.1.0
  Build Metadata: 20240115.123456.abc123
  Git Commit: abc123
  Build Date: 2024-01-15T12:34:56Z

# ECR tags
📤 Pushing to ECR...
✅ Docker image built and pushed successfully
  Image: 123456789012.dkr.ecr.us-west-2.amazonaws.com/devops-cicd-demo:1.1.0
  Latest: 123456789012.dkr.ecr.us-west-2.amazonaws.com/devops-cicd-demo:latest
  Branch: 123456789012.dkr.ecr.us-west-2.amazonaws.com/devops-cicd-demo:main
```

### Application Response
```json
{
  "name": "devops-cicd-demo",
  "version": "1.1.0",
  "build_date": "2024-01-15T12:34:56Z",
  "environment": "production",
  "host": "your-app.com",
  "user_agent": "curl/7.68.0"
}
```

---

**Note**: This versioning strategy ensures consistent, traceable, and automated version management across the entire CI/CD pipeline. 