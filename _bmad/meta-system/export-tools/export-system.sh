#!/bin/bash
#
# Meta Agentic System - Export Tool
# Copies entire MAS to another project
#
# Usage: ./export-system.sh /path/to/target/project
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -ne 1 ]; then
    echo -e "${RED}Usage: $0 /path/to/target/project${NC}"
    echo ""
    echo "Copies the entire Meta Agentic System to another project."
    echo ""
    echo "Example:"
    echo "  ./export-system.sh ~/my-new-project"
    exit 1
fi

TARGET_DIR="$1"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_ROOT="$(cd "$SOURCE_DIR/.." && pwd)"

# Validate source
echo -e "${YELLOW}Checking source system...${NC}"
if [ ! -d "$PROJECT_ROOT/.claude/skills" ]; then
    echo -e "${RED}Error: Source .claude/skills directory not found${NC}"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source meta-system directory not found${NC}"
    exit 1
fi

# Validate target
echo -e "${YELLOW}Checking target directory...${NC}"
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory does not exist${NC}"
    exit 1
fi

if [ ! -d "$TARGET_DIR/.claude" ] && [ ! -d "$TARGET_DIR/_bmad" ]; then
    echo -e "${YELLOW}Warning: Target doesn't look like a project directory${NC}"
    echo -e "${YELLOW}Continue anyway? (y/n)${NC}"
    read -r CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Confirm
echo ""
echo -e "${GREEN}Source: $PROJECT_ROOT${NC}"
echo -e "${GREEN}Target: $TARGET_DIR${NC}"
echo ""
echo -e "${YELLOW}This will copy:${NC}"
echo "  - .claude/skills/meta-* (meta skills)"
echo "  - _bmad/meta-system/ (system files)"
echo ""
echo -e "${YELLOW}Continue? (y/n)${NC}"
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Create target directories
echo ""
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/_bmad"

# Copy meta skills
echo -e "${YELLOW}Copying meta skills...${NC}"
for skill in "$PROJECT_ROOT/.claude/skills"/meta-*; do
    if [ -d "$skill" ]; then
        skill_name=$(basename "$skill")
        echo "  - $skill_name"
        cp -r "$skill" "$TARGET_DIR/.claude/skills/"
    fi
done

# Copy meta-system
echo -e "${YELLOW}Copying meta-system...${NC}"
cp -r "$SOURCE_DIR" "$TARGET_DIR/_bmad/"

# Copy README to root for easy access
echo -e "${YELLOW}Creating quick reference...${NC}"
cp "$SOURCE_DIR/README.md" "$TARGET_DIR/META_SYSTEM.md"

# Validate
echo ""
echo -e "${GREEN}✓ Export complete!${NC}"
echo ""
echo -e "${YELLOW}Verification:${NC}"
echo "  - Meta skills: $(ls -1 "$TARGET_DIR/.claude/skills"/meta-* 2>/dev/null | wc -l) found"
echo "  - System files: $(ls -1 "$TARGET_DIR/_bmad/meta-system" 2>/dev/null | wc -l) files"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Review: cat $TARGET_DIR/META_SYSTEM.md"
echo "  2. Test: Use a meta-skill in the new project"
echo "  3. Customize: Adapt for your needs"
echo ""
echo -e "${GREEN}✅ MAS successfully exported to $TARGET_DIR${NC}"
