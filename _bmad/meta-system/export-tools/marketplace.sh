#!/bin/bash
#
# MAS Marketplace Tool
# Search, browse, and validate skills from marketplace
#
# Usage:
#   ./marketplace.sh --list
#   ./marketplace.sh --search "testing"
#   ./marketplace.sh --info data-validator
#   ./marketplace.sh --validate data-validator
#   ./marketplace.sh --install data-validator
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
MODE="list"
QUERY=""
REPO="mas-marketplace/mas-core"
REGISTRY_URL="https://raw.githubusercontent.com/mas-marketplace/mas-core/main/marketplace/registry.json"
LOCAL_REGISTRY=""

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --list)
                MODE="list"
                shift
                ;;
            --search)
                MODE="search"
                QUERY="$2"
                shift 2
                ;;
            --info)
                MODE="info"
                QUERY="$2"
                shift 2
                ;;
            --validate)
                MODE="validate"
                QUERY="$2"
                shift 2
                ;;
            --install)
                MODE="install"
                QUERY="$2"
                shift 2
                ;;
            --repo)
                REPO="$2"
                shift 2
                ;;
            --registry)
                REGISTRY_URL="$2"
                shift 2
                ;;
            --local)
                LOCAL_REGISTRY="$2"
                shift 2
                ;;
            --help)
                show_help
                ;;
            *)
                shift
                ;;
        esac
    done
}

show_help() {
    cat << EOF
MAS Marketplace Tool v1.0.0

Usage:
  ./marketplace.sh --list                    # List all skills
  ./marketplace.sh --search "testing"        # Search by keyword
  ./marketplace.sh --info data-validator     # Show skill details
  ./marketplace.sh --validate data-validator # Validate before install
  ./marketplace.sh --install data-validator  # Install skill

Options:
  --list                List all available skills
  --search <query>      Search skills
  --info <skill>        Show skill information
  --validate <skill>    Validate skill before installation
  --install <skill>     Install skill from marketplace
  --repo <org/repo>     Marketplace repository
  --registry <url>      Custom registry URL
  --local <path>        Use local marketplace

Examples:
  # Browse marketplace
  ./marketplace.sh --list

  # Find testing skills
  ./marketplace.sh --search testing

  # Get skill details
  ./marketplace.sh --info data-validator

  # Validate before install
  ./marketplace.sh --validate data-validator

  # Install from marketplace
  ./marketplace.sh --install data-validator

  # Use local marketplace
  ./marketplace.sh --local /shared/marketplace --list

EOF
    exit 0
}

log() {
    echo -e "$1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

# Fetch registry
fetch_registry() {
    local temp_file=$(mktemp)

    if [ -n "$LOCAL_REGISTRY" ]; then
        if [ -f "$LOCAL_REGISTRY/registry.json" ]; then
            cp "$LOCAL_REGISTRY/registry.json" "$temp_file"
        else
            log_error "Local registry not found: $LOCAL_REGISTRY/registry.json"
            exit 1
        fi
    else
        log_info "Fetching registry from $REGISTRY_URL..."

        if command -v curl &> /dev/null; then
            if ! curl -sL -o "$temp_file" "$REGISTRY_URL"; then
                log_error "Failed to fetch registry"
                exit 1
            fi
        else
            log_error "curl required"
            exit 1
        fi

        # Check if valid JSON
        if ! python3 -c "import json; json.load(open('$temp_file'))" 2>/dev/null; then
            log_error "Invalid registry format"
            exit 1
        fi
    fi

    echo "$temp_file"
}

# List skills
list_skills() {
    local registry="$1"

    log_info "Available skills:"

    # Parse JSON with Python (more reliable than jq)
    python3 << EOF
import json
import sys

with open('$registry') as f:
    data = json.load(f)

skills = data.get('skills', [])

if not skills:
    print("  No skills found")
    sys.exit(0)

# Group by category if available
categories = {}
for skill in skills:
    cat = skill.get('category', 'general')
    if cat not in categories:
        categories[cat] = []
    categories[cat].append(skill)

for cat, cat_skills in categories.items():
    print(f"\n  {cat.upper()}:")
    for skill in cat_skills:
        name = skill.get('name', 'unknown')
        desc = skill.get('description', 'No description')
        version = skill.get('version', '1.0.0')
        tags = skill.get('tags', [])
        status = skill.get('validation_status', 'unknown')

        status_icon = "✅" if status == "verified" else "⚠️" if status == "pending" else "❌"

        print(f"    {status_icon} {name} (v{version})")
        print(f"       {desc}")
        if tags:
            print(f"       Tags: {', '.join(tags)}")
        print()

print(f"Total: {len(skills)} skills")
EOF
}

# Search skills
search_skills() {
    local registry="$1"
    local query="$2"

    log_info "Searching for: $query"

    python3 << EOF
import json
import sys

with open('$registry') as f:
    data = json.load(f)

query = '$query'.lower()
skills = data.get('skills', [])

matches = []
for skill in skills:
    name = skill.get('name', '').lower()
    desc = skill.get('description', '').lower()
    tags = [t.lower() for t in skill.get('tags', [])]

    if query in name or query in desc or query in tags:
        matches.append(skill)

if not matches:
    print("  No matches found")
    sys.exit(0)

print(f"\n  Found {len(matches)} matches:\n")
for skill in matches:
    name = skill.get('name')
    version = skill.get('version', '1.0.0')
    desc = skill.get('description')
    tags = skill.get('tags', [])
    status = skill.get('validation_status', 'unknown')

    status_icon = "✅" if status == "verified" else "⚠️"

    print(f"    {status_icon} {name} (v{version})")
    print(f"       {desc}")
    if tags:
        print(f"       Tags: {', '.join(tags)}")
    print()
EOF
}

# Show skill info
show_info() {
    local registry="$1"
    local skill_name="$2"

    python3 << EOF
import json
import sys

with open('$registry') as f:
    data = json.load(f)

skill_name = '$skill_name'
skills = data.get('skills', [])

skill = None
for s in skills:
    if s.get('name') == skill_name:
        skill = s
        break

if not skill:
    print(f"  Skill '{skill_name}' not found")
    sys.exit(1)

print(f"\n  ═══════════════════════════════════════════════════════")
print(f"  {skill.get('name', 'Unknown')}")
print(f"  ═══════════════════════════════════════════════════════\n")

print(f"  Version:      {skill.get('version', '1.0.0')}")
print(f"  Author:       {skill.get('author', 'Unknown')}")
print(f"  Category:     {skill.get('category', 'General')}")
print(f"  Status:       {skill.get('validation_status', 'Unknown')}")
print(f"  Downloads:    {skill.get('downloads', 0)}")
print(f"  Rating:       {skill.get('rating', 'N/A')}")

desc = skill.get('description', 'No description')
print(f"\n  Description:\n    {desc}")

tags = skill.get('tags', [])
if tags:
    print(f"\n  Tags: {', '.join(tags)}")

deps = skill.get('dependencies', [])
if deps:
    print(f"\n  Dependencies: {', '.join(deps)}")

print(f"\n  GitHub:       {skill.get('github', 'N/A')}")
print(f"  Last Updated: {skill.get('last_updated', 'N/A')}")
print(f"\n  ═══════════════════════════════════════════════════════")
EOF
}

# Validate skill
validate_skill() {
    local registry="$1"
    local skill_name="$2"

    log_info "Validating: $skill_name"

    # Get skill info
    local skill_info=$(python3 << EOF
import json
import sys

with open('$registry') as f:
    data = json.load(f)

skill_name = '$skill_name'
skills = data.get('skills', [])

skill = None
for s in skills:
    if s.get('name') == skill_name:
        skill = s
        break

if skill:
    print(json.dumps(skill))
else:
    sys.exit(1)
EOF
)

    if [ $? -ne 0 ]; then
        log_error "Skill not found in registry"
        exit 1
    fi

    # Check validation status
    local status=$(echo "$skill_info" | python3 -c "import json, sys; print(json.load(sys.stdin).get('validation_status', 'unknown'))")

    if [ "$status" = "verified" ]; then
        log_success "✅ Verified skill - safe to install"
        return 0
    elif [ "$status" = "pending" ]; then
        log_warn "⚠️  Pending review - use with caution"
        return 1
    else
        log_error "❌ Not verified - do not install"
        return 1
    fi
}

# Install skill
install_skill() {
    local registry="$1"
    local skill_name="$2"

    log_info "Installing: $skill_name"

    # Validate first
    if ! validate_skill "$registry" "$skill_name"; then
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Use install-from-marketplace.sh
    if [ -f "./_bmad/meta-system/export-tools/install-from-marketplace.sh" ]; then
        log_info "Using install-from-marketplace.sh..."
        "./_bmad/meta-system/export-tools/install-from-marketplace.sh" "$skill_name" .
    else
        log_error "install-from-marketplace.sh not found"
        log_info "Install MAS first: curl -sSL https://get.mas.dev | bash"
        exit 1
    fi
}

# Main execution
main() {
    parse_args "$@"

    # Fetch registry
    registry=$(fetch_registry)
    trap "rm -f $registry" EXIT

    case "$MODE" in
        "list")
            list_skills "$registry"
            ;;
        "search")
            if [ -z "$QUERY" ]; then
                log_error "Query required for --search"
                exit 1
            fi
            search_skills "$registry" "$QUERY"
            ;;
        "info")
            if [ -z "$QUERY" ]; then
                log_error "Skill name required for --info"
                exit 1
            fi
            show_info "$registry" "$QUERY"
            ;;
        "validate")
            if [ -z "$QUERY" ]; then
                log_error "Skill name required for --validate"
                exit 1
            fi
            validate_skill "$registry" "$QUERY"
            ;;
        "install")
            if [ -z "$QUERY" ]; then
                log_error "Skill name required for --install"
                exit 1
            fi
            install_skill "$registry" "$QUERY"
            ;;
    esac
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi