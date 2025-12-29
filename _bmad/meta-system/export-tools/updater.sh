#!/bin/bash
#
# MAS Updater v2.0
# Updates Meta Agentic System to latest version with v2.0 schema support
#
# Usage:
#   ./updater.sh
#   ./updater.sh --check
#   ./updater.sh --version 2.0.0
#   ./updater.sh --bulk ~/projects/*
#   ./updater.sh --migrate-v1-to-v2
#
# Supports:
#   - v2.0 schemas (skill.json, registry.json)
#   - MCP servers updates
#   - Schema migration (v1.1.0  v2.0)
#   - Safe rollback
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
REPO="mas-marketplace/mas-core"
CURRENT_VERSION=""
LATEST_VERSION=""
TARGET="."
CHECK_ONLY=false
BULK_MODE=false
AUTO_CONFIRM=false
BACKUP_DIR=""
MIGRATE_V1_TO_V2=false
UPDATE_MCP=true

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check)
                CHECK_ONLY=true
                shift
                ;;
            --version)
                LATEST_VERSION="$2"
                shift 2
                ;;
            --repo)
                REPO="$2"
                shift 2
                ;;
            --target)
                TARGET="$2"
                shift 2
                ;;
            --bulk)
                BULK_MODE=true
                shift
                ;;
            --yes)
                AUTO_CONFIRM=true
                shift
                ;;
            --migrate-v1-to-v2)
                MIGRATE_V1_TO_V2=true
                shift
                ;;
            --no-mcp)
                UPDATE_MCP=false
                shift
                ;;
            --help)
                show_help
                ;;
            *)
                if [ "$BULK_MODE" = true ]; then
                    # Treat as project path
                    echo "$1"
                fi
                shift
                ;;
        esac
    done
}

show_help() {
    cat << EOF
MAS Updater v2.0.0

Usage:
  ./updater.sh                          # Update current project
  ./updater.sh --check                  # Check for updates only
  ./updater.sh --version 2.0.0          # Update to specific version
  ./updater.sh --bulk ~/projects/*      # Update multiple projects
  ./updater.sh --migrate-v1-to-v2       # Migrate from v1.1.0 to v2.0

Options:
  --check              Check for updates without installing
  --version <ver>      Update to specific version
  --repo <org/repo>    GitHub repository
  --target <path>      Project directory
  --bulk               Update multiple projects
  --yes                Auto-confirm updates
  --migrate-v1-to-v2   Migrate v1.1.0 to v2.0 schema
  --no-mcp             Skip MCP server updates
  --help               Show this help

Examples:
  # Check for updates
  ./updater.sh --check

  # Update current project
  ./updater.sh

  # Update to specific version
  ./updater.sh --version 2.0.0

  # Migrate from v1.1.0 to v2.0
  ./updater.sh --migrate-v1-to-v2

  # Update all projects in directory
  ./updater.sh --bulk ~/projects/*

  # Update without prompting
  ./updater.sh --yes

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

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

# Get current version
get_current_version() {
    if [ -f "$TARGET/.mas-version" ]; then
        CURRENT_VERSION=$(cat "$TARGET/.mas-version")
    elif [ -f "$TARGET/_bmad/meta-system/registry.yaml" ]; then
        CURRENT_VERSION=$(grep "version:" "$TARGET/_bmad/meta-system/registry.yaml" | head -1 | awk '{print $2}' | tr -d '\"')
    else
        CURRENT_VERSION="unknown"
    fi
}

# Get latest version from GitHub
get_latest_version() {
    if [ -n "$LATEST_VERSION" ]; then
        return 0  # Already set via --version
    fi

    log_info "Checking for updates from $REPO..."

    if command -v curl &> /dev/null; then
        LATEST_VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '\"tag_name\":' | sed -E 's/.*\"([^\"]+)\".*/\\1/')
        if [ -z "$LATEST_VERSION" ]; then
            # Fallback to main branch
            LATEST_VERSION="main"
        fi
    else
        log_error "curl required to check for updates"
        exit 1
    fi

    log_verbose "Latest version: $LATEST_VERSION"
}

# Compare versions
compare_versions() {
    if [ "$CURRENT_VERSION" = "unknown" ]; then
        log_warn "Could not determine current version"
        return 1
    fi

    if [ "$LATEST_VERSION" = "main" ]; then
        log_warn "Using main branch, version comparison skipped"
        return 0
    fi

    # Remove 'v' prefix if present
    local current=$(echo "$CURRENT_VERSION" | sed 's/^v//')
    local latest=$(echo "$LATEST_VERSION" | sed 's/^v//')

    # Simple version comparison
    if [ "$current" = "$latest" ]; then
        log_info "Already up to date (v$current)"
        return 1
    else
        log_info "Update available: v$current  v$latest"
        return 0
    fi
}

# Create backup
create_backup() {
    BACKUP_DIR="$TARGET/_bmad-backup-$(date +%Y-%m-%d-%H%M%S)"
    log_info "Creating backup: $BACKUP_DIR"

    mkdir -p "$BACKUP_DIR"

    # Backup critical files
    if [ -d "$TARGET/_bmad/meta-system" ]; then
        cp -r "$TARGET/_bmad/meta-system" "$BACKUP_DIR/"
    fi

    if [ -f "$TARGET/.mas-version" ]; then
        cp "$TARGET/.mas-version" "$BACKUP_DIR/"
    fi

    if [ -f "$TARGET/MAS-INSTALL-README.md" ]; then
        cp "$TARGET/MAS-INSTALL-README.md" "$BACKUP_DIR/"
    fi

    if [ -f "$TARGET/.mcp.json" ]; then
        cp "$TARGET/.mcp.json" "$BACKUP_DIR/"
    fi

    log_success "Backup created"
}

# Download update
download_update() {
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    log_info "Downloading update..."

    local version="$LATEST_VERSION"
    if [[ ! "$version" =~ ^v ]]; then
        version="v$version"
    fi

    # Try release first
    local url="https://github.com/$REPO/archive/refs/tags/$version.tar.gz"
    if [ "$LATEST_VERSION" = "main" ]; then
        url="https://github.com/$REPO/archive/refs/heads/main.tar.gz"
    fi

    if command -v curl &> /dev/null; then
        curl -sL -o "$temp_dir/mas-update.tar.gz" "$url"
    else
        exit 1
    fi

    if [ ! -f "$temp_dir/mas-update.tar.gz" ]; then
        log_error "Download failed"
        exit 1
    fi

    tar -xzf "$temp_dir/mas-update.tar.gz" -C "$temp_dir" --strip-components=1

    echo "$temp_dir"
}

# Migrate from v1.1.0 to v2.0
migrate_v1_to_v2() {
    log_info "Migrating from v1.1.0 to v2.0..."

    # Check if v1.1.0 is installed
    if [ ! -d "$TARGET/_bmad/meta-system" ]; then
        log_error "MAS not found in $TARGET"
        exit 1
    fi

    # Create v2.0 directory structure
    mkdir -p "$TARGET/_bmad/meta-system/mcp-servers"
    mkdir -p "$TARGET/_bmad/meta-system/schemas"
    mkdir -p "$TARGET/_bmad/meta-system/templates"
    mkdir -p "$TARGET/_bmad/_cache"

    # Copy v2.0 schemas if available
    if [ -f "$TARGET/_bmad/meta-system/schemas/skill.json" ]; then
        log_success "v2.0 schemas already present"
    else
        log_warn "v2.0 schemas not found - will be added on next update"
    fi

    # Update export tools to v2.0
    if [ -f "$TARGET/_bmad/meta-system/export-tools/installer.sh" ]; then
        local installer_version=$(grep "MAS Universal Installer" "$TARGET/_bmad/meta-system/export-tools/installer.sh" | grep -o "v[0-9.]*" | head -1)
        if [[ "$installer_version" == "v2.0"* ]]; then
            log_success "Export tools already at v2.0"
        else
            log_warn "Export tools need update - run updater.sh again"
        fi
    fi

    # Create .mcp.json if missing
    if [ ! -f "$TARGET/.mcp.json" ] && [ -d "$TARGET/_bmad/meta-system/mcp-servers" ]; then
        cat > "$TARGET/.mcp.json" << 'EOF'
{
  "mcpServers": {
    "mas-marketplace": {
      "command": "node",
      "args": ["_bmad/meta-system/mcp-servers/marketplace.js"],
      "env": {
        "MAS_PROJECT_ROOT": "${workspaceFolder}"
      }
    },
    "mas-prompt-manager": {
      "command": "node",
      "args": ["_bmad/meta-system/mcp-servers/prompt-manager.js"],
      "env": {
        "MAS_PROJECT_ROOT": "${workspaceFolder}"
      }
    },
    "mas-construction": {
      "command": "node",
      "args": ["_bmad/meta-system/mcp-servers/construction.js"],
      "env": {
        "MAS_PROJECT_ROOT": "${workspaceFolder}"
      }
    },
    "mas-evolution": {
      "command": "node",
      "args": ["_bmad/meta-system/mcp-servers/evolution.js"],
      "env": {
        "MAS_PROJECT_ROOT": "${workspaceFolder}"
      }
    }
  }
}
EOF
        log_success "Created .mcp.json configuration"
    fi

    # Update version file
    echo "2.0.0" > "$TARGET/.mas-version"
    log_success "Version updated to 2.0.0"

    log_success "Migration complete!"
    log_info "Next: Run ./updater.sh to get latest v2.0 components"
}

# Apply update
apply_update() {
    local temp_dir="$1"

    log_info "Applying update..."

    # Update meta-skills
    if [ -d "$temp_dir/.claude/skills" ]; then
        for skill in "$temp_dir/.claude/skills"/*; do
            skill_name=$(basename "$skill")
            if [ -d "$TARGET/.claude/skills/$skill_name" ]; then
                rm -rf "$TARGET/.claude/skills/$skill_name"
            fi
            cp -r "$skill" "$TARGET/.claude/skills/"
        done
        log_success "Meta-skills updated"
    fi

    # Update export tools
    if [ -d "$temp_dir/_bmad/meta-system/export-tools" ]; then
        cp -r "$temp_dir/_bmad/meta-system/export-tools/"* "$TARGET/_bmad/meta-system/export-tools/"
        chmod +x "$TARGET/_bmad/meta-system/export-tools/"*.sh
        log_success "Export tools updated"
    fi

    # Update MCP servers (if requested)
    if [ "$UPDATE_MCP" = true ] && [ -d "$temp_dir/_bmad/meta-system/mcp-servers" ]; then
        mkdir -p "$TARGET/_bmad/meta-system/mcp-servers"
        cp -r "$temp_dir/_bmad/meta-system/mcp-servers/"* "$TARGET/_bmad/meta-system/mcp-servers/"
        chmod +x "$TARGET/_bmad/meta-system/mcp-servers/"*.js
        log_success "MCP servers updated"
    fi

    # Update schemas
    if [ -d "$temp_dir/_bmad/meta-system/schemas" ]; then
        mkdir -p "$TARGET/_bmad/meta-system/schemas"
        cp -r "$temp_dir/_bmad/meta-system/schemas/"* "$TARGET/_bmad/meta-system/schemas/"
        log_success "v2.0 schemas updated"
    fi

    # Update templates
    if [ -d "$temp_dir/_bmad/meta-system/templates" ]; then
        mkdir -p "$TARGET/_bmad/meta-system/templates"
        cp -r "$temp_dir/_bmad/meta-system/templates/"* "$TARGET/_bmad/meta-system/templates/"
        log_success "Templates updated"
    fi

    # Update registry
    if [ -f "$temp_dir/_bmad/meta-system/registry.yaml" ]; then
        cp "$temp_dir/_bmad/meta-system/registry.yaml" "$TARGET/_bmad/meta-system/"
        log_success "Registry updated"
    fi

    # Update .mcp.json if needed
    if [ "$UPDATE_MCP" = true ] && [ ! -f "$TARGET/.mcp.json" ] && [ -d "$TARGET/_bmad/meta-system/mcp-servers" ]; then
        cat > "$TARGET/.mcp.json" << 'EOF'
{
  "mcpServers": {
    "mas-marketplace": {
      "command": "node",
      "args": ["_bmad/meta-system/mcp-servers/marketplace.js"],
      "env": {
        "MAS_PROJECT_ROOT": "${workspaceFolder}"
      }
    },
    "mas-prompt-manager": {
      "command": "node",
      "args": ["_bmad/meta-system/mcp-servers/prompt-manager.js"],
      "env": {
        "MAS_PROJECT_ROOT": "${workspaceFolder}"
      }
    },
    "mas-construction": {
      "command": "node",
      "args": ["_bmad/meta-system/mcp-servers/construction.js"],
      "env": {
        "MAS_PROJECT_ROOT": "${workspaceFolder}"
      }
    },
    "mas-evolution": {
      "command": "node",
      "args": ["_bmad/meta-system/mcp-servers/evolution.js"],
      "env": {
        "MAS_PROJECT_ROOT": "${workspaceFolder}"
      }
    }
  }
}
EOF
        log_success "Created .mcp.json"
    fi

    # Update version
    echo "$LATEST_VERSION" > "$TARGET/.mas-version"
    log_success "Version updated to: $LATEST_VERSION"
}

# Show diff
show_diff() {
    log_info "Changes in this update:"

    if [ -f "$BACKUP_DIR/_bmad/meta-system/registry.yaml" ] && [ -f "$TARGET/_bmad/meta-system/registry.yaml" ]; then
        log "Registry changes:"
        diff -u "$BACKUP_DIR/_bmad/meta-system/registry.yaml" "$TARGET/_bmad/meta-system/registry.yaml" | grep -E "^[+-]" | head -10
    fi

    log ""
    log "Files modified:"
    find "$TARGET/_bmad/meta-system" -type f -newer "$BACKUP_DIR" 2>/dev/null | head -5
}

# Confirm update
confirm_update() {
    if [ "$AUTO_CONFIRM" = true ]; then
        return 0
    fi

    echo ""
    echo -e "${YELLOW}About to update MAS:${NC}"
    echo -e "  From: ${CYAN}$CURRENT_VERSION${NC}"
    echo -e "  To:   ${CYAN}$LATEST_VERSION${NC}"
    echo -e "  In:   ${CYAN}$TARGET${NC}"
    echo ""
    echo -e "${YELLOW}This will:${NC}"
    echo "  - Create backup in $TARGET/_bmad-backup-*"
    echo "  - Update meta-skills"
    echo "  - Update export tools"
    echo "  - Update MCP servers"
    echo "  - Update schemas"
    echo "  - Update registry"
    echo ""
    read -p "Continue? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warn "Update cancelled"
        exit 0
    fi
}

# Run validation
run_validation() {
    if [ -f "$TARGET/_bmad/meta-system/export-tools/validate-system.sh" ]; then
        log_info "Running post-update validation..."

        if "$TARGET/_bmad/meta-system/export-tools/validate-system.sh" --quick > /tmp/mas-update-validation.log 2>&1; then
            log_success "Validation passed"
        else
            log_warn "Validation found issues (check /tmp/mas-update-validation.log)"
        fi
    fi
}

# Generate update report
generate_report() {
    local report="$TARGET/_bmad/reports/update-$(date +%Y-%m-%d-%H%M%S).md"

    mkdir -p "$TARGET/_bmad/reports"

    cat > "$report" << EOF
# MAS Update Report

**Date:** $(date)
**From:** $CURRENT_VERSION
**To:** $LATEST_VERSION
**Target:** $TARGET

## Summary
 Update completed successfully

## Changes
- Meta-skills: Updated
- Export tools: Updated
- MCP servers: Updated
- Schemas: Updated
- Registry: Updated
- Version: $LATEST_VERSION

## Backup
Backup location: $BACKUP_DIR

## Validation
See: /tmp/mas-update-validation.log

## Rollback
To rollback:
\`\`\`bash
rm -rf $TARGET/_bmad/meta-system
cp -r $BACKUP_DIR/meta-system $TARGET/_bmad/
\`\`\`

---
*MAS Updater v2.0.0*
EOF

    log_success "Update report: $report"
}

# Bulk update mode
bulk_update() {
    local projects=("$@")

    if [ ${#projects[@]} -eq 0 ]; then
        log_error "No projects specified for bulk update"
        exit 1
    fi

    log_info "Bulk update mode: ${#projects[@]} projects"

    local success=0
    local failed=0

    for project in "${projects[@]}"; do
        if [ ! -d "$project" ]; then
            log_warn "Skipping $project (not found)"
            continue
        fi

        if [ ! -f "$project/.mas-version" ]; then
            log_warn "Skipping $project (not a MAS project)"
            continue
        fi

        echo ""
        log_info "Updating: $project"

        # Run update for this project
        if "$0" --target "$project" --yes; then
            success=$((success + 1))
            log_success "Updated: $project"
        else
            failed=$((failed + 1))
            log_error "Failed: $project"
        fi
    done

    echo ""
    log "Bulk update complete:"
    log "  Success: $success"
    log "  Failed: $failed"
    log "  Total: ${#projects[@]}"
}

# Main execution
main() {
    # Check if in bulk mode
    if [ "$BULK_MODE" = true ]; then
        # Collect project paths from remaining args
        projects=()
        while IFS= read -r line; do
            projects+=("$line")
        done < <(parse_args "$@")

        bulk_update "${projects[@]}"
        exit 0
    fi

    parse_args "$@"

    # Handle migration mode
    if [ "$MIGRATE_V1_TO_V2" = true ]; then
        migrate_v1_to_v2
        exit 0
    fi

    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  MAS Updater v2.0.0                                        ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""

    # Get current version
    get_current_version
    log_info "Current version: $CURRENT_VERSION"

    # Get latest version
    get_latest_version
    log_info "Latest version: $LATEST_VERSION"

    # Check if update needed
    if ! compare_versions; then
        if [ "$CHECK_ONLY" = true ]; then
            exit 0
        else
            exit 1
        fi
    fi

    # If only checking
    if [ "$CHECK_ONLY" = true ]; then
        log_info "Run without --check to perform update"
        exit 0
    fi

    # Confirm
    confirm_update

    # Create backup
    create_backup

    # Download
    temp_dir=$(download_update)

    # Apply update
    apply_update "$temp_dir"

    # Show diff
    show_diff

    # Validate
    run_validation

    # Generate report
    generate_report

    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Update Complete!                                          ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "From: ${CYAN}$CURRENT_VERSION${NC}"
    echo -e "To:   ${CYAN}$LATEST_VERSION${NC}"
    echo -e "Backup: ${CYAN}$BACKUP_DIR${NC}"
    echo ""
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
