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

## 📚 Documentation

### 🚀 Getting Started
- **[QUICK_START.md](docs/QUICK_START.md)**: Detailed quick start guide
- **[SETUP.md](docs/SETUP.md)**: Complete setup instructions
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)**: Common issues and solutions

### 🏗️ AWS Resources
- **[AWS_RESOURCES.md](AWS_RESOURCES.md)**: AWS services overview and justification
- **[AWS_COMPONENTS_ANALYSIS.md](AWS_COMPONENTS_ANALYSIS.md)**: Detailed analysis of AWS components and their roles
- **[ALTERNATIVE_ARCHITECTURES.md](ALTERNATIVE_ARCHITECTURES.md)**: Alternative architectural solutions and comparisons

### 🏗️ Architecture & Design
- **[ARCHITECTURE_OVERVIEW.md](docs/ARCHITECTURE_OVERVIEW.md)**: System architecture overview
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)**: Detailed architecture documentation
- **[ARCHITECTURE_DIAGRAM.md](docs/ARCHITECTURE_DIAGRAM.md)**: Architecture diagrams
- **[AWS_COMPONENTS_INVENTORY.md](docs/AWS_COMPONENTS_INVENTORY.md)**: Complete AWS resources inventory

### 🔧 Development & Operations
- **[VERSIONING_GUIDE.md](docs/VERSIONING_GUIDE.md)**: Version management guide
- **[DOCKER_GUIDE.md](docs/DOCKER_GUIDE.md)**: Docker best practices and usage
- **[FEATURES.md](docs/FEATURES.md)**: Comprehensive feature documentation
- **[SECRET_MANAGEMENT.md](docs/SECRET_MANAGEMENT.md)**: Secret management best practices
- **[SECRET_MANAGEMENT_EXAMPLES.md](docs/SECRET_MANAGEMENT_EXAMPLES.md)**: Practical secret management examples
- **[CODE_REVIEW_REPORT.md](CODE_REVIEW_REPORT.md)**: Comprehensive code review and recommendations

### 🎮 Educational & Demo
- **[DEMO_CONCEPTS.md](docs/DEMO_CONCEPTS.md)**: Demo concepts documentation
- **[code-quality/README.md](code-quality/README.md)**: Code quality module

### 📊 Monitoring & Optimization
- **[OPTIMIZATION.md](docs/OPTIMIZATION.md)**: Performance optimization strategies
- **[AUTO_VERSIONING.md](docs/AUTO_VERSIONING.md)**: Automatic versioning documentation

## 🔄 Versioning Strategy

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

### 🏗️ Version Management Workflow
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

See [docs/VERSIONING_GUIDE.md](docs/VERSIONING_GUIDE.md) for detailed documentation.

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

See [docs/DOCKER_GUIDE.md](docs/DOCKER_GUIDE.md) for detailed documentation.

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

See [docs/ARCHITECTURE_OVERVIEW.md](docs/ARCHITECTURE_OVERVIEW.md) for detailed architecture documentation.

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

See [docs/FEATURES.md](docs/FEATURES.md) for comprehensive feature documentation.

## 🚀 Deployment Target

**Primary Target**: AWS ECS with Fargate
- **Container Registry**: AWS ECR
- **Orchestration**: ECS with Fargate (serverless)
- **Load Balancer**: Application Load Balancer
- **Networking**: VPC with public/private subnets
- **Monitoring**: CloudWatch integration
- **Versioning**: Automated version management

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