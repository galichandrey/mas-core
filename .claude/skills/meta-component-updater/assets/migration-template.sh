#!/bin/bash
# Migration Script Template
# Usage: Copy this file, rename with actual versions, and customize

set -e

SKILL_NAME="skill-name"
FROM_VERSION="1.0.0"
TO_VERSION="2.0.0"
BACKUP_DIR="./backup-${SKILL_NAME}-${FROM_VERSION}"

echo "=========================================="
echo "Migration: ${SKILL_NAME}"
echo "From: v${FROM_VERSION}"
echo "To: v${TO_VERSION}"
echo "=========================================="
echo ""

# Step 1: Verify skill exists
if [ ! -d ".claude/skills/${SKILL_NAME}" ]; then
    echo "❌ Error: Skill ${SKILL_NAME} not found"
    exit 1
fi

# Step 2: Create backup
echo "Step 1: Creating backup..."
mkdir -p "${BACKUP_DIR}"
cp -r ".claude/skills/${SKILL_NAME}"/* "${BACKUP_DIR}/"
echo "✅ Backup created: ${BACKUP_DIR}"

# Step 3: Apply updates
echo ""
echo "Step 2: Applying updates..."

# TODO: Add specific migration steps here
# Example 1: Update SKILL.md
# if [ -f ".claude/skills/${SKILL_NAME}/SKILL.md" ]; then
#     sed -i 's/old-pattern/new-pattern/g' ".claude/skills/${SKILL_NAME}/SKILL.md"
# fi

# Example 2: Move files
# mkdir -p ".claude/skills/${SKILL_NAME}/scripts"
# mv ".claude/skills/${SKILL_NAME}"/*.py ".claude/skills/${SKILL_NAME}/scripts/" 2>/dev/null || true

# Example 3: Update version
# sed -i "s/version: ${FROM_VERSION}/version: ${TO_VERSION}/" ".claude/skills/${SKILL_NAME}/SKILL.md"

echo "✅ Updates applied"

# Step 4: Validate
echo ""
echo "Step 3: Validating migration..."

if [ -f ".claude/skills/${SKILL_NAME}/SKILL.md" ]; then
    echo "✅ SKILL.md exists"
else
    echo "❌ SKILL.md missing"
    exit 1
fi

# Step 5: Create rollback script
echo ""
echo "Step 4: Creating rollback script..."

cat > "rollback-${SKILL_NAME}-${TO_VERSION}-to-${FROM_VERSION}.sh" << 'ROLLBACK_EOF'
#!/bin/bash
# Rollback Script
set -e

SKILL_NAME="'"${SKILL_NAME}"'"
FROM_VERSION="'"${FROM_VERSION}"'"
BACKUP_DIR="'"${BACKUP_DIR}"'"

echo "Rolling back ${SKILL_NAME} to v${FROM_VERSION}..."

if [ ! -d "${BACKUP_DIR}" ]; then
    echo "❌ Backup not found: ${BACKUP_DIR}"
    exit 1
fi

rm -rf ".claude/skills/${SKILL_NAME}"
cp -r "${BACKUP_DIR}" ".claude/skills/${SKILL_NAME}"

echo "✅ Rollback complete!"
echo "Restored from: ${BACKUP_DIR}"
ROLLBACK_EOF

chmod +x "rollback-${SKILL_NAME}-${TO_VERSION}-to-${FROM_VERSION}.sh"
echo "✅ Rollback script created"

# Step 6: Summary
echo ""
echo "=========================================="
echo "✅ Migration Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  - Skill: ${SKILL_NAME}"
echo "  - Version: ${FROM_VERSION} → ${TO_VERSION}"
echo "  - Backup: ${BACKUP_DIR}"
echo "  - Rollback: rollback-${SKILL_NAME}-${TO_VERSION}-to-${FROM_VERSION}.sh"
echo ""
echo "Next steps:"
echo "  1. Test the updated skill"
echo "  2. Verify all workflows work"
echo "  3. Delete backup if everything is OK"
echo ""
echo "To rollback (if needed):"
echo "  bash rollback-${SKILL_NAME}-${TO_VERSION}-to-${FROM_VERSION}.sh"