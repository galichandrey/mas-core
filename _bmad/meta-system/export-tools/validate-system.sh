#!/bin/bash
# Meta Agentic System - Validation Tool v2.0

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
META_SYSTEM="$PROJECT_ROOT/_bmad/meta-system"
SKILLS_DIR="$PROJECT_ROOT/.claude/skills"
QUICK_MODE=false
STRICT_MODE=false
CHECK_MCP=false

show_help() {
    echo "MAS Validation Tool v2.0.0"
    echo "Usage: ./validate-system.sh [--quick|--strict|--check-mcp]"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick) QUICK_MODE=true; shift ;;
        --strict) STRICT_MODE=true; shift ;;
        --check-mcp) CHECK_MCP=true; shift ;;
        --help) show_help ;;
        *) shift ;;
    esac
done

log() { echo -e "$1"; }
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1" >&2; }

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Meta Agentic System - Validation Tool v2.0               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

PASS=0
FAIL=0
WARN=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL + 1)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; WARN=$((WARN + 1)); }

echo -e "${YELLOW}1. Checking MAS version...${NC}"
if [ -f "$PROJECT_ROOT/.mas-version" ]; then
    VERSION=$(cat "$PROJECT_ROOT/.mas-version")
    echo -e "  Version: ${CYAN}$VERSION${NC}"
    pass "Version file exists"
else
    fail "Version file not found"
fi

echo ""
echo -e "${YELLOW}2. Checking directory structure...${NC}"
[ -d "$SKILLS_DIR" ] && pass "Skills directory exists" || fail "Skills directory missing"
[ -d "$META_SYSTEM" ] && pass "Meta-system directory exists" || fail "Meta-system directory missing"
[ -d "$META_SYSTEM/export-tools" ] && pass "Export tools directory exists" || fail "Export tools directory missing"
[ -d "$META_SYSTEM/mcp-servers" ] && pass "MCP servers directory exists" || warn "MCP servers directory missing"
[ -d "$META_SYSTEM/schemas" ] && pass "Schemas directory exists" || warn "Schemas directory missing"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Validation Summary                                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}Passed:${NC}   $PASS"
echo -e "  ${RED}Failed:${NC}   $FAIL"
echo -e "  ${YELLOW}Warnings:${NC} $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
    if [ $WARN -eq 0 ]; then
        echo -e "${GREEN}✅ System is valid and ready to use!${NC}"
    else
        echo -e "${YELLOW}⚠ System is valid with some warnings${NC}"
    fi
    exit 0
else
    echo -e "${RED}❌ System has issues that need to be fixed${NC}"
    exit 1
fi
