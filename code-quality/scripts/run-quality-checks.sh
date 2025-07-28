#!/bin/bash

# DevOps CI/CD Demo - Code Quality Checks
# Simple quality check script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/../configs"
REPORTS_DIR="$SCRIPT_DIR/../reports"

# Create reports directory
mkdir -p "$REPORTS_DIR"/{coverage,security,metrics}

echo -e "${BLUE}🔍 Starting Code Quality Checks...${NC}"

# Initialize failure counter
FAILURES=0

# Function to run a check and report status
run_check() {
    local check_name="$1"
    local command="$2"
    
    echo -e "\n${YELLOW}Running $check_name...${NC}"
    
    if eval "$command"; then
        echo -e "${GREEN}✅ $check_name passed${NC}"
        return 0
    else
        echo -e "${RED}❌ $check_name failed${NC}"
        return 1
    fi
}

# 1. Code Formatting with Black
run_check "Black Code Formatting" \
    "black --check --config $CONFIGS_DIR/pyproject.toml src/ tests/" || ((FAILURES++))

# 2. Import Sorting with isort
run_check "Import Sorting" \
    "isort --check-only --config $CONFIGS_DIR/pyproject.toml src/ tests/" || ((FAILURES++))

# 3. Linting with Flake8
run_check "Flake8 Linting" \
    "flake8 --config $CONFIGS_DIR/flake8.ini src/ tests/" || ((FAILURES++))

# 4. Advanced Analysis with Pylint
run_check "Pylint Analysis" \
    "pylint --rcfile $CONFIGS_DIR/pylintrc src/" || ((FAILURES++))

# 5. Security Scanning with Bandit
run_check "Bandit Security Scan" \
    "bandit -r src/ -f json -o $REPORTS_DIR/security/bandit-report.json --configfile $CONFIGS_DIR/.bandit" || ((FAILURES++))

# 6. Dependency Security with Safety
run_check "Safety Dependency Check" \
    "safety check --json --output $REPORTS_DIR/security/safety-report.json" || ((FAILURES++))

# 7. Testing with Pytest
run_check "Pytest Testing" \
    "pytest --config $CONFIGS_DIR/pytest.ini" || ((FAILURES++))

# 8. Code Coverage
run_check "Code Coverage" \
    "coverage run -m pytest tests/ && coverage html --directory=$REPORTS_DIR/coverage/" || ((FAILURES++))

# Generate summary report
echo -e "\n${BLUE}📊 Quality Check Summary${NC}"
echo -e "${BLUE}========================${NC}"

if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}🎉 All quality checks passed!${NC}"
    echo -e "${GREEN}✅ Code quality is excellent${NC}"
    exit 0
else
    echo -e "${RED}⚠️  $FAILURES quality check(s) failed${NC}"
    echo -e "${YELLOW}📋 Check the reports in $REPORTS_DIR for details${NC}"
    exit 1
fi 