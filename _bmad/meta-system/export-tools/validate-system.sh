#!/bin/bash
#
# Meta Agentic System - Validation Tool
# Checks system integrity and structure
#
# Usage: ./validate-system.sh
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
META_SYSTEM="$PROJECT_ROOT/_bmad/meta-system"
SKILLS_DIR="$PROJECT_ROOT/.claude/skills"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Meta Agentic System - Validation Tool                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

PASS=0
FAIL=0

# Helper functions
pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    PASS=$((PASS + 1))
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
    FAIL=$((FAIL + 1))
}

check() {
    if [ "$1" -eq 0 ]; then
        pass "$2"
    else
        fail "$2"
    fi
}

# 1. Check directory structure
echo -e "${YELLOW}1. Checking directory structure...${NC}"

if [ -d "$SKILLS_DIR" ]; then
    pass "Skills directory exists"
else
    fail "Skills directory missing"
fi

if [ -d "$META_SYSTEM" ]; then
    pass "Meta-system directory exists"
else
    fail "Meta-system directory missing"
fi

if [ -d "$META_SYSTEM/export-tools" ]; then
    pass "Export tools directory exists"
else
    fail "Export tools directory missing"
fi

# 2. Check meta skills
echo ""
echo -e "${YELLOW}2. Checking meta skills...${NC}"

for skill in meta-skill-creator meta-agent-factory meta-prompt-generator; do
    if [ -d "$SKILLS_DIR/$skill" ]; then
        if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
            pass "$skill exists with SKILL.md"
        else
            fail "$skill missing SKILL.md"
        fi
    else
        fail "$skill not found"
    fi
done

# 3. Check registry
echo ""
echo -e "${YELLOW}3. Checking registry...${NC}"

if [ -f "$META_SYSTEM/registry.yaml" ]; then
    pass "registry.yaml exists"

    # Check if it's valid YAML (basic check)
    if command -v python3 &> /dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('$META_SYSTEM/registry.yaml'))" 2>/dev/null
        if [ $? -eq 0 ]; then
            pass "registry.yaml is valid YAML"
        else
            fail "registry.yaml has YAML syntax errors"
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} python3 not available, skipping YAML validation"
    fi
else
    fail "registry.yaml not found"
fi

# 4. Check export tools
echo ""
echo -e "${YELLOW}4. Checking export tools...${NC}"

for tool in export-system.sh export-skill.sh validate-system.sh; do
    tool_path="$META_SYSTEM/export-tools/$tool"
    if [ -f "$tool_path" ]; then
        if [ -x "$tool_path" ]; then
            pass "$tool is executable"
        else
            fail "$tool exists but not executable"
        fi
    else
        fail "$tool not found"
    fi
done

# 5. Check documentation
echo ""
echo -e "${YELLOW}5. Checking documentation...${NC}"

[ -f "$META_SYSTEM/README.md" ] && pass "README.md exists" || fail "README.md missing"

# 6. Check for common issues
echo ""
echo -e "${YELLOW}6. Checking for common issues...${NC}"

# Check for deeply nested files in skills (relative to skill root)
DEEP_FILES=0
for skill_dir in "$SKILLS_DIR"/meta-*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        find "$skill_dir" -name "*.md" -o -name "*.py" -o -name "*.sh" 2>/dev/null | \
        while read f; do
            # Get relative path from skill directory
            rel_path="${f#$skill_dir/}"
            depth=$(echo "$rel_path" | tr '/' '\n' | wc -l)
            if [ $depth -gt 2 ]; then
                DEEP_FILES=$((DEEP_FILES + 1))
            fi
        done
    fi
done

if [ "$DEEP_FILES" -eq 0 ]; then
    pass "No deeply nested files"
else
    fail "Found $DEEP_FILES deeply nested files"
fi

# Check for absolute paths in SKILL.md files
ABS_PATHS=$(grep -r "^/" "$SKILLS_DIR"/meta-*/SKILL.md 2>/dev/null | grep -v "^Binary" | wc -l)
if [ "$ABS_PATHS" -eq 0 ]; then
    pass "No absolute paths in SKILL.md files"
else
    fail "Found $ABS_PATHS absolute paths in SKILL.md files"
fi

# Summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Validation Summary                                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Passed: ${GREEN}$PASS${NC}"
echo -e "  Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ System is valid and ready to use!${NC}"
    exit 0
else
    echo -e "${RED}❌ System has issues that need to be fixed.${NC}"
    exit 1
fi
