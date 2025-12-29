#!/bin/bash
#
# MAS Publisher
# Publish skills to marketplace or share with team
#
# Usage:
#   ./publisher.sh --prepare my-skill
#   ./publisher.sh --submit my-skill
#   ./publisher.sh --local my-skill /shared/marketplace
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
MODE="prepare"
SKILL_NAME=""
TARGET_DIR=""
REPO="mas-marketplace/mas-core"
GITHUB_TOKEN=""
TEMP_DIR=""

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --prepare)
                MODE="prepare"
                SKILL_NAME="$2"
                shift 2
                ;;
            --submit)
                MODE="submit"
                SKILL_NAME="$2"
                shift 2
                ;;
            --local)
                MODE="local"
                SKILL_NAME="$2"
                TARGET_DIR="$3"
                shift 3
                ;;
            --publish)
                MODE="publish"
                SKILL_NAME="$2"
                shift 2
                ;;
            --repo)
                REPO="$2"
                shift 2
                ;;
            --token)
                GITHUB_TOKEN="$2"
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
MAS Publisher v1.0.0

Usage:
  # Prepare skill for publication
  ./publisher.sh --prepare my-skill

  # Submit to GitHub marketplace (creates PR)
  ./publisher.sh --submit my-skill

  # Publish to local/shared marketplace
  ./publisher.sh --local my-skill /shared/marketplace

  # Direct publish (requires token)
  ./publisher.sh --publish my-skill --token <github-token>

Options:
  --prepare <skill>    Validate and package skill
  --submit <skill>     Submit PR to marketplace
  --local <skill> <dir>  Publish to local directory
  --publish <skill>    Direct publish (needs --token)
  --repo <org/repo>    Target repository
  --token <token>      GitHub token for authentication
  --help               Show this help

Examples:
  # Prepare skill
  ./publisher.sh --prepare data-validator

  # Submit to marketplace
  ./publisher.sh --submit data-validator

  # Share with team
  ./publisher.sh --local data-validator /shared/marketplace

  # Direct publish
  ./publisher.sh --publish data-validator --token ghp_xxx

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

# Validate skill structure
validate_skill() {
    local skill_path="$1"

    log_info "Validating skill: $SKILL_NAME"

    if [ ! -d "$skill_path" ]; then
        log_error "Skill directory not found: $skill_path"
        return 1
    fi

    local errors=0
    local warnings=0

    # Check SKILL.md
    if [ ! -f "$skill_path/SKILL.md" ]; then
        log_error "Missing SKILL.md"
        errors=$((errors + 1))
    else
        local content=$(cat "$skill_path/SKILL.md")

        # Check required sections
        if ! echo "$content" | grep -q "^# "; then
            log_error "SKILL.md missing header"
            errors=$((errors + 1))
        fi

        if ! echo "$content" | grep -q "## Overview"; then
            log_warn "Missing ## Overview section"
            warnings=$((warnings + 1))
        fi

        if ! echo "$content" | grep -q "## Purpose"; then
            log_error "Missing ## Purpose section"
            errors=$((errors + 1))
        fi

        if ! echo "$content" | grep -q "## Capabilities"; then
            log_warn "Missing ## Capabilities section"
            warnings=$((warnings + 1))
        fi

        # Check for forbidden patterns
        if echo "$content" | grep -qE "<[^>]+>"; then
            log_warn "Contains HTML tags (avoid these)"
            warnings=$((warnings + 1))
        fi

        if echo "$content" | grep -qE "http://"; then
            log_warn "Contains http:// links (use https://)"
            warnings=$((warnings + 1))
        fi
    fi

    # Check directory structure
    for dir in scripts references assets; do
        if [ -d "$skill_path/$dir" ]; then
            log_success "  ✓ $dir/ exists"
        else
            log_warn "  ⚠ $dir/ missing (optional)"
            warnings=$((warnings + 1))
        fi
    done

    # Check for executable scripts
    if [ -d "$skill_path/scripts" ]; then
        for script in "$skill_path/scripts"/*; do
            if [ -f "$script" ] && [[ "$script" == *.sh || "$script" == *.py ]]; then
                if [ ! -x "$script" ]; then
                    log_warn "  ⚠ $(basename "$script") not executable"
                    warnings=$((warnings + 1))
                fi
            fi
        done
    fi

    # Check for absolute paths
    if grep -r "/" "$skill_path/SKILL.md" 2>/dev/null | grep -qE "^/"; then
        log_error "Contains absolute paths"
        errors=$((errors + 1))
    fi

    # Check file sizes
    local skill_size=$(du -sh "$skill_path" | cut -f1)
    log_info "  Skill size: $skill_size"

    # Summary
    echo ""
    if [ $errors -eq 0 ]; then
        log_success "Validation passed ($warnings warnings)"
        return 0
    else
        log_error "Validation failed ($errors errors, $warnings warnings)"
        return 1
    fi
}

# Prepare skill package
prepare_skill() {
    local skill_path="$1"
    local package_dir="$2"

    log_info "Preparing skill package..."

    # Create package structure
    mkdir -p "$package_dir"

    # Copy skill files
    cp -r "$skill_path"/* "$package_dir/"

    # Generate metadata
    local version="1.0.0"
    if [ -f "$skill_path/SKILL.md" ]; then
        version=$(grep "^## Version" "$skill_path/SKILL.md" | awk '{print $2}' | head -1)
        if [ -z "$version" ]; then
            version="1.0.0"
        fi
    fi

    # Get description
    local description=$(grep -A 5 "## Overview" "$skill_path/SKILL.md" | grep -v "## Overview" | head -3 | tr '\n' ' ' | sed 's/^[ \t]*//')

    # Get tags
    local tags="[]"
    if grep -q "## Tags" "$skill_path/SKILL.md"; then
        tags=$(grep -A 1 "## Tags" "$skill_path/SKILL.md" | grep -v "## Tags" | sed 's/^[ \t]*//' | tr -d '\n')
    fi

    # Get dependencies
    local dependencies="[]"
    if grep -q "## Dependencies" "$skill_path/SKILL.md"; then
        dependencies=$(grep -A 10 "## Dependencies" "$skill_path/SKILL.md" | grep -v "## Dependencies" | grep -E "^-" | sed 's/^- //' | tr '\n' ',' | sed 's/,$//')
        dependencies="[$dependencies]"
    fi

    # Create metadata file
    cat > "$package_dir/.meta.json" << EOF
{
  "name": "$SKILL_NAME",
  "version": "$version",
  "description": "$description",
  "tags": $tags,
  "dependencies": $dependencies,
  "author": "$(git config user.name 2>/dev/null || echo "Unknown")",
  "created": "$(date -Iseconds)",
  "validation_status": "pending",
  "package_size": "$skill_size"
}
EOF

    log_success "Package created at: $package_dir"
    log_success "Metadata: $package_dir/.meta.json"
}

# Submit to GitHub (creates PR)
submit_to_github() {
    local skill_path="$1"

    log_info "Submitting to GitHub: $REPO"

    # Check for git
    if ! command -v git &> /dev/null; then
        log_error "git required for submission"
        exit 1
    fi

    # Check for GitHub CLI (optional)
    if command -v gh &> /dev/null; then
        log_info "Using GitHub CLI"
        submit_with_gh "$skill_path"
    else
        log_warn "GitHub CLI not found, using manual process"
        submit_manual "$skill_path"
    fi
}

submit_with_gh() {
    local skill_path="$1"

    # Create temporary branch
    local branch="submit/$SKILL_NAME-$(date +%s)"

    # Clone or fork
    log_info "Cloning repository..."
    local temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    gh repo clone "$REPO" "$temp_dir" -- --depth 1

    # Create branch
    cd "$temp_dir"
    git checkout -b "$branch"

    # Copy skill
    mkdir -p "skills/$SKILL_NAME"
    cp -r "$skill_path"/* "skills/$SKILL_NAME/"

    # Update registry
    if [ -f "registry.json" ]; then
        # Add to registry (would need jq or manual editing)
        log_warn "Registry update requires manual review"
    fi

    # Commit
    git add "skills/$SKILL_NAME/"
    git commit -m "feat: submit $SKILL_NAME

- Version: $(grep -A 1 "## Version" "$skill_path/SKILL.md" | tail -1)
- Description: $(grep -A 5 "## Overview" "$skill_path/SKILL.md" | grep -v "## Overview" | head -1)
- Author: $(git config user.name)

🤖 Generated with MAS Publisher"

    # Push
    git push origin "$branch"

    # Create PR
    gh pr create \
        --title "Submit $SKILL_NAME to marketplace" \
        --body "This PR submits a new skill to MAS Marketplace.

## Skill Details
- Name: $SKILL_NAME
- Version: $(grep -A 1 "## Version" "$skill_path/SKILL.md" | tail -1)
- Description: $(grep -A 5 "## Overview" "$skill_path/SKILL.md" | grep -v "## Overview" | head -1)

## Validation
- [ ] Structure validated
- [ ] Tests pass
- [ ] Documentation complete

🤖 This PR was created by MAS Publisher" \
        --base main \
        --head "$branch"

    log_success "PR created! Check: https://github.com/$REPO/pulls"
}

submit_manual() {
    local skill_path="$1"

    log_info "Manual submission steps:"
    echo ""
    echo "1. Fork $REPO"
    echo "2. Clone your fork: git clone https://github.com/YOURUSER/mas-marketplace.git"
    echo "3. Create branch: git checkout -b submit/$SKILL_NAME"
    echo "4. Copy skill: cp -r $skill_path/* mas-marketplace/skills/$SKILL_NAME/"
    echo "5. Update registry.json (add skill entry)"
    echo "6. Commit: git commit -m 'Submit $SKILL_NAME'"
    echo "7. Push: git push origin submit/$SKILL_NAME"
    echo "8. Create PR: https://github.com/$REPO/compare"
    echo ""
    log_info "Or use GitHub Desktop for easier process"
}

# Publish to local directory
publish_local() {
    local skill_path="$1"
    local target="$2"

    log_info "Publishing to local marketplace: $target"

    if [ ! -d "$target" ]; then
        mkdir -p "$target"
    fi

    # Create marketplace structure
    mkdir -p "$target/skills"
    mkdir -p "$target/validation"

    # Copy skill
    cp -r "$skill_path" "$target/skills/"

    # Generate metadata
    local meta_file="$target/skills/$SKILL_NAME/.meta.json"
    if [ ! -f "$meta_file" ]; then
        cat > "$meta_file" << EOF
{
  "name": "$SKILL_NAME",
  "version": "1.0.0",
  "local": true,
  "published": "$(date -Iseconds)"
}
EOF
    fi

    # Update local registry
    local registry="$target/registry.json"
    if [ ! -f "$registry" ]; then
        echo '{"skills": []}' > "$registry"
    fi

    # Add to registry (requires jq or manual)
    log_warn "Add to $registry manually or install jq"

    log_success "Skill published to: $target/skills/$SKILL_NAME"
    log_success "Team can install: ./install-from-marketplace.sh --local $target $SKILL_NAME"
}

# Direct publish (with token)
publish_direct() {
    local skill_path="$1"

    if [ -z "$GITHUB_TOKEN" ]; then
        log_error "GitHub token required for direct publish"
        exit 1
    fi

    log_info "Direct publishing to $REPO..."

    # This would use GitHub API to:
    # 1. Create branch
    # 2. Upload files
    # 3. Update registry
    # 4. Merge (if permissions allow)

    log_warn "Direct publish requires GitHub API implementation"
    log_info "Use --submit for safer PR-based workflow"

    # Example API call (would need curl with token)
    # curl -H "Authorization: token $GITHUB_TOKEN" \
    #      -H "Content-Type: application/json" \
    #      -d '{"message":"Submit skill","content":"..."}' \
    #      "https://api.github.com/repos/$REPO/contents/skills/$SKILL_NAME"
}

# Main execution
main() {
    parse_args "$@"

    if [ -z "$SKILL_NAME" ]; then
        log_error "Skill name required"
        show_help
        exit 1
    fi

    # Resolve skill path
    local skill_path=".claude/skills/$SKILL_NAME"
    if [ ! -d "$skill_path" ]; then
        # Try current directory
        if [ -d "$SKILL_NAME" ]; then
            skill_path="$SKILL_NAME"
        else
            log_error "Skill not found: $SKILL_NAME"
            log_error "Checked: .claude/skills/$SKILL_NAME and $SKILL_NAME"
            exit 1
        fi
    fi

    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  MAS Publisher v1.0.0                                      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    case "$MODE" in
        "prepare")
            if validate_skill "$skill_path"; then
                TEMP_DIR=$(mktemp -d)
                prepare_skill "$skill_path" "$TEMP_DIR/$SKILL_NAME"
                log_info "Package ready at: $TEMP_DIR/$SKILL_NAME"
                log_info "Next: ./publisher.sh --submit $SKILL_NAME"
            else
                exit 1
            fi
            ;;

        "submit")
            if validate_skill "$skill_path"; then
                submit_to_github "$skill_path"
            else
                exit 1
            fi
            ;;

        "local")
            if [ -z "$TARGET_DIR" ]; then
                log_error "Target directory required for --local"
                exit 1
            fi
            if validate_skill "$skill_path"; then
                publish_local "$skill_path" "$TARGET_DIR"
            else
                exit 1
            fi
            ;;

        "publish")
            if validate_skill "$skill_path"; then
                publish_direct "$skill_path"
            else
                exit 1
            fi
            ;;
    esac

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  Complete!                                                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi