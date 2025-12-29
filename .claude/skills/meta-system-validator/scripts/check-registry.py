#!/usr/bin/env python3
"""
Meta System Validator - Registry Validation Module
Validates registry.yaml integrity and consistency
"""

import yaml
import json
from pathlib import Path
from typing import Dict, List

class RegistryValidator:
    def __init__(self, registry_path: str = "_bmad/meta-system/registry.yaml"):
        self.registry_path = Path(registry_path)
        self.issues = []
        self.warnings = []

    def validate(self) -> Dict:
        """Validate registry and return report"""
        if not self.registry_path.exists():
            return {
                "status": "fail",
                "message": "Registry file not found",
                "score": 0
            }

        try:
            content = yaml.safe_load(self.registry_path.read_text())
            if content is None:
                return {
                    "status": "fail",
                    "message": "Registry is empty",
                    "score": 0
                }

            score = 100
            checks = []

            # Check 1: Required top-level keys (supports both old and new formats)
            # New format: components -> skills/agents/prompts
            # Old format: skills/agents/prompts at top level

            if "components" in content:
                # New format
                components = content["components"]
                required_keys = ["meta_system", "skills", "agents", "prompts"]
                for key in required_keys:
                    if key in components:
                        checks.append({"check": f"Key 'components.{key}'", "status": "pass"})
                        score += 5
                    else:
                        checks.append({"check": f"Key 'components.{key}'", "status": "fail", "message": "Missing"})
                        self.issues.append(f"Missing required key: components.{key}")
                        score -= 10
                skills_container = components
            else:
                # Old format
                required_keys = ["meta_system", "skills", "agents", "prompts"]
                for key in required_keys:
                    if key in content:
                        checks.append({"check": f"Key '{key}'", "status": "pass"})
                        score += 5
                    else:
                        checks.append({"check": f"Key '{key}'", "status": "fail", "message": "Missing"})
                        self.issues.append(f"Missing required key: {key}")
                        score -= 10
                skills_container = content

            # Check 2: Skills structure
            if "skills" in skills_container:
                skills = skills_container["skills"]
                if isinstance(skills, list):
                    checks.append({"check": "Skills format", "status": "pass"})
                    score += 10

                    # Check for duplicates
                    names = [s.get("name") for s in skills if isinstance(s, dict)]
                    duplicates = [n for n in names if names.count(n) > 1]
                    if duplicates:
                        checks.append({"check": "No duplicates", "status": "fail", "message": str(duplicates)})
                        self.issues.append(f"Duplicate skills: {duplicates}")
                        score -= 15
                    else:
                        checks.append({"check": "No duplicates", "status": "pass"})
                        score += 10

                    # Check each skill has required fields
                    for skill in skills:
                        if isinstance(skill, dict):
                            if "name" not in skill:
                                self.warnings.append("Skill missing 'name' field")
                            if "path" not in skill:
                                self.warnings.append(f"Skill {skill.get('name')} missing 'path' field")
                else:
                    checks.append({"check": "Skills format", "status": "fail", "message": "Must be a list"})
                    score -= 20

            # Check 3: Version consistency
            meta_container = content if "components" not in content else content["components"]
            if "meta_system" in meta_container and isinstance(meta_container["meta_system"], dict):
                version = meta_container["meta_system"].get("version")
                if version:
                    checks.append({"check": "Version present", "status": "pass", "message": f"v{version}"})
                    score += 10
                else:
                    checks.append({"check": "Version present", "status": "warning"})
                    self.warnings.append("Version not specified")
                    score += 5

            # Check 4: Marketplace section (optional but recommended)
            if "marketplace" in content or "marketplace" in meta_container:
                checks.append({"check": "Marketplace config", "status": "pass"})
                score += 10
            else:
                checks.append({"check": "Marketplace config", "status": "warning", "message": "Optional but recommended"})
                self.warnings.append("Marketplace section missing")
                score += 5

            # Check 5: Dependencies resolution
            if "skills" in skills_container:
                all_skills = [s.get("name") for s in skills_container["skills"] if isinstance(s, dict)]
                for skill in skills_container["skills"]:
                    if isinstance(skill, dict) and "dependencies" in skill:
                        for dep in skill["dependencies"]:
                            if dep not in all_skills:
                                self.warnings.append(f"{skill.get('name')}: Unknown dependency {dep}")

            # Normalize score
            score = max(0, min(score, 100))

            status = "pass" if score >= 80 else "warning" if score >= 60 else "fail"

            return {
                "status": status,
                "score": score,
                "checks": checks,
                "issues": self.issues,
                "warnings": self.warnings,
                "metadata": {
                    "skills_count": len(skills_container.get("skills", [])),
                    "agents_count": len(skills_container.get("agents", [])),
                    "prompts_count": len(skills_container.get("prompts", []))
                }
            }

        except yaml.YAMLError as e:
            return {
                "status": "fail",
                "message": f"YAML parse error: {e}",
                "score": 0
            }
        except Exception as e:
            return {
                "status": "fail",
                "message": f"Unexpected error: {e}",
                "score": 0
            }

def main():
    import argparse

    parser = argparse.ArgumentParser(description="Validate registry.yaml")
    parser.add_argument("--registry", default="_bmad/meta-system/registry.yaml", help="Registry path")
    parser.add_argument("--format", choices=["text", "json"], default="text")

    args = parser.parse_args()

    validator = RegistryValidator(args.registry)
    report = validator.validate()

    if args.format == "json":
        print(json.dumps(report, indent=2))
    else:
        print(f"\n{'='*60}")
        print(f"REGISTRY VALIDATION REPORT")
        print(f"{'='*60}\n")

        if report["status"] == "fail":
            print(f"❌ REGISTRY INVALID")
        elif report["status"] == "warning":
            print(f"⚠️  REGISTRY HAS WARNINGS")
        else:
            print(f"✅ REGISTRY VALID")

        print(f"\nScore: {report['score']}/100")

        if "metadata" in report:
            meta = report["metadata"]
            print(f"Skills: {meta['skills_count']}")
            print(f"Agents: {meta['agents_count']}")
            print(f"Prompts: {meta['prompts_count']}")

        if report["issues"]:
            print(f"\n❌ Issues:")
            for issue in report["issues"]:
                print(f"  - {issue}")

        if report["warnings"]:
            print(f"\n⚠️  Warnings:")
            for warning in report["warnings"]:
                print(f"  - {warning}")

        print(f"\n{'='*60}\n")

if __name__ == "__main__":
    main()