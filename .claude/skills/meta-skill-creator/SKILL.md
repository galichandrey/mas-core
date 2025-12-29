---
name: meta-skill-creator
description: Creates new skills from scratch. Generates complete skill packages with SKILL.md, organized directories, and validation. Use when building new capabilities, extending existing skills, or creating reusable skill templates for other projects.
---

# Meta Skill Creator

**The skill that creates skills.** Generates complete, production-ready skill packages following best practices.

## Quick Start

**Create a new skill:**
```
Create a skill named "data-processor" for processing CSV files with validation and transformation capabilities.
```

Claude will generate:
- `data-processor/SKILL.md` with proper structure
- `data-processor/scripts/` with example utilities
- `data-processor/references/` with documentation templates
- `data-processor/assets/` with placeholder files

## Skill Creation Workflow

### Step 1: Analyze Requirements
Understand what the skill should do and when it should trigger.

**Questions to answer:**
- What specific task does this skill perform?
- What triggers should activate this skill?
- What file types or domains does it handle?
- What are the common user requests?

### Step 2: Choose Design Pattern

**Pattern A: Workflow-Based**
For sequential processes with clear steps.

```
## Overview
## Workflow Steps
  1. Analyze input
  2. Process data
  3. Validate output
  4. Deliver results
## Step 1: [Detailed instructions]
## Step 2: [Detailed instructions]
## Resources
```

**Pattern B: Task-Based**
For tool collections with multiple operations.

```
## Overview
## Quick Start
## Task Category 1
## Task Category 2
## Common Patterns
## Resources
```

**Pattern C: Reference/Guidelines**
For standards, specifications, or policies.

```
## Overview
## Guidelines
## Specifications
## Usage Examples
## Resources
```

**Pattern D: Capabilities-Based**
For integrated systems with multiple features.

```
## Overview
## Core Capabilities
### 1. [Capability]
### 2. [Capability]
### 3. [Capability]
## Integration Patterns
## Resources
```

### Step 3: Generate SKILL.md Structure

**Required Frontmatter:**
```yaml
---
name: [hyphen-case-name]
description: [What it does AND when to use it - be specific]
---
```

**Description Best Practices:**
- ✅ "Extracts text from PDFs, handles forms, and merges documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction."
- ❌ "Helps with PDFs" (too vague)
- ❌ "I can process PDFs for you" (wrong person)

**Body Structure:**
```
# [Skill Title]

## Overview
[1-2 sentences explaining purpose]

## Quick Start
[Basic usage example]

## Core Capabilities
[Main features with examples]

## Resources
[Links to scripts, references, assets]
```

### Step 4: Create Resource Directories

**scripts/**
Executable code for deterministic operations.

**When to include:**
- Same code rewritten repeatedly
- Complex operations needing reliability
- Tasks requiring testing

**Example structure:**
```
scripts/
├── process.py      # Main processing logic
├── validate.py     # Input validation
└── helper.sh       # Shell utilities
```

**references/**
Documentation loaded on-demand.

**When to include:**
- API documentation
- Database schemas
- Domain knowledge
- Detailed workflows

**Example structure:**
```
references/
├── api-docs.md     # API reference
├── schemas.md      # Data schemas
└── patterns.md     # Common patterns
```

**assets/**
Files used in output, not loaded into context.

**When to include:**
- Templates (PPTX, DOCX, HTML)
- Boilerplate code
- Brand assets
- Sample data

**Example structure:**
```
assets/
├── template.pptx   # Presentation template
├── boilerplate/    # Project starter
└── config.json     # Default config
```

### Step 5: Add Content

**For Scripts:**
```python
#!/usr/bin/env python3
"""
Process data with validation
"""

def process_data(input_file, output_file):
    """Process input file and write to output"""
    # Validate input
    # Process data
    # Write output
    pass

if __name__ == "__main__":
    import sys
    process_data(sys.argv[1], sys.argv[2])
```

**For References:**
```markdown
# API Reference

## Authentication
[Details about auth]

## Endpoints
[Endpoint documentation]

## Examples
[Usage examples]
```

**For Assets:**
```
This is a template file.
Replace with actual content.
```

### Step 6: Validate

**Checklist:**
- [ ] SKILL.md exists with valid YAML frontmatter
- [ ] Name is hyphen-case (lowercase, digits, hyphens only)
- [ ] Description includes "what" and "when to use"
- [ ] Description < 1024 characters
- [ ] No angle brackets in description
- [ ] Body under 500 lines
- [ ] Resource directories created
- [ ] No deeply nested references (max 2 levels)
- [ ] All paths use forward slashes
- [ ] No absolute paths

**Validation Test:**
```
Ask Claude to use the skill with a sample request.
Does it trigger automatically?
Does it follow the workflow correctly?
Does it produce expected output?
```

## Complete Example

### Request:
```
Create a skill named "json-validator" that validates JSON files against schemas and provides detailed error reports.
```

### Generated Structure:
```
json-validator/
├── SKILL.md
├── scripts/
│   └── validate.py
├── references/
│   └── schema-examples.md
└── assets/
    └── template-error-report.txt
```

### SKILL.md Content:
```yaml
---
name: json-validator
description: Validates JSON files against schemas, provides detailed error reports with line numbers and suggestions. Use when user needs to validate JSON structure, check data integrity, or debug JSON parsing errors.
---

# JSON Validator

## Overview
Validates JSON files against schemas with detailed error reporting.

## Quick Start
Provide a JSON file and schema, get validation results with error details.

## Core Capabilities

### 1. Schema Validation
Validates JSON against provided schema with detailed error messages.

### 2. Error Reporting
Provides line numbers, error descriptions, and fix suggestions.

### 3. Batch Processing
Validates multiple files at once.

## Resources

### scripts/
- `validate.py` - Main validation logic

### references/
- `schema-examples.md` - Common schema patterns

### assets/
- `template-error-report.txt` - Report format
```

## Advanced Patterns

### Progressive Disclosure
Keep SKILL.md lean by splitting content:

```
SKILL.md (overview + navigation)
├── references/workflows.md (detailed procedures)
├── references/patterns.md (common patterns)
├── scripts/helper.py (utilities)
└── assets/template.txt (templates)
```

**SKILL.md references:**
```markdown
## Advanced Features
- **Complex workflows**: See [workflows.md](references/workflows.md)
- **Pattern library**: See [patterns.md](references/patterns.md)
```

### Conditional Workflows
Guide through decision points:

```
1. Determine task type:
   **New skill?** → Follow creation workflow
   **Existing skill?** → Follow evolution workflow
   **Multiple skills?** → Follow combination workflow

2. Creation workflow:
   - Analyze requirements
   - Choose pattern
   - Generate structure
   - Add content
   - Validate
```

### Feedback Loops
Implement validation cycles:

```
1. Generate skill
2. Validate structure
3. Test with real usage
4. Collect feedback
5. Iterate and improve
```

## Common Mistakes to Avoid

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

### ❌ Deeply Nested References
**Bad:**
```
SKILL.md → references/advanced.md → references/details.md
```

**Good:**
```
SKILL.md → references/advanced.md
SKILL.md → references/details.md
```

### ❌ Vague Descriptions
**Bad:**
```yaml
description: Helps with documents
```

**Good:**
```yaml
description: Extracts text, fills forms, and merges PDF documents. Use when working with PDF files or document tasks.
```

### ❌ Time-Sensitive Info
**Bad:**
```markdown
Use the v2 API (available until August 2025)
```

**Good:**
```markdown
Use the v2 API. For legacy v1, see [old-patterns.md](references/old-patterns.md)
```

## Testing Your Skill

### Test 1: Auto-Trigger
```
User: "I need to validate some JSON"
Expected: Skill triggers automatically
```

### Test 2: Workflow Execution
```
User: "Validate this JSON against the schema"
Expected: Follows complete workflow without guidance
```

### Test 3: Edge Cases
```
User: "What if the JSON is empty?"
Expected: Handles gracefully with clear error
```

### Test 4: Resource Loading
```
User: "Show me advanced patterns"
Expected: Loads references/ patterns.md correctly
```

## Meta-Capabilities

This skill demonstrates meta-patterns:

### Self-Improvement
Can analyze and improve itself:
```
"Analyze this skill and suggest improvements for token efficiency"
```

### Pattern Extraction
Can learn from existing skills:
```
"Analyze these 3 skills and extract common patterns"
```

### Template Creation
Can create reusable templates:
```
"Create a template for workflow-based skills"
```

## Integration with BMAD

### During Planning
```
"Create a skill for requirements analysis"
→ Generates analysis-skill
```

### During Implementation
```
"Create a skill for this specific API"
→ Generates api-skill with proper structure
```

### During Testing
```
"Create a skill for test generation"
→ Generates test-skill
```

## Best Practices Summary

1. **Concise is key** - Every token must justify itself
2. **Clear triggers** - Description enables auto-triggering
3. **Progressive disclosure** - Split content into references
4. **Self-documenting** - Examples over explanations
5. **Test-driven** - Validate before sharing
6. **Portable** - No absolute paths, forward slashes only
7. **Consistent** - Use same terminology throughout

## Quick Reference

### File Structure
```
skill-name/
├── SKILL.md              # Required
├── scripts/              # Optional - executable code
├── references/           # Optional - documentation
└── assets/               # Optional - templates
```

### SKILL.md Format
```yaml
---
name: [hyphen-case]
description: [what + when]
---
# [Title]
## Overview
## Quick Start
## Core Capabilities
## Resources
```

### Validation Checklist
- [ ] Frontmatter valid
- [ ] Name hyphen-case
- [ ] Description clear
- [ ] Body < 500 lines
- [ ] Resources organized
- [ ] No deep nesting

---

**Remember:** The best skills work without explanation. If users need to ask "how do I use this?", the skill needs improvement.
