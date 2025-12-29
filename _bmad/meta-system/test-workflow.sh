#!/bin/bash
#
# Test complete MAS GitHub workflow
#

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  MAS GitHub Workflow Test                                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

test_step() {
    echo -e "${YELLOW}Testing: $1${NC}"
}

pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    FAIL=$((FAIL + 1))
}

# Test 1: Check all scripts exist
test_step "All export tools exist"
for script in installer.sh updater.sh publisher.sh marketplace.sh validate-system.sh export-system.sh export-skill.sh; do
    if [ -f "_bmad/meta-system/export-tools/$script" ] && [ -x "_bmad/meta-system/export-tools/$script" ]; then
        pass "$script exists and is executable"
    else
        fail "$script missing or not executable"
    fi
done

# Test 2: Check installer.sh syntax
test_step "Installer.sh syntax"
if bash -n "_bmad/meta-system/export-tools/installer.sh" 2>/dev/null; then
    pass "Installer syntax valid"
else
    fail "Installer has syntax errors"
fi

# Test 3: Check updater.sh syntax
test_step "Updater.sh syntax"
if bash -n "_bmad/meta-system/export-tools/updater.sh" 2>/dev/null; then
    pass "Updater syntax valid"
else
    fail "Updater has syntax errors"
fi

# Test 4: Check publisher.sh syntax
test_step "Publisher.sh syntax"
if bash -n "_bmad/meta-system/export-tools/publisher.sh" 2>/dev/null; then
    pass "Publisher syntax valid"
else
    fail "Publisher has syntax errors"
fi

# Test 5: Check marketplace.sh syntax
test_step "Marketplace.sh syntax"
if bash -n "_bmad/meta-system/export-tools/marketplace.sh" 2>/dev/null; then
    pass "Marketplace syntax valid"
else
    fail "Marketplace has syntax errors"
fi

# Test 6: Check MCP server
test_step "MCP server files"
if [ -f "_bmad/meta-system/mcp-server/index.js" ]; then
    pass "MCP server index.js exists"
else
    fail "MCP server index.js missing"
fi

if [ -f "_bmad/meta-system/mcp-server/package.json" ]; then
    pass "MCP server package.json exists"
else
    fail "MCP server package.json missing"
fi

# Test 7: Check registry template
test_step "Registry template"
if [ -f "_bmad/meta-system/marketplace-registry-template.json" ]; then
    # Validate JSON
    if python3 -c "import json; json.load(open('_bmad/meta-system/marketplace-registry-template.json'))" 2>/dev/null; then
        pass "Registry template is valid JSON"
    else
        fail "Registry template has invalid JSON"
    fi
else
    fail "Registry template missing"
fi

# Test 8: Check meta-skills
test_step "Meta-skills structure"
for skill in meta-skill-creator meta-agent-factory meta-prompt-generator meta-system-validator; do
    if [ -d ".claude/skills/$skill" ] && [ -f ".claude/skills/$skill/SKILL.md" ]; then
        pass "$skill exists with SKILL.md"
    else
        fail "$skill missing or incomplete"
    fi
done

# Test 9: Check documentation
test_step "Documentation files"
for doc in README.md GITHUB-README-TEMPLATE.md GITHUB-REPO-SETUP.md; do
    if [ -f "_bmad/meta-system/$doc" ]; then
        pass "$doc exists"
    else
        fail "$doc missing"
    fi
done

# Test 10: Check GitHub workflows
test_step "GitHub Actions workflows"
for workflow in validate-skill.yml release.yml; do
    if [ -f "_bmad/meta-system/github-workflows/$workflow" ]; then
        pass "$workflow exists"
    else
        fail "$workflow missing"
    fi
done

# Test 11: Check GitHub workflow scripts
test_step "GitHub workflow scripts"
for script in validate_skills.py security_scan.py; do
    if [ -f "_bmad/meta-system/github-workflows/scripts/$script" ]; then
        pass "$script exists"
        # Check Python syntax
        if python3 -m py_compile "_bmad/meta-system/github-workflows/scripts/$script" 2>/dev/null; then
            pass "$script syntax valid"
        else
            fail "$script has syntax errors"
        fi
    else
        fail "$script missing"
    fi
done

# Test 12: Test installer help
test_step "Installer help output"
if "_bmad/meta-system/export-tools/installer.sh" --help > /dev/null 2>&1; then
    pass "Installer --help works"
else
    fail "Installer --help failed"
fi

# Test 13: Test updater help
test_step "Updater help output"
if "_bmad/meta-system/export-tools/updater.sh" --help > /dev/null 2>&1; then
    pass "Updater --help works"
else
    fail "Updater --help failed"
fi

# Test 14: Test publisher help
test_step "Publisher help output"
if "_bmad/meta-system/export-tools/publisher.sh" --help > /dev/null 2>&1; then
    pass "Publisher --help works"
else
    fail "Publisher --help failed"
fi

# Test 15: Test marketplace help
test_step "Marketplace help output"
if "_bmad/meta-system/export-tools/marketplace.sh" --help > /dev/null 2>&1; then
    pass "Marketplace --help works"
else
    fail "Marketplace --help failed"
fi

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Test Summary                                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! Workflow is ready.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Create GitHub organization: mas-marketplace"
    echo "2. Create mas-core repository"
    echo "3. Push all files"
    echo "4. Create v1.1.0 release"
    echo "5. Test: curl -sSL https://get.mas.dev | bash"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Fix issues before proceeding.${NC}"
    exit 1
fi