# Code Quality Module

This module provides comprehensive code quality tools and configurations for the DevOps CI/CD demo project.

## 🎯 Overview

The code quality module ensures high code standards, security, and maintainability through automated checks integrated into the CI/CD pipeline.

## 📋 Summary

### What We Created
- **Configuration Files**: Flake8, Pylint, Pytest, Bandit, and PyProject configurations
- **Quality Scripts**: Run quality checks, CI gates, and calculate quality index
- **Pre-commit Hooks**: Based on p-shmonim-ve-ehad-example-app pattern
- **GitHub Actions**: Automated quality checks with PR comments
- **Quality Metrics**: Simple 3-metric quality index (coverage, security, style)

### Key Features
- ✅ **Simple & Focused**: Only essential tools and configurations
- ✅ **CI/CD Integrated**: Works with main pipeline
- ✅ **Pre-commit Hooks**: Local quality enforcement
- ✅ **Quality Gates**: Block deployment if thresholds not met
- ✅ **PR Comments**: Automatic quality reports on pull requests

### Quick Start
```bash
# Install tools
pip install -r code-quality/requirements.txt

# Setup hooks
bash code-quality/scripts/setup-pre-commit.sh

# Run checks
bash code-quality/scripts/run-quality-checks.sh
```

## 📁 Structure

```
code-quality/
├── README.md                    # This file
├── requirements.txt             # Quality tools dependencies
├── configs/                    # Configuration files
│   ├── flake8.ini            # Flake8 linting config
│   ├── pylintrc              # Pylint analysis config
│   ├── pytest.ini           # Pytest testing config
│   ├── .bandit               # Bandit security config
│   └── pyproject.toml        # Project configuration
├── scripts/                    # Quality check scripts
│   ├── run-quality-checks.sh # Main quality check script
│   ├── ci-quality-gates.sh   # CI quality gates
│   └── calculate-quality-index.py # Quality metrics calculator
└── reports/                   # Generated reports (auto-created)
    ├── coverage/             # Coverage reports
    ├── security/             # Security scan reports
    └── metrics/              # Quality metrics
```

## 🛠️ Tools

### Linting & Formatting
- **Flake8**: Python style guide enforcement
- **Black**: Uncompromising code formatter
- **Pylint**: Advanced code analysis

### Security Scanning
- **Bandit**: Python security linter
- **Safety**: Dependency vulnerability scanner
- **Trivy**: Container vulnerability scanner

### Testing & Coverage
- **Pytest**: Testing framework
- **Coverage**: Code coverage measurement

## 🚀 Quick Start

### 1. Install Quality Tools
```bash
pip install -r code-quality/requirements.txt
```

### 2. Run Quality Checks
```bash
# Run all quality checks
bash code-quality/scripts/run-quality-checks.sh

# Run CI quality gates
bash code-quality/scripts/ci-quality-gates.sh
```

### 3. Setup Pre-commit Hooks
```bash
bash code-quality/scripts/setup-pre-commit.sh
```

## 📊 Quality Gates

| Metric | Threshold | Action |
|--------|-----------|--------|
| **Test Coverage** | ≥ 80% | Block merge if below |
| **Security Issues** | 0 High/Critical | Block merge if found |
| **Linting Errors** | 0 | Block merge if found |
| **Code Complexity** | ≤ 10 | Warning if above |

## 🔧 Configuration

### Flake8 Configuration
```ini
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude = .git,__pycache__,build,dist
```

### Pytest Configuration
```ini
[tool:pytest]
testpaths = tests
addopts = --cov=src --cov-report=html --cov-fail-under=80
```

### Bandit Security Configuration
```yaml
exclude_dirs:
  - tests
  - docs
skips:
  - B101  # assert_used
```

## 📈 Quality Metrics

### Code Quality Index
The module calculates a comprehensive quality index based on:
- Test coverage (40% weight)
- Security score (40% weight)
- Style compliance (20% weight)

### Quality Grades
- **A+ (90-100)**: Excellent
- **A (80-89)**: Very Good
- **B (70-79)**: Good
- **C (60-69)**: Fair
- **D (50-59)**: Poor
- **F (0-49)**: Very Poor

## 🔄 CI/CD Integration

### GitHub Actions Workflow
The module integrates with GitHub Actions through `.github/workflows/quality-checks.yml`:

- **Triggers**: Push to main/develop, Pull Requests
- **Jobs**: Quality checks with comprehensive reporting
- **Artifacts**: Upload quality reports for review
- **PR Comments**: Automatic quality reports on pull requests

### Pre-commit Hooks
Based on [p-shmonim-ve-ehad-example-app](https://github.com/langburd/p-shmonim-ve-ehad-example-app), the module includes:

#### Pre-commit Hook
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black
        args: [--config=code-quality/configs/pyproject.toml]

  - repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
      - id: isort
        args: [--config=code-quality/configs/pyproject.toml]

  - repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
        args: [--config=code-quality/configs/flake8.ini]

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: [-r, src/, -f, json, -o, code-quality/reports/security/bandit-report.json]
```

#### Pre-push Hook
```bash
#!/bin/bash
# .git/hooks/pre-push

echo "🚀 Running pre-push checks..."

# Run quality checks
bash code-quality/scripts/run-quality-checks.sh

if [ $? -ne 0 ]; then
    echo "❌ Quality checks failed. Please fix the issues and try again."
    exit 1
fi

echo "✅ Pre-push checks passed!"
exit 0
```

#### Commit Message Hook
```bash
#!/bin/bash
# .git/hooks/commit-msg

commit_msg=$(cat "$1")

# Check conventional commits format
if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+"; then
    echo "❌ Commit message does not follow conventional commits format."
    echo "Format: <type>(<scope>): <description>"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(api): add new endpoint for user management"
    exit 1
fi

echo "✅ Commit message format is valid!"
exit 0
```

## 📋 Usage Examples

### Local Development
```bash
# Setup pre-commit hooks
bash code-quality/scripts/setup-pre-commit.sh

# Run quality checks locally
bash code-quality/scripts/run-quality-checks.sh

# Calculate quality index
python code-quality/scripts/calculate-quality-index.py
```

### CI/CD Pipeline
```yaml
# GitHub Actions integration
- name: Run Code Quality Checks
  run: |
    bash code-quality/scripts/ci-quality-gates.sh

- name: Calculate Quality Index
  run: |
    python code-quality/scripts/calculate-quality-index.py
```

### Quality Reports
```bash
# View coverage report
open code-quality/reports/coverage/index.html

# View security report
cat code-quality/reports/security/bandit-report.json

# View quality metrics
cat code-quality/reports/metrics/quality-index.json
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Pre-commit Hooks Not Working
```bash
# Reinstall hooks
pre-commit uninstall
pre-commit install

# Clear cache
pre-commit clean
```

#### 2. Quality Checks Failing
```bash
# Check specific tool
flake8 src/ --config=code-quality/configs/flake8.ini
pylint src/ --rcfile=code-quality/configs/pylintrc
bandit -r src/ --configfile=code-quality/configs/.bandit
```

#### 3. Coverage Issues
```bash
# Debug coverage
coverage debug data
coverage report --show-missing
```

## 📚 Best Practices

### 1. Code Organization
- Keep functions small and focused
- Use meaningful variable names
- Add comprehensive docstrings
- Follow PEP 8 style guide

### 2. Testing Strategy
- Write tests for all new features
- Maintain high test coverage
- Use descriptive test names
- Mock external dependencies

### 3. Security Practices
- Regularly update dependencies
- Scan for vulnerabilities
- Follow security best practices
- Review security reports

### 4. Documentation
- Keep documentation up-to-date
- Use clear and concise language
- Include code examples
- Document API changes

## 🔗 Integration with Main CI/CD

The code quality module integrates seamlessly with the main CI/CD pipeline:

1. **Quality Checks**: Run before deployment
2. **Security Scanning**: Integrated into build process
3. **Coverage Reporting**: Part of test suite
4. **Quality Gates**: Block deployment if thresholds not met

## 📊 Monitoring

### Quality Metrics Dashboard
The module generates comprehensive reports:
- **Coverage Reports**: HTML coverage reports
- **Security Reports**: JSON vulnerability reports
- **Quality Metrics**: Overall quality index and grades
- **Trend Analysis**: Quality metrics over time

### Automated Alerts
- Quality degradation alerts
- Security vulnerability notifications
- Coverage threshold warnings
- Complexity increase alerts

---

**Note**: This module is designed to be simple yet comprehensive. All implementation details are documented in the respective configuration files and scripts. Customize the thresholds and rules according to your project's specific requirements. 