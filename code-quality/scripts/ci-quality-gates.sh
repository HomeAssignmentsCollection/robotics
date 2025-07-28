#!/bin/bash

# DevOps CI/CD Demo - CI Quality Gates
# Simple quality gates for CI/CD pipeline

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

echo -e "${BLUE}🚀 CI Quality Gates - Starting Checks...${NC}"

# Initialize failure counter
FAILURES=0

# Function to check quality gate
check_quality_gate() {
    local gate_name="$1"
    local threshold="$2"
    local current_value="$3"
    local operator="$4"
    
    echo -e "\n${YELLOW}Checking $gate_name...${NC}"
    echo "Threshold: $threshold, Current: $current_value"
    
    case $operator in
        "ge")
            if [ "$current_value" -ge "$threshold" ]; then
                echo -e "${GREEN}✅ $gate_name passed${NC}"
                return 0
            else
                echo -e "${RED}❌ $gate_name failed${NC}"
                return 1
            fi
            ;;
        "le")
            if [ "$current_value" -le "$threshold" ]; then
                echo -e "${GREEN}✅ $gate_name passed${NC}"
                return 0
            else
                echo -e "${RED}❌ $gate_name failed${NC}"
                return 1
            fi
            ;;
        "eq")
            if [ "$current_value" -eq "$threshold" ]; then
                echo -e "${GREEN}✅ $gate_name passed${NC}"
                return 0
            else
                echo -e "${RED}❌ $gate_name failed${NC}"
                return 1
            fi
            ;;
    esac
}

# 1. Code Formatting Check
echo -e "\n${BLUE}1. Code Formatting Check${NC}"
if black --check --config "$CONFIGS_DIR/pyproject.toml" src/ tests/; then
    echo -e "${GREEN}✅ Code formatting passed${NC}"
else
    echo -e "${RED}❌ Code formatting failed${NC}"
    ((FAILURES++))
fi

# 2. Import Sorting Check
echo -e "\n${BLUE}2. Import Sorting Check${NC}"
if isort --check-only --config "$CONFIGS_DIR/pyproject.toml" src/ tests/; then
    echo -e "${GREEN}✅ Import sorting passed${NC}"
else
    echo -e "${RED}❌ Import sorting failed${NC}"
    ((FAILURES++))
fi

# 3. Linting Check
echo -e "\n${BLUE}3. Linting Check${NC}"
LINTING_ERRORS=$(flake8 --config "$CONFIGS_DIR/flake8.ini" src/ tests/ --count --quiet)
check_quality_gate "Linting Errors" 0 "$LINTING_ERRORS" "le" || ((FAILURES++))

# 4. Security Scan
echo -e "\n${BLUE}4. Security Scan${NC}"
bandit -r src/ -f json -o "$REPORTS_DIR/security/bandit-report.json" --configfile "$CONFIGS_DIR/.bandit" || true

# Count high/critical security issues
SECURITY_ISSUES=$(jq -r '.results[] | select(.issue_severity == "HIGH" or .issue_severity == "MEDIUM") | .issue_text' "$REPORTS_DIR/security/bandit-report.json" 2>/dev/null | wc -l)
check_quality_gate "Security Issues" 0 "$SECURITY_ISSUES" "le" || ((FAILURES++))

# 5. Dependency Security
echo -e "\n${BLUE}5. Dependency Security Check${NC}"
safety check --json --output "$REPORTS_DIR/security/safety-report.json" || true

# Count vulnerable dependencies
VULNERABLE_DEPS=$(jq -r '.vulnerabilities | length' "$REPORTS_DIR/security/safety-report.json" 2>/dev/null || echo "0")
check_quality_gate "Vulnerable Dependencies" 0 "$VULNERABLE_DEPS" "le" || ((FAILURES++))

# 6. Test Coverage
echo -e "\n${BLUE}6. Test Coverage Check${NC}"
coverage run -m pytest tests/ --config "$CONFIGS_DIR/pytest.ini" --cov=src --cov-report=term-missing --cov-fail-under=80

# Extract coverage percentage
COVERAGE_PERCENT=$(coverage report --show-missing | grep TOTAL | awk '{print $4}' | sed 's/%//')
check_quality_gate "Test Coverage" 80 "$COVERAGE_PERCENT" "ge" || ((FAILURES++))

# Generate quality report
echo -e "\n${BLUE}📊 Quality Gates Summary${NC}"
echo -e "${BLUE}=======================${NC}"

# Create quality report
cat > "$REPORTS_DIR/metrics/quality-report.json" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "quality_gates": {
    "test_coverage": {
      "threshold": 80,
      "current": $COVERAGE_PERCENT,
      "passed": $([ "$COVERAGE_PERCENT" -ge 80 ] && echo "true" || echo "false")
    },
    "security_issues": {
      "threshold": 0,
      "current": $SECURITY_ISSUES,
      "passed": $([ "$SECURITY_ISSUES" -eq 0 ] && echo "true" || echo "false")
    },
    "linting_errors": {
      "threshold": 0,
      "current": $LINTING_ERRORS,
      "passed": $([ "$LINTING_ERRORS" -eq 0 ] && echo "true" || echo "false")
    },
    "vulnerable_dependencies": {
      "threshold": 0,
      "current": $VULNERABLE_DEPS,
      "passed": $([ "$VULNERABLE_DEPS" -eq 0 ] && echo "true" || echo "false")
    }
  },
  "summary": {
    "total_checks": 6,
    "passed_checks": $((6 - FAILURES)),
    "failed_checks": $FAILURES,
    "overall_status": "$([ $FAILURES -eq 0 ] && echo "PASSED" || echo "FAILED")"
  }
}
EOF

# Final result
if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}🎉 All quality gates passed!${NC}"
    echo -e "${GREEN}✅ Code quality meets all standards${NC}"
    echo -e "${BLUE}📋 Quality report: $REPORTS_DIR/metrics/quality-report.json${NC}"
    exit 0
else
    echo -e "${RED}⚠️  $FAILURES quality gate(s) failed${NC}"
    echo -e "${YELLOW}📋 Check the reports in $REPORTS_DIR for details${NC}"
    echo -e "${YELLOW}📋 Quality report: $REPORTS_DIR/metrics/quality-report.json${NC}"
    exit 1
fi 