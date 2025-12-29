#!/bin/bash
# MAS Universal Installer v2.0
# One-line installation for Meta Agentic System
#
# Usage:
#   curl -sSL https://get.mas.dev | bash
#   curl -sSL https://get.mas.dev | bash -s -- --target /path/to/project
#   curl -sSL https://get.mas.dev | bash -s -- --skill meta-skill-creator
#
# Or from local:
#   bash installer.sh
#   bash installer.sh --target /path/to/project
#   bash installer.sh --skill meta-component-updater

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script info
VERSION="2.0.0"
REPO="https://github.com/yourusername/mas-core"
INSTALL_SOURCE="local"  # local, github, curl

# Default values
TARGET_DIR="."
MODE="full"  # full, skill, update
SKILL_NAME=""
VERBOSE=false

# Helper functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step() { echo -e "${CYAN}[→]${NC} $1"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --skill)
            MODE="skill"
            SKILL_NAME="$2"
            shift 2
            ;;
        --update)
            MODE="update"
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

show_help() {
    cat << EOF
MAS Universal Installer v${VERSION}

Usage:
  $0 [OPTIONS]

Options:
  --target DIR        Install to specific directory (default: current)
  --skill NAME        Install only specific skill
  --update            Update existing installation
  --verbose, -v       Show detailed output
  --help, -h          Show this help

Examples:
  # Full installation
  $0

  # Install to specific project
  $0 --target /path/to/project

  # Install single skill
  $0 --skill meta-skill-creator

  # Update existing
  $0 --update

  # Verbose mode
  $0 --verbose
EOF
}

# Detect installation source
detect_source() {
    if [ -f "$(dirname "$0")/../_bmad/meta-system/README.md" ]; then
        INSTALL_SOURCE="local"
        log_info "Installation source: Local files"
    elif [ -d ".claude/skills" ]; then
        INSTALL_SOURCE="curl"
        log_info "Installation source: Curl download"
    else
        INSTALL_SOURCE="github"
        log_info "Installation source: GitHub"
    fi
}

# Get source directory
get_source_dir() {
    case $INSTALL_SOURCE in
        local)
            echo "$(cd "$(dirname "$0")/.." && pwd)"
            ;;
        curl)
            echo "$(pwd)"
            ;;
        github)
            # Would download from GitHub
            echo "/tmp/mas-core-$$"
            ;;
    esac
}

# Validate target directory
validate_target() {
    if [ ! -d "$TARGET_DIR" ]; then
        log_error "Target directory does not exist: $TARGET_DIR"
        exit 1
    fi

    # Check if it's a git repo (optional but recommended)
    if [ -d "$TARGET_DIR/.git" ]; then
        log_success "Target is a git repository"
    else
        log_warn "Target is not a git repository (this is OK, but recommended)"
    fi

    # Check for existing MAS
    if [ -d "$TARGET_DIR/_bmad/meta-system" ]; then
        log_warn "MAS already installed in $TARGET_DIR"
        if [ "$MODE" != "update" ]; then
            log_info "Use --update to update existing installation"
            read -p "Continue anyway? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 0
            fi
        fi
    fi
}

# Create directory structure
create_structure() {
    log_step "Creating directory structure..."

    mkdir -p "$TARGET_DIR/.claude/skills"
    mkdir -p "$TARGET_DIR/_bmad/meta-system/export-tools"
    mkdir -p "$TARGET_DIR/_bmad/meta-system/templates"
    mkdir -p "$TARGET_DIR/_bmad/meta-system/mcp-server"

    log_success "Directory structure created"
}

# Copy core files
copy_core() {
    local source_dir="$1"

    log_step "Copying MAS core files..."

    # Copy meta-skills
    for skill in meta-skill-creator meta-agent-factory meta-prompt-generator meta-system-validator meta-component-updater; do
        if [ -d "$source_dir/.claude/skills/$skill" ]; then
            cp -r "$source_dir/.claude/skills/$skill" "$TARGET_DIR/.claude/skills/"
            log_success "Copied: $skill"
        else
            log_warn "Missing: $skill"
        fi
    done

    # Copy meta-system
    if [ -d "$source_dir/_bmad/meta-system" ]; then
        cp -r "$source_dir/_bmad/meta-system/"* "$TARGET_DIR/_bmad/meta-system/"
        log_success "Copied: meta-system"
    fi

    # Copy registry
    if [ -f "$source_dir/_bmad/meta-system/registry.yaml" ]; then
        cp "$source_dir/_bmad/meta-system/registry.yaml" "$TARGET_DIR/_bmad/meta-system/"
        log_success "Copied: registry.yaml"
    fi
}

# Copy single skill
copy_skill() {
    local source_dir="$1"
    local skill="$2"

    log_step "Installing skill: $skill"

    if [ ! -d "$source_dir/.claude/skills/$skill" ]; then
        log_error "Skill not found: $skill"
        log_info "Available skills:"
        ls "$source_dir/.claude/skills/" 2>/dev/null | grep "^meta-" || echo "No skills found"
        exit 1
    fi

    mkdir -p "$TARGET_DIR/.claude/skills"
    cp -r "$source_dir/.claude/skills/$skill" "$TARGET_DIR/.claude/skills/"
    log_success "Installed: $skill"
}

# Update existing installation
update_installation() {
    log_step "Updating MAS installation..."

    if [ ! -d "$TARGET_DIR/_bmad/meta-system" ]; then
        log_error "MAS not found in $TARGET_DIR"
        exit 1
    fi

    # Backup current
    BACKUP_DIR="$TARGET_DIR/_bmad/meta-system-backup-$(date +%Y%m%d-%H%M%S)"
    log_info "Creating backup: $BACKUP_DIR"
    cp -r "$TARGET_DIR/_bmad/meta-system" "$BACKUP_DIR"

    # Update
    source_dir=$(get_source_dir)
    copy_core "$source_dir"

    log_success "Update complete"
    log_info "Backup preserved: $BACKUP_DIR"
}

# Validate installation
validate_installation() {
    log_step "Validating installation..."

    local errors=0

    # Check meta-skills
    for skill in meta-skill-creator meta-agent-factory meta-prompt-generator meta-system-validator; do
        if [ ! -d "$TARGET_DIR/.claude/skills/$skill" ]; then
            log_error "Missing skill: $skill"
            ((errors++))
        elif [ ! -f "$TARGET_DIR/.claude/skills/$skill/SKILL.md" ]; then
            log_error "Invalid skill: $skill (missing SKILL.md)"
            ((errors++))
        fi
    done

    # Check meta-system
    if [ ! -d "$TARGET_DIR/_bmad/meta-system" ]; then
        log_error "Missing meta-system directory"
        ((errors++))
    fi

    if [ ! -f "$TARGET_DIR/_bmad/meta-system/registry.yaml" ]; then
        log_error "Missing registry.yaml"
        ((errors++))
    fi

    # Check export tools
    for tool in export-system.sh export-skill.sh validate-system.sh install-from-marketplace.sh; do
        if [ ! -f "$TARGET_DIR/_bmad/meta-system/export-tools/$tool" ]; then
            log_warn "Missing tool: $tool"
        fi
    done

    if [ $errors -eq 0 ]; then
        log_success "Validation passed"
        return 0
    else
        log_error "Validation failed with $errors error(s)"
        return 1
    fi
}

# Show post-install instructions
show_instructions() {
    cat << EOF

${GREEN}╔════════════════════════════════════════════════════════════╗${NC}
${GREEN}║${NC}  ${CYAN}MAS Installation Complete!${NC}                               ${GREEN}║${NC}
${GREEN}╚════════════════════════════════════════════════════════════╝${NC}

${YELLOW}What's installed:${NC}
  • Meta Skill Creator
  • Meta Agent Factory
  • Meta Prompt Generator
  • Meta System Validator
  • Meta Component Updater
  • Export tools
  • MCP Server

${YELLOW}Quick Start:${NC}
  1. Create a skill:
     ${CYAN}Create a skill named data-processor for CSV handling${NC}

  2. Build an agent:
     ${CYAN}Build an agent named monitoring-bot for system health${NC}

  3. Validate system:
     ${CYAN}Use meta-system-validator to validate current project${NC}

${YELLOW}Next Steps:${NC}
  • Read: ${TARGET_DIR}/_bmad/meta-system/README.md
  • Test: Run validation script
  • Explore: Check registry.yaml for all components

${YELLOW}Need Help?${NC}
  • Documentation: _bmad/meta-system/USAGE.md
  • Troubleshooting: _bmad/meta-system/TROUBLESHOOTING.md
  • GitHub: https://github.com/yourusername/mas-core

${GREEN}Happy building!${NC}
EOF
}

# Main execution
main() {
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  MAS Universal Installer v${VERSION}                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    detect_source
    source_dir=$(get_source_dir)

    if [ "$MODE" = "update" ]; then
        validate_target
        update_installation
    elif [ "$MODE" = "skill" ]; then
        validate_target
        create_structure
        copy_skill "$source_dir" "$SKILL_NAME"
    else
        validate_target
        create_structure
        copy_core "$source_dir"
    fi

    if validate_installation; then
        show_instructions
    else
        log_error "Installation validation failed"
        exit 1
    fi
}

# Run main
main "$@"