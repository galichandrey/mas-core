# Common Validation Errors & Solutions

## Overview
This guide helps you fix common issues found during MAS validation.

## Tier 1 Errors (Structure)

### Error: Missing Skills Directory
**Detection:** `.claude/skills/` not found
**Severity:** Critical
**Impact:** System cannot function

**Solution:**
```bash
mkdir -p .claude/skills/
# Then reinstall meta-skills
```

**Prevention:** Always run export-system.sh with --create-dirs flag

---

### Error: Missing Registry
**Detection:** `_bmad/meta-system/registry.yaml` not found
**Severity:** Critical
**Impact:** No component tracking

**Solution:**
```bash
# Regenerate registry
./_bmad/meta-system/export-tools/validate-system.sh --regenerate-registry
```

**Alternative:** Manually create from template:
```yaml
meta_system:
  version: "1.0.0"
  installed: "2025-12-29"
skills: []
agents: []
prompts: []
```

---

### Error: Missing Export Tools
**Detection:** `_bmad/meta-system/export-tools/` incomplete
**Severity:** High
**Impact:** Cannot export/copy system

**Solution:**
```bash
# Reinstall export tools
./_bmad/meta-system/export-tools/export-system.sh --tools-only .
```

**Files needed:**
- export-system.sh
- export-skill.sh
- validate-system.sh
- install-from-marketplace.sh (new)

---

## Tier 2 Errors (SKILL.md Format)

### Error: Missing Required Sections
**Detection:** SKILL.md missing Overview, Purpose, or Capabilities
**Severity:** High
**Impact:** Skill unusable

**Example:**
```markdown
❌ WRONG:
# My Skill
Just does stuff.

✅ CORRECT:
# My Skill

## Overview
Processes data files

## Purpose
Automates data transformation tasks

## Capabilities
- Parse CSV files
- Convert formats
- Validate data

## Usage Examples
User: "Process my data.csv"
Assistant: [Uses skill to process]
```

**Quick Fix:**
```bash
# Use meta-skill-creator to regenerate
"Update .claude/skills/[name]/SKILL.md with proper sections"
```

---

### Error: Incomplete Metadata
**Detection:** Missing Author or Version fields
**Severity:** Medium
**Impact:** Hard to track versions

**Solution:**
Add to SKILL.md:
```markdown
## Author
Your Name or "MAS Meta-System"

## Version
1.0.0

## Tags
csv, data, processing (optional)
```

---

### Error: No Usage Examples
**Detection:** Missing "## Usage Examples" section
**Severity:** Medium
**Impact:** Users don't know how to use it

**Solution:**
Add 2-3 concrete examples:
```markdown
## Usage Examples

### Example 1: Basic Usage
User: "Use [skill-name] to [action]"
Assistant: [Shows result]

### Example 2: Advanced Usage
User: "Use [skill-name] with [parameter]"
Assistant: [Shows result with parameters]
```

---

## Tier 3 Errors (Registry)

### Error: Invalid YAML
**Detection:** Registry cannot be parsed
**Severity:** Critical
**Impact:** System broken

**Common Causes:**
- Missing colons
- Wrong indentation
- Unmatched quotes
- Tabs instead of spaces

**Solution:**
```bash
# Validate YAML
python3 -c "import yaml; yaml.safe_load(open('_bmad/meta-system/registry.yaml'))"

# If error, fix manually or regenerate
```

**Tool to help:**
```bash
# Install yamllint
pip install yamllint
yamllint _bmad/meta-system/registry.yaml
```

---

### Error: Duplicate Entries
**Detection:** Same skill/agent listed multiple times
**Severity:** Medium
**Impact:** Confusion, potential conflicts

**Solution:**
```bash
# Check for duplicates
grep -n "name:" _bmad/meta-system/registry.yaml | sort | uniq -d

# Remove duplicates manually
```

**Prevention:** Always use meta-skills to update registry

---

### Error: Missing Required Keys
**Detection:** Registry missing meta_system, skills, agents, or prompts
**Severity:** Critical
**Impact:** System cannot track components

**Solution:**
```yaml
# Ensure all keys exist
meta_system:
  version: "1.0.0"
  installed: "2025-12-29"

skills: []

agents: []

prompts: []
```

---

### Error: Unresolved Dependencies
**Detection:** Skill lists dependency that doesn't exist
**Severity:** High
**Impact:** Skill may fail

**Example:**
```yaml
# registry.yaml
skills:
  - name: "my-skill"
    dependencies: ["missing-skill"]  # ❌ Doesn't exist
```

**Solution:**
1. Create the missing skill first
2. Or remove from dependencies if not needed
3. Or mark as optional:
```yaml
dependencies: ["missing-skill?"]  # Optional
```

---

## Tier 4 Errors (Integration)

### Error: Skill Creation Fails
**Detection:** Cannot create new skills
**Severity:** Critical
**Impact:** Cannot expand system

**Possible Causes:**
1. meta-skill-creator missing or broken
2. Claude Code permissions issue
3. Directory structure wrong

**Solution:**
```bash
# Check meta-skill-creator
ls -la .claude/skills/meta-skill-creator/

# Test it
echo "Create a skill named test-skill for testing" | claude --continue

# If fails, reinstall
"Recreate meta-skill-creator skill"
```

---

### Error: Agent Creation Fails
**Detection:** Cannot create new agents
**Severity:** High
**Impact:** Cannot expand agent team

**Solution:**
```bash
# Check meta-agent-factory
ls -la .claude/skills/meta-agent-factory/

# Verify _bmad/_config/agents/ exists
mkdir -p _bmad/_config/agents/

# Test
echo "Build an agent named test-agent for testing" | claude --continue
```

---

### Error: Prompt Generation Fails
**Detection:** Cannot generate prompts
**Severity:** Medium
**Impact:** Cannot create new prompts

**Solution:**
```bash
# Check meta-prompt-generator
ls -la .claude/skills/meta-prompt-generator/

# Verify prompts directory
mkdir -p _bmad/meta-system/prompts/

# Test
echo "Generate a prompt for testing" | claude --continue
```

---

### Error: Cross-Component References Broken
**Detection:** Skills don't reference each other
**Severity:** Medium
**Impact:** Workflow disruption

**Example:**
```markdown
# In SKILL.md
## Dependencies
- meta-skill-creator (✅ Good)
- missing-skill (❌ Broken)
```

**Solution:**
1. Check if dependency exists
2. If yes, update reference
3. If no, create it or remove from dependencies

---

## Performance Issues

### Slow Validation
**Symptoms:** Validation takes >30 seconds
**Causes:** Too many files, inefficient scripts

**Solutions:**
```bash
# Limit scope
./validate-system.sh --skills-only
./validate-system.sh --quick

# Or validate specific skill
./validate-system.sh --skill meta-skill-creator
```

---

### High Memory Usage
**Symptoms:** System slows down during validation
**Causes:** Large registry, many components

**Solutions:**
```bash
# Clean up old versions
./_bmad/meta-system/export-tools/cleanup.sh

# Archive old reports
mkdir -p _bmad/reports/archive
mv _bmad/reports/health-2025-* _bmad/reports/archive/
```

---

## Permission Issues

### Error: Cannot Write to Directory
**Detection:** Permission denied errors
**Severity:** High
**Impact:** Cannot save files

**Solution:**
```bash
# Check permissions
ls -la .claude/skills/
ls -la _bmad/meta-system/

# Fix
chmod -R 755 .claude/skills/
chmod -R 755 _bmad/meta-system/
```

---

### Error: Cannot Execute Scripts
**Detection:** "Permission denied" on .sh or .py files
**Severity:** Medium
**Impact:** Scripts won't run

**Solution:**
```bash
# Make executable
chmod +x _bmad/meta-system/export-tools/*.sh
chmod +x .claude/skills/*/scripts/*.py
```

---

## Recovery Procedures

### Complete System Recovery
If system is completely broken:

```bash
# 1. Backup current state
cp -r .claude/skills/ .claude/skills-backup/
cp -r _bmad/ _bmad-backup/

# 2. Reinstall from scratch
rm -rf .claude/skills/
rm -rf _bmad/

# 3. Use export from working system
./path/to/working/system/_bmad/meta-system/export-tools/export-system.sh .

# 4. Validate
./_bmad/meta-system/export-tools/validate-system.sh

# 5. Restore custom skills if needed
cp -r .claude/skills-backup/custom-* .claude/skills/
```

### Partial Recovery (Single Skill)
```bash
# 1. Remove broken skill
rm -rf .claude/skills/broken-skill/

# 2. Recreate
echo "Create a skill named broken-skill for [purpose]" | claude --continue

# 3. Update registry
./_bmad/meta-system/export-tools/validate-system.sh --regenerate-registry
```

---

## Prevention Checklist

Before running validation, check:
- [ ] All required directories exist
- [ ] SKILL.md has all sections
- [ ] Registry is valid YAML
- [ ] No duplicate entries
- [ ] All dependencies exist
- [ ] Scripts are executable
- [ ] Permissions are correct

---

## Getting Help

If you encounter an error not listed here:

1. **Check the validation report:**
   ```bash
   ./_bmad/meta-system/export-tools/validate-system.sh --format json > report.json
   ```

2. **Run specific test:**
   ```bash
   python3 .claude/skills/meta-system-validator/scripts/validate-skills.py --format json
   ```

3. **Create issue:**
   - Include validation report
   - Describe what you were doing
   - List steps to reproduce

---

*Last Updated: 2025-12-29*