# Meta Agentic System - Design Patterns

## Overview

This document catalogs proven patterns for building and using the Meta Agentic System.

---

## Skill Design Patterns

### Pattern 1: Progressive Disclosure

**Problem:** Skills become too large and consume too many tokens.

**Solution:** Split content into SKILL.md + references.

```
SKILL.md (overview + navigation)
├── references/workflows.md (detailed procedures)
├── references/patterns.md (common patterns)
└── references/examples.md (usage examples)
```

**SKILL.md:**
```markdown
## Advanced Features
- **Complex workflows**: See [workflows.md](references/workflows.md)
- **Pattern library**: See [patterns.md](references/patterns.md)
```

**When to use:** Skills with multiple complex features.

---

### Pattern 2: Workflow Decision Tree

**Problem:** Users need different approaches for different scenarios.

**Solution:** Guide users through decisions.

```
## Workflow

1. Determine task type:
   **New data?** → Follow "Creation workflow"
   **Existing data?** → Follow "Modification workflow"
   **Analysis needed?** → Follow "Analysis workflow"

2. Creation workflow:
   - Step 1: Validate input
   - Step 2: Transform data
   - Step 3: Save output

3. Modification workflow:
   - Step 1: Load existing
   - Step 2: Apply changes
   - Step 3: Verify results
```

**When to use:** Skills with multiple operation modes.

---

### Pattern 3: Template & Examples

**Problem:** Users need consistent output format.

**Solution:** Provide templates and examples.

```markdown
## Output Format

ALWAYS use this template:

```markdown
# [Title]

## Summary
[Brief overview]

## Details
[Specific findings]

## Recommendations
[Actionable items]
```

## Examples

**Input:** "Analyze this data"
**Output:** [Complete example following template]
```

**When to use:** Skills producing structured output.

---

### Pattern 4: Validation Loop

**Problem:** Errors go unnoticed until final output.

**Solution:** Validate at each step.

```
## Workflow

1. Validate input
   - Check format
   - Verify completeness
   - Report issues

2. Process
   - Apply transformations
   - Log changes

3. Validate output
   - Check against requirements
   - Verify quality
   - Iterate if needed
```

**When to use:** Critical operations requiring accuracy.

---

### Pattern 5: Resource Navigation

**Problem:** Users don't know what resources are available.

**Solution:** Clear navigation in SKILL.md.

```markdown
## Resources

### scripts/
- `process.py` - Main processing logic
- `validate.py` - Input validation
- `helper.sh` - Utility functions

### references/
- `api-docs.md` - API reference
- `schemas.md` - Data schemas
- `patterns.md` - Common patterns

### assets/
- `template.json` - Output template
- `boilerplate/` - Starter project
```

**When to use:** Skills with multiple resource types.

---

## Agent Design Patterns

### Pattern 1: Specialist Agent

**Problem:** Need deep expertise in specific domain.

**Solution:** Single-domain agent with focused commands.

```yaml
name: billing-analyzer
description: Analyzes invoices, identifies discrepancies, generates reports

commands:
  - analyze-invoice
  - detect-anomalies
  - generate-report

capabilities:
  - Parse PDF invoices
  - Extract line items
  - Calculate totals
  - Compare against subscriptions
```

**When to use:** Deep domain expertise needed.

---

### Pattern 2: Orchestrator Agent

**Problem:** Need to coordinate multiple agents.

**Solution:** Agent that delegates and synthesizes.

```yaml
name: project-coordinator
description: Coordinates development across multiple specialized agents

commands:
  - coordinate-workflow
  - delegate-task
  - synthesize-results

integrations:
  - frontend-dev
  - backend-dev
  - qa-specialist
```

**When to use:** Complex multi-step workflows.

---

### Pattern 3: Support Agent

**Problem:** Need auxiliary capabilities.

**Solution:** Agent focused on supporting roles.

```yaml
name: validator
description: Validates outputs and ensures quality standards

commands:
  - validate-output
  - check-compliance
  - run-tests

capabilities:
  - Output validation
  - Quality checks
  - Compliance verification
```

**When to use:** Quality assurance and validation.

---

### Pattern 4: Multi-Agent Team

**Problem:** Need complete team for workflow.

**Solution:** Coordinated agents with shared skills.

```
PM Agent → Architect Agent → [Dev Agents] → QA Agent
            ↓                    ↓              ↓
        Design Skill       Code Skill    Test Skill
```

**When to use:** Full lifecycle workflows.

---

## Prompt Design Patterns

### Pattern 1: Chain-of-Thought

**Problem:** Complex reasoning needed.

**Solution:** Explicit step-by-step process.

```markdown
## Process

1. **Analyze** the problem
2. **Break down** into components
3. **Evaluate** each part
4. **Synthesize** solution
5. **Validate** against requirements

## Output
Include reasoning at each step.
```

**When to use:** Complex problem-solving.

---

### Pattern 2: Few-Shot Learning

**Problem:** Need consistent style/format.

**Solution:** Provide multiple examples.

```markdown
## Examples

### Example 1
**Input:** [specific input]
**Output:** [exact output format]

### Example 2
**Input:** [different input]
**Output:** [same format]

### Example 3
**Input:** [edge case]
**Output:** [same format]

## New Task
[User's actual request]

## Output
[Generate following pattern]
```

**When to use:** Style consistency critical.

---

### Pattern 3: Constraint-Based

**Problem:** Need strict boundaries.

**Solution:** Clear constraints and validation.

```markdown
## Constraints

1. Must use JSON format
2. Must include all required fields
3. Must not exceed 500 words
4. Must follow style guide

## Validation Checklist
- [ ] All fields present
- [ ] Valid JSON
- [ ] Under word limit
- [ ] Follows style
```

**When to use:** Strict requirements.

---

### Pattern 4: Iterative Refinement

**Problem:** First draft needs improvement.

**Solution:** Build in critique and refinement cycles.

```markdown
## Process

1. **Draft** initial version
2. **Critique** for issues
3. **Refine** based on critique
4. **Finalize** polished version

## Output Format
Include all three versions with explanations.
```

**When to use:** Creative or complex outputs.

---

## Integration Patterns

### Pattern 1: Skill → Agent

**Problem:** Agent needs specific capability.

**Solution:** Agent uses skill as tool.

```
Agent Command:
  "Process this data"

Agent Internally:
  1. Loads data-skill
  2. Executes skill workflow
  3. Returns result
```

**When to use:** Agent needs domain capability.

---

### Pattern 2: Agent → Agent

**Problem:** Workflow spans multiple domains.

**Solution:** Agents coordinate.

```
Agent A (PM):
  "Create requirements"
  → Passes to Agent B

Agent B (Architect):
  "Design system"
  → Passes to Agent C

Agent C (Developer):
  "Implement feature"
```

**When to use:** Multi-domain workflows.

---

### Pattern 3: Prompt → Skill

**Problem:** Skill needs optimized instructions.

**Solution:** Use generated prompts.

```
Skill uses prompt:
  "Analyze this data following best practices"

Prompt provides:
  - Step-by-step instructions
  - Quality criteria
  - Examples
```

**When to use:** Complex skill operations.

---

### Pattern 4: Multi-Tool Chain

**Problem:** Need multiple capabilities in sequence.

**Solution:** Chain of tools.

```
Input
  ↓
[Skill 1: Validate]
  ↓
[Skill 2: Transform]
  ↓
[Skill 3: Export]
  ↓
Output
```

**When to use:** Pipeline operations.

---

## Evolution Patterns

### Pattern 1: Self-Improvement

**Problem:** Skills become outdated.

**Solution:** Analyze and improve.

```
1. Analyze usage patterns
2. Identify inefficiencies
3. Apply optimizations
4. Test improvements
5. Deploy updates
```

**When to use:** Skills with heavy usage.

---

### Pattern 2: Pattern Extraction

**Problem:** Repeated similar structures.

**Solution:** Extract reusable patterns.

```
1. Analyze multiple skills
2. Identify common elements
3. Create template
4. Apply to new skills
```

**When to use:** Building many similar skills.

---

### Pattern 3: Composition

**Problem:** Need composite capabilities.

**Solution:** Combine existing components.

```
Skill A + Skill B + Skill C
  ↓
[Composite Skill]
  ↓
New capability
```

**When to use:** Building complex systems.

---

### Pattern 4: Specialization

**Problem:** Generic skill needs domain focus.

**Solution:** Specialize for domain.

```
Generic Skill: "Process data"
  ↓
Specialized: "Process medical records"
  ↓
Domain-specific: "Process HIPAA-compliant records"
```

**When to use:** Domain-specific requirements.

---

## Anti-Patterns (What NOT to Do)

### ❌ Over-Explaining

**Bad:**
```markdown
## Overview
PDF (Portable Document Format) is a common file format...
Claude is an AI assistant...
Skills are packages that extend capabilities...
```

**Good:**
```markdown
## Overview
Extracts text and tables from PDF files.
```

---

### ❌ Deep Nesting

**Bad:**
```
SKILL.md → references/advanced.md → references/details.md → references/examples.md
```

**Good:**
```
SKILL.md → references/advanced.md
SKILL.md → references/details.md
SKILL.md → references/examples.md
```

---

### ❌ Vague Descriptions

**Bad:**
```yaml
description: Helps with documents
```

**Good:**
```yaml
description: Extracts text, fills forms, merges PDFs. Use when working with PDF files.
```

---

### ❌ Too Many Commands

**Bad:**
```yaml
commands:
  - do-1
  - do-2
  - do-3
  - do-4
  - do-5
  - do-6
  - do-7
```

**Good:**
```yaml
commands:
  - analyze-[domain]
  - generate-[output]
  - validate-[type]
```

---

### ❌ Missing Examples

**Bad:**
```markdown
## Output Format
Use JSON with fields: name, value
```

**Good:**
```markdown
## Output Format
```json
{
  "name": "example",
  "value": 123
}
```

## Example
Input: "Process this"
Output: [complete example]
```

---

## Pattern Selection Guide

| Problem | Pattern | Why |
|---------|---------|-----|
| Skill too large | Progressive Disclosure | Reduces token usage |
| Multiple workflows | Workflow Decision Tree | Guides user choices |
| Need consistency | Template & Examples | Shows exact format |
| Quality critical | Validation Loop | Catches errors early |
| Complex reasoning | Chain-of-Thought | Explicit steps |
| Style matters | Few-Shot Learning | Shows pattern |
| Strict rules | Constraint-Based | Clear boundaries |
| Need improvement | Iterative Refinement | Built-in critique |
| Domain expertise | Specialist Agent | Focused capability |
| Coordination needed | Orchestrator Agent | Manages workflow |
| Multi-step process | Multi-Agent Team | Complete solution |

---

## Applying Patterns

### Step 1: Identify Problem
What issue are you solving?
- Too large? → Progressive Disclosure
- Multiple modes? → Decision Tree
- Need quality? → Validation Loop

### Step 2: Choose Pattern
Select pattern that addresses the problem.

### Step 3: Adapt Pattern
Modify pattern to fit your specific needs.

### Step 4: Test
Validate that pattern solves the problem.

### Step 5: Iterate
Refine based on usage and feedback.

---

## Pattern Library

### Quick Reference

**Skills:**
- Progressive Disclosure
- Workflow Decision Tree
- Template & Examples
- Validation Loop
- Resource Navigation

**Agents:**
- Specialist Agent
- Orchestrator Agent
- Support Agent
- Multi-Agent Team

**Prompts:**
- Chain-of-Thought
- Few-Shot Learning
- Constraint-Based
- Iterative Refinement

**Integration:**
- Skill → Agent
- Agent → Agent
- Prompt → Skill
- Multi-Tool Chain

**Evolution:**
- Self-Improvement
- Pattern Extraction
- Composition
- Specialization

---

## Best Practices

1. **Start with proven patterns** - Don't reinvent
2. **Adapt to context** - Modify as needed
3. **Test thoroughly** - Validate effectiveness
4. **Document patterns used** - Help others learn
5. **Share improvements** - Contribute back

---

**Remember:** Patterns are tools, not rules. Use what works, adapt what doesn't.
