# 🔄 Versioning Strategy Guide

Our project implements a comprehensive semantic versioning strategy with automated management through GitHub Actions and custom scripts.

## 📋 Version Structure

### Semantic Versioning Format
```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

**Examples**:
- `1.0.0` - Initial release
- `1.0.1` - Bug fix
- `1.1.0` - New feature
- `2.0.0` - Breaking change
- `1.0.0-alpha.1` - Pre-release
- `1.0.0+20231201.123456` - Build metadata

### Version Components
- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backward compatible)
- **PATCH**: Bug fixes (backward compatible)
- **PRERELEASE**: Alpha, beta, rc versions
- **BUILD**: Build metadata (timestamp, commit hash)

## 🏗️ Version Storage

### Primary Sources
- **Git Tags**: `v1.0.0` (primary source of truth)
- **VERSION File**: `VERSION` file for easy access
- **Environment Variables**: Passed to application and Docker
- **Application Integration**: Available via `/info` endpoint

### Version File Format
```
1.0.2
```

### Environment Variables
```bash
APP_VERSION=1.0.2
BUILD_DATE=2023-12-01T12:34:56Z
VCS_REF=abc123def456
```

## 🔄 Version Management Workflow

### Development Workflow
```bash
# Development
git checkout -b feature/new-feature
# ... make changes ...
git commit -m "feat: add new feature"

# Release preparation
git checkout main
git merge feature/new-feature

# Version bumping
./scripts/version.sh bump minor  # For new features
./scripts/version.sh bump patch  # For bug fixes
./scripts/version.sh bump major  # For breaking changes

# Create release
./scripts/version.sh release
```

### Automated Versioning
The project includes automatic versioning through GitHub Actions:

1. **Auto Version Workflow**: `.github/workflows/auto-version.yml`
   - Triggers on push to main
   - Automatically increments patch version
   - Creates Git tags and GitHub releases

2. **Manual Version Workflow**: `.github/workflows/manual-version.yml`
   - Manual version management
   - Support for patch, minor, major increments
   - Custom version specification

## 🐳 Docker Image Tagging

### Version-based Tags
```bash
# Local development
devops-cicd-demo:1.0.0          # Specific version
devops-cicd-demo:latest          # Latest stable
devops-cicd-demo:main            # Latest from main branch

# ECR tagging
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY
docker tag devops-cicd-demo:$VERSION $ECR_REGISTRY/devops-cicd-demo:$VERSION
docker push $ECR_REGISTRY/devops-cicd-demo:$VERSION
```

### Tagging Strategy
- **Version Tags**: `1.0.0`, `1.0.1`, `1.1.0`
- **Latest Tag**: Always points to the most recent stable version
- **Branch Tags**: `main`, `develop` for development versions
- **Pre-release Tags**: `1.0.0-alpha.1`, `1.0.0-beta.1`

## 📊 Version Script Commands

### Basic Commands
```bash
# Get current version
./scripts/version.sh get

# Show version information
./scripts/version.sh info

# Validate version format
./scripts/version.sh validate
```

### Version Bumping
```bash
# Increment patch version (1.0.0 -> 1.0.1)
./scripts/version.sh bump patch

# Increment minor version (1.0.1 -> 1.1.0)
./scripts/version.sh bump minor

# Increment major version (1.1.0 -> 2.0.0)
./scripts/version.sh bump major
```

### Release Management
```bash
# Create release
./scripts/version.sh release

# Initialize version (if needed)
./scripts/version.sh init
```

## 🔄 CI/CD Integration

### GitHub Actions Workflow
```yaml
# Get version information
- name: Get version information
  run: |
    VERSION=$(./scripts/version.sh get)
    echo "VERSION=$VERSION" >> $GITHUB_ENV

# Build Docker image with version
- name: Build Docker image
  run: |
    docker build -f docker/Dockerfile \
      --build-arg APP_VERSION=$VERSION \
      --build-arg BUILD_DATE=$BUILD_DATE \
      --build-arg VCS_REF=$GIT_COMMIT \
      -t devops-cicd-demo:$VERSION .
```

### Build Arguments
```dockerfile
ARG APP_VERSION=1.0.0
ARG BUILD_DATE
ARG VCS_REF

ENV APP_VERSION=$APP_VERSION \
    BUILD_DATE=$BUILD_DATE \
    VCS_REF=$VCS_REF
```

## 📈 Version Tracking

### Application Endpoints
```python
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

### Version Information
```bash
# Check version in application
curl http://localhost:5000/info | jq .

# Check Git tags
git tag -l
git log --oneline --decorate

# Check GitHub releases
# GitHub → Releases
```

## 🚨 Version Management Best Practices

### Development Guidelines
1. **Feature Development**: Use feature branches
2. **Commit Messages**: Use conventional commit format
3. **Version Bumping**: Choose appropriate increment type
4. **Release Process**: Always create releases for production

### Release Guidelines
1. **Patch Releases**: Bug fixes and minor improvements
2. **Minor Releases**: New features (backward compatible)
3. **Major Releases**: Breaking changes
4. **Pre-releases**: Alpha, beta, rc for testing

### Automation Guidelines
1. **Auto Versioning**: Use for regular development
2. **Manual Versioning**: Use for controlled releases
3. **Custom Versions**: Use for specific requirements
4. **Release Notes**: Always include meaningful descriptions

## 🔍 Monitoring and Verification

### Version Verification
```bash
# Check current version
./scripts/version.sh get

# Verify version format
./scripts/version.sh validate

# Check application version
curl http://localhost:5000/info

# Check Docker image version
docker run --rm devops-cicd-demo:latest python -c "import os; print(os.getenv('APP_VERSION'))"
```

### Version History
```bash
# View version history
git log --oneline --decorate

# View tags
git tag -l

# View release notes
# GitHub → Releases
```

## 🚨 Troubleshooting

### Common Version Issues
1. **Version Conflicts**: Check VERSION file and git tags
2. **Invalid Format**: Use semantic versioning format
3. **Missing Tags**: Ensure tags are pushed to remote
4. **Build Failures**: Check version script permissions

### Debug Commands
```bash
# Check version script
./scripts/version.sh info

# Validate version format
./scripts/version.sh validate

# Check Git status
git status
git tag -l

# Check application version
curl http://localhost:5000/info
```

## 📚 Related Documentation

- **[AUTO_VERSIONING.md](AUTO_VERSIONING.md)**: Automatic versioning documentation
- **[VERSIONING_STRATEGY.md](VERSIONING_STRATEGY.md)**: Detailed versioning strategy
- **[SETUP.md](SETUP.md)**: Setup and configuration guide

---

**Note**: This versioning strategy ensures consistent, automated version management across the entire CI/CD pipeline while maintaining traceability and reproducibility. 