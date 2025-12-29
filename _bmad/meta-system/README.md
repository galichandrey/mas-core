# Meta Agentic System (MAS) v1.1.0

**System that builds your system! Meta prompts, meta subagents, meta skills.**

> "The tool that creates tools. The agent that builds agents. The system that designs systems."

---

## 🎯 What is MAS?

**Meta Agentic System** is a self-building ecosystem that creates, manages, and improves AI development tools. It's designed to be **copied to any project** and immediately start enhancing it.

### Core Philosophy
```
Your Project → Install MAS → MAS builds tools → Tools improve project
```

### Key Features (v1.1.0)
- ✅ **4 Meta Skills** - Create skills, agents, prompts, validate systems
- ✅ **Universal Installer** - Install from local/GitHub/ZIP
- ✅ **3-Tier Validation** - Structure, format, integration
- ✅ **Portable** - Copy to any project, works immediately
- ✅ **Self-Improving** - Can create improved versions of itself

---

## 🚀 Quick Start (30 seconds)

### Installation
```bash
# Install entire system
./_bmad/meta-system/export-tools/install-from-marketplace.sh --system /path/to/project

# Or install specific skill
./_bmad/meta-system/export-tools/install-from-marketplace.sh meta-system-validator .
```

### Validation
```bash
# Full validation
./_bmad/meta-system/export-tools/validate-system.sh

# Quick check
./_bmad/meta-system/export-tools/validate-system.sh --quick

# Health report
./_bmad/meta-system/export-tools/validate-system.sh --report
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

## 📦 What's Included (v1.1.0)

### Meta Skills (4 total)

| Skill | Purpose | Usage |
|-------|---------|-------|
| **meta-skill-creator** | Creates complete skill packages | `Create a skill named [name] for [purpose]` |
| **meta-agent-factory** | Builds specialized agents | `Build an agent named [name] for [domain]` |
| **meta-prompt-generator** | Generates optimized prompts | `Generate a prompt for [task]` |
| **meta-system-validator** | Validates system integrity | `Use meta-system-validator to validate` |

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
project/
├── .claude/skills/              # Your skills
│   ├── meta-skill-creator/      # Creates other skills
│   ├── meta-agent-factory/      # Creates agents
│   ├── meta-prompt-generator/   # Creates prompts
│   └── meta-system-validator/   # Validates everything
│
├── _bmad/
│   ├── meta-system/             # MAS core
│   │   ├── export-tools/        # Installation & export
│   │   ├── registry.yaml        # Component catalog
│   │   ├── prompts/             # Prompt templates
│   │   └── docs/                # Documentation
│   │
│   └── _config/agents/          # Agent configurations
│
└── MAS-INSTALL-README.md        # Installation guide
```

### Component Flow
```
1. User Request
   ↓
2. Meta Skill (creates component)
   ↓
3. Registry Update
   ↓
4. Validation
   ↓
5. Ready to Use
```

### 2. Meta Agents (in `_bmad/`)

```
[BMAD Agent Collection]
- Analyst, PM, Architect, SM, DEV, TEA, etc.
```

**These agents can:**
- Coordinate multi-agent workflows
- Execute complex tasks
- Integrate with meta skills

### 3. Marketplace System

```
_bmad/meta-system/
├── registry.yaml          # Available components
├── templates/             # Starter templates
└── installers/            # One-click installers
```

---

## 🚀 Quick Start

### Option A: Copy Entire System to New Project

```bash
# From current project
cp -r .claude/skills/meta-* /path/to/new-project/.claude/skills/
cp -r _bmad/meta-system /path/to/new-project/_bmad/

# Result: Full MAS in new project
```

### Option B: Import Specific Components

```bash
# Just need skill creation?
cp -r .claude/skills/meta-skill-creator /path/to/project/.claude/skills/

# Just need agent factory?
cp -r .claude/skills/meta-agent-factory /path/to/project/.claude/skills/
```

### Option C: Use as Template

```bash
# Clone and customize
git clone <this-repo> new-project
cd new-project
# Customize for your needs
```

---

## 📂 File Structure

```
project/
├── .claude/
│   └── skills/
│       ├── meta-skill-creator/      # Skill creation
│       │   ├── SKILL.md
│       │   └── [references/assets]
│       ├── meta-agent-factory/      # Agent creation
│       │   ├── SKILL.md
│       │   └── [references/assets]
│       └── meta-prompt-generator/   # Prompt creation
│           ├── SKILL.md
│           └── [references/assets]
│
└── _bmad/
    └── meta-system/
        ├── README.md                # This file
        ├── registry.yaml            # Component catalog
        ├── STRUCTURE.md             # Architecture docs
        ├── templates/               # Starter templates
        │   ├── skill-template/
        │   ├── agent-template/
        │   └── prompt-template/
        └── export-tools/
            ├── export-system.sh     # Copy all
            ├── export-skill.sh      # Copy single skill
            └── validate-system.sh   # Check integrity
```

---

## 🎨 Usage Patterns

### Pattern 1: Build New Capability Stack

```
1. Use meta-skill-creator to create domain skill
2. Use meta-agent-factory to create specialist agent
3. Use meta-prompt-generator to create task prompts
4. Integrate into existing workflow
```

**Example:**
```bash
# Step 1: Create data skill
"Create a skill named data-validator for JSON/CSV validation"

# Step 2: Create analysis agent
"Build an agent named data-analyst for insights"

# Step 3: Create report prompt
"Generate a prompt for data summary reports"

# Result: Complete data analysis capability
```

### Pattern 2: Evolve Existing System

```
1. Analyze current capabilities
2. Identify gaps
3. Use meta-skills to fill gaps
4. Test and iterate
```

**Example:**
```bash
# "Our testing is weak. Create testing capabilities"
→ meta-skill-creator creates test-generator
→ meta-agent-factory creates qa-agent
→ meta-prompt-generator creates test-prompts

# Result: Enhanced testing capability
```

### Pattern 3: Create Specialized Teams

```
1. Design team structure
2. Use meta-agent-factory for each role
3. Use meta-skill-creator for shared skills
4. Configure coordination patterns
```

**Example:**
```bash
# "Create a full-stack development team"
→ meta-agent-factory: frontend-dev, backend-dev, devops
→ meta-skill-creator: code-reviewer, deploy-helper
→ meta-prompt-generator: spec-generator, test-writer

# Result: Complete dev team
```

---

## 🔧 Core Capabilities

### Meta-Skill-Creator Capabilities

**Creates:**
- Complete SKILL.md with proper structure
- Organized resource directories
- Example files for each type
- Validation checklists

**Use when:**
- Building new capabilities
- Extending existing skills
- Creating reusable templates

### Meta-Agent-Factory Capabilities

**Creates:**
- Agent configuration files
- Custom command definitions
- Capability specifications
- Integration patterns

**Use when:**
- Building domain specialists
- Creating orchestrators
- Designing agent teams

### Meta-Prompt-Generator Capabilities

**Creates:**
- Optimized prompt templates
- Input/output examples
- Validation criteria
- Chain-of-thought patterns

**Use when:**
- Building prompt libraries
- Optimizing workflows
- Creating reusable patterns

---

## 🏗️ Integration with BMAD Workflow

### Phase 1: Analysis
```
Analyst uses meta-skills to create:
- research-skill
- analysis-skill
- documentation-skill
```

### Phase 2: Planning
```
PM uses meta-skills to create:
- roadmap-skill
- prioritization-skill
- requirement-skill
```

### Phase 3: Architecture
```
Architect uses meta-skills to create:
- design-skill
- diagram-skill
- integration-skill
```

### Phase 4: Implementation
```
DEV uses meta-skills to create:
- code-gen-skill
- refactoring-skill
- optimization-skill
```

### Phase 5: Testing
```
TEA uses meta-skills to create:
- test-gen-skill
- validation-skill
- monitoring-skill
```

---

## 📋 Marketplace Registry

### Registry Structure (`registry.yaml`)

```yaml
version: 1.0
components:
  skills:
    - name: meta-skill-creator
      version: 1.0
      description: Creates complete skill packages
      tags: [meta, skill, creation]
      dependencies: []

    - name: meta-agent-factory
      version: 1.0
      description: Builds specialized subagents
      tags: [meta, agent, creation]
      dependencies: []

  agents:
    - name: code-reviewer
      version: 1.0
      description: Reviews code quality and security
      tags: [development, quality, security]
      skills: [meta-prompt-generator]

  templates:
    - name: skill-base
      version: 1.0
      description: Minimal skill template
      tags: [template, skill]
```

### Using Registry

**List available components:**
```bash
cat _bmad/meta-system/registry.yaml
```

**Install component:**
```bash
# Manual copy
cp -r .claude/skills/meta-skill-creator /path/to/project/.claude/skills/
```

**Validate installation:**
```bash
./_bmad/meta-system/export-tools/validate-system.sh
```

---

## 📚 Documentation

### Core Docs

```
_bmad/meta-system/
├── README.md              # This file - overview
├── STRUCTURE.md           # Architecture details
├── USAGE.md               # Detailed usage guide
├── PATTERNS.md            # Design patterns
└── TROUBLESHOOTING.md     # Common issues
```

### Quick Reference

**Create:**
```bash
# Skill
"Create a skill named [name] for [purpose]"

# Agent
"Build an agent named [name] for [domain]"

# Prompt
"Generate a prompt for [task]"
```

**Copy:**
```bash
# All
cp -r .claude/skills/meta-* /target/.claude/skills/

# Single
cp -r .claude/skills/meta-skill-creator /target/.claude/skills/
```

**Validate:**
```bash
# Check structure
./_bmad/meta-system/export-tools/validate-system.sh

# Test capabilities
"Use meta-skill-creator to create a test skill"
```

---

## 🔐 Best Practices

### 1. Start Small
Don't copy everything. Start with what you need:
- Just skills? Copy `meta-skill-creator`
- Just agents? Copy `meta-agent-factory`
- Full system? Copy all

### 2. Customize
MAS is a template. Adapt it:
- Rename components
- Add domain-specific skills
- Modify workflows

### 3. Test Thoroughly
Before committing:
- Create sample skills
- Build test agents
- Validate outputs

### 4. Iterate
MAS evolves:
- Add new meta-skills
- Improve existing ones
- Share improvements

### 5. Document
Keep track:
- What you added
- What you modified
- What worked well

---

## 🎯 Common Workflows

### Workflow 1: New Project Setup

```
1. Copy MAS to new project
2. Run validation
3. Create first skill
4. Create supporting agent
5. Test integration
```

### Workflow 2: Capability Expansion

```
1. Identify gap
2. Use meta-skill-creator
3. Test with real tasks
4. Refine based on feedback
5. Add to registry
```

### Workflow 3: Team Building

```
1. Design team structure
2. Use meta-agent-factory for each role
3. Create shared skills
4. Configure coordination
5. Test workflows
```

### Workflow 4: System Evolution

```
1. Analyze usage patterns
2. Identify improvements
3. Use meta-skills to evolve
4. Validate changes
5. Deploy updates
```

---

## 🛠️ Export Tools

### export-system.sh
Copy entire MAS to another project:
```bash
./_bmad/meta-system/export-tools/export-system.sh /path/to/target
```

### export-skill.sh
Copy single skill:
```bash
./_bmad/meta-system/export-tools/export-skill.sh meta-skill-creator /path/to/target
```

### validate-system.sh
Check system integrity:
```bash
./_bmad/meta-system/export-tools/validate-system.sh
```

---

## 🤝 Contributing

MAS is designed to be:
- **Extensible** - Add new capabilities
- **Shareable** - Contribute improvements
- **Adaptable** - Fit different needs
- **Evolvable** - Learn and grow

### How to Contribute

1. **Create new meta-skills** for common tasks
2. **Build specialized agents** for domains
3. **Generate prompt templates** for workflows
4. **Improve documentation** and examples
5. **Share patterns** that work well

---

## 📖 Next Steps

1. **Read**: [STRUCTURE.md](STRUCTURE.md) - Architecture details
2. **Try**: [USAGE.md](USAGE.md) - Hands-on guide
3. **Create**: Use meta-skills to build your first capability
4. **Share**: Contribute back improvements

---

## 💡 The Vision

> "We don't just build tools. We build tool-builders."
>
> "We don't just create agents. We create agent-factories."
>
> "We don't just write prompts. We write prompt-writers."

**Meta Agentic System** is the foundation for recursive AI capability building.

---

**Status**: ✅ Ready to Use
**Version**: 1.0.0
**License**: MIT
**Portable**: Yes - copy to any project
