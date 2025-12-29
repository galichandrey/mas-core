# Meta Agentic System - Quick Start Guide

**2 minutes to your first meta-skill!**

---

## What You Have

✅ **3 Meta Skills** (in `.claude/skills/`)
- `meta-skill-creator` - Creates skills
- `meta-agent-factory` - Creates agents
- `meta-prompt-generator` - Creates prompts

✅ **System Files** (in `_bmad/meta-system/`)
- Registry of all components
- Export tools
- Documentation

✅ **Ready to Use** - Copy to any project!

---

## 30-Second Test

### Verify Installation
```bash
./_bmad/meta-system/export-tools/validate-system.sh
```

Should output: ✅ **System is valid and ready to use!**

---

## 2-Minute Tutorial

### Step 1: Create Your First Skill (30 seconds)

**Just say:**
```
Create a skill named "csv-processor" for processing CSV files with validation.
```

**Claude creates:**
```
.claude/skills/csv-processor/
├── SKILL.md
├── scripts/
├── references/
└── assets/
```

### Step 2: Use It (30 seconds)

**Say:**
```
Process this CSV: data.csv
```

**The skill triggers automatically!**

### Step 3: Export It (60 seconds)

```bash
# Copy to another project
./_bmad/meta-system/export-tools/export-system.sh /path/to/new-project

# Or just one skill
./_bmad/meta-system/export-tools/export-skill.sh csv-processor /path/to/new-project
```

**Done!** 🎉

---

## Common Tasks

### Create a Skill
```
Create a skill named [name] for [purpose].
```

### Create an Agent
```
Build an agent named [name] for [domain].
```

### Create a Prompt
```
Generate a prompt for [task].
```

### Export Everything
```bash
./_bmad/meta-system/export-tools/export-system.sh /target
```

### Export One Skill
```bash
./_bmad/meta-system/export-tools/export-skill.sh skill-name /target
```

### Validate System
```bash
./_bmad/meta-system/export-tools/validate-system.sh
```

---

## Real Examples

### Example 1: Data Processing
```
Create a skill named "json-validator" for validating JSON against schemas.
```

**Result:** Complete skill with validation logic, examples, and templates.

### Example 2: Team Building
```
Build an agent named "code-reviewer" for security and quality checks.
```

**Result:** Agent with commands for review, audit, and reporting.

### Example 3: Documentation
```
Generate a prompt for creating technical specifications.
```

**Result:** Optimized prompt with examples and format.

---

## What's Next?

### Learn More
- **Architecture**: Read `STRUCTURE.md`
- **Patterns**: Read `PATTERNS.md`
- **Usage**: Read `USAGE.md`
- **Troubleshooting**: Read `TROUBLESHOOTING.md`

### Build Your System
1. Create domain-specific skills
2. Build specialized agents
3. Generate task prompts
4. Export to other projects

### Share & Evolve
- Contribute improvements
- Share new patterns
- Help the ecosystem

---

## Quick Reference Card

| Action | Command |
|--------|---------|
| **Create skill** | `Create a skill named X for Y` |
| **Create agent** | `Build an agent named X for Y` |
| **Create prompt** | `Generate a prompt for X` |
| **Export all** | `./export-system.sh /path` |
| **Export one** | `./export-skill.sh name /path` |
| **Validate** | `./validate-system.sh` |

---

## Pro Tips

### Tip 1: Start Small
Don't copy everything. Start with what you need:
```bash
# Just skill creation
./export-skill.sh meta-skill-creator /target
```

### Tip 2: Test First
Always validate after creating:
```bash
./validate-system.sh
```

### Tip 3: Use Templates
The meta-skills include templates. Use them!

### Tip 4: Iterate
Create → Test → Refine → Repeat

---

## Troubleshooting

**"System not found"**
```bash
# Check what you have
ls .claude/skills/meta-*
ls _bmad/meta-system/
```

**"Command not found"**
```bash
# Make executable
chmod +x _bmad/meta-system/export-tools/*.sh
```

**"Permission denied"**
```bash
# Check permissions
ls -la _bmad/meta-system/export-tools/
```

---

## You're Ready!

The Meta Agentic System is now in your project. You can:
- ✅ Create skills that create skills
- ✅ Build agents that build agents
- ✅ Generate prompts that generate prompts
- ✅ Export to any project
- ✅ Evolve your system

**Next:** Try creating something real!

---

**Need more help?** See:
- `USAGE.md` - Detailed guide
- `PATTERNS.md` - Design patterns
- `TROUBLESHOOTING.md` - Fix issues
