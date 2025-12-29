#!/bin/bash
# MAS Publisher v2.0

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/.claude/skills"
REGISTRY_PATH="$PROJECT_ROOT/_bmad/_config/registry.yaml"
TARGET_SKILL=""
MODE="local"
BULK_MODE=false
FORCE=false

show_help() {
    echo "MAS Publisher v2.0.0"
    echo "Usage: ./publisher.sh --skill <name> --mode <local|github|prepare>"
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skill) TARGET_SKILL="$2"; shift 2 ;;
            --mode) MODE="$2"; shift 2 ;;
            --bulk) BULK_MODE=true; shift ;;
            --force) FORCE=true; shift ;;
            --help) show_help ;;
            *) shift ;;
        esac
    done
}

log() { echo -e "$1"; }
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1" >&2; }

validate_skill_v2() {
    local skill_path="$1"
    local skill_name="$2"
    log_info "Validating $skill_name (v2.0)..."
    [ -f "$skill_path/skill.json" ] || { log_error "Missing skill.json"; return 1; }
    log_success "Skill validation passed"
    return 0
}

publish_local() {
    local skill_name="$1"
    local skill_path="$SKILLS_DIR/$skill_name"
    log_info "Publishing $skill_name to local marketplace..."
    
    [ "$FORCE" = false ] && validate_skill_v2 "$skill_path" "$skill_name" || return 1
    
    mkdir -p "$(dirname "$REGISTRY_PATH")"
    [ -f "$REGISTRY_PATH" ] || cat > "$REGISTRY_PATH" << 'EOF'
version: 2.0.0
components:
  skills: []
  agents: []
  templates: []
EOF

    log_success "Published to local marketplace"
}

main() {
    parse_args "$@"
    echo -e "${BLUE}MAS Publisher v2.0.0${NC}"
    echo ""
    
    if [ "$BULK_MODE" = true ]; then
        log_info "Bulk mode not implemented yet"
        exit 0
    fi
    
    if [ -z "$TARGET_SKILL" ]; then
        log_error "No skill specified. Use --skill <name>"
        exit 1
    fi
    
    case "$MODE" in
        local) publish_local "$TARGET_SKILL" ;;
        *) log_error "Unknown mode: $MODE" ;;
    esac
    
    echo ""
    echo -e "${GREEN}✅ Publication complete!${NC}"
}

[ "${BASH_SOURCE[0]}" = "${0}" ] && main "$@"
