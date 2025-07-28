# 🤖 Automatic Versioning

## 📋 Overview

The project has automatic versioning configured through GitHub Actions. There are several ways to manage versions:

## 🚀 Ways to Change Version

### 1. **Automatic (on every push to main)**

**Workflow:** `.github/workflows/auto-version.yml`

**How it works:**
- On every push to the `main` branch, the patch version is automatically incremented
- Exceptions: changes to the `VERSION` file and the workflow itself
- Creates a Git tag and GitHub Release
- Triggers the main CI/CD pipeline

**Example:**
```bash
# Current version: 1.0.2
git push origin main
# Result: version will automatically become 1.0.3
```

### 2. **Manual through GitHub Actions**

**Workflow:** `.github/workflows/manual-version.yml`

**How to use:**
1. Go to GitHub → Actions
2. Select "Manual Version Management"
3. Click "Run workflow"
4. Choose version type:
   - `patch` - 1.0.2 → 1.0.3
   - `minor` - 1.0.2 → 1.1.0
   - `major` - 1.0.2 → 2.0.0
5. Optionally specify a custom version

### 3. **Local Management**

**Script:** `scripts/version.sh`

```bash
# Show current version
./scripts/version.sh get

# Increment patch version
./scripts/version.sh bump patch

# Increment minor version
./scripts/version.sh bump minor

# Increment major version
./scripts/version.sh bump major

# Create release
./scripts/version.sh release
```

## 🔄 Automatic Versioning Process

### Step 1: Auto Version Workflow
```yaml
# .github/workflows/auto-version.yml
on:
  push:
    branches: [ main ]
    paths-ignore:
      - 'VERSION'  # Exclude changes to VERSION
```

### Step 2: Version Increment
```bash
# Get current version
CURRENT_VERSION=$(./scripts/version.sh get)

# Increment patch version
NEW_VERSION=$(./scripts/version.sh bump patch)

# Commit changes
git add VERSION
git commit -m "chore: auto bump version to $NEW_VERSION [skip ci]"
git push origin main
```

### Step 3: Create Tag and Release
```bash
# Create Git tag
git tag -a "v$VERSION" -m "Auto release version $VERSION"
git push origin "v$VERSION"

# Create GitHub Release
# (automatically through actions/create-release@v1)
```

### Step 4: Main CI/CD Pipeline
```yaml
# .github/workflows/ci-cd.yml
# Runs after version change
jobs:
  - version-management  # Reads new version
  - test               # Testing
  - build-and-push     # Build and upload to ECR
  - deploy             # Deploy to ECS
  - notify-deployment  # Completion notification
```

## 📊 Version Structure

### Semantic Versioning
```
MAJOR.MINOR.PATCH
   1  .  0  .  2
```

- **MAJOR** - incompatible API changes
- **MINOR** - new functionality (backward compatible)
- **PATCH** - bug fixes (backward compatible)

### Examples
```bash
1.0.2 → 1.0.3  # patch
1.0.2 → 1.1.0  # minor
1.0.2 → 2.0.0  # major
```

## 🔧 Configuration

### Environment Variables
```bash
# In application
APP_VERSION = os.getenv('APP_VERSION', '1.0.2')
BUILD_DATE = os.getenv('BUILD_DATE', datetime.datetime.now().isoformat())
VCS_REF = os.getenv('VCS_REF', 'latest')
```

### Docker build arguments
```dockerfile
ARG APP_VERSION=1.0.0
ARG BUILD_DATE
ARG VCS_REF

ENV APP_VERSION=$APP_VERSION \
    BUILD_DATE=$BUILD_DATE \
    VCS_REF=$VCS_REF
```

### GitHub Actions
```yaml
docker build -f docker/Dockerfile \
  --build-arg APP_VERSION=$VERSION \
  --build-arg BUILD_DATE=$BUILD_DATE \
  --build-arg VCS_REF=$GIT_COMMIT \
  -t devops-cicd-demo:$VERSION .
```

## 🎯 Recommendations

### For Development
1. **Regular changes:** Just push to main → automatic patch version increment
2. **New features:** Use manual workflow → minor version
3. **Critical changes:** Use manual workflow → major version

### For Releases
1. **Automatic:** Every push to main creates a new release
2. **Manual:** Use manual workflow for control
3. **Custom:** Specify exact version in manual workflow

## 🔍 Monitoring

### Check Version in Application
```bash
curl http://production-devops-cicd-demo-alb-685489736.eu-north-1.elb.amazonaws.com/ | jq .
```

### Check Tags
```bash
git tag -l
git log --oneline --decorate
```

### Check GitHub Releases
- GitHub → Releases
- Automatically created on each version change

## 🚨 Exceptions

### What Does NOT Trigger Auto-Version:
- Changes to the `VERSION` file
- Changes to `.github/workflows/auto-version.yml`
- Push to other branches (not main)

### What Triggers Auto-Version:
- Any code changes
- Documentation changes
- Configuration changes
- Push to main branch

## 📝 Logs

### Auto Version Workflow
```
🔄 Auto bumping patch version...
Current version: 1.0.2
New version: 1.0.3
✅ Version bumped to 1.0.3
🏷️ Creating git tag v1.0.3...
✅ Git tag v1.0.3 created
```

### Main CI/CD Pipeline
```
📋 Version Information:
  Version: 1.0.3
  Build Metadata: 20250728.142530.abc123
  Git Commit: abc123
  Git Branch: main
```

---

**Automatic versioning ready to use! 🚀** 