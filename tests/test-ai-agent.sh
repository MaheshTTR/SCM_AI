#!/bin/bash

# Test script to validate AI Agent workflows
# This script checks that all workflow files are valid and properly configured

set -e

echo "🧪 Testing AI Agent CI/CD Integration"
echo "======================================"
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name=$1
    local test_command=$2
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Testing: $test_name ... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "1. Checking Directory Structure"
echo "--------------------------------"
run_test "Workflows directory exists" "[ -d .github/workflows ]"
run_test "AI agent directory exists" "[ -d .ai-agent ]"
run_test "AI agent logs directory exists" "[ -d .ai-agent/logs ]"
echo ""

echo "2. Checking Workflow Files"
echo "---------------------------"
run_test "AI Security Scan workflow exists" "[ -f .github/workflows/ai-security-scan.yml ]"
run_test "AI Risk Assessment workflow exists" "[ -f .github/workflows/ai-risk-assessment.yml ]"
run_test "AI Autonomous Remediation workflow exists" "[ -f .github/workflows/ai-autonomous-remediation.yml ]"
echo ""

echo "3. Checking Configuration Files"
echo "--------------------------------"
run_test "AI agent config exists" "[ -f .ai-agent/config.yml ]"
run_test "AI agent README exists" "[ -f .ai-agent/README.md ]"
run_test "Quick start guide exists" "[ -f QUICKSTART.md ]"
run_test "Gitignore exists" "[ -f .gitignore ]"
echo ""

echo "4. Validating YAML Syntax"
echo "--------------------------"
run_test "Security scan YAML is valid" "python3 -c 'import yaml; yaml.safe_load(open(\".github/workflows/ai-security-scan.yml\"))'"
run_test "Risk assessment YAML is valid" "python3 -c 'import yaml; yaml.safe_load(open(\".github/workflows/ai-risk-assessment.yml\"))'"
run_test "Autonomous remediation YAML is valid" "python3 -c 'import yaml; yaml.safe_load(open(\".github/workflows/ai-autonomous-remediation.yml\"))'"
run_test "AI config YAML is valid" "python3 -c 'import yaml; yaml.safe_load(open(\".ai-agent/config.yml\"))'"
echo ""

echo "5. Checking Workflow Structure"
echo "-------------------------------"
run_test "Security scan has 'on' triggers" "grep -q 'on:' .github/workflows/ai-security-scan.yml"
run_test "Security scan has 'jobs' section" "grep -q 'jobs:' .github/workflows/ai-security-scan.yml"
run_test "Risk assessment has 'on' triggers" "grep -q 'on:' .github/workflows/ai-risk-assessment.yml"
run_test "Risk assessment has 'jobs' section" "grep -q 'jobs:' .github/workflows/ai-risk-assessment.yml"
run_test "Remediation has 'on' triggers" "grep -q 'on:' .github/workflows/ai-autonomous-remediation.yml"
run_test "Remediation has 'jobs' section" "grep -q 'jobs:' .github/workflows/ai-autonomous-remediation.yml"
echo ""

echo "6. Checking Key Features"
echo "------------------------"
run_test "Security scan includes CodeQL" "grep -q 'codeql' .github/workflows/ai-security-scan.yml"
run_test "Security scan creates artifacts" "grep -q 'upload-artifact' .github/workflows/ai-security-scan.yml"
run_test "Risk assessment calculates risk score" "grep -q 'risk_score' .github/workflows/ai-risk-assessment.yml"
run_test "Risk assessment posts comments" "grep -q 'github-script' .github/workflows/ai-risk-assessment.yml"
run_test "Remediation includes dependency check" "grep -q 'dependency' .github/workflows/ai-autonomous-remediation.yml"
run_test "Remediation includes issue triage" "grep -q 'issue' .github/workflows/ai-autonomous-remediation.yml"
echo ""

echo "7. Checking Documentation"
echo "-------------------------"
run_test "README mentions AI agent" "grep -q 'AI agent' README.md"
run_test "Config has capabilities section" "grep -q 'capabilities' .ai-agent/config.yml"
run_test "AI README has overview section" "grep -q 'Overview' .ai-agent/README.md"
run_test "Quick start has commands" "grep -q 'Quick Commands' QUICKSTART.md"
echo ""

echo "8. Checking Permissions"
echo "-----------------------"
run_test "Security scan has proper permissions" "grep -q 'permissions:' .github/workflows/ai-security-scan.yml"
run_test "Risk assessment has proper permissions" "grep -q 'permissions:' .github/workflows/ai-risk-assessment.yml"
run_test "Remediation has proper permissions" "grep -q 'permissions:' .github/workflows/ai-autonomous-remediation.yml"
echo ""

# Summary
echo "======================================"
echo "Test Summary"
echo "======================================"
echo -e "Total Tests: $TESTS_RUN"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
else
    echo -e "Failed: $TESTS_FAILED"
fi
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo "AI Agent integration is properly configured."
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    echo "Please review the failures above."
    exit 1
fi
