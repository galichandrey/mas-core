# Meta Agentic System - Usage Guide

## Quick Start (2 minutes)

### Step 1: Verify Installation
```bash
cd /path/to/your/project
./_bmad/meta-system/export-tools/validate-system.sh
```

Expected output: ✅ System is valid and ready to use!

### Step 2: Create Your First Skill
```
Create a skill named "csv-processor" for processing CSV files with validation and transformation.
```

Claude will generate:
```
.claude/skills/csv-processor/
├── SKILL.md
├── scripts/
├── references/
└── assets/
```

### Step 3: Use Your Skill
```
Process this CSV file: data.csv
```

The skill triggers automatically!

---

## Detailed Usage

### Creating Skills

#### Basic Skill Creation
```
Create a skill named [name] for [purpose].
```

**Example:**
```
Create a skill named "json-validator" for validating JSON files against schemas.
```

#### Skill with Specific Pattern
```
Create a workflow-based skill named [name] for [purpose].
```

**Example:**
```
Create a workflow-based skill named "pdf-form-filler" for filling PDF forms step-by-step.
```

#### Skill from Template
```
Create a skill named [name] using the [pattern] pattern.
```

**Available patterns:**
- workflow-based
- task-based
- reference-based
- capabilities-based

### Creating Agents

#### Basic Agent Creation
```
Build an agent named [name] for [domain].
```

**Example:**
```
Build an agent named "billing-analyzer" for analyzing invoices and payments.
```

#### Agent with Commands
```
Build an agent named [name] with commands for [tasks].
```

**Example:**
```
Build an agent named "code-reviewer" with commands for security audit and quality check.
```

#### Agent Team Creation
```
Build a team of agents for [workflow].
```

**Example:**
```
Build a team of agents for content creation workflow.
```

### Creating Prompts

#### Basic Prompt Generation
```
Generate a prompt for [task].
```

**Example:**
```
Generate a prompt for analyzing business requirements.
```

#### Prompt with Specific Format
```
Generate a [format] prompt for [task].
```

**Available formats:**
- chain-of-thought
- few-shot
- template
- workflow

#### Prompt with Examples
```
Generate a prompt for [task] with [N] examples.
```

**Example:**
```
Generate a prompt for code review with 3 examples.
```

---

## Common Workflows

### Workflow 1: Build Domain Capability

```
1. Create domain skill
   "Create a skill named data-analyzer for statistical analysis"

2. Create specialist agent
   "Build an agent named data-scientist for insights generation"

3. Create task prompts
   "Generate a prompt for creating data visualizations"

4. Test integration
   "Analyze this dataset and create a report"
```

### Workflow 2: Extend Existing System

```
1. Identify gap
   "Our documentation is inconsistent"

2. Create skill
   "Create a skill named doc-standardizer for enforcing style"

3. Create agent
   "Build an agent named tech-writer for documentation"

4. Integrate
   Use in existing workflows
```

### Workflow 3: Create Team from Scratch

```
1. Design team
   "Create a development team: frontend, backend, QA"

2. Build agents
   - "Build an agent named frontend-dev for UI/UX"
   - "Build an agent named backend-dev for APIs"
   - "Build an agent named qa-specialist for testing"

3. Create shared skills
   - "Create a skill named code-reviewer"
   - "Create a skill named deploy-helper"

4. Test coordination
   "Implement feature X with full team"
```

---

## Export & Portability

### Export Entire System
```bash
./_bmad/meta-system/export-tools/export-system.sh /path/to/new-project
```

**What it copies:**
- All meta-skills
- System files
- Registry
- Tools

### Export Single Skill
```bash
./_bmad/meta-system/export-tools/export-skill.sh meta-skill-creator /path/to/new-project
```

**What it copies:**
- Just that skill
- All its resources

### Validate Before Export
```bash
./_bmad/meta-system/export-tools/validate-system.sh
```

**Checks:**
- Directory structure
- File integrity
- Common issues

---

## Integration with BMAD

### During Analysis Phase
```
"Create a skill for requirements gathering"
→ meta-skill-creator
→ requirements-skill
```

### During Planning Phase
```
"Build an agent for roadmap planning"
→ meta-agent-factory
→ roadmap-agent
```

### During Architecture Phase
```
"Generate a prompt for system design"
→ meta-prompt-generator
→ design-prompt
```

### During Implementation Phase
```
"Create a skill for this specific API"
→ meta-skill-creator
→ api-skill
```

---

## Advanced Patterns

### Pattern 1: Self-Improvement

```
"Analyze meta-skill-creator and suggest improvements"
→ Claude analyzes current skill
→ Identifies optimization opportunities
→ Suggests enhancements
```

### Pattern 2: Pattern Extraction

```
"Analyze these 3 skills and extract common patterns"
→ Claude reads multiple skills
→ Identifies shared structures
→ Creates reusable template
```

### Pattern 3: Composite Creation

```
"Create a complete analytics system"
→ meta-skill-creator (data-skill)
→ meta-agent-factory (analyst-agent)
→ meta-prompt-generator (report-prompt)
→ Complete system
```

### Pattern 4: Evolution

```
"Evolve the data-processor skill based on usage"
→ Analyze how skill is used
→ Identify pain points
→ Apply improvements
→ Updated skill
```

---

## Troubleshooting

### Problem: Skill doesn't trigger

**Check:**
1. Description includes clear triggers
2. Name follows hyphen-case
3. SKILL.md is valid

**Fix:**
```
"Improve the description to trigger on 'CSV processing'"
```

### Problem: Export fails

**Check:**
1. Target directory exists
2. Source files are valid
3. Permissions are correct

**Fix:**
```bash
mkdir -p /path/to/target
./_bmad/meta-system/export-tools/validate-system.sh
```

### Problem: Validation errors

**Run:**
```bash
./_bmad/meta-system/export-tools/validate-system.sh
```

**Common fixes:**
- Fix frontmatter format
- Update description
- Remove absolute paths
- Reduce body length

### Problem: Components not found

**Check registry:**
```bash
cat _bmad/meta-system/registry.yaml
```

**Update if needed:**
```yaml
components:
  skills:
    - name: your-skill
      location: .claude/skills/your-skill
      # ... other fields
```

---

## Best Practices

### 1. Start Small
```bash
# Instead of: Copy everything
# Do: Copy only what you need
./_bmad/meta-system/export-tools/export-skill.sh meta-skill-creator /target
```

### 2. Test Early
```
After creating a skill:
"Use this skill to process a sample file"
```

### 3. Validate Often
```bash
# Before each export
./_bmad/meta-system/export-tools/validate-system.sh
```

### 4. Document Changes
```
Keep notes on:
- What you created
- What worked well
- What needs improvement
```

### 5. Iterate Gradually
```
Version 1: Basic skill
Version 2: Add resources
Version 3: Optimize
Version 4: Share back
```

---

## Quick Reference

### Commands

| Action | Command |
|--------|---------|
| Create skill | "Create a skill named [name] for [purpose]" |
| Create agent | "Build an agent named [name] for [domain]" |
| Create prompt | "Generate a prompt for [task]" |
| Export system | `./export-system.sh /path` |
| Export skill | `./export-skill.sh skill /path` |
| Validate | `./validate-system.sh` |

### File Locations

| Component | Location |
|-----------|----------|
| Meta skills | `.claude/skills/meta-*` |
| System files | `_bmad/meta-system/` |
| Registry | `_bmad/meta-system/registry.yaml` |
| Tools | `_bmad/meta-system/export-tools/` |

### Patterns

| Pattern | Use When |
|---------|----------|
| Workflow-based | Sequential processes |
| Task-based | Multiple operations |
| Reference-based | Standards/guidelines |
| Capabilities-based | Integrated systems |

---

## Next Steps

1. **Try it now**: Create your first skill
2. **Export it**: Copy to another project
3. **Customize**: Adapt for your needs
4. **Share**: Contribute improvements

---

**Need help?** Check:
- `STRUCTURE.md` - Architecture details
- `registry.yaml` - Available components
- `README.md` - Overview
