# Version Management Guide

## Version Numbering

### Semantic Versioning (SemVer)
```
MAJOR.MINOR.PATCH

Examples:
1.0.0  → Initial release
1.1.0  → New features, backward compatible
1.0.1  → Bug fixes only
2.0.0  → Breaking changes
```

### MAS Skill Versioning Rules

**PATCH (1.0.x):**
- Bug fixes
- Documentation updates
- Non-breaking improvements

**MINOR (1.x.0):**
- New features
- Backward compatible changes
- New capabilities

**MAJOR (x.0.0):**
- Breaking changes
- Removed features
- API changes
- Structure changes

## Version Tracking

### In SKILL.md
```yaml
---
name: skill-name
description: What it does
version: 1.2.3
---

# Skill Name

## Version History
### 1.2.3 (2025-12-29)
- Fixed bug in validation
- Added new pattern

### 1.2.0 (2025-12-28)
- Added batch processing
- New configuration options
```

### In Registry
```yaml
components:
  skills:
    - name: skill-name
      version: 1.2.3
      previous_versions:
        - 1.2.0
        - 1.1.0
        - 1.0.0
      compatibility:
        - ">=1.0.0"
```

## Compatibility Matrix

| From/To | 1.0.x | 1.1.x | 1.2.x | 2.0.x |
|---------|-------|-------|-------|-------|
| 1.0.x   | ✅    | ✅    | ✅    | ⚠️    |
| 1.1.x   | -     | ✅    | ✅    | ⚠️    |
| 1.2.x   | -     | -     | ✅    | ⚠️    |

Legend:
- ✅: Direct upgrade
- ⚠️: Migration required
- ❌: Not supported

## Breaking Changes

### What counts as breaking?
- Removed functions/commands
- Changed function signatures
- Changed file structure
- Changed configuration format
- Changed resource paths

### What doesn't count?
- Added functions
- New optional parameters
- Internal refactoring
- Performance improvements

### Migration Strategy
For breaking changes:

1. **Deprecation Phase** (1 version)
   ```python
   # Old (deprecated)
   def old_function():
       warnings.warn("Deprecated, use new_function")
       return new_function()

   # New
   def new_function():
       # New implementation
   ```

2. **Removal Phase** (next major version)
   ```python
   # Only new_function remains
   ```

## Version Comparison

### Check current version
```bash
# In skill directory
grep "version:" SKILL.md
```

### Compare versions
```python
from packaging import version

v1 = version.parse("1.2.3")
v2 = version.parse("1.3.0")

if v2 > v1:
    print("Update available")
```

### Update workflow
```bash
# 1. Check current
current=$(grep "version:" SKILL.md | awk '{print $2}')

# 2. Determine new version
#    - Bug fix: PATCH +1
#    - New feature: MINOR +1, PATCH =0
#    - Breaking: MAJOR +1, MINOR=0, PATCH=0

# 3. Update
sed -i "s/version: $current/version: $new/" SKILL.md
```

## Best Practices

### 1. Always backup before major updates
```bash
./scripts/updater.py skill-name 2.0.0 "Breaking changes"
```

### 2. Test updates on copy first
```bash
cp -r skill-name skill-name-test
# Test in skill-name-test
```

### 3. Document everything
- Changelog in SKILL.md
- Migration guide in migrations/
- Breaking changes clearly marked

### 4. Keep old versions accessible
- Store in migrations/
- Tag in git
- Keep backups

### 5. Validate compatibility
- Check dependencies
- Test integration
- Verify workflows

## Common Patterns

### Pattern 1: Add optional parameter
```python
# v1.0.0
def process(data):
    pass

# v1.1.0 (backward compatible)
def process(data, validate=True):
    if validate:
        # validation logic
    pass
```

### Pattern 2: Change return type
```python
# v1.0.0
def get_data():
    return list  # Returns list

# v2.0.0 (breaking)
def get_data():
    return dict  # Returns dict
```

Migration needed! Update all callers.

### Pattern 3: Rename function
```python
# v1.0.0
def old_name():
    pass

# v1.1.0 (deprecated)
def old_name():
    return new_name()

def new_name():
    # Implementation

# v2.0.0 (removed)
# Only new_name remains
```