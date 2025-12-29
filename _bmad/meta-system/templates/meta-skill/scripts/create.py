#!/usr/bin/env python3
"""
Meta Skill: Creates other skills
Usage: python create.py <skill_name> <description> <type>
"""

import sys
import json
import os
from pathlib import Path


def analyze_requirements(name, description, skill_type):
    """Analyze what the skill needs"""
    return {
        "name": name,
        "description": description,
        "type": skill_type,
        "capabilities": extract_capabilities(description),
        "dependencies": []
    }


def extract_capabilities(description):
    """Extract capabilities from description"""
    # TODO: Implement NLP extraction
    return ["capability-1", "capability-2"]


def generate_structure(analysis):
    """Generate skill directory structure"""
    skill_dir = Path(f".claude/skills/{analysis['name']}")
    skill_dir.mkdir(parents=True, exist_ok=True)

    # Create skill.json
    skill_json = {
        "name": analysis['name'],
        "version": "1.0.0",
        "type": analysis['type'],
        "description": analysis['description'],
        "tags": ["generated", analysis['type']],
        "capabilities": analysis['capabilities'],
        "dependencies": analysis['dependencies']
    }

    with open(skill_dir / "skill.json", "w") as f:
        json.dump(skill_json, f, indent=2)

    # Create SKILL.md
    skill_md = f"""---
name: {analysis['name']}
description: {analysis['description']}
type: {analysis['type']}
version: 1.0.0
---

# {analysis['name'].replace('-', ' ').title()}

## Overview
{analysis['description']}

## Quick Start
[Usage example]

## Core Capabilities
{chr(10).join(f'### {cap}\n- Description\n- Example' for cap in analysis['capabilities'])}

## Resources
- scripts/ - Implementation
- references/ - Documentation
- assets/ - Templates
"""

    with open(skill_dir / "SKILL.md", "w") as f:
        f.write(skill_md)

    # Create directories
    (skill_dir / "scripts").mkdir(exist_ok=True)
    (skill_dir / "references").mkdir(exist_ok=True)
    (skill_dir / "assets").mkdir(exist_ok=True)

    return skill_dir


def validate_skill(skill_dir):
    """Basic validation"""
    required_files = ["skill.json", "SKILL.md"]
    for file in required_files:
        if not (skill_dir / file).exists():
            return False, f"Missing {file}"

    return True, "Valid"


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python create.py <name> <description> <type>")
        sys.exit(1)

    name = sys.argv[1]
    description = sys.argv[2]
    skill_type = sys.argv[3]

    print(f"Creating {skill_type} skill: {name}")

    # Analyze
    analysis = analyze_requirements(name, description, skill_type)

    # Generate
    skill_dir = generate_structure(analysis)

    # Validate
    valid, message = validate_skill(skill_dir)

    if valid:
        print(f"✅ Skill created: {skill_dir}")
        print(f"   Type: {skill_type}")
        print(f"   Capabilities: {', '.join(analysis['capabilities'])}")
    else:
        print(f"❌ Validation failed: {message}")
        sys.exit(1)
