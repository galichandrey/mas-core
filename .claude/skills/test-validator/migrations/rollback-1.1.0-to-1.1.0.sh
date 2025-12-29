#!/bin/bash
# Rollback script: test-validator 1.1.0 → 1.1.0
# Generated: 2025-12-29T13:55:21.766633

set -e

echo "Rolling back test-validator from 1.1.0 to 1.1.0..."

if [ ! -d "./backup-test-validator-1.1.0" ]; then
    echo "❌ Backup not found!"
    exit 1
fi

# Restore from backup
rm -rf .claude/skills/test-validator
cp -r "./backup-test-validator-1.1.0" .claude/skills/test-validator

echo "✅ Rollback complete!"
echo "Restored to version 1.1.0"
