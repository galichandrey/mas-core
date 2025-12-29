#!/usr/bin/env python3
"""
Meta System Validator - Skills Validation Module
Validates structure and content of all skills in .claude/skills/
"""

import os
import yaml
import json
from pathlib import Path
from typing import List, Dict, Tuple

class SkillsValidator:
    def __init__(self, skills_dir: str = ".claude/skills"):
        self.skills_dir = Path(skills_dir)
        self.issues = []
        self.warnings = []

    def validate_all(self) -> Dict:
        """Validate all skills and return report"""
        if not self.skills_dir.exists():
            return {
                "status": "fail",
                "message": "Skills directory not found",
                "score": 0
            }

        skills = list(self.skills_dir.iterdir())
        if not skills:
            return {
                "status": "warning",
                "message": "No skills found",
                "score": 0
            }

        results = []
        total_score = 0

        for skill_path in skills:
            if skill_path.is_dir():
                result = self.validate_skill(skill_path)
                results.append(result)
                total_score += result.get("score", 0)

        avg_score = total_score / len(results) if results else 0

        return {
            "status": "pass" if avg_score >= 80 else "warning" if avg_score >= 60 else "fail",
            "overall_score": round(avg_score, 1),
            "skills_checked": len(results),
            "results": results,
            "issues": self.issues,
            "warnings": self.warnings
        }

    def validate_skill(self, skill_path: Path) -> Dict:
        """Validate a single skill"""
        skill_name = skill_path.name
        result = {
            "name": skill_name,
            "score": 0,
            "checks": [],
            "status": "pass"
        }

        # Check 1: SKILL.md exists
        skill_md = skill_path / "SKILL.md"
        if not skill_md.exists():
            result["checks"].append({
                "check": "SKILL.md exists",
                "status": "fail",
                "message": "Missing SKILL.md file"
            })
            result["status"] = "fail"
            self.issues.append(f"{skill_name}: Missing SKILL.md")
            return result

        result["checks"].append({
            "check": "SKILL.md exists",
            "status": "pass"
        })
        result["score"] += 20

        # Check 2: SKILL.md format
        try:
            content = skill_md.read_text()

            # Check for basic required sections (any skill should have these)
            # Look for header (starts with #), Overview, Purpose, Capabilities
            has_header = content.startswith("#") or "\n#" in content
            has_overview = "## Overview" in content
            has_purpose = "## Purpose" in content
            has_capabilities = "## Capabilities" in content
            has_usage = "## Usage" in content or "## Usage Examples" in content

            # Count how many required sections are present
            required_count = sum([has_header, has_purpose, has_capabilities])
            optional_count = sum([has_overview, has_usage])

            if required_count >= 2:  # At least 2 of 3 required
                result["checks"].append({
                    "check": "SKILL.md format",
                    "status": "pass",
                    "message": f"Required sections: {required_count}/3, Optional: {optional_count}/2"
                })
                result["score"] += 20
            elif required_count >= 1:
                result["checks"].append({
                    "check": "SKILL.md format",
                    "status": "warning",
                    "message": f"Minimal format ({required_count}/3 required sections)"
                })
                self.warnings.append(f"{skill_name}: Minimal format")
                result["score"] += 10
            else:
                result["checks"].append({
                    "check": "SKILL.md format",
                    "status": "fail",
                    "message": "Insufficient required sections"
                })
                result["status"] = "fail"
                self.issues.append(f"{skill_name}: Missing required sections")

        except Exception as e:
            result["checks"].append({
                "check": "SKILL.md format",
                "status": "fail",
                "message": str(e)
            })
            result["status"] = "fail"
            self.issues.append(f"{skill_name}: SKILL.md read error - {e}")

        # Check 3: Directory structure
        required_dirs = ["scripts", "references", "assets"]
        for dir_name in required_dirs:
            dir_path = skill_path / dir_name
            if dir_path.exists():
                result["checks"].append({
                    "check": f"{dir_name}/ exists",
                    "status": "pass"
                })
                result["score"] += 5
            else:
                result["checks"].append({
                    "check": f"{dir_name}/ exists",
                    "status": "warning",
                    "message": "Optional directory missing"
                })
                self.warnings.append(f"{skill_name}: Missing optional directory {dir_name}")
                result["score"] += 2

        # Check 4: No duplicate files
        all_files = list(skill_path.rglob("*"))
        python_files = [f for f in all_files if f.suffix == ".py"]
        if len(python_files) > 0:
            result["checks"].append({
                "check": "Python scripts",
                "status": "pass",
                "message": f"{len(python_files)} script(s) found"
            })
            result["score"] += 10

        # Check 5: Metadata in SKILL.md
        metadata_fields = ["## Author", "## Version", "## Tags"]
        found_fields = [f for f in metadata_fields if f in content]
        if len(found_fields) >= 2:
            result["checks"].append({
                "check": "Metadata fields",
                "status": "pass",
                "message": f"{len(found_fields)}/{len(metadata_fields)} fields present"
            })
            result["score"] += 15
        else:
            result["checks"].append({
                "check": "Metadata fields",
                "status": "warning",
                "message": "Some metadata fields missing"
            })
            self.warnings.append(f"{skill_name}: Incomplete metadata")
            result["score"] += 8

        # Normalize score to 100
        result["score"] = min(result["score"], 100)

        return result

def main():
    """CLI entry point"""
    import argparse

    parser = argparse.ArgumentParser(description="Validate MAS skills")
    parser.add_argument("--skills-dir", default=".claude/skills", help="Skills directory")
    parser.add_argument("--format", choices=["text", "json"], default="text", help="Output format")

    args = parser.parse_args()

    validator = SkillsValidator(args.skills_dir)
    report = validator.validate_all()

    if args.format == "json":
        print(json.dumps(report, indent=2))
    else:
        print(f"\n{'='*60}")
        print(f"SKILLS VALIDATION REPORT")
        print(f"{'='*60}\n")

        if report["status"] == "fail":
            print(f"❌ VALIDATION FAILED")
        elif report["status"] == "warning":
            print(f"⚠️  VALIDATION WARNINGS")
        else:
            print(f"✅ VALIDATION PASSED")

        print(f"\nOverall Score: {report['overall_score']}/100")
        print(f"Skills Checked: {report['skills_checked']}")

        if report["issues"]:
            print(f"\n❌ Critical Issues ({len(report['issues'])}):")
            for issue in report["issues"]:
                print(f"  - {issue}")

        if report["warnings"]:
            print(f"\n⚠️  Warnings ({len(report['warnings'])}):")
            for warning in report["warnings"]:
                print(f"  - {warning}")

        print(f"\n{'='*60}\n")

if __name__ == "__main__":
    main()