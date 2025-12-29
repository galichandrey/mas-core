#!/bin/bash
# Rollback Script Template
# Usage: Copy this file, rename with actual versions, and customize

set -e

SKILL_NAME="skill-name"
TARGET_VERSION="1.0.0"
BACKUP_DIR="./backup-${SKILL_NAME}-${TARGET_VERSION}"

echo "=========================================="
echo "Rollback: ${SKILL_NAME}"
echo "Target Version: v${TARGET_VERSION}"
echo "=========================================="
echo ""

# Step 1: Verify backup exists
echo "Step 1: Checking backup..."
if [ ! -d "${BACKUP_DIR}" ]; then
    echo "❌ Error: Backup not found at ${BACKUP_DIR}"
    echo ""
    echo "Available backups:"
    ls -la .meta-backups/ 2>/dev/null || echo "No backups directory"
    exit 1
fi
echo "✅ Backup found: ${BACKUP_DIR}"

# Step 2: Verify current skill
echo ""
echo "Step 2: Checking current skill..."
if [ ! -d ".claude/skills/${SKILL_NAME}" ]; then
    echo "⚠️  Warning: Current skill not found, will restore from backup"
else
    echo "✅ Current skill exists"
fi

# Step 3: Create pre-rollback backup
echo ""
echo "Step 3: Creating pre-rollback backup..."
PRE_ROLLBACK="./pre-rollback-${SKILL_NAME}-$(date +%Y%m%d-%H%M%S)"
if [ -d ".claude/skills/${SKILL_NAME}" ]; then
    mkdir -p "${PRE_ROLLBACK}"
    cp -r ".claude/skills/${SKILL_NAME}"/* "${PRE_ROLLBACK}/"
    echo "✅ Pre-rollback backup: ${PRE_ROLLBACK}"
else
    echo "⚠️  No current skill to backup"
fi

# Step 4: Execute rollback
echo ""
echo "Step 4: Executing rollback..."
rm -rf ".claude/skills/${SKILL_NAME}"
cp -r "${BACKUP_DIR}" ".claude/skills/${SKILL_NAME}"
echo "✅ Rollback complete"

# Step 5: Verify restoration
echo ""
echo "Step 5: Verifying restoration..."
if [ -f ".claude/skills/${SKILL_NAME}/SKILL.md" ]; then
    echo "✅ SKILL.md restored"

    # Extract version
    VERSION=$(grep "version:" ".claude/skills/${SKILL_NAME}/SKILL.md" | head -1 | awk '{print $2}' | tr -d '"')
    if [ ! -z "$VERSION" ]; then
        echo "✅ Version: ${VERSION}"
    fi
else
    echo "❌ SKILL.md not found after rollback"
    echo "Restoring from pre-rollback backup..."
    cp -r "${PRE_ROLLBACK}" ".claude/skills/${SKILL_NAME}"
    exit 1
fi

# Step 6: Cleanup old version
echo ""
echo "Step 6: Optional cleanup..."
echo "You can remove the backup directory if rollback is successful:"
echo "  rm -rf ${BACKUP_DIR}"
echo ""
echo "Or keep it for safety:"
echo "  mv ${BACKUP_DIR} ${BACKUP_DIR}-archived"

# Step 7: Summary
echo ""
echo "=========================================="
echo "✅ Rollback Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  - Skill: ${SKILL_NAME}"
echo "  - Restored to: v${TARGET_VERSION}"
echo "  - Backup used: ${BACKUP_DIR}"
if [ -d "${PRE_ROLLBACK}" ]; then
    echo "  - Pre-rollback backup: ${PRE_ROLLBACK}"
fi
echo ""
echo "Next steps:"
echo "  1. Test the rolled back skill"
echo "  2. Verify all workflows work"
echo "  3. Investigate why rollback was needed"
echo ""
echo "To restore pre-rollback state (if needed):"
echo "  cp -r ${PRE_ROLLBACK} .claude/skills/${SKILL_NAME}"