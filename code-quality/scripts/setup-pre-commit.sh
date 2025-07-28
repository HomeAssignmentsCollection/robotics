#!/bin/bash

# DevOps CI/CD Demo - Pre-commit Setup
# Based on p-shmonim-ve-ehad-example-app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Setting up Pre-commit Hooks...${NC}"

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo -e "${YELLOW}Installing pre-commit...${NC}"
    pip install pre-commit
fi

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  # Pre-commit hooks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: debug-statements

  # Python formatting
  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black
        language_version: python3
        args: [--config=code-quality/configs/pyproject.toml]

  # Import sorting
  - repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
      - id: isort
        args: [--config=code-quality/configs/pyproject.toml]

  # Python linting
  - repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
        args: [--config=code-quality/configs/flake8.ini]

  # Security scanning
  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: [-r, src/, -f, json, -o, code-quality/reports/security/bandit-report.json, --configfile, code-quality/configs/.bandit]
EOF

echo -e "${GREEN}✅ Created .pre-commit-config.yaml${NC}"

# Install pre-commit hooks
echo -e "${YELLOW}Installing pre-commit hooks...${NC}"
pre-commit install

# Install additional hooks
pre-commit install --hook-type pre-push
pre-commit install --hook-type commit-msg

echo -e "${GREEN}✅ Pre-commit hooks installed successfully${NC}"

# Create git hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create custom pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Custom pre-commit hook for DevOps CI/CD Demo

echo "🔍 Running pre-commit checks..."

# Run pre-commit
pre-commit run --all-files

# Check if pre-commit passed
if [ $? -ne 0 ]; then
    echo "❌ Pre-commit checks failed. Please fix the issues and try again."
    exit 1
fi

echo "✅ Pre-commit checks passed!"
exit 0
EOF

chmod +x .git/hooks/pre-commit

echo -e "${GREEN}✅ Custom pre-commit hook created${NC}"

# Create pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

# Custom pre-push hook for DevOps CI/CD Demo

echo "🚀 Running pre-push checks..."

# Run quality checks
bash code-quality/scripts/run-quality-checks.sh

# Check if quality checks passed
if [ $? -ne 0 ]; then
    echo "❌ Quality checks failed. Please fix the issues and try again."
    exit 1
fi

echo "✅ Pre-push checks passed!"
exit 0
EOF

chmod +x .git/hooks/pre-push

echo -e "${GREEN}✅ Custom pre-push hook created${NC}"

# Create commit-msg hook
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

# Custom commit-msg hook for DevOps CI/CD Demo

# Check commit message format
commit_msg=$(cat "$1")

# Check if commit message follows conventional commits
if ! echo "$commit_msg" | grep -qE "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+"; then
    echo "❌ Commit message does not follow conventional commits format."
    echo "Format: <type>(<scope>): <description>"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(api): add new endpoint for user management"
    exit 1
fi

echo "✅ Commit message format is valid!"
exit 0
EOF

chmod +x .git/hooks/commit-msg

echo -e "${GREEN}✅ Custom commit-msg hook created${NC}"

# Test pre-commit installation
echo -e "${YELLOW}Testing pre-commit installation...${NC}"
pre-commit run --all-files || true

echo -e "${GREEN}🎉 Pre-commit setup completed successfully!${NC}"
echo -e "${BLUE}📋 Hooks installed:${NC}"
echo -e "  - pre-commit: Runs on every commit"
echo -e "  - pre-push: Runs before pushing to remote"
echo -e "  - commit-msg: Validates commit message format"
echo -e ""
echo -e "${BLUE}🔧 Available commands:${NC}"
echo -e "  - pre-commit run --all-files: Run all hooks"
echo -e "  - pre-commit run <hook-id>: Run specific hook"
echo -e "  - pre-commit clean: Remove cached files"
echo -e "  - pre-commit uninstall: Remove all hooks" 