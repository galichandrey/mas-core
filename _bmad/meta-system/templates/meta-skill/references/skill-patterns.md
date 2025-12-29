# Skill Creation Patterns

## Pattern 1: Workflow-Based Skills
**Use when:** Sequential processes with clear steps

**Structure:**
```
## Overview
## Workflow Steps
  1. [Step 1]
  2. [Step 2]
  3. [Step 3]
## Step 1: [Detailed]
## Step 2: [Detailed]
## Resources
```

**Example:** Data processing pipeline

---

## Pattern 2: Task-Based Skills
**Use when:** Multiple related operations

**Structure:**
```
## Overview
## Quick Start
## Task Category 1
## Task Category 2
## Common Patterns
## Resources
```

**Example:** File manipulation toolkit

---

## Pattern 3: Reference/Guidelines
**Use when:** Standards, specifications, policies

**Structure:**
```
## Overview
## Guidelines
## Specifications
## Usage Examples
## Resources
```

**Example:** Coding standards guide

---

## Pattern 4: Capabilities-Based
**Use when:** Integrated systems with multiple features

**Structure:**
```
## Overview
## Core Capabilities
### 1. [Capability]
### 2. [Capability]
### 3. [Capability]
## Integration Patterns
## Resources
```

**Example:** Complete validation system

---

## Pattern 5: Meta-Skills
**Use when:** Creating/modifying other skills

**Structure:**
```
## Overview
## Quick Start
## Core Capabilities
## Meta-Capabilities
  - Self-improvement
  - Pattern learning
## Integration
## Meta-Loops
## Best Practices
```

**Example:** Skill optimizer

---

## Pattern 6: Composite Skills
**Use when:** Orchestrating multiple base skills

**Structure:**
```
## Overview
## Composition
  - Base Skill 1 → Role
  - Base Skill 2 → Role
## Workflow
## Integration Points
## Resources
```

**Example:** Data pipeline (read → validate → transform → write)

---

## Selection Guide

| Use Case | Pattern | Why |
|----------|---------|-----|
| Sequential process | Workflow | Clear steps |
| Multiple operations | Task | Organized by function |
| Standards/policies | Reference | Easy to browse |
| Multi-feature system | Capabilities | Highlights features |
| Skill creation | Meta | Self-referential |
| Multi-skill workflow | Composite | Orchestration |

---

## Best Practices

### 1. Progressive Disclosure
- Keep SKILL.md lean
- Move details to references/
- Link to detailed docs

### 2. Clear Triggers
- Description must include "when to use"
- Enable auto-triggering
- Be specific about use cases

### 3. Resource Organization
- scripts/: Executable code
- references/: Documentation
- assets/: Templates/files

### 4. Validation
- Always validate before publishing
- Test with real usage
- Get feedback

### 5. Versioning
- Use semantic versioning
- Document breaking changes
- Provide migration guides
