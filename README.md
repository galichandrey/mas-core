# Meta Agentic System (MAS) v2.0

**System that builds your system! Meta prompts, meta subagents, meta skills.**

> "The tool that creates tools. The agent that builds agents. The system that designs systems."

---

## 🎯 What is MAS?

**Meta Agentic System** is a self-building ecosystem that creates, manages, and improves AI development tools. It's designed to be **copied to any project** and immediately start enhancing it.

### Core Philosophy
```
Your Project → Install MAS → MAS builds tools → Tools improve project
```

---

## 🚀 Quick Start

### Installation (One Line)
```bash
# From GitHub (when published)
curl -sSL https://get.mas.dev | bash

# Or from local (for testing)
cp -r ~/dev/mas-core/.claude/skills/meta-* /target/.claude/skills/
cp -r ~/dev/mas-core/_bmad/meta-system /target/_bmad/
```

### Usage
```bash
# Create a skill
"Create a skill named data-processor for CSV handling"

# Create an agent
"Build an agent named monitoring-bot for system health"

# Validate
"Use meta-system-validator to validate current project"
```

---

## 📦 What's Included

### Meta Skills (5 total)

| Skill | Purpose | Usage |
|-------|---------|-------|
| **meta-skill-creator** | Creates complete skill packages | `Create a skill named [name] for [purpose]` |
| **meta-agent-factory** | Builds specialized agents | `Build an agent named [name] for [domain]` |
| **meta-prompt-generator** | Generates optimized prompts | `Generate a prompt for [task]` |
| **meta-system-validator** | Validates system integrity | `Use meta-system-validator to validate` |
| **test-validator** | Validates JSON files | Example skill for testing |

### Export Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| **export-system.sh** | Copy entire MAS | `./export-system.sh /path/to/target` |
| **export-skill.sh** | Copy single skill | `./export-skill.sh skill-name /path` |
| **validate-system.sh** | Check system health | `./validate-system.sh` |
| **install-from-marketplace.sh** | Universal installer | `./install-from-marketplace.sh --system /path` |

---

## 🏗️ Architecture

### Directory Structure
```
mas-core/
├── .claude/skills/              # Meta-skills
│   ├── meta-skill-creator/      # Creates other skills
│   ├── meta-agent-factory/      # Creates agents
│   ├── meta-prompt-generator/   # Creates prompts
│   ├── meta-system-validator/   # Validates everything
│   └── test-validator/          # Example skill
│
├── _bmad/meta-system/           # MAS core
│   ├── export-tools/            # Installation & export
│   ├── registry.yaml            # Component catalog
│   ├── mcp-server/              # Marketplace server
│   └── templates/               # Starter templates
│
└── README.md                    # This file
```

---

## 🔧 Usage Patterns

### Pattern 1: Build New Capability Stack
```
1. Use meta-skill-creator to create domain skill
2. Use meta-agent-factory to create specialist agent
3. Use meta-prompt-generator to create task prompts
4. Integrate into existing workflow
```

### Pattern 2: Evolve Existing System
```
1. Analyze current capabilities
2. Identify gaps
3. Use meta-skills to fill gaps
4. Test and iterate
```

### Pattern 3: Create Specialized Teams
```
1. Design team structure
2. Use meta-agent-factory for each role
3. Use meta-skill-creator for shared skills
4. Configure coordination patterns
```

---

## 📋 Development Status

### Current: v2.0 Development ✅
- ✅ MAS core structure extracted
- ✅ 5 meta-skills (4 core + 1 test)
- ✅ Export tools working
- ✅ Registry system updated
- ✅ MCP server ready
- ✅ Meta-component-updater created
- ✅ Version management working
- ✅ Migration scripts generated
- ✅ Rollback capability tested

### Completed Epic 3.1: Meta-Component-Updater
- ✅ Skill created with full functionality
- ✅ Version management implemented
- ✅ Migration script generation
- ✅ Automatic backup system
- ✅ Rollback capability tested
- ✅ Validation passed

### Next: Epic 3.2 - Enhanced Installer
- One-line installation script
- GitHub Actions setup
- Marketplace preparation

---

## 🎯 Testing

### Test Current Skills
```bash
# Test meta-skill-creator
cd /tmp/test-project
cp -r ~/dev/mas-core/.claude/skills/meta-skill-creator ./.claude/skills/
# Try: "Create a skill named test for testing"
```

### Validate Structure
```bash
cd ~/dev/mas-core
./_bmad/meta-system/export-tools/validate-system.sh
```

---

## 🚀 Next Steps

1. **Complete testing** of all meta-skills
2. **Create meta-component-updater** (Epic 3.1)
3. **Test installation** on 3 different projects
4. **Prepare GitHub repository**
5. **Launch v2.0**

---

## 📚 Documentation

- [STRUCTURE.md](_bmad/meta-system/STRUCTURE.md) - Architecture details
- [USAGE.md](_bmad/meta-system/USAGE.md) - Usage guide
- [PATTERNS.md](_bmad/meta-system/PATTERNS.md) - Design patterns
- [TROUBLESHOOTING.md](_bmad/meta-system/TROUBLESHOOTING.md) - Common issues

---

**Status**: 🟡 Development - Day 1 of 2
**Next**: Test all skills, create updater, prepare GitHub release