# Meta Agentic System - Component Index

**Complete catalog of all MAS components**

---

## Meta Skills (3)

### 1. meta-skill-creator
**Location:** `.claude/skills/meta-skill-creator/`
**Version:** 1.0.0
**Purpose:** Creates complete skill packages
**Usage:** `Create a skill named [name] for [purpose]`
**Files:**
- `SKILL.md` - Main instructions (10.7 KB)
- `scripts/` - Helper utilities
- `references/` - Patterns & examples
- `assets/` - Templates

### 2. meta-agent-factory
**Location:** `.claude/skills/meta-agent-factory/`
**Version:** 1.0.0
**Purpose:** Builds specialized subagents
**Usage:** `Build an agent named [name] for [domain]`
**Files:**
- `SKILL.md` - Main instructions (12.2 KB)

### 3. meta-prompt-generator
**Location:** `.claude/skills/meta-prompt-generator/`
**Version:** 1.0.0
**Purpose:** Generates optimized prompts
**Usage:** `Generate a prompt for [task]`
**Files:**
- `SKILL.md` - Main instructions (12.5 KB)

---

## Existing Skills (2)

### 4. skill-creator
**Location:** `.claude/skills/skill-creator/`
**Purpose:** Original skill creation guide

### 5. test-generator
**Location:** `.claude/skills/test-generator/`
**Purpose:** API test suite generation

---

## BMAD Agents (9)

| Agent | Location | Purpose |
|-------|----------|---------|
| Analyst | `_bmad/_config/agents/bmm-analyst.customize.yaml` | Business analysis & research |
| PM | `_bmad/_config/agents/bmm-pm.customize.yaml` | Product requirements |
| Architect | `_bmad/_config/agents/bmm-architect.customize.yaml` | System architecture |
| SM | `_bmad/_config/agents/bmm-sm.customize.yaml` | Sprint planning |
| DEV | `_bmad/_config/agents/bmm-dev.customize.yaml` | Code implementation |
| Quick Flow Solo Dev | `_bmad/_config/agents/bmm-quick-flow-solo-dev.customize.yaml` | Fast solo dev |
| TEA | `_bmad/_config/agents/bmm-tea.customize.yaml` | Test architecture |
| UX Designer | `_bmad/_config/agents/bmm-ux-designer.customize.yaml` | UX/UI design |
| Tech Writer | `_bmad/_config/agents/bmm-tech-writer.customize.yaml` | Documentation |

---

## System Files

### Registry
**File:** `_bmad/meta-system/registry.yaml`
**Size:** 8.9 KB
**Contains:** Component catalog with versions, locations, capabilities

### Export Tools
**Directory:** `_bmad/meta-system/export-tools/`

| Tool | Purpose | Usage |
|------|---------|-------|
| `export-system.sh` | Copy entire MAS | `./export-system.sh /target` |
| `export-skill.sh` | Copy single skill | `./export-skill.sh skill /target` |
| `validate-system.sh` | Check integrity | `./validate-system.sh` |

### Documentation

| File | Size | Purpose |
|------|------|---------|
| `README.md` | 10.9 KB | System overview |
| `STRUCTURE.md` | 11.4 KB | Architecture details |
| `USAGE.md` | 8.1 KB | How to use |
| `PATTERNS.md` | 12.1 KB | Design patterns |
| `TROUBLESHOOTING.md` | 10.5 KB | Fix issues |
| `QUICKSTART.md` | 5.8 KB | 2-minute guide |
| `INDEX.md` | This file | Component catalog |

---

## Quick Reference

### Create Something New
```bash
# Skill
"Create a skill named data-processor for CSV files"

# Agent
"Build an agent named billing-analyzer for invoices"

# Prompt
"Generate a prompt for code review"
```

### Export & Share
```bash
# Everything
./_bmad/meta-system/export-tools/export-system.sh /target

# Single skill
./_bmad/meta-system/export-tools/export-skill.sh meta-skill-creator /target
```

### Validate
```bash
./_bmad/meta-system/export-tools/validate-system.sh
```

---

## File Structure

```
project/
├── .claude/skills/
│   ├── meta-skill-creator/      ← Creates skills
│   ├── meta-agent-factory/      ← Creates agents
│   ├── meta-prompt-generator/   ← Creates prompts
│   ├── skill-creator/           ← Original
│   └── test-generator/          ← Original
│
└── _bmad/
    ├── meta-system/
    │   ├── README.md            ← Start here
    │   ├── QUICKSTART.md        ← 2-min guide
    │   ├── USAGE.md             ← Detailed usage
    │   ├── STRUCTURE.md         ← Architecture
    │   ├── PATTERNS.md          ← Design patterns
    │   ├── TROUBLESHOOTING.md   ← Fix issues
    │   ├── INDEX.md             ← This file
    │   ├── registry.yaml        ← Component catalog
    │   └── export-tools/        ← Copy utilities
    │
    └── _config/agents/          ← BMAD agents
        ├── bmm-analyst.customize.yaml
        ├── bmm-pm.customize.yaml
        └── ... (9 total)
```

---

## System Stats

- **Total Meta Skills:** 3
- **Total Existing Skills:** 2
- **Total Agents:** 9
- **Total Export Tools:** 3
- **Total Documentation:** 7 files
- **Total Size:** ~100 KB

---

## Next Steps

1. **Read:** `QUICKSTART.md` - 2-minute setup
2. **Try:** Create your first skill
3. **Validate:** Run `validate-system.sh`
4. **Export:** Copy to another project
5. **Customize:** Adapt for your needs

---

**System Status:** ✅ Validated & Ready to Use
**Last Updated:** 2025-12-29
