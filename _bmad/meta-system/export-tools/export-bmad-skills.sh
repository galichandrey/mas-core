#!/bin/bash
# Export BMAD-Specific Skills v2.0

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SKILLS_DIR="$PROJECT_ROOT/.claude/skills"
TARGET_DIR=""
LIST_ONLY=false

show_help() {
    echo "Export BMAD-Specific Skills v2.0"
    echo "Usage: ./export-bmad-skills.sh --list | /path/to/target"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --list) LIST_ONLY=true; shift ;;
        --help) show_help ;;
        *) [ -z "$TARGET_DIR" ] && TARGET_DIR="$1"; shift ;;
    esac
done

log() { echo -e "$1"; }
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1" >&2; }

list_bmad_skills() {
    log_info "Scanning for BMAD-specific skills..."
    local found=0
    for skill_path in "$SKILLS_DIR"/bmad-*; do
        if [ -d "$skill_path" ]; then
            [ $found -eq 0 ] && log "" && log "${CYAN}BMAD-Specific Skills:${NC}" && log ""
            found=$((found + 1))
            log "  ${GREEN}$(basename "$skill_path")${NC}"
        fi
    done
    [ $found -eq 0 ] && log_warn "No BMAD-specific skills found" || log_success "Found $found BMAD-specific skills"
}

export_skills() {
    local target="$1"
    log_info "Exporting to: $target"
    [ ! -d "$target" ] && log_error "Target not found" && exit 1
    
    local export_dir="$target/_bmad-export-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$export_dir"
    local count=0
    
    for skill_path in "$SKILLS_DIR"/bmad-*; do
        if [ -d "$skill_path" ]; then
            cp -r "$skill_path" "$export_dir/"
            count=$((count + 1))
            log_success "Exported: $(basename "$skill_path")"
        fi
    done
    
    log ""
    log_success "Export complete: $export_dir ($count skills)"
}

main() {
    echo "Export BMAD-Specific Skills v2.0"
    echo ""
    
    if [ "$LIST_ONLY" = true ]; then
        list_bmad_skills
        exit 0
    fi
    
    if [ -z "$TARGET_DIR" ]; then
        log_error "No target specified"
        exit 1
    fi
    
    export_skills "$TARGET_DIR"
}

[ "${BASH_SOURCE[0]}" = "${0}" ] && main "$@"
