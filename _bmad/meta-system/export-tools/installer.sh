#!/bin/bash
#
# MAS Universal Installer
# Installs Meta Agentic System from GitHub with one command
#
# Usage:
#   curl -sSL https://raw.githubusercontent.com/mas-marketplace/mas-core/main/scripts/installer.sh | bash
#   curl -sSL https://get.mas.dev | bash
#
# Or with options:
#   curl -sSL https://get.mas.dev | bash -s -- --target ~/project --version 1.1.0
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default configuration
REPO="mas-marketplace/mas-core"
BRANCH="main"
VERSION="latest"
TARGET="."
QUIET=false
VERBOSE=false
MODE="full"  # full, minimal, skill-only

# Parse command line arguments (from stdin or direct)
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --target)
                TARGET="$2"
                shift 2
                ;;
            --version)
                VERSION="$2"
                shift 2
                ;;
            --repo)
                REPO="$2"
                shift 2
                ;;
            --branch)
                BRANCH="$2"
                shift 2
                ;;
            --mode)
                MODE="$2"
                shift 2
                ;;
            --quiet)
                QUIET=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
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
MAS Installer v1.0.0

Usage:
  curl -sSL https://get.mas.dev | bash
  curl -sSL https://get.mas.dev | bash -s -- --target ~/project --version 1.1.0

Options:
  --target <path>      Installation directory (default: current)
  --version <ver>      Specific version (default: latest)
  --repo <org/repo>    GitHub repository (default: mas-marketplace/mas-core)
  --branch <name>      Git branch (default: main)
  --mode <full|minimal|skill-only>  What to install
  --quiet              Suppress output
  --verbose            Show detailed info
  --help               Show this help

Examples:
  # Quick install
  curl -sSL https://get.mas.dev | bash

  # Install to specific project
  curl -sSL https://get.mas.dev | bash -s -- --target /path/to/project

  # Install specific version
  curl -sSL https://get.mas.dev | bash -s -- --version 1.1.0

  # Install only meta-skills (no export tools)
  curl -sSL https://get.mas.dev | bash -s -- --mode skill-only

  # Install from fork
  curl -sSL https://get.mas.dev | bash -s -- --repo myuser/mas-core

EOF
    exit 0
}

log() {
    if [ "$QUIET" = false ]; then
        echo -e "$1"
    fi
}

log_info() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

log_success() {
    if [ "$QUIET" = false ]; then
        echo -e "${GREEN}[✓]${NC} $1"
    fi
}

log_warn() {
    if [ "$QUIET" = false ]; then
        echo -e "${YELLOW}[⚠]${NC} $1"
    fi
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" >&2
}

log_verbose() {
    if [ "$VERBOSE" = true ] && [ "$QUIET" = false ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# Check prerequisites
check_prereqs() {
    log_verbose "Checking prerequisites..."

    local missing=()

    # Check for curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing+=("curl or wget")
    fi

    # Check for git (optional, for updates)
    if ! command -v git &> /dev/null; then
        log_warn "git not found, updates will use curl only"
    fi

    # Check for tar/gzip
    if ! command -v tar &> /dev/null; then
        missing+=("tar")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing prerequisites: ${missing[*]}"
        exit 1
    fi

    log_verbose "All prerequisites met"
}

# Resolve target directory
resolve_target() {
    log_verbose "Resolving target: $TARGET"

    # Create if doesn't exist
    if [ ! -d "$TARGET" ]; then
        log_info "Creating directory: $TARGET"
        mkdir -p "$TARGET"
    fi

    # Get absolute path
    TARGET="$(cd "$TARGET" && pwd)"

    log_verbose "Target resolved to: $TARGET"
}

# Download from GitHub
download_from_github() {
    local repo="$1"
    local version="$2"
    local temp_dir="$3"

    log_info "Downloading MAS from GitHub: $repo (version: $version)"

    # Construct URL
    if [ "$version" = "latest" ]; then
        # Get latest release
        if command -v curl &> /dev/null; then
            version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
            if [ -z "$version" ]; then
                version="main"  # Fallback to main branch
            fi
        else
            version="main"
        fi
    fi

    log_verbose "Using version/branch: $version"

    # Try to download release asset first
    if [ "$version" != "main" ] && [ "$version" != "master" ]; then
        log_verbose "Trying to download release asset..."

        # GitHub releases are typically tagged as v1.1.0 or 1.1.0
        local tag="$version"
        if [[ ! "$version" =~ ^v ]]; then
            tag="v$version"
        fi

        # Try to download release tarball
        local url="https://github.com/$repo/archive/refs/tags/$tag.tar.gz"

        if command -v curl &> /dev/null; then
            if curl -sL -o "$temp_dir/mas.tar.gz" "$url"; then
                log_success "Downloaded release $version"
                tar -xzf "$temp_dir/mas.tar.gz" -C "$temp_dir" --strip-components=1
                return 0
            fi
        fi
    fi

    # Fallback: Download from main branch
    log_verbose "Falling back to branch download..."

    local url="https://github.com/$repo/archive/refs/heads/$version.tar.gz"
    if [ "$version" = "main" ]; then
        url="https://github.com/$repo/archive/refs/heads/main.tar.gz"
    fi

    if command -v curl &> /dev/null; then
        curl -sL -o "$temp_dir/mas.tar.gz" "$url"
    else
        wget -q -O "$temp_dir/mas.tar.gz" "$url"
    fi

    if [ ! -f "$temp_dir/mas.tar.gz" ]; then
        log_error "Failed to download from GitHub"
        exit 1
    fi

    tar -xzf "$temp_dir/mas.tar.gz" -C "$temp_dir" --strip-components=1
    log_success "Downloaded from $repo ($version)"
}

# Install based on mode
install() {
    local temp_dir="$1"

    log_info "Installing MAS to: $TARGET"

    case "$MODE" in
        "full")
            install_full "$temp_dir"
            ;;
        "minimal")
            install_minimal "$temp_dir"
            ;;
        "skill-only")
            install_skill_only "$temp_dir"
            ;;
        *)
            log_error "Unknown mode: $MODE"
            exit 1
            ;;
    esac
}

install_full() {
    local temp_dir="$1"

    log_info "Installing full MAS (meta-skills + export tools)"

    # Create directory structure
    mkdir -p "$TARGET/.claude/skills"
    mkdir -p "$TARGET/_bmad/meta-system/export-tools"
    mkdir -p "$TARGET/_bmad/_config/agents"
    mkdir -p "$TARGET/_bmad/meta-system/prompts"
    mkdir -p "$TARGET/_bmad/reports"

    # Copy meta-skills
    if [ -d "$temp_dir/.claude/skills" ]; then
        cp -r "$temp_dir/.claude/skills/"* "$TARGET/.claude/skills/"
        log_success "Meta-skills installed"
    else
        log_warn "Meta-skills directory not found in download"
    fi

    # Copy export tools
    if [ -d "$temp_dir/_bmad/meta-system/export-tools" ]; then
        cp -r "$temp_dir/_bmad/meta-system/export-tools/"* "$TARGET/_bmad/meta-system/export-tools/"
        chmod +x "$TARGET/_bmad/meta-system/export-tools/"*.sh
        log_success "Export tools installed"
    fi

    # Copy registry
    if [ -f "$temp_dir/_bmad/meta-system/registry.yaml" ]; then
        cp "$temp_dir/_bmad/meta-system/registry.yaml" "$TARGET/_bmad/meta-system/"
        log_success "Registry installed"
    fi

    # Copy documentation
    if [ -f "$temp_dir/_bmad/meta-system/README.md" ]; then
        cp "$temp_dir/_bmad/meta-system/README.md" "$TARGET/_bmad/meta-system/"
    fi

    # Create version file
    echo "$VERSION" > "$TARGET/.mas-version"
    log_success "Version file created: $VERSION"
}

install_minimal() {
    local temp_dir="$1"

    log_info "Installing minimal MAS (export tools only)"

    mkdir -p "$TARGET/_bmad/meta-system/export-tools"

    if [ -d "$temp_dir/_bmad/meta-system/export-tools" ]; then
        cp -r "$temp_dir/_bmad/meta-system/export-tools/"* "$TARGET/_bmad/meta-system/export-tools/"
        chmod +x "$TARGET/_bmad/meta-system/export-tools/"*.sh
        log_success "Export tools installed"
    fi

    echo "$VERSION" > "$TARGET/.mas-version"
}

install_skill_only() {
    local temp_dir="$1"

    log_info "Installing meta-skills only"

    mkdir -p "$TARGET/.claude/skills"

    if [ -d "$temp_dir/.claude/skills" ]; then
        cp -r "$temp_dir/.claude/skills/"* "$TARGET/.claude/skills/"
        log_success "Meta-skills installed"
    fi

    echo "$VERSION" > "$TARGET/.mas-version"
}

# Generate installation guide
generate_guide() {
    cat > "$TARGET/MAS-INSTALL-README.md" << EOF
# MAS Installation Complete

## What was installed
- **Version:** $VERSION
- **Mode:** $MODE
- **Target:** $TARGET
- **Repository:** $REPO
- **Timestamp:** $(date)

## Quick Start

### 1. Validate
\`\`\`bash
./_bmad/meta-system/export-tools/validate-system.sh
\`\`\`

### 2. Create your first skill
\`\`\`bash
"Create a skill named my-skill for testing"
\`\`\`

### 3. Validate your skill
\`\`\`bash
"Use meta-system-validator to check my-skill"
\`\`\`

### 4. Update MAS
\`\`\`bash
./_bmad/meta-system/export-tools/updater.sh
\`\`\`

## What's included

### Meta Skills (4)
- meta-skill-creator
- meta-agent-factory
- meta-prompt-generator
- meta-system-validator

### Export Tools (4)
- install-from-marketplace.sh
- validate-system.sh
- export-system.sh
- export-skill.sh

## Next Steps

1. Read: \`_bmad/meta-system/README.md\`
2. Try: Create a skill for your project
3. Share: Use publisher.sh to share with team

## Troubleshooting

If validation fails:
\`\`\`bash
./_bmad/meta-system/export-tools/validate-system.sh --quick
\`\`\`

---
*MAS Installer v1.0.0*
EOF

    log_success "Installation guide created: MAS-INSTALL-README.md"
}

# Run validation
run_validation() {
    if [ -f "$TARGET/_bmad/meta-system/export-tools/validate-system.sh" ]; then
        log_info "Running validation..."

        if "$TARGET/_bmad/meta-system/export-tools/validate-system.sh" --quick > /tmp/mas-validation.log 2>&1; then
            log_success "Validation passed!"
            return 0
        else
            log_warn "Validation found some issues (check $TARGET/MAS-INSTALL-README.md)"
            return 1
        fi
    else
        log_warn "Validation script not found, skipping"
    fi
}

# Main execution
main() {
    # Parse arguments
    parse_args "$@"

    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║  MAS Universal Installer v1.0.0                           ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
    fi

    # Check prerequisites
    check_prereqs

    # Resolve target
    resolve_target

    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    log_verbose "Using temp directory: $TEMP_DIR"

    # Download
    if ! download_from_github "$REPO" "$VERSION" "$TEMP_DIR"; then
        log_error "Download failed"
        exit 1
    fi

    # Install
    install "$TEMP_DIR"

    # Generate guide
    generate_guide

    # Validate
    run_validation

    # Summary
    if [ "$QUIET" = false ]; then
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  Installation Complete!                                    ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "Target: ${CYAN}$TARGET${NC}"
        echo -e "Version: ${CYAN}$VERSION${NC}"
        echo -e "Mode: ${CYAN}$MODE${NC}"
        echo ""
        echo -e "Next: Read ${CYAN}$TARGET/MAS-INSTALL-README.md${NC}"
        echo ""
    fi
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi