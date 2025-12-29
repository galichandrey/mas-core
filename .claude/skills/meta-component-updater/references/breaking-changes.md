# Breaking Changes Guide

## What is a Breaking Change?

A breaking change is any modification that requires users to update their code, configuration, or workflows.

### Examples by Type

#### 1. Removed Features
```yaml
# Before (v1.0)
skills:
  - name: old-skill
    commands: [old-command]

# After (v2.0)
# old-skill removed entirely
```

**Impact:** Users must find alternative

#### 2. Changed Command Syntax
```yaml
# Before
"Update skill-name"

# After
"Update skill-name to version 2.0"
```

**Impact:** Old commands no longer work

#### 3. Changed File Structure
```
# Before
skill/
├── SKILL.md
├── script.py

# After
skill/
├── SKILL.md
├── scripts/
│   └── main.py
```

**Impact:** References to old paths break

#### 4. Changed Configuration
```yaml
# Before
config:
  timeout: 30

# After
config:
  timeouts:
    main: 30
    backup: 60
```

**Impact:** Old configs invalid

## Migration Strategies

### Strategy 1: Deprecation Warning (Recommended)

**Phase 1: Add deprecation (v1.1)**
```python
def old_function():
    warnings.warn(
        "old_function is deprecated, use new_function",
        DeprecationWarning,
        stacklevel=2
    )
    return new_function()

def new_function():
    # New implementation
```

**Phase 2: Remove (v2.0)**
```python
# old_function removed
def new_function():
    # Implementation
```

### Strategy 2: Automatic Migration

**Create migration script:**
```bash
#!/bin/bash
# migrate-v1-to-v2.sh

echo "Migrating skill to v2.0..."

# 1. Backup
cp -r skill skill-backup-v1

# 2. Update SKILL.md
sed -i 's/old-pattern/new-pattern/g' skill/SKILL.md

# 3. Move files
mkdir -p skill/scripts
mv skill/*.py skill/scripts/

# 4. Update references
find skill -type f -exec sed -i 's/old-path/new-path/g' {} \;

echo "Migration complete!"
echo "Backup: skill-backup-v1"
```

### Strategy 3: Dual Support

**Support both versions temporarily:**
```python
def process(data, format="v1"):
    if format == "v1":
        return process_v1(data)
    elif format == "v2":
        return process_v2(data)
    else:
        raise ValueError("Unsupported format")
```

## Breaking Change Checklist

### Before Release
- [ ] Document all breaking changes
- [ ] Create migration scripts
- [ ] Update documentation
- [ ] Test migration on sample projects
- [ ] Prepare rollback plan

### During Migration
- [ ] Create backup first
- [ ] Run migration script
- [ ] Validate results
- [ ] Test all workflows
- [ ] Verify no data loss

### After Migration
- [ ] Update version numbers
- [ ] Update changelog
- [ ] Notify users
- [ ] Monitor for issues

## Common Breaking Changes in MAS

### 1. Skill Structure Changes
```
v1.0: .claude/skills/name/SKILL.md
v2.0: .claude/skills/name/SKILL.md + references/ + scripts/
```

**Migration:** Copy new structure, preserve user content

### 2. Registry Format Changes
```yaml
# v1.0
registry:
  skills: [...]

# v2.0
components:
  skills: [...]
```

**Migration:** Transform registry format

### 3. Command Syntax Changes
```
v1.0: "Create skill X"
v2.0: "Create skill X for [purpose]"
```

**Migration:** Update user prompts

### 4. Configuration Changes
```json
// v1.0
{"version": "1.0"}

// v2.0
{"version": "2.0", "compatibility": ">=1.0.0"}
```

**Migration:** Add new fields with defaults

## Rollback Plan

### When to Rollback
- Migration fails
- Data corruption
- Critical bugs
- User complaints

### How to Rollback
```bash
# Using backup
./scripts/updater.py skill-name 1.0.0 --rollback

# Manual
cp -r backup-skill-v1/* skill/
```

### Rollback Validation
- [ ] All files restored
- [ ] Version correct
- [ ] Functionality works
- [ ] No data loss

## Communication

### Release Notes Template
```markdown
## Breaking Changes in v2.0

### What Changed
- [Feature X] now requires parameter Y
- [Command Z] syntax updated

### Migration Required
Run: `./migrate-v1-to-v2.sh`

### Timeline
- v1.1: Deprecation warnings
- v2.0: Breaking changes active
- v3.0: Old features removed

### Support
- Migration guide: [link]
- Rollback instructions: [link]
- Issue tracker: [link]
```

### User Notification
```
Subject: Action Required: Skill Update v2.0

Hi!

Skill X is getting a major update with breaking changes.

What you need to do:
1. Backup your project
2. Run: ./migrate-v1-to-v2.sh
3. Test your workflows
4. Report any issues

Timeline: Update by [date]

Questions? See [docs]
```

## Testing Breaking Changes

### Test 1: Migration Success
```bash
# Create test project
mkdir test-project
cd test-project

# Install old version
cp -r ../skill-v1 skill/

# Run migration
./migrate-v1-to-v2.sh

# Verify
./scripts/validate.py
```

### Test 2: Rollback Success
```bash
# After migration
./rollback-v2-to-v1.sh

# Verify
./scripts/validate.py
```

### Test 3: Data Integrity
```bash
# Before
./scripts/process.py data.json

# After migration
./scripts/process.py data.json

# Compare outputs
diff output-v1.json output-v2.json
```

## Examples

### Example 1: Simple Rename
```python
# v1.0
def validate_json(data):
    pass

# v2.0
def validate(data, format="json"):
    if format == "json":
        pass
```

**Migration:** None (backward compatible)

### Example 2: Parameter Change
```python
# v1.0
def process(data, timeout=30):
    pass

# v2.0
def process(data, config=None):
    if config is None:
        config = {"timeout": 30}
```

**Migration:** Update calls or use default

### Example 3: Return Type Change
```python
# v1.0
def get_data():
    return [item1, item2]  # List

# v2.0
def get_data():
    return {"items": [item1, item2]}  # Dict
```

**Migration:** Required - update all callers

## Tools

### Version Checker
```python
def check_compatibility(current, required):
    from packaging import version
    return version.parse(current) >= version.parse(required)
```

### Migration Runner
```bash
#!/bin/bash
# run-migration.sh

SKILL=$1
FROM=$2
TO=$3

if [ -f "migrations/migrate-${FROM}-to-${TO}.sh" ]; then
    bash "migrations/migrate-${FROM}-to-${TO}.sh"
else
    echo "No migration script found"
    exit 1
fi
```

### Rollback Runner
```bash
#!/bin/bash
# run-rollback.sh

SKILL=$1
TO=$2

# Find latest backup
BACKUP=$(ls -td .meta-backups/${SKILL}-* | head -1)

if [ -z "$BACKUP" ]; then
    echo "No backup found"
    exit 1
fi

cp -r "$BACKUP/skill" .claude/skills/
echo "Rolled back to $(cat "$BACKUP/version-info.json" | grep version)"
```