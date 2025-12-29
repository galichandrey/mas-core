#!/usr/bin/env python3
"""
Meta Skill Creator v2.0 - Creates complete MAS v2.0 skill packages

Usage:
    python create-skill.py <skill-name> --type <base|meta|composite> --path <output-directory> --desc "<description>"

Example:
    python create-skill.py data-processor --type base --path ./skills --desc "Processes CSV files with validation"
    python create-skill.py skill-creator --type meta --path ./skills --desc "Creates skills from natural language"
    python create-skill.py data-pipeline --type composite --path ./skills --desc "Orchestrates read-validate-transform-write"
"""

import sys
import os
import json
from pathlib import Path
import argparse


SKILL_TEMPLATE = """---
name: {skill_name}
description: [TODO: Complete - what it does AND when to use it]
---

# {skill_title}

## Overview

[TODO: 1-2 sentences explaining this skill]

## Quick Start

[TODO: Basic usage example]

## Core Capabilities

### Capability 1

[TODO: Describe first main feature]

## Resources

### scripts/
[TODO: List executable utilities]

### references/
[TODO: List reference docs]

### assets/
[TODO: List templates/assets]
"""

EXAMPLE_SCRIPT = '''#!/usr/bin/env python3
"""
Example script for {skill_name}
"""

def main():
    print("Example script for {skill_name}")
    # TODO: Add actual implementation

if __name__ == "__main__":
    main()
'''

EXAMPLE_REFERENCE = """# Reference for {skill_title}

## Overview

[Detailed reference documentation]

## Usage

[Examples and patterns]
"""

EXAMPLE_ASSET = """# Asset placeholder for {skill_title}

This directory contains output templates and assets.
"""


def create_skill(skill_name, output_path):
    """Create a complete skill package"""

    # Convert skill name to title case
    skill_title = ' '.join(word.capitalize() for word in skill_name.split('-'))

    # Create skill directory
    skill_dir = Path(output_path) / skill_name
    skill_dir.mkdir(parents=True, exist_ok=True)

    print(f"✅ Created skill directory: {skill_dir}")

    # Create SKILL.md
    skill_md = skill_dir / 'SKILL.md'
    skill_md.write_text(SKILL_TEMPLATE.format(
        skill_name=skill_name,
        skill_title=skill_title
    ))
    print(f"✅ Created SKILL.md")

    # Create scripts directory
    scripts_dir = skill_dir / 'scripts'
    scripts_dir.mkdir(exist_ok=True)

    # Create example script
    example_script = scripts_dir / 'example.py'
    example_script.write_text(EXAMPLE_SCRIPT.format(skill_name=skill_name))
    example_script.chmod(0o755)
    print(f"✅ Created scripts/example.py")

    # Create references directory
    refs_dir = skill_dir / 'references'
    refs_dir.mkdir(exist_ok=True)

    # Create example reference
    example_ref = refs_dir / 'reference.md'
    example_ref.write_text(EXAMPLE_REFERENCE.format(skill_title=skill_title))
    print(f"✅ Created references/reference.md")

    # Create assets directory
    assets_dir = skill_dir / 'assets'
    assets_dir.mkdir(exist_ok=True)

    # Create example asset
    example_asset = assets_dir / 'example.txt'
    example_asset.write_text(EXAMPLE_ASSET.format(skill_title=skill_title))
    print(f"✅ Created assets/example.txt")

    print(f"\n✅ Skill '{skill_name}' created successfully!")
    print(f"   Location: {skill_dir}")
    print(f"\nNext steps:")
    print(f"1. Edit SKILL.md to complete TODOs")
    print(f"2. Add custom scripts to scripts/")
    print(f"3. Add reference docs to references/")
    print(f"4. Add templates to assets/")
    print(f"5. Validate: python scripts/validate-skill.py {skill_dir}")

    return skill_dir


def main():
    parser = argparse.ArgumentParser(description='Create a new skill package')
    parser.add_argument('skill_name', help='Name of the skill (hyphen-case)')
    parser.add_argument('--path', required=True, help='Output directory path')

    args = parser.parse_args()

    # Validate skill name
    if not all(c.islower() or c.isdigit() or c == '-' for c in args.skill_name):
        print("❌ Error: Skill name must be lowercase letters, digits, and hyphens only")
        sys.exit(1)

    if args.skill_name.startswith('-') or args.skill_name.endswith('-'):
        print("❌ Error: Skill name cannot start or end with hyphen")
        sys.exit(1)

    print(f"🚀 Creating skill: {args.skill_name}")
    print(f"   Output path: {args.path}")
    print()

    try:
        result = create_skill(args.skill_name, args.path)
        print(f"\n✨ Skill creation complete!")
        sys.exit(0)
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
