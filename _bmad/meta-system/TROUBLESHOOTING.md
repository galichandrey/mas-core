# Meta Agentic System - Troubleshooting Guide

## Common Issues & Solutions

---

## Skills

### Issue 1: Skill doesn't trigger automatically

**Symptoms:**
- User mentions topic but skill doesn't activate
- Have to manually specify skill

**Causes:**
- Description too vague
- Name doesn't match triggers
- Missing keywords in description

**Solution:**
```yaml
# Before (bad)
description: Helps with PDFs

# After (good)
description: Extracts text, fills forms, merges PDF documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.
```

**Test:**
```
User: "I need to work with PDFs"
Expected: Skill triggers automatically
```

---

### Issue 2: Validation fails

**Symptoms:**
- `validate-system.sh` reports errors
- Can't package skill

**Common errors:**

#### Error: "No YAML frontmatter found"
**Fix:** Ensure SKILL.md starts with:
```yaml
---
name: skill-name
description: Skill description
---
```

#### Error: "Name should be hyphen-case"
**Fix:** Use lowercase with hyphens:
```bash
# Bad
MySkill
my_skill
mySkill

# Good
my-skill
```

#### Error: "Description too long"
**Fix:** Keep under 1024 characters:
```yaml
# Bad
description: This skill does many things including processing files, validating data, generating reports, and more. It can handle various formats...

# Good
description: Processes files, validates data, generates reports. Use for data processing tasks.
```

#### Error: "Body too long"
**Fix:** Split into references:
```
SKILL.md (under 500 lines)
├── references/workflows.md
├── references/patterns.md
└── references/examples.md
```

---

### Issue 3: Deeply nested files

**Symptoms:**
- Validation warns about deep nesting
- Claude has trouble loading files

**Solution:**
```
# Bad (too deep)
skill/
├── SKILL.md
└── references/
    └── advanced/
        └── detailed/
            └── examples.md  # 3 levels deep

# Good (max 2 levels)
skill/
├── SKILL.md
└── references/
    ├── advanced.md
    └── examples.md
```

**Fix:**
```bash
# Flatten structure
mv skill/references/advanced/detailed/examples.md skill/references/examples.md
rmdir skill/references/advanced/detailed skill/references/advanced
```

---

### Issue 4: Absolute paths

**Symptoms:**
- Validation fails
- Skill not portable

**Solution:**
```markdown
# Bad
See [/home/user/project/docs/api.md](/home/user/project/docs/api.md)

# Good
See [api.md](references/api.md)
```

**Fix:**
```bash
# Find absolute paths
grep -r "^/" .claude/skills/your-skill/SKILL.md

# Replace with relative
sed -i 's|/home/user/project/docs/||g' .claude/skills/your-skill/SKILL.md
```

---

### Issue 5: Script won't execute

**Symptoms:**
- "Permission denied" error
- Script doesn't run

**Solution:**
```bash
# Check permissions
ls -la .claude/skills/your-skill/scripts/

# Make executable
chmod +x .claude/skills/your-skill/scripts/*.py
chmod +x .claude/skills/your-skill/scripts/*.sh
```

**Check shebang:**
```python
#!/usr/bin/env python3
# Correct shebang for Python
```

---

## Agents

### Issue 1: Agent commands not recognized

**Symptoms:**
- "Unknown command" error
- Commands don't work

**Causes:**
- Command not in configuration
- Wrong format
- Missing description

**Solution:**
```yaml
# Check format
commands:
  - name: analyze-invoice
    description: "Analyzes invoice for discrepancies"
    parameters: "invoice_file, date_range?"
    example: "analyze-invoice invoice.pdf --range 2024-01..2024-12"
```

---

### Issue 2: Agent doesn't coordinate

**Symptoms:**
- Agents work in isolation
- No handoffs between agents

**Solution:**
```yaml
# Define integrations
integrations:
  - payment-processor
  - subscription-manager

# In description
description: Coordinates billing analysis and payment processing
```

---

### Issue 3: Too many commands

**Symptoms:**
- Agent is confusing
- Commands overlap

**Solution:**
```yaml
# Before (too many)
commands:
  - analyze-invoice
  - invoice-analysis
  - check-invoice
  - validate-invoice
  - process-invoice
  - review-invoice

# After (consolidated)
commands:
  - analyze-invoice
  - process-payment
  - generate-report
```

---

## Prompts

### Issue 1: Prompt produces inconsistent output

**Symptoms:**
- Different results each time
- Format varies

**Solution:**
```markdown
## Output Format
ALWAYS use this exact structure:

```json
{
  "field1": "value",
  "field2": "value"
}
```

## Examples
[3+ complete examples showing exact format]
```

---

### Issue 2: Prompt ignores constraints

**Symptoms:**
- Exceeds length limits
- Wrong format
- Missing required fields

**Solution:**
```markdown
## Constraints
1. Must be under 200 words
2. Must include all 3 sections
3. Must use bullet points

## Validation
[Checklist for output]
```

---

### Issue 3: Prompt too vague

**Symptoms:**
- Claude asks clarifying questions
- Output doesn't match expectations

**Solution:**
```markdown
# Before (vague)
"Analyze this and give me insights"

# After (specific)
"Analyze this data and provide:
1. Key trends (3 bullet points)
2. Anomalies found
3. 3 recommendations

Format: Markdown with sections"
```

---

## Export Tools

### Issue 1: Export-system.sh fails

**Symptoms:**
- "Directory not found"
- Permission errors

**Solution:**
```bash
# Check source
ls .claude/skills/meta-*

# Check target
mkdir -p /path/to/target

# Run with correct path
./_bmad/meta-system/export-tools/export-system.sh /path/to/target
```

---

### Issue 2: Export-skill.sh not found

**Symptoms:**
- "Command not found"
- Script missing

**Solution:**
```bash
# Make executable
chmod +x _bmad/meta-system/export-tools/export-skill.sh

# Check location
ls _bmad/meta-system/export-tools/
```

---

### Issue 3: Validation shows false positives

**Symptoms:**
- Validation fails but skill works
- Warnings about non-issues

**Solution:**
```bash
# Check what's failing
./_bmad/meta-system/export-tools/validate-system.sh 2>&1

# Review specific checks
# Some warnings are informational, not errors
```

---

## Registry

### Issue 1: Registry out of sync

**Symptoms:**
- Components exist but not in registry
- Registry lists missing components

**Solution:**
```yaml
# Update registry.yaml
components:
  skills:
    - name: your-new-skill
      version: 1.0.0
      location: .claude/skills/your-new-skill
      description: What it does
      tags: [relevant, tags]
```

---

### Issue 2: Duplicate entries

**Symptoms:**
- Same component listed multiple times
- Confusion about which to use

**Solution:**
```bash
# Find duplicates
grep -n "name:" _bmad/meta-system/registry.yaml | sort | uniq -d

# Remove duplicates, keep latest version
```

---

## System-Wide Issues

### Issue 1: Components not found after export

**Symptoms:**
- "Skill not found" in new project
- Missing files

**Solution:**
```bash
# Verify export
ls -la /path/to/target/.claude/skills/meta-*

# Check structure
find /path/to/target -name "meta-*" -type d

# Re-export if needed
./_bmad/meta-system/export-tools/export-system.sh /path/to/target
```

---

### Issue 2: Version conflicts

**Symptoms:**
- Old and new versions mixed
- Unexpected behavior

**Solution:**
```bash
# Remove old versions
rm -rf .claude/skills/meta-skill-creator

# Copy fresh version
./_bmad/meta-system/export-tools/export-skill.sh meta-skill-creator .
```

---

### Issue 3: Missing dependencies

**Symptoms:**
- Skill needs another skill
- Circular dependencies

**Solution:**
```yaml
# In registry.yaml
components:
  skills:
    - name: advanced-skill
      dependencies:
        - basic-skill
        - helper-skill
```

---

## Diagnostic Commands

### Check System Health
```bash
./_bmad/meta-system/export-tools/validate-system.sh
```

### List All Meta Skills
```bash
ls -la .claude/skills/meta-*/
```

### Find Skills by Name
```bash
find .claude/skills -name "*skill*" -type d
```

### Check File Sizes
```bash
du -sh .claude/skills/meta-*
```

### Validate YAML
```bash
python3 -c "import yaml; yaml.safe_load(open('_bmad/meta-system/registry.yaml'))"
```

### Find Deep Nesting
```bash
find .claude/skills/meta-* -type d | awk -F/ 'NF>6'
```

### Find Absolute Paths
```bash
grep -r "^/" .claude/skills/meta-*/SKILL.md
```

---

## Quick Fixes

### Problem: Everything broken
```bash
# Reset to known good state
./_bmad/meta-system/export-tools/export-system.sh /tmp/backup
rm -rf .claude/skills/meta-*
./_bmad/meta-system/export-tools/export-system.sh .
```

### Problem: Can't find component
```bash
# Search everywhere
find . -name "*meta-skill-creator*" -o -name "*meta-agent-factory*"
```

### Problem: Permission issues
```bash
# Fix all permissions
chmod -R +x .claude/skills/meta-*/
chmod +x _bmad/meta-system/export-tools/*.sh
```

---

## Getting Help

### 1. Check Logs
```bash
# Run with verbose output
bash -x ./_bmad/meta-system/export-tools/validate-system.sh
```

### 2. Verify Installation
```bash
# What should exist
echo "Expected:"
echo "  .claude/skills/meta-skill-creator/"
echo "  .claude/skills/meta-agent-factory/"
echo "  .claude/skills/meta-prompt-generator/"
echo "  _bmad/meta-system/"

echo ""
echo "Actual:"
ls -d .claude/skills/meta-* _bmad/meta-system/ 2>/dev/null
```

### 3. Test Basic Functionality
```
"Create a skill named test-skill for testing"
```
Should generate complete skill package.

---

## Prevention

### Regular Maintenance
```bash
# Weekly
./_bmad/meta-system/export-tools/validate-system.sh

# Before export
./_bmad/meta-system/export-tools/validate-system.sh

# After creating components
# Update registry.yaml
```

### Best Practices
1. Validate before exporting
2. Keep descriptions specific
3. Use relative paths only
4. Limit body to 500 lines
5. Test each new component
6. Update registry promptly

---

## Emergency Recovery

### If system is completely broken:

1. **Backup current state**
```bash
cp -r .claude/skills /tmp/skills-backup
cp -r _bmad/meta-system /tmp/meta-backup
```

2. **Clean slate**
```bash
rm -rf .claude/skills/meta-*
rm -rf _bmad/meta-system
```

3. **Reinstall from source**
```bash
# Copy from original project or git
cp -r /original/project/.claude/skills/meta-* .claude/skills/
cp -r /original/project/_bmad/meta-system _bmad/
```

4. **Validate**
```bash
./_bmad/meta-system/export-tools/validate-system.sh
```

5. **Test**
```
"Create a test skill"
```

---

**Still stuck?** Check:
- `README.md` - Overview
- `STRUCTURE.md` - Architecture
- `USAGE.md` - How to use
