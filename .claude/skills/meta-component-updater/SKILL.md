---
name: meta-component-updater
description: Updates existing skills with version management, creates migration scripts, and provides rollback capabilities. Use when updating skills, managing versions, or creating migration paths between skill versions.
---

# Meta Component Updater

## Overview
Updates MAS components with version control, migration scripts, and rollback support.

## Quick Start
```
"Update meta-skill-creator to version 1.1.0 with breaking changes"
"Rollback meta-system-validator to previous version"
"Create migration script for test-validator v1.0 to v2.0"
```

## Core Capabilities

### 1. Version Management
- Track skill versions
- Compare versions
- Generate changelogs
- Validate version compatibility

### 2. Migration Scripts
- Create automated migration scripts
- Handle breaking changes
- Preserve user data
- Test migrations

### 3. Rollback Support
- Backup current version
- Restore previous version
- Verify rollback integrity
- Clean up old versions

### 4. Dependency Updates
- Update skill dependencies
- Resolve version conflicts
- Validate compatibility
- Test integration

## Workflow

### Update Process
```
1. Analyze current skill structure
2. Compare with target version
3. Generate migration plan
4. Create backup
5. Apply updates
6. Validate changes
7. Create rollback script
```

### Rollback Process
```
1. Identify target version
2. Verify backup exists
3. Execute rollback script
4. Validate restoration
5. Clean up temporary files
```

## Resources

### scripts/
- `updater.py` - Main update logic
- `migrator.py` - Migration generator
- `rollback.py` - Rollback handler
- `validator.py` - Version validation

### references/
- `versioning.md` - Version management patterns
- `breaking-changes.md` - Migration strategies
- `rollback-guide.md` - Rollback best practices

### assets/
- `migration-template.sh` - Migration script template
- `rollback-template.sh` - Rollback script template
- `changelog-template.md` - Changelog format