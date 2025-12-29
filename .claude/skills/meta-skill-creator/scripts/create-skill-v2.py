#!/usr/bin/env python3
"""
Meta Skill Creator v2.0 - Creates complete MAS v2.0 skill packages

Usage:
    python create-skill-v2.py <skill-name> --type <base|meta|composite> --path <output-directory> --desc "<description>"

Example:
    python create-skill-v2.py data-processor --type base --path ./skills --desc "Processes CSV files with validation"
    python create-skill-v2.py skill-creator --type meta --path ./skills --desc "Creates skills from natural language"
    python create-skill-v2.py data-pipeline --type composite --path ./skills --desc "Orchestrates read-validate-transform-write"
"""

import sys
import os
import json
from pathlib import Path
import argparse
import shutil


def generate_skill_json(skill_name, skill_type, description, tags=None):
    """Generate skill.json manifest"""

    # Determine capabilities based on type
    if skill_type == "base":
        capabilities = ["capability-1", "capability-2"]
        type_specific = {"base": {"atomic": True, "dependencies": []}}
    elif skill_type == "meta":
        capabilities = ["skill-creation", "skill-analysis", "skill-optimization"]
        type_specific = {"meta": {"creates": ["skill"], "self_improvement": True}}
    else:  # composite
        capabilities = ["workflow-orchestration", "multi-skill-coordination"]
        type_specific = {
            "composite": {
                "composition_type": "sequential",
                "base_skills": [
                    {"name": "base-skill-1", "role": "input", "optional": False},
                    {"name": "base-skill-2", "role": "processing", "optional": False},
                    {"name": "base-skill-3", "role": "output", "optional": False}
                ]
            }
        }

    skill_json = {
        "name": skill_name,
        "version": "1.0.0",
        "type": skill_type,
        "description": description,
        "tags": tags or [skill_type, "generated"],
        "capabilities": capabilities,
        "type_specific": type_specific,
        "dependencies": {
            "skills": [],
            "agents": [],
            "tools": []
        },
        "compatibility": {
            "mas": "^2.0.0",
            "claude": ">=3.5",
            "platforms": ["linux", "macos", "windows"]
        },
        "author": "Your Name",
        "license": "MIT",
        "repository": f"https://github.com/your-org/{skill_name}",
        "metadata": {
            "token_usage": "medium",
            "execution_time": "fast",
            "difficulty": "intermediate",
            "auto_trigger": True,
            "cost_credits": 0
        },
        "quality": {
            "validation_status": "unverified",
            "test_coverage": 0,
            "security_score": 0,
            "docs_quality": "basic"
        }
    }

    return skill_json


def generate_skill_md(skill_name, skill_type, description):
    """Generate SKILL.md content based on type"""

    skill_title = ' '.join(word.capitalize() for word in skill_name.split('-'))

    if skill_type == "base":
        return f"""---
name: {skill_name}
description: {description}
type: base
version: 1.0.0
---

# {skill_title}

## Overview
{description}

## Quick Start
[Basic usage example]

## Core Capabilities

### 1. [Capability Name]
- What it does
- When to use
- Example

### 2. [Capability Name]
- What it does
- When to use
- Example

## Resources

### scripts/
- `main.py` - Core logic
- `helpers.sh` - Utilities

### references/
- `patterns.md` - Common patterns
- `api-docs.md` - API reference

### assets/
- `template.json` - Output template

## Validation Checklist
- [ ] SKILL.md exists with valid YAML frontmatter
- [ ] Name is hyphen-case
- [ ] Description includes "what" and "when to use"
- [ ] Description < 1024 characters
- [ ] Resource directories created
- [ ] No deeply nested references (max 2 levels)
- [ ] All paths use forward slashes
- [ ] No absolute paths
"""

    elif skill_type == "meta":
        return f"""---
name: {skill_name}
description: {description}
type: meta
version: 1.0.0
---

# Meta Skill: {skill_title}

**The skill that creates/modifies other skills.**

## Overview
{description}

## Quick Start

### Create a new skill
```
Create a skill named [name] for [purpose]
```

### Optimize an existing skill
```
Optimize [skill-name] for [metric]
```

## Core Capabilities

### 1. Skill Creation
[How it creates skills from scratch]

### 2. Skill Analysis
[How it analyzes existing skills]

### 3. Skill Optimization
[How it improves skills]

## Meta-Capabilities

### Self-Improvement
This meta-skill can improve itself:
```
"Analyze and optimize {skill_name} for better token efficiency"
```

### Pattern Learning
Can learn from existing skills:
```
"Analyze these skills and extract common patterns"
```

## Resources

### scripts/
- `create.py` - Skill creation logic
- `analyze.py` - Skill analysis
- `optimize.py` - Optimization engine

### references/
- `skill-patterns.md` - Common patterns
- `best-practices.md` - Meta-skill best practices
- `templates.md` - Template library

### assets/
- `skill-template.json` - Base template
- `validation-rules.json` - Validation rules

## Integration

### With Other Meta-Skills
- Uses `meta-prompt-generator` for prompt creation
- Uses `meta-system-validator` for validation

### With Marketplace
- Can publish created skills
- Can update existing skills

## Meta-Loops

### Creation Loop
```
User Request → Analyze → Generate → Validate → Deploy → Learn → Improve
```

### Optimization Loop
```
Usage Metrics → Analyze → Optimize → Validate → Deploy → Measure
```

## Best Practices

1. **Start Simple** - Create basic skills first
2. **Validate Everything** - Always validate before deploying
3. **Learn from Patterns** - Extract and reuse patterns
4. **Self-Improve** - Use your own capabilities to improve yourself
5. **Document** - Keep clear documentation of changes

## Quick Reference

### File Structure
```
{skill_name}/
├── SKILL.md
├── skill.json
├── scripts/
│   ├── create.py
│   ├── analyze.py
│   └── optimize.py
├── references/
│   ├── skill-patterns.md
│   └── best-practices.md
└── assets/
    └── templates/
```

### Validation Checklist
- [ ] Frontmatter valid
- [ ] Self-improvement capability documented
- [ ] Meta-loops explained
- [ ] Integration points clear
"""

    else:  # composite
        return f"""---
name: {skill_name}
description: {description}
type: composite
version: 1.0.0
---

# Composite Skill: {skill_title}

**Orchestrates multiple base skills into a complete workflow.**

## Overview
{description}

## Quick Start
```
User: [Example request]
Result: [Complete workflow execution]
```

## Composition

### Base Skills
This composite skill orchestrates the following base skills:

| Skill | Role | Optional |
|-------|------|----------|
| base-skill-1 | Input/Reading | No |
| base-skill-2 | Validation/Processing | No |
| base-skill-3 | Output/Writing | No |

### Workflow Type
**Sequential** - Skills execute in order, passing data between them

## Workflow Steps

### Step 1: [Input]
- Skill: base-skill-1
- Purpose: Read and prepare data
- Input: [User request]
- Output: [Prepared data]

### Step 2: [Processing]
- Skill: base-skill-2
- Purpose: Validate and transform
- Input: [Output from Step 1]
- Output: [Processed data]

### Step 3: [Output]
- Skill: base-skill-3
- Purpose: Write results
- Input: [Output from Step 2]
- Output: [Final result]

## Integration Patterns

### Error Handling
If any step fails:
1. Stop execution
2. Report error with context
3. Provide recovery suggestions

### Data Flow
```
Input → Validate → Transform → Output
  ↓       ↓         ↓         ↓
Step1 → Step2 → Step3 → Final Result
```

## Resources

### scripts/
- `orchestrator.py` - Main workflow coordinator
- `router.py` - Data routing logic
- `error-handler.py` - Error handling

### references/
- `composition-guide.md` - How to compose skills
- `workflow-patterns.md` - Common patterns
- `troubleshooting.md` - Common issues

### assets/
- `workflow-template.json` - Workflow configuration template

## Testing

### Test 1: Complete Workflow
```
Input: [Test data]
Expected: [Complete result]
Steps: 3
```

### Test 2: Error Recovery
```
Input: [Invalid data]
Expected: [Clear error message]
```

## Quick Reference

### Composition Definition
```json
{{
  "composition_type": "sequential",
  "base_skills": [
    {{"name": "skill-1", "role": "input"}},
    {{"name": "skill-2", "role": "process"}},
    {{"name": "skill-3", "role": "output"}}
  ]
}}
```

### Validation Checklist
- [ ] All base skills exist
- [ ] Workflow logic tested
- [ ] Error handling implemented
- [ ] Data flow validated
- [ ] Performance acceptable
"""


def copy_template_files(skill_dir, skill_type):
    """Copy appropriate template files based on skill type"""

    template_dir = Path("/home/ag/dev/mas-core/_bmad/meta-system/templates") / f"{skill_type}-skill"

    if not template_dir.exists():
        print(f"⚠️  Warning: Template directory {template_dir} not found")
        return

    # Copy all files from template
    for item in template_dir.iterdir():
        dest = skill_dir / item.name
        if item.is_file():
            shutil.copy2(item, dest)
            print(f"   📄 Copied: {item.name}")
        elif item.is_dir():
            shutil.copytree(item, dest, dirs_exist_ok=True)
            print(f"   📁 Copied: {item.name}/")


def create_skill(skill_name, skill_type, description, output_path):
    """Create a complete MAS v2.0 skill package"""

    # Validate inputs
    if not all(c.islower() or c.isdigit() or c == '-' for c in skill_name):
        raise ValueError("Skill name must be lowercase letters, digits, and hyphens only")

    if skill_name.startswith('-') or skill_name.endswith('-'):
        raise ValueError("Skill name cannot start or end with hyphen")

    if skill_type not in ['base', 'meta', 'composite']:
        raise ValueError("Skill type must be 'base', 'meta', or 'composite'")

    # Create skill directory
    skill_dir = Path(output_path) / skill_name
    skill_dir.mkdir(parents=True, exist_ok=True)

    print(f"✅ Created skill directory: {skill_dir}")

    # Generate and write skill.json
    skill_json = generate_skill_json(skill_name, skill_type, description)
    with open(skill_dir / "skill.json", "w") as f:
        json.dump(skill_json, f, indent=2)
    print(f"✅ Created skill.json")

    # Generate and write SKILL.md
    skill_md = generate_skill_md(skill_name, skill_type, description)
    with open(skill_dir / "SKILL.md", "w") as f:
        f.write(skill_md)
    print(f"✅ Created SKILL.md")

    # Copy template files
    print(f"\n📋 Copying template files for '{skill_type}' skill:")
    copy_template_files(skill_dir, skill_type)

    # Create README
    readme = f"""# {skill_name}

**Type:** {skill_type.capitalize()} Skill
**Version:** 1.0.0
**License:** MIT

## What is this?

{description}

## Installation

```bash
# Via marketplace
mas install {skill_name}

# Manual
cp -r {skill_name} .claude/skills/
```

## Usage

```bash
# Auto-trigger
"User request that matches description"

# Direct
"Use {skill_name} to [task]"
```

## Development

```bash
# View skill.json
cat skill.json

# View SKILL.md
cat SKILL.md

# Validate
# Use meta-system-validator
```

## Next Steps

1. Review skill.json and update capabilities
2. Edit SKILL.md with detailed documentation
3. Add implementation to scripts/
4. Add reference docs to references/
5. Test the skill
6. Validate with meta-system-validator
7. Publish to marketplace
"""

    with open(skill_dir / "README.md", "w") as f:
        f.write(readme)
    print(f"✅ Created README.md")

    print(f"\n✨ Skill '{skill_name}' created successfully!")
    print(f"   Location: {skill_dir}")
    print(f"   Type: {skill_type}")
    print(f"   Description: {description}")

    return skill_dir


def main():
    parser = argparse.ArgumentParser(
        description='Create MAS v2.0 skill packages',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Create base skill
  python create-skill-v2.py csv-parser --type base --path . --desc "Parse CSV files with validation"

  # Create meta skill
  python create-skill-v2.py skill-optimizer --type meta --path . --desc "Optimize skills for performance"

  # Create composite skill
  python create-skill-v2.py data-pipeline --type composite --path . --desc "Read-validate-transform-write workflow"
        """
    )

    parser.add_argument('skill_name', help='Name of the skill (hyphen-case)')
    parser.add_argument('--type', required=True, choices=['base', 'meta', 'composite'],
                       help='Skill type')
    parser.add_argument('--path', required=True, help='Output directory path')
    parser.add_argument('--desc', required=True, help='Skill description (what + when)')

    args = parser.parse_args()

    print(f"🚀 Creating MAS v2.0 skill: {args.skill_name}")
    print(f"   Type: {args.type}")
    print(f"   Path: {args.path}")
    print(f"   Description: {args.desc}")
    print()

    try:
        result = create_skill(args.skill_name, args.type, args.desc, args.path)
        print(f"\n✨ Skill creation complete!")
        print(f"\nNext steps:")
        print(f"1. cd {result}")
        print(f"2. Review and edit skill.json")
        print(f"3. Edit SKILL.md with detailed docs")
        print(f"4. Add implementation to scripts/")
        print(f"5. Test and validate")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
