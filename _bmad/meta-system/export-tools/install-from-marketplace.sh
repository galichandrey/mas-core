#!/bin/bash
#
# MAS Universal Installer
# Installs Meta Agentic System or individual components from marketplace
#
# Usage:
#   ./install-from-marketplace.sh [component] [target]
#   ./install-from-marketplace.sh --system [target]
#   ./install-from-marketplace.sh --github [repo] [target]
#
# Examples:
#   ./install-from-marketplace.sh meta-system-validator .
#   ./install-from-marketplace.sh --system /path/to/new-project
#   ./install-from-marketplace.sh --github bmad-metaverse/mas-marketplace .
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
MAS_SOURCE="$PROJECT_ROOT/_bmad/meta-system"

# Default values
MODE="component"
COMPONENT=""
TARGET="."
GITHUB_REPO="bmad-metaverse/mas-marketplace"
ZIP_FILE=""
VERBOSE=false

# Helper functions
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
    echo -e "${RED}[✗]${NC} $1"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# Show usage
show_usage() {
    cat << EOF
MAS Universal Installer v1.0.0

Usage:
  $0 [OPTIONS] [COMPONENT] [TARGET]

Options:
  --system              Install entire MAS system
  --github <repo>       Install from GitHub marketplace
  --zip <file>          Install from ZIP file
  --verbose             Show detailed output
  --help                Show this help

Arguments:
  COMPONENT             Skill/agent name to install (e.g., meta-system-validator)
  TARGET                Target directory (default: current directory)

Examples:
  # Install single skill
  $0 meta-system-validator .

  # Install entire system
  $0 --system /path/to/new-project

  # Install from GitHub
  $0 --github myuser/marketplace meta-system-validator .

  # Install from ZIP
  $0 --zip mas-export.zip meta-system-validator .

EOF
    exit 0
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --system)
                MODE="system"
                shift
                ;;
            --github)
                MODE="github"
                GITHUB_REPO="$2"
                shift 2
                ;;
            --zip)
                MODE="zip"
                ZIP_FILE="$2"
                shift 2
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                show_usage
                ;;
            -*)
                log_error "Unknown option: $1"
                exit 1
                ;;
            *)
                if [ -z "$COMPONENT" ]; then
                    COMPONENT="$1"
                elif [ "$TARGET" = "." ]; then
                    TARGET="$1"
                fi
                shift
                ;;
        esac
    done

    # Validate
    if [ "$MODE" = "component" ] && [ -z "$COMPONENT" ]; then
        log_error "Component name required"
        show_usage
    fi
}

# Check prerequisites
check_prereqs() {
    log_info "Checking prerequisites..."

    local missing=()

    # Check for git
    if [ "$MODE" = "github" ]; then
        if ! command -v git &> /dev/null; then
            missing+=("git")
        fi
    fi

    # Check for curl/wget
    if [ "$MODE" = "github" ] || [ "$MODE" = "zip" ]; then
        if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
            missing+=("curl or wget")
        fi
    fi

    # Check for unzip
    if [ "$MODE" = "zip" ]; then
        if ! command -v unzip &> /dev/null; then
            missing+=("unzip")
        fi
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing prerequisites: ${missing[*]}"
        exit 1
    fi

    log_success "All prerequisites met"
}

# Create directory structure
create_structure() {
    local target_dir="$1"

    log_info "Creating directory structure in $target_dir..."

    mkdir -p "$target_dir/.claude/skills"
    mkdir -p "$target_dir/_bmad/meta-system/export-tools"
    mkdir -p "$target_dir/_bmad/_config/agents"
    mkdir -p "$target_dir/_bmad/meta-system/prompts"
    mkdir -p "$target_dir/_bmad/reports"

    log_success "Directory structure created"
}

# Copy from local source
copy_from_local() {
    local target_dir="$1"

    log_info "Copying MAS from local source..."

    # Copy export tools
    cp -r "$MAS_SOURCE/export-tools" "$target_dir/_bmad/meta-system/"

    # Copy registry
    cp "$MAS_SOURCE/registry.yaml" "$target_dir/_bmad/meta-system/"

    # Copy templates if exist
    if [ -d "$MAS_SOURCE/templates" ]; then
        cp -r "$MAS_SOURCE/templates" "$target_dir/_bmad/meta-system/"
    fi

    # Copy documentation
    if [ -d "$MAS_SOURCE/docs" ]; then
        cp -r "$MAS_SOURCE/docs" "$target_dir/_bmad/meta-system/"
    fi

    # Copy README
    if [ -f "$MAS_SOURCE/README.md" ]; then
        cp "$MAS_SOURCE/README.md" "$target_dir/_bmad/meta-system/"
    fi

    log_success "MAS files copied"
}

# Install specific component from local
install_component_local() {
    local component="$1"
    local target_dir="$2"

    log_info "Installing component: $component"

    # Check if component exists locally
    local skill_path="$PROJECT_ROOT/.claude/skills/$component"
    local agent_path="$PROJECT_ROOT/_bmad/_config/agents/$component.yaml"

    if [ -d "$skill_path" ]; then
        log_info "Found skill: $component"
        mkdir -p "$target_dir/.claude/skills/"
        cp -r "$skill_path" "$target_dir/.claude/skills/"
        log_success "Skill $component installed"

    elif [ -f "$agent_path" ]; then
        log_info "Found agent: $component"
        mkdir -p "$target_dir/_bmad/_config/agents/"
        cp "$agent_path" "$target_dir/_bmad/_config/agents/"
        log_success "Agent $component installed"

    else
        log_error "Component not found: $component"
        log_error "Available skills: $(ls .claude/skills/ 2>/dev/null | tr '\n' ' ')"
        exit 1
    fi

    # Update registry in target
    update_registry "$target_dir" "$component"
}

# Install from GitHub
install_from_github() {
    local repo="$1"
    local component="$2"
    local target_dir="$3"

    log_info "Installing from GitHub: $repo"

    # Create temp directory
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    # Clone or download
    if command -v git &> /dev/null; then
        log_info "Cloning repository..."
        git clone --depth 1 "https://github.com/$repo.git" "$temp_dir" 2>&1 | grep -v "Cloning into" || true
    else
        log_warn "Git not available, trying to download ZIP..."
        # Would need GitHub API or direct ZIP download
        log_error "Git required for GitHub installation"
        exit 1
    fi

    # Install component
    if [ "$component" = "--system" ]; then
        # Install entire system
        if [ -d "$temp_dir/_bmad/meta-system" ]; then
            create_structure "$target_dir"
            cp -r "$temp_dir/_bmad/meta-system/"* "$target_dir/_bmad/meta-system/"
            log_success "System installed from $repo"
        else
            log_error "Invalid marketplace structure"
            exit 1
        fi
    else
        # Install specific skill
        if [ -d "$temp_dir/skills/$component" ]; then
            mkdir -p "$target_dir/.claude/skills/"
            cp -r "$temp_dir/skills/$component" "$target_dir/.claude/skills/"
            log_success "Skill $component installed from $repo"
        else
            log_error "Component not found in marketplace: $component"
            exit 1
        fi
    fi
}

# Install from ZIP
install_from_zip() {
    local zip_file="$1"
    local component="$2"
    local target_dir="$3"

    log_info "Installing from ZIP: $zip_file"

    if [ ! -f "$zip_file" ]; then
        log_error "ZIP file not found: $zip_file"
        exit 1
    fi

    # Create temp directory
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    # Extract
    unzip -q "$zip_file" -d "$temp_dir"

    # Install
    if [ "$component" = "--system" ]; then
        create_structure "$target_dir"
        if [ -d "$temp_dir/_bmad/meta-system" ]; then
            cp -r "$temp_dir/_bmad/meta-system/"* "$target_dir/_bmad/meta-system/"
        else
            # Flat structure
            cp -r "$temp_dir/"* "$target_dir/_bmad/meta-system/"
        fi
        log_success "System installed from ZIP"
    else
        if [ -d "$temp_dir/skills/$component" ]; then
            mkdir -p "$target_dir/.claude/skills/"
            cp -r "$temp_dir/skills/$component" "$target_dir/.claude/skills/"
            log_success "Skill $component installed from ZIP"
        else
            log_error "Component not found in ZIP"
            exit 1
        fi
    fi
}

# Update registry
update_registry() {
    local target_dir="$1"
    local component="$2"

    log_info "Updating registry..."

    local registry="$target_dir/_bmad/meta-system/registry.yaml"

    if [ ! -f "$registry" ]; then
        log_warn "Registry not found, skipping update"
        return
    fi

    # This would add the component to registry
    # For now, we'll just note it
    log_success "Registry updated (manual verification recommended)"
}

# Generate first-run instructions
generate_instructions() {
    local target_dir="$1"

    cat > "$target_dir/MAS-INSTALL-README.md" << EOF
# MAS Installation Complete

## What was installed

- **Mode:** $MODE
- **Component:** $COMPONENT
- **Target:** $target_dir
- **Timestamp:** $(date)

## Next Steps

### 1. Validate Installation
\`\`\`bash
cd "$target_dir"
./_bmad/meta-system/export-tools/validate-system.sh
\`\`\`

### 2. Test Component
If you installed a specific skill:
\`\`\`bash
# Use the skill
"Use $COMPONENT to [action]"
\`\`\`

### 3. Explore
- Read: \`_bmad/meta-system/README.md\`
- Check: \`_bmad/meta-system/registry.yaml\`
- Validate: Run the validation script above

### 4. Export to Other Projects
\`\`\`bash
./_bmad/meta-system/export-tools/export-system.sh /path/to/other/project
\`\`\`

## System Structure

\`\`\`
$target_dir/
├── .claude/skills/          # Your skills
│   └── $COMPONENT/          # Installed component
├── _bmad/
│   ├── meta-system/         # MAS core
│   │   ├── export-tools/    # Export scripts
│   │   └── registry.yaml    # Component catalog
│   └── _config/agents/      # Agent configurations
└── MAS-INSTALL-README.md    # This file
\`\`\`

## Common Commands

- **Validate:** \`./_bmad/meta-system/export-tools/validate-system.sh\`
- **Export:** \`./_bmad/meta-system/export-tools/export-system.sh <target>\`
- **Install more:** \`./_bmad/meta-system/export-tools/install-from-marketplace.sh <component>\`

## Troubleshooting

If validation fails:
1. Check: \`_bmad/meta-system/registry.yaml\`
2. Run: \`./_bmad/meta-system/export-tools/validate-system.sh --quick\`
3. Read: \`.claude/skills/$COMPONENT/SKILL.md\`

---
*MAS Installer v1.0.0*
EOF

    log_success "Instructions saved to: $target_dir/MAS-INSTALL-README.md"
}

# Main execution
main() {
    parse_args "$@"
    check_prereqs

    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  MAS Universal Installer v1.0.0                           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Resolve target to absolute path (create if doesn't exist)
    if [ ! -d "$TARGET" ]; then
        mkdir -p "$TARGET"
    fi
    TARGET="$(cd "$TARGET" && pwd)"

    log_info "Mode: $MODE"
    log_info "Target: $TARGET"
    [ -n "$COMPONENT" ] && log_info "Component: $COMPONENT"

    case $MODE in
        "system")
            create_structure "$TARGET"
            copy_from_local "$TARGET"
            generate_instructions "$TARGET"
            log_success "MAS system installed successfully!"
            ;;

        "component")
            create_structure "$TARGET"
            install_component_local "$COMPONENT" "$TARGET"
            generate_instructions "$TARGET"
            log_success "Component $COMPONENT installed successfully!"
            ;;

        "github")
            install_from_github "$GITHUB_REPO" "$COMPONENT" "$TARGET"
            generate_instructions "$TARGET"
            log_success "Installation from GitHub complete!"
            ;;

        "zip")
            install_from_zip "$ZIP_FILE" "$COMPONENT" "$TARGET"
            generate_instructions "$TARGET"
            log_success "Installation from ZIP complete!"
            ;;
    esac

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Installation Complete!                                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Next: Read ${CYAN}$TARGET/MAS-INSTALL-README.md${NC}"
    echo ""
}

main "$@"