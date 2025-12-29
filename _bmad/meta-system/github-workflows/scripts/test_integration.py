#!/usr/bin/env python3
"""
Integration tests for skills
"""

import os
import sys
import subprocess
from pathlib import Path

def test_skill(skill_path):
    """Test a single skill"""
    issues = []
    skill_name = skill_path.name

    # Check if SKILL.md can be parsed
    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        issues.append(f"{skill_name}: No SKILL.md")
        return issues

    content = skill_md.read_text()

    # Check for basic structure
    if "# " not in content:
        issues.append(f"{skill_name}: No header")

    if "## Overview" not in content:
        issues.append(f"{skill_name}: No Overview")

    # Test scripts if they exist
    scripts_dir = skill_path / "scripts"
    if scripts_dir.exists():
        for script in scripts_dir.glob("*"):
            if script.suffix in [".py", ".sh"]:
                # Check if executable
                if not os.access(script, os.X_OK):
                    issues.append(f"{skill_name}: {script.name} not executable")

                # Try to execute (dry run)
                try:
                    if script.suffix == ".py":
                        result = subprocess.run(
                            ["python3", "-m", "py_compile", str(script)],
                            capture_output=True,
                            timeout=5
                        )
                        if result.returncode != 0:
                            issues.append(f"{skill_name}: {script.name} syntax error")
                    elif script.suffix == ".sh":
                        result = subprocess.run(
                            ["bash", "-n", str(script)],
                            capture_output=True,
                            timeout=5
                        )
                        if result.returncode != 0:
                            issues.append(f"{skill_name}: {script.name} syntax error")
                except Exception as e:
                    issues.append(f"{skill_name}: {script.name} test failed: {e}")

    return issues

def main():
    skills_dir = Path("skills")

    if not skills_dir.exists():
        print("No skills directory")
        sys.exit(0)

    all_issues = []

    for skill_path in skills_dir.iterdir():
        if skill_path.is_dir():
            issues = test_skill(skill_path)
            all_issues.extend(issues)

    if all_issues:
        print("❌ INTEGRATION TESTS FAILED:")
        for issue in all_issues:
            print(f"  - {issue}")
        sys.exit(1)
    else:
        print("✅ All integration tests passed")
        sys.exit(0)

if __name__ == "__main__":
    main()