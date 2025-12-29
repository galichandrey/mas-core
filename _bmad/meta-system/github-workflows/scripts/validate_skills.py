#!/usr/bin/env python3
"""
GitHub Actions: Validate submitted skills
"""

import os
import sys
import yaml
import json
from pathlib import Path

def validate_skill(skill_path):
    """Validate a single skill"""
    errors = []
    warnings = []

    skill_path = Path(skill_path)
    skill_name = skill_path.name

    # Check SKILL.md
    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        errors.append(f"{skill_name}: Missing SKILL.md")
        return errors, warnings

    content = skill_md.read_text()

    # Check required sections
    required = ["## Overview", "## Purpose", "## Capabilities"]
    for section in required:
        if section not in content:
            errors.append(f"{skill_name}: Missing {section}")

    # Check for forbidden patterns
    if "<" in content and ">" in content:
        warnings.append(f"{skill_name}: Contains HTML tags")

    if "http://" in content:
        warnings.append(f"{skill_name}: Uses http instead of https")

    # Check directory structure
    for subdir in ["scripts", "references", "assets"]:
        if (skill_path / subdir).exists():
            # Check for executable permissions on scripts
            if subdir == "scripts":
                for script in (skill_path / subdir).glob("*"):
                    if script.suffix in [".sh", ".py"]:
                        if not os.access(script, os.X_OK):
                            warnings.append(f"{skill_name}: {subdir}/{script.name} not executable")

    # Check for absolute paths in SKILL.md
    lines = content.split("\n")
    for i, line in enumerate(lines, 1):
        if line.strip().startswith("/"):
            errors.append(f"{skill_name}: Line {i} has absolute path")

    # Check file size
    total_size = sum(f.stat().st_size for f in skill_path.rglob("*") if f.is_file())
    if total_size > 10 * 1024 * 1024:  # 10MB
        warnings.append(f"{skill_name}: Large size ({total_size / 1024 / 1024:.1f}MB)")

    return errors, warnings

def main():
    skills_dir = Path("skills")

    if not skills_dir.exists():
        print("No skills directory found")
        sys.exit(0)

    all_errors = []
    all_warnings = []

    for skill_path in skills_dir.iterdir():
        if skill_path.is_dir():
            errors, warnings = validate_skill(skill_path)
            all_errors.extend(errors)
            all_warnings.extend(warnings)

    # Write report
    report_path = Path("/tmp/validation-report.txt")
    with open(report_path, "w") as f:
        if all_errors:
            f.write("❌ ERRORS:\n")
            for error in all_errors:
                f.write(f"  - {error}\n")
            f.write("\n")

        if all_warnings:
            f.write("⚠️ WARNINGS:\n")
            for warning in all_warnings:
                f.write(f"  - {warning}\n")
            f.write("\n")

        if not all_errors and not all_warnings:
            f.write("✅ All validations passed!\n")

    print(report_path.read_text())

    # Exit with error if critical issues
    if all_errors:
        sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()