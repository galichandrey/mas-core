#!/bin/bash
#
# Meta Agentic System - Single Skill Export Tool
# Copies a single skill to another project
#
# Usage: ./export-skill.sh skill-name /path/to/target/project
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check arguments
if [ $# -ne 2 ]; then
    echo -e "${RED}Usage: $0 skill-name /path/to/target/project${NC}"
    echo ""
    echo "Available skills:"
    ls -1 "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/../.claude/skills"/meta-* 2>/dev/null | xargs -n1 basename
    exit 1
fi

SKILL_NAME="$1"
TARGET_DIR="$2"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_ROOT="$(cd "$SOURCE_DIR/.." && pwd)"

# Check if skill exists
SKILL_PATH="$PROJECT_ROOT/.claude/skills/$SKILL_NAME"
if [ ! -d "$SKILL_PATH" ]; then
    echo -e "${RED}Error: Skill '$SKILL_NAME' not found${NC}"
    echo -e "${YELLOW}Available skills:${NC}"
    ls -1 "$PROJECT_ROOT/.claude/skills"/meta-* 2>/dev/null | xargs -n1 basename
    exit 1
fi

# Validate target
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target directory does not exist${NC}"
    exit 1
fi

# Confirm
echo -e "${GREEN}Skill: $SKILL_NAME${NC}"
echo -e "${GREEN}Source: $SKILL_PATH${NC}"
echo -e "${GREEN}Target: $TARGET_DIR/.claude/skills/${NC}"
echo ""
echo -e "${YELLOW}Copy this skill? (y/n)${NC}"
read -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Create target directory
mkdir -p "$TARGET_DIR/.claude/skills"

# Copy skill
echo -e "${YELLOW}Copying $SKILL_NAME...${NC}"
cp -r "$SKILL_PATH" "$TARGET_DIR/.claude/skills/"

# Validate
if [ -d "$TARGET_DIR/.claude/skills/$SKILL_NAME" ]; then
    echo -e "${GREEN}✓ Successfully copied $SKILL_NAME${NC}"
    echo ""
    echo -e "${YELLOW}Files copied:${NC}"
    find "$TARGET_DIR/.claude/skills/$SKILL_NAME" -type f | sed "s|$TARGET_DIR/||"
    echo ""
    echo -e "${GREEN}✅ Ready to use in $TARGET_DIR${NC}"
else
    echo -e "${RED}✗ Copy failed${NC}"
    exit 1
fi
