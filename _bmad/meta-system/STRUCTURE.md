# Meta Agentic System - Architecture

## Overview

The Meta Agentic System (MAS) is a **recursive capability-building framework**. It's designed to be:
- **Portable** - Copy to any project
- **Self-replicating** - Can create itself
- **Evolvable** - Improves through usage
- **Composable** - Components work together

---

## Core Architecture

### The Recursive Principle

```
┌─────────────────────────────────────────┐
│  MAS (Meta Agentic System)             │
│  "System that builds systems"          │
└─────────────────────────────────────────┘
           │
    ┌──────┴──────┬──────────────┬──────────────┐
    ▼             ▼              ▼              ▼
┌─────────┐  ┌─────────┐   ┌─────────┐   ┌─────────┐
│Meta     │  │Meta     │   │Meta     │   │Meta     │
│Skills   │  │Agents   │   │Prompts  │   │Tools    │
└─────────┘  └─────────┘   └─────────┘   └─────────┘
    │             │              │              │
    ▼             ▼              ▼              ▼
┌─────────┐  ┌─────────┐   ┌─────────┐   ┌─────────┐
│Skills   │  │Agents   │   │Prompts  │   │Systems  │
└─────────┘  └─────────┘   └─────────┘   └─────────┘
```

**Key Insight:** Each layer can create the layer below it, creating infinite recursion.

---

## Component Architecture

### 1. Meta Skills Layer

**Purpose:** Create and manage skills

**Components:**
```
meta-skill-creator/
├── SKILL.md              # Main instructions
├── references/           # Patterns & examples
└── assets/               # Templates
```

**Capabilities:**
- Generate complete skill packages
- Validate skill structure
- Optimize for token efficiency
- Create reusable templates

**Recursion:** Can create itself and other meta-skills

### 2. Meta Agents Layer

**Purpose:** Create and manage agents

**Components:**
```
meta-agent-factory/
├── SKILL.md              # Agent creation guide
├── references/           # Agent patterns
└── assets/               # Agent templates
```

**Capabilities:**
- Generate agent configurations
- Define custom commands
- Specify capabilities
- Map integrations

**Recursion:** Can create meta-agent-factory and other meta-agents

### 3. Meta Prompts Layer

**Purpose:** Create and optimize prompts

**Components:**
```
meta-prompt-generator/
├── SKILL.md              # Prompt creation guide
├── references/           # Prompt patterns
└── assets/               # Prompt templates
```

**Capabilities:**
- Generate prompt templates
- Optimize for clarity
- Create prompt chains
- Validate effectiveness

**Recursion:** Can create prompts for meta-skills and meta-agents

### 4. Marketplace Layer

**Purpose:** Distribute and manage components

**Components:**
```
meta-system/
├── registry.yaml         # Component catalog
├── export-tools/         # Copy utilities
│   ├── export-system.sh
│   ├── export-skill.sh
│   └── validate-system.sh
├── templates/            # Starter templates
└── README.md             # Documentation
```

**Capabilities:**
- Catalog all components
- Export to other projects
- Validate system integrity
- Provide usage examples

---

## Data Flow

### Creating a New Skill

```
User Request
    ↓
[meta-skill-creator]
    ↓
Analyze Requirements
    ↓
Choose Pattern
    ↓
Generate Structure
    ↓
Create SKILL.md
    ↓
Create Resources
    ↓
Validate
    ↓
Package
    ↓
New Skill
```

### Creating a New Agent

```
User Request
    ↓
[meta-agent-factory]
    ↓
Define Domain
    ↓
Specify Commands
    ↓
Define Capabilities
    ↓
Map Integrations
    ↓
Generate Config
    ↓
New Agent
```

### Creating a New Prompt

```
User Request
    ↓
[meta-prompt-generator]
    ↓
Analyze Task
    ↓
Choose Pattern
    ↓
Define Structure
    ↓
Add Examples
    ↓
Test & Refine
    ↓
New Prompt
```

---

## Integration Patterns

### Pattern 1: Direct Creation

```
User → Meta Skill → New Component
```

**Example:**
```
"Create a skill for data processing"
→ meta-skill-creator
→ data-processor skill
```

### Pattern 2: Agent-Mediated

```
User → Meta Agent → Meta Skill → New Component
```

**Example:**
```
"Build a development team"
→ dev-team-coordinator agent
→ meta-skill-creator (creates skills)
→ meta-agent-factory (creates agents)
→ Complete team
```

### Pattern 3: Prompt-Driven

```
User → Meta Prompt → Meta Skill → New Component
```

**Example:**
```
"Generate prompt for skill creation"
→ meta-prompt-generator
→ Skill creation prompt
→ meta-skill-creator (uses prompt)
→ New skill
```

### Pattern 4: Multi-Agent Workflow

```
User → Coordinator → [Specialist 1, Specialist 2, Specialist 3] → Result
```

**Example:**
```
"Create complete analytics system"
→ PM agent (requirements)
→ Architect agent (design)
→ Meta-skill-creator (skills)
→ Meta-agent-factory (agents)
→ Complete system
```

---

## File Structure Deep Dive

### Skills Directory

```
.claude/skills/
├── meta-skill-creator/          # Creates skills
│   ├── SKILL.md                 # Main instructions
│   ├── references/              # Detailed docs
│   │   ├── patterns.md
│   │   └── examples.md
│   └── assets/                  # Templates
│       └── skill-template/
│
├── meta-agent-factory/          # Creates agents
│   ├── SKILL.md
│   ├── references/
│   └── assets/
│
├── meta-prompt-generator/       # Creates prompts
│   ├── SKILL.md
│   ├── references/
│   └── assets/
│
└── [other skills]               # Your skills
```

### Meta System Directory

```
_bmad/meta-system/
├── README.md                    # Overview
├── STRUCTURE.md                 # This file
├── registry.yaml                # Component catalog
├── USAGE.md                     # How to use
├── PATTERNS.md                  # Design patterns
├── TROUBLESHOOTING.md           # Common issues
│
├── export-tools/                # Copy utilities
│   ├── export-system.sh         # Copy all
│   ├── export-skill.sh          # Copy single
│   └── validate-system.sh       # Check integrity
│
└── templates/                   # Starter templates
    ├── skill-base/
    ├── agent-base/
    └── prompt-base/
```

---

## The Registry

### Purpose
Catalog all components for easy discovery and management.

### Structure
```yaml
version: 1.0.0
components:
  skills:
    - name: meta-skill-creator
      version: 1.0.0
      location: .claude/skills/meta-skill-creator
      description: Creates complete skill packages
      tags: [meta, skill, creation]
      capabilities: [...]
      usage: "Create a skill named [name] for [purpose]"

  agents:
    - name: code-reviewer
      version: 1.0.0
      location: _bmad/_config/agents/code-reviewer.yaml
      description: Reviews code quality
      tags: [development, quality]
      commands: [...]
```

### Usage
```bash
# View all components
cat _bmad/meta-system/registry.yaml

# Find specific skill
grep -A 10 "meta-skill-creator" _bmad/meta-system/registry.yaml
```

---

## Export/Import Flow

### Export System

```
Source Project
    ↓
[export-system.sh]
    ↓
Copy meta-skills
    ↓
Copy meta-system
    ↓
Create reference
    ↓
Target Project
```

### Export Single Skill

```
Source Project
    ↓
[export-skill.sh skill-name]
    ↓
Copy skill directory
    ↓
Target Project
```

### Validate System

```
Project
    ↓
[validate-system.sh]
    ↓
Check structure
    ↓
Check registry
    ↓
Check tools
    ↓
Report issues
```

---

## Recursion Examples

### Example 1: Self-Creation

```
meta-skill-creator creates:
  → meta-skill-creator (improved version)
  → meta-agent-factory
  → meta-prompt-generator
```

### Example 2: Agent Creation

```
meta-agent-factory creates:
  → skill-creation-agent (uses meta-skill-creator)
  → agent-creation-agent (uses meta-agent-factory)
  → prompt-creation-agent (uses meta-prompt-generator)
```

### Example 3: Prompt Creation

```
meta-prompt-generator creates:
  → Prompt for skill creation
  → Prompt for agent creation
  → Prompt for prompt creation (meta-prompt!)
```

### Example 4: Full System

```
User: "Create a complete content creation system"
    ↓
meta-skill-creator → content-skill
meta-agent-factory → writer-agent, editor-agent
meta-prompt-generator → content-prompts
    ↓
Complete system that creates content
```

---

## Evolution Path

### Phase 1: Bootstrap
```
Initial MAS
    ↓
Create basic skills
    ↓
Create basic agents
    ↓
Basic capability
```

### Phase 2: Expansion
```
Basic MAS
    ↓
Create specialized skills
    ↓
Create team agents
    ↓
Domain capability
```

### Phase 3: Optimization
```
Domain MAS
    ↓
Analyze usage patterns
    ↓
Optimize components
    ↓
Efficient capability
```

### Phase 4: Autonomy
```
Optimized MAS
    ↓
Self-improvement loops
    ↓
Automatic evolution
    ↓
Autonomous system
```

---

## Best Practices

### 1. Start Small
```
✓ Copy only what you need
✓ Start with one meta-skill
✓ Test before expanding
✗ Don't copy everything at once
```

### 2. Validate Often
```
✓ Run validate-system.sh regularly
✓ Test each new component
✓ Check for regressions
✗ Don't skip validation
```

### 3. Document Changes
```
✓ Track what you modify
✓ Note what works well
✓ Share improvements
✗ Don't lose knowledge
```

### 4. Iterate Gradually
```
✓ Build one capability at a time
✓ Test integration
✓ Refine based on feedback
✗ Don't over-engineer
```

### 5. Share Back
```
✓ Contribute improvements
✓ Share new patterns
✓ Help the ecosystem
✗ Don't keep improvements private
```

---

## Troubleshooting

### Issue: Skills don't trigger
**Cause:** Description too vague
**Fix:** Make description specific with clear triggers

### Issue: Export fails
**Cause:** Missing directories
**Fix:** Create target directories first

### Issue: Validation fails
**Cause:** Structure issues
**Fix:** Run validate-system.sh and fix reported issues

### Issue: Components not found
**Cause:** Registry out of sync
**Fix:** Update registry.yaml after adding components

---

## Next Steps

1. **Understand the basics** - Read this document
2. **Try it out** - Use meta-skill-creator
3. **Export to new project** - Test portability
4. **Customize** - Adapt for your needs
5. **Contribute** - Share improvements

---

**Remember:** MAS is a living system. It grows and evolves with your needs.
