# 🚀 MAS v2.0 Quick Start

**Get started with Meta Agentic System v2.0 in 5 minutes**

---

## ⚡ 30-Second Overview

You want to create a skill? Here's how:

```bash
# Create a skill
python .claude/skills/meta-skill-creator/scripts/create-skill-v2.py \
  my-skill --type base --path .claude/skills --desc "Processes data"

# Done! You now have a complete skill package
```

That's it. Seriously.

---

## 🎯 What You Get

### **Complete Skill Package**
```
my-skill/
├── skill.json          # Metadata & validation
├── SKILL.md            # Documentation
├── scripts/            # Implementation
├── references/         # Detailed docs
├── assets/             # Templates
└── README.md           # Quick guide
```

### **Three Skill Types**

| Type | Use When | Example |
|------|----------|---------|
| **base** | Single capability | json-validator, file-reader |
| **meta** | Creates skills | skill-creator, optimizer |
| **composite** | Orchestrates workflows | data-pipeline, report-generator |

---

## 🏁 Step-by-Step

### **Step 1: Create Your First Skill**

```bash
cd /home/ag/dev/mas-core

# Base skill (most common)
python .claude/skills/meta-skill-creator/scripts/create-skill-v2.py \
  csv-parser \
  --type base \
  --path .claude/skills \
  --desc "Parses CSV files with validation and error reporting"

# Explore the result
cd .claude/skills/csv-parser
ls -la
```

### **Step 2: Review the Structure**

```bash
# View metadata
cat skill.json

# View documentation
cat SKILL.md

# View template files
cat scripts/main.py
cat references/patterns.md
```

### **Step 3: Customize**

Edit `SKILL.md`:
```yaml
---
name: csv-parser
description: Parses CSV files with validation. Use when user needs to read CSV data.
type: base
version: 1.0.0
---

# CSV Parser

## Overview
Parses CSV files with validation and error reporting.

## Quick Start
User: "Parse this CSV file"
Result: Validated data with line numbers
```

Edit `scripts/main.py`:
```python
#!/usr/bin/env python3
import csv

def parse_csv(file_path):
    # Your implementation here
    with open(file_path, 'r') as f:
        reader = csv.DictReader(f)
        return list(reader)
```

---

## 🎨 Examples

### **Example 1: Base Skill**
```bash
python create-skill-v2.py json-validator --type base --path . --desc "Validate JSON against schemas"
```

### **Example 2: Meta Skill**
```bash
python create-skill-v2.py skill-optimizer --type meta --path . --desc "Optimize skills for performance"
```

### **Example 3: Composite Skill**
```bash
python create-skill-v2.py data-pipeline --type composite --path . --desc "Read-validate-transform-write workflow"
```

---

## 📋 Skill.json Explained

```json
{
  "name": "my-skill",              // Lowercase, hyphens only
  "version": "1.0.0",              // Semantic versioning
  "type": "base",                  // base | meta | composite
  "description": "What + when",    // Must include trigger context
  "tags": ["validation", "json"],  // For discovery
  "capabilities": ["validate"],    // What it can do
  "dependencies": {                // What it needs
    "skills": [],
    "agents": [],
    "tools": []
  },
  "compatibility": {               // Version requirements
    "mas": "^2.0.0",
    "claude": ">=3.5"
  },
  "quality": {                     // Marketplace metrics
    "validation_status": "unverified",
    "test_coverage": 0,
    "security_score": 0
  }
}
```

---

## 📝 SKILL.md Structure

```yaml
---
name: my-skill
description: What it does AND when to use it
type: base
version: 1.0.0
---

# Skill Title

## Overview
[Brief description]

## Quick Start
[Usage example]

## Core Capabilities
### 1. [Capability]
- What it does
- When to use
- Example

## Resources
### scripts/
- `main.py` - Core logic
### references/
- `patterns.md` - Patterns
### assets/
- `template.json` - Templates
```

---

## ✅ Validation Checklist

Before publishing, check:
- [ ] `skill.json` is valid JSON
- [ ] Name is lowercase with hyphens
- [ ] Description includes "what" and "when"
- [ ] Description < 1024 characters
- [ ] SKILL.md exists
- [ ] Resource directories created
- [ ] No absolute paths
- [ ] All paths use forward slashes

---

## 🚀 Next Steps

### **Option A: Build Skills**
```bash
# Create 3-5 base skills
python create-skill-v2.py file-reader --type base --path . --desc "Read files"
python create-skill-v2.py data-validator --type base --path . --desc "Validate data"
python create-skill-v2.py file-writer --type base --path . --desc "Write files"
```

### **Option B: Create Meta Skills**
```bash
# Meta skill that creates skills
python create-skill-v2.py skill-generator --type meta --path . --desc "Generate skills from descriptions"
```

### **Option C: Build Composites**
```bash
# Combine base skills
python create-skill-v2.py data-pipeline --type composite --path . --desc "Read-validate-write workflow"
```

---

## 🎯 Common Workflows

### **Workflow 1: Data Processing**
```
file-reader → data-validator → data-transformer → file-writer
```

### **Workflow 2: API Integration**
```
api-client → authenticator → request-builder → response-processor
```

### **Workflow 3: Quality Check**
```
file-reader → linter → tester → reporter
```

---

## 💡 Tips

### **1. Description is Key**
```
❌ "Helps with JSON"
✅ "Validates JSON files against schemas. Use when user needs to check JSON structure or debug parsing errors."
```

### **2. Start Simple**
- Create base skills first
- Test each one
- Then compose into workflows

### **3. Use Templates**
```bash
# Copy template files
cp -r _bmad/meta-system/templates/base-skill/* my-skill/
```

### **4. Validate Often**
```bash
# Check JSON syntax
python -m json.tool skill.json

# Check structure
cat skill.json | grep -E '"name"|"type"|"version"'
```

---

## 🔧 Troubleshooting

### **Problem: "Invalid skill name"**
```bash
# Skill names must be lowercase, digits, hyphens only
❌ my_skill
❌ MySkill
✅ my-skill
✅ my-skill-123
```

### **Problem: "Description too vague"**
```bash
# Must include what AND when
❌ "Validates JSON"
✅ "Validates JSON files. Use when user needs to check JSON structure."
```

### **Problem: "Missing files"**
```bash
# Check template directory exists
ls _bmad/meta-system/templates/base-skill/
# If missing, copy from templates
```

---

## 📚 Reference Files

### **Must Read**
1. `_bmad/meta-system/META-AGENTIC-MANIFEST.md` - Complete overview
2. `_bmad/meta-system/ROADMAP-V2.0.md` - Implementation plan
3. `_bmad/meta-system/schemas/skill.json` - Full specification

### **Templates**
1. `_bmad/meta-system/templates/base-skill/` - Base template
2. `_bmad/meta-system/templates/meta-skill/` - Meta template
3. `_bmad/meta-system/templates/composite-skill/` - Composite template

### **Tools**
1. `.claude/skills/meta-skill-creator/scripts/create-skill-v2.py` - Creator

---

## 🎉 You're Ready!

### **Create Your First Skill Now:**
```bash
cd /home/ag/dev/mas-core
python .claude/skills/meta-skill-creator/scripts/create-skill-v2.py \
  hello-world \
  --type base \
  --path .claude/skills \
  --desc "My first MAS v2.0 skill"
```

### **Then:**
```bash
cd .claude/skills/hello-world
cat skill.json
cat SKILL.md
```

**Welcome to MAS v2.0! 🚀**

---

**Need Help?**
- Read: `_bmad/meta-system/META-AGENTIC-MANIFEST.md`
- Roadmap: `_bmad/meta-system/ROADMAP-V2.0.md`
- Schemas: `_bmad/meta-system/schemas/`

**Status:** ✅ Ready to Use
**Version:** 2.0.0
**Created:** 2025-12-29