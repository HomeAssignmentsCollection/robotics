# DevOps CI/CD Demo Project

A comprehensive DevOps CI/CD pipeline demonstration project with AWS cloud services, Docker containerization, and automated deployment.

## 🎯 Project Overview

This project demonstrates a complete DevOps CI/CD pipeline for a Python microservice, including:

- **GitHub Repository**: Public repository with comprehensive documentation
- **Python Microservice**: Simple Flask application with health checks
- **Docker Containerization**: Multi-stage Docker build with security best practices
- **AWS Cloud Services**: ECR, ECS, ALB, VPC, CloudWatch, IAM
- **CI/CD Pipeline**: GitHub Actions with automated testing, building, and deployment
- **Infrastructure as Code**: Terraform modules for AWS resource provisioning
- **Code Quality Module**: Comprehensive quality checks and pre-commit hooks
- **Demo Concepts**: Simulated pipelines for educational purposes
- **Docker Best Practices**: Secure and optimized containerization
- **Versioning Strategy**: Semantic versioning with automated management
- **Monitoring & Observability**: CloudWatch dashboards and alarms
- **Security**: IAM roles, security groups, and vulnerability scanning

## 📁 Project Structure

```
robotics/
├── README.md                           # Main project documentation
├── LICENSE                             # MIT License
├── .gitignore                         # Git ignore patterns
├── .dockerignore                      # Docker build optimization
├── VERSION                            # Current version file
├── requirements.txt                    # Python dependencies
├── src/
│   └── hello_world.py                 # Flask microservice
├── tests/
│   └── test_hello_world.py            # Unit and integration tests
├── scripts/
│   └── version.sh                     # Version management script
├── docker/
│   └── Dockerfile                     # Multi-stage Docker build
├── infrastructure/
│   ├── terraform/                     # Infrastructure as Code
│   │   ├── main.tf                   # Main Terraform configuration
│   │   ├── variables.tf              # Input variables
│   │   ├── outputs.tf                # Output values
│   │   └── modules/                  # Terraform modules
│   │       ├── vpc/                  # VPC and networking
│   │       ├── ecr/                  # Container registry
│   │       ├── ecs/                  # Container orchestration
│   │       ├── alb/                  # Load balancer
│   │       ├── cloudwatch/           # Monitoring and logging
│   │       └── iam/                  # Identity and access management
│   └── scripts/
│       ├── deploy.sh                 # Infrastructure deployment script
│       └── destroy.sh                # Infrastructure cleanup script
├── .github/
│   └── workflows/
│       ├── ci-cd.yml                 # Main CI/CD pipeline
│       ├── quality-checks.yml        # Code quality checks
│       ├── demo-concept.yml          # Demo concept pipeline
│       └── demo-advanced.yml         # Advanced demo concepts
├── code-quality/                      # Code Quality Module
│   ├── README.md                     # Quality module documentation
│   ├── requirements.txt              # Quality tools dependencies
│   ├── configs/                     # Tool configurations
│   │   ├── flake8.ini              # Flake8 linting config
│   │   ├── pylintrc                # Pylint analysis config
│   │   ├── pytest.ini             # Pytest testing config
│   │   ├── .bandit                 # Bandit security config
│   │   └── pyproject.toml          # Project configuration
│   └── scripts/                     # Quality check scripts
│       ├── run-quality-checks.sh   # Main quality check script
│       ├── ci-quality-gates.sh     # CI quality gates
│       └── calculate-quality-index.py # Quality metrics calculator
└── docs/                            # Detailed documentation
    ├── SETUP.md                     # Setup guide
    ├── ARCHITECTURE.md              # Architecture documentation
    ├── OPTIMIZATION.md              # Optimization strategies
    ├── DEMO_CONCEPTS.md             # Demo concepts documentation
    ├── DOCKER_BEST_PRACTICES.md     # Docker best practices
    ├── VERSIONING_STRATEGY.md       # Versioning strategy
    └── ANSWERS.md                   # Assignment answers
```

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform installed
- Docker installed
- Python 3.11+

### 1. Clone and Setup
```bash
git clone <your-repo-url>
cd robotics
pip install -r requirements.txt
pip install -r code-quality/requirements.txt
```

### 2. Setup Code Quality
```bash
# Setup pre-commit hooks
bash code-quality/scripts/setup-pre-commit.sh

# Run quality checks
bash code-quality/scripts/run-quality-checks.sh
```

### 3. Version Management
```bash
# Initialize version (if needed)
./scripts/version.sh init

# Check current version
./scripts/version.sh get

# Show version information
./scripts/version.sh info

# Bump version (patch, minor, major)
./scripts/version.sh bump patch
```

### 4. Build and Test Docker Image
```bash
# Build Docker image
docker build -f docker/Dockerfile -t devops-cicd-demo:latest .

# Test Docker image
docker run --rm -p 5000:5000 devops-cicd-demo:latest

# Test health check
curl http://localhost:5000/health
```

### 5. Deploy Infrastructure
```bash
# Deploy AWS infrastructure
bash infrastructure/scripts/deploy.sh

# Follow the prompts to configure your deployment
```

### 6. Test the Pipeline
```bash
# Make a change to the code
echo "# Updated comment" >> src/hello_world.py

# Commit and push
git add .
git commit -m "feat(app): update hello world message"
git push origin main
```

## 🔢 Versioning Strategy

Our project implements a comprehensive semantic versioning strategy with automated management:

### 📋 Version Structure
```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

**Examples**:
- `1.0.0` - Initial release
- `1.0.1` - Bug fix
- `1.1.0` - New feature
- `2.0.0` - Breaking change

### 🏗️ Version Storage
- **Primary Source**: Git tags (`v1.0.0`)
- **Version File**: `VERSION` file for easy access
- **Environment Variables**: Passed to application and Docker
- **Application Integration**: Available via `/info` endpoint

### 🔄 Version Management Workflow
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

### 🐳 Docker Image Tagging
```bash
# Version-based tags
devops-cicd-demo:1.0.0          # Specific version
devops-cicd-demo:latest          # Latest stable
devops-cicd-demo:main            # Latest from main branch

# ECR tagging
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY
docker tag devops-cicd-demo:$VERSION $ECR_REGISTRY/devops-cicd-demo:$VERSION
docker push $ECR_REGISTRY/devops-cicd-demo:$VERSION
```

### 📊 Version Script Commands
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

### 🔄 CI/CD Integration
```yaml
# GitHub Actions workflow
- name: Get version information
  run: |
    VERSION=$(./scripts/version.sh get)
    echo "VERSION=$VERSION" >> $GITHUB_ENV

- name: Build Docker image
  run: |
    docker build -f docker/Dockerfile \
      --build-arg APP_VERSION=$VERSION \
      --build-arg BUILD_DATE=$BUILD_DATE \
      --build-arg VCS_REF=$GIT_COMMIT \
      -t devops-cicd-demo:$VERSION .
```

### 📈 Version Tracking
```python
# Application endpoints
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

See [docs/VERSIONING_STRATEGY.md](docs/VERSIONING_STRATEGY.md) for detailed documentation.

## 🐳 Docker Best Practices

Our Dockerfile implements comprehensive best practices for secure and efficient containerization:

### ✅ Implemented Best Practices
- **Multi-stage Build**: Reduces final image size
- **Non-root User**: Security-first approach
- **Layer Optimization**: Efficient caching and smaller images
- **Health Checks**: Application monitoring
- **Security Scanning**: Vulnerability detection
- **Production Configuration**: Optimized Gunicorn settings
- **Version Support**: Build arguments for versioning

### 🔐 Security Features
```dockerfile
# Non-root user execution
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Proper file ownership
COPY --chown=appuser:appuser src/ ./src/

# Minimal attack surface
RUN apt-get update && apt-get install -y \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

### 📊 Performance Optimization
```dockerfile
# Multi-stage build
FROM python:3.11-slim as builder
# ... build dependencies ...

FROM python:3.11-slim
# ... production image ...

# Layer optimization
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
```

### 🧪 Health Monitoring
```dockerfile
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1
```

### 🚀 Production Configuration
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

See [docs/DOCKER_BEST_PRACTICES.md](docs/DOCKER_BEST_PRACTICES.md) for detailed documentation.

## 🔧 Code Quality Module

The project includes a comprehensive code quality module with:

### Features
- **Linting & Formatting**: Flake8, Black, Pylint
- **Security Scanning**: Bandit, Safety, Trivy
- **Testing & Coverage**: Pytest with coverage reporting
- **Pre-commit Hooks**: Based on p-shmonim-ve-ehad-example-app pattern
- **Quality Gates**: CI/CD integration with thresholds
- **Quality Metrics**: Simple 3-metric quality index

### Quick Quality Setup
```bash
# Install quality tools
pip install -r code-quality/requirements.txt

# Setup pre-commit hooks
bash code-quality/scripts/setup-pre-commit.sh

# Run quality checks
bash code-quality/scripts/run-quality-checks.sh

# Calculate quality index
python code-quality/scripts/calculate-quality-index.py
```

### Quality Gates
| Metric | Threshold | Action |
|--------|-----------|--------|
| **Test Coverage** | ≥ 80% | Block merge if below |
| **Security Issues** | 0 High/Critical | Block merge if found |
| **Linting Errors** | 0 | Block merge if found |

See [code-quality/README.md](code-quality/README.md) for detailed documentation.

## 🎮 Demo Concepts

The project includes demo concept pipelines for educational purposes:

### Demo Concept Pipeline (`demo-concept.yml`)
- **Purpose**: Basic CI/CD pipeline demonstration
- **Features**: Simulated Docker image signing, quality checks, deployment
- **Triggers**: Push, PR, Manual with demo type selection
- **Demo Types**: full, build-only, security-only, quality-only

### Demo Advanced Concepts (`demo-advanced.yml`)
- **Purpose**: Advanced CI/CD concepts demonstration
- **Features**: Advanced signing, multiple deployment strategies, compliance
- **Triggers**: Push, PR, Manual with environment and strategy selection
- **Environments**: staging, production, canary
- **Strategies**: rolling, blue-green, canary

### 🔐 Docker Image Signing Simulation
```bash
🔐 STEP: Simulate Docker Image Signing
   🔑 Generating signing key...
   📝 Creating signature...
   🏷️ Image: devops-cicd-demo:latest
   🔍 Signature: sha256:abc123def456...
   📋 Certificate: CN=Demo Signing Authority
   ✅ Image signed successfully
```

### 🚀 Deployment Strategies
- **Rolling Update**: Zero-downtime deployment
- **Blue-Green**: Traffic switching deployment
- **Canary**: Gradual rollout strategy

### 📊 Quality Metrics
```bash
📈 Quality Score: 95/100
🛡️ Security Score: 98/100
🧪 Test Coverage: 87%
🏗️ Build Time: 2m 15s
🚀 Deploy Time: 1m 30s
```

See [docs/DEMO_CONCEPTS.md](docs/DEMO_CONCEPTS.md) for detailed documentation.

## 🏗️ Architecture

### AWS Services Used
- **ECR**: Docker image registry
- **ECS**: Container orchestration (Fargate)
- **ALB**: Application Load Balancer
- **VPC**: Network infrastructure
- **CloudWatch**: Monitoring and logging
- **IAM**: Security and access management

### CI/CD Pipeline
1. **GitHub Actions**: Triggered on push to main
2. **Version Management**: Automated version detection and tagging
3. **Testing**: Run unit and integration tests
4. **Building**: Build Docker image with versioning
5. **Security**: Scan for vulnerabilities
6. **Deployment**: Deploy to ECS via ECR
7. **Monitoring**: CloudWatch dashboards and alarms

## 🏗️ System Architecture

Our DevOps CI/CD pipeline is built on AWS cloud services with GitHub Actions as the CI/CD engine:

### 🎯 AWS Services Architecture

#### 1. **Amazon ECR (Elastic Container Registry)**
**Purpose**: Container image registry and storage
**Why ECR**: 
- **Security**: Integrated with AWS IAM for access control
- **Performance**: High-speed image pulls within AWS network
- **Integration**: Seamless integration with ECS and other AWS services
- **Cost-effective**: Pay only for storage and data transfer

#### 2. **Amazon ECS (Elastic Container Service) with Fargate**
**Purpose**: Container orchestration and runtime environment
**Why ECS Fargate**:
- **Serverless**: No server management required
- **Scalability**: Automatic scaling based on demand
- **Cost-effective**: Pay only for resources used
- **Security**: Isolated compute environment
- **Integration**: Native AWS service integration

#### 3. **Application Load Balancer (ALB)**
**Purpose**: Traffic distribution and health monitoring
**Why ALB**:
- **High Availability**: Multi-AZ deployment
- **Health Checks**: Automatic unhealthy instance removal
- **SSL Termination**: Built-in SSL/TLS support
- **Path-based Routing**: Advanced routing capabilities
- **Integration**: Native ECS integration

#### 4. **Amazon VPC (Virtual Private Cloud)**
**Purpose**: Network isolation and security
**Why VPC**:
- **Security**: Network-level isolation
- **Control**: Complete network control
- **Compliance**: Meet security requirements
- **Integration**: Native AWS service integration
- **Scalability**: Support for large deployments

#### 5. **Amazon CloudWatch**
**Purpose**: Monitoring, logging, and observability
**Why CloudWatch**:
- **Comprehensive**: Metrics, logs, and alarms
- **Integration**: Native AWS service integration
- **Real-time**: Real-time monitoring and alerting
- **Cost-effective**: Basic monitoring included
- **Automation**: Automated responses to events

#### 6. **Amazon IAM (Identity and Access Management)**
**Purpose**: Security and access control
**Why IAM**:
- **Security**: Fine-grained access control
- **Compliance**: Meet security requirements
- **Integration**: Native AWS service integration
- **Audit**: Comprehensive access logging
- **Automation**: Programmatic access management

### 🔄 CI/CD Pipeline Architecture

#### GitHub Actions Workflow
**Purpose**: Automated CI/CD orchestration
**Why GitHub Actions**:
- **Integration**: Native GitHub integration
- **Flexibility**: Customizable workflows
- **Security**: Secure secrets management
- **Cost-effective**: Free for public repositories
- **Community**: Large ecosystem of actions

#### Pipeline Stages:
1. **Version Management**: Automated version detection
2. **Testing**: Unit and integration tests
3. **Quality Checks**: Code quality validation
4. **Building**: Docker image creation
5. **Security Scanning**: Vulnerability detection
6. **Deployment**: AWS service updates
7. **Monitoring**: Health check verification

### 🏗️ Infrastructure as Code (Terraform)

#### Terraform Modules
**Purpose**: Reusable infrastructure components
**Why Terraform**:
- **Declarative**: Infrastructure as code
- **Version Control**: Track infrastructure changes
- **Reusability**: Modular architecture
- **State Management**: Track resource state
- **Multi-cloud**: Support for multiple providers

### 🔐 Security Architecture

#### Security Layers:
1. **Network Security**: VPC, Security Groups, NACLs
2. **Application Security**: IAM roles, policies
3. **Container Security**: Non-root user, minimal base image
4. **Data Security**: Encryption at rest and in transit
5. **Access Security**: Multi-factor authentication

### 📊 Monitoring and Observability

#### Monitoring Stack:
1. **CloudWatch Metrics**: Application and infrastructure metrics
2. **CloudWatch Logs**: Centralized logging
3. **CloudWatch Alarms**: Automated alerting
4. **Application Health Checks**: Endpoint monitoring
5. **Custom Dashboards**: Operational visibility

### 🚀 Deployment Strategy

#### Deployment Types:
1. **Blue-Green Deployment**: Zero-downtime deployments
2. **Rolling Deployment**: Gradual rollout
3. **Canary Deployment**: Risk mitigation
4. **Immutable Deployment**: Version-based deployments

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) and [docs/ARCHITECTURE_DIAGRAM.md](docs/ARCHITECTURE_DIAGRAM.md) for detailed architecture documentation.

## 📊 Features

### Core Features
- ✅ **Automated CI/CD**: GitHub Actions pipeline
- ✅ **Container Orchestration**: ECS with Fargate
- ✅ **Load Balancing**: ALB with health checks
- ✅ **Monitoring**: CloudWatch dashboards and alarms
- ✅ **Security**: IAM roles, security groups, vulnerability scanning
- ✅ **Infrastructure as Code**: Terraform modules
- ✅ **Code Quality**: Comprehensive quality checks
- ✅ **Versioning**: Semantic versioning strategy
- ✅ **Demo Concepts**: Educational pipeline demonstrations
- ✅ **Docker Best Practices**: Secure and optimized containerization

### Versioning Features
- ✅ **Semantic Versioning**: Major.Minor.Patch format
- ✅ **Automated Management**: Version script with Git integration
- ✅ **Docker Tagging**: Version-based image tagging
- ✅ **CI/CD Integration**: Automated version detection
- ✅ **Build Metadata**: Timestamps and commit hashes
- ✅ **Release Automation**: Git tags and GitHub releases

### Quality Features
- ✅ **Pre-commit Hooks**: Local quality enforcement
- ✅ **Quality Gates**: CI/CD integration
- ✅ **Security Scanning**: Automated vulnerability detection
- ✅ **Coverage Reporting**: Test coverage metrics
- ✅ **PR Comments**: Automatic quality reports

### Demo Features
- ✅ **Simulated Signing**: Docker image signing concepts
- ✅ **Multiple Strategies**: Different deployment approaches
- ✅ **Educational**: Step-by-step pipeline demonstration
- ✅ **Manual Triggers**: Customizable demo scenarios

### Docker Features
- ✅ **Multi-stage Build**: Optimized image size
- ✅ **Security First**: Non-root user, minimal attack surface
- ✅ **Health Monitoring**: Application health checks
- ✅ **Production Ready**: Optimized Gunicorn configuration
- ✅ **Layer Optimization**: Efficient caching strategy
- ✅ **Version Support**: Build arguments and labels

## 📈 Monitoring

### CloudWatch Dashboards
- ECS Service Metrics
- ALB Performance Metrics
- Application Health Metrics
- Error Rate Monitoring
- Version Deployment Tracking

### Alerts
- High CPU/Memory Usage
- Error Rate Thresholds
- Health Check Failures
- Security Vulnerability Alerts
- Version Deployment Status

## 🔒 Security

### Security Features
- **IAM Roles**: Least privilege access
- **Security Groups**: Network-level security
- **Vulnerability Scanning**: Bandit, Safety, Trivy
- **Container Security**: Non-root user, minimal base image
- **HTTPS**: ALB with SSL termination
- **Image Signing**: Simulated signing for educational purposes
- **Docker Security**: Multi-stage builds, minimal attack surface
- **Version Security**: Signed Git tags and releases

## 💰 Cost Optimization

### Cost-Saving Strategies
- **Fargate Spot**: Use spot instances for non-critical workloads
- **Auto Scaling**: Scale based on demand
- **Resource Optimization**: Right-size containers
- **Monitoring**: Track and optimize costs
- **Docker Optimization**: Smaller images, efficient layers

## 🚀 Deployment Target

**Primary Target**: AWS ECS with Fargate
- **Container Registry**: AWS ECR
- **Orchestration**: ECS with Fargate (serverless)
- **Load Balancer**: Application Load Balancer
- **Networking**: VPC with public/private subnets
- **Monitoring**: CloudWatch integration
- **Versioning**: Automated version management

## 📚 Documentation

- **[SETUP.md](docs/SETUP.md)**: Detailed setup guide
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)**: Architecture documentation
- **[OPTIMIZATION.md](docs/OPTIMIZATION.md)**: Optimization strategies
- **[DEMO_CONCEPTS.md](docs/DEMO_CONCEPTS.md)**: Demo concepts documentation
- **[DOCKER_BEST_PRACTICES.md](docs/DOCKER_BEST_PRACTICES.md)**: Docker best practices
- **[VERSIONING_STRATEGY.md](docs/VERSIONING_STRATEGY.md)**: Versioning strategy
- **[ANSWERS.md](docs/ANSWERS.md)**: Assignment answers
- **[QUICK_START.md](QUICK_START.md)**: Quick start guide
- **[code-quality/README.md](code-quality/README.md)**: Code quality module

## 🔄 Versioning Strategy

### Semantic Versioning (Major.Minor.Patch)
- **Major**: Breaking changes
- **Minor**: New features, backward compatible
- **Patch**: Bug fixes, backward compatible

### Implementation
- **Application Version**: Environment variables in Flask app
- **Docker Image Tags**: Version-based tagging in ECR
- **ECS Service**: Automatic deployment with new image versions
- **GitHub Actions**: Automated version bumping and tagging
- **Git Tags**: Release tracking and version history

## 🧪 Testing

### Test Strategy
- **Unit Tests**: Pytest with coverage reporting
- **Integration Tests**: End-to-end API testing
- **Security Tests**: Vulnerability scanning
- **Quality Tests**: Linting and formatting checks
- **Docker Tests**: Container build and runtime testing
- **Version Tests**: Version management and validation

### Test Coverage
- **Minimum Threshold**: 80%
- **Coverage Reports**: HTML reports in CI/CD
- **Quality Gates**: Block deployment if below threshold

## 🚨 Troubleshooting

### Common Issues
1. **AWS Credentials**: Ensure AWS CLI is configured
2. **Terraform State**: Check state file and backend configuration
3. **Docker Build**: Verify Dockerfile and dependencies
4. **Quality Checks**: Run local quality checks before pushing
5. **Version Conflicts**: Check VERSION file and git tags

### Debug Commands
```bash
# Check AWS credentials
aws sts get-caller-identity

# Validate Terraform
terraform validate

# Test Docker build
docker build -f docker/Dockerfile -t devops-cicd-demo:latest .

# Test Docker image
docker run --rm -p 5000:5000 devops-cicd-demo:latest

# Run quality checks
bash code-quality/scripts/run-quality-checks.sh

# Check version
./scripts/version.sh info
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run quality checks: `bash code-quality/scripts/run-quality-checks.sh`
5. Commit with conventional format: `feat(scope): description`
6. Push and create a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **AWS**: Cloud infrastructure and services
- **GitHub**: CI/CD platform and repository hosting
- **Terraform**: Infrastructure as Code tooling
- **Docker**: Containerization platform
- **Python Community**: Testing and quality tools

---

**Note**: This project demonstrates a production-ready DevOps CI/CD pipeline with comprehensive quality assurance, security scanning, monitoring capabilities, educational demo concepts, Docker best practices, and automated versioning strategy. 