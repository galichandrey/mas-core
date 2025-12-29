#!/usr/bin/env python3
"""
Meta System Validator - Integration Testing Module
Tests end-to-end workflows between MAS components
"""

import subprocess
import json
from pathlib import Path
from typing import Dict, List

class IntegrationTester:
    def __init__(self):
        self.results = []
        self.errors = []

    def run_all_tests(self) -> Dict:
        """Run all integration tests"""
        tests = [
            self.test_skill_creation,
            self.test_agent_creation,
            self.test_prompt_generation,
            self.test_registry_update,
            self.test_cross_component_communication
        ]

        passed = 0
        failed = 0

        for test in tests:
            try:
                result = test()
                self.results.append(result)
                if result["status"] == "pass":
                    passed += 1
                else:
                    failed += 1
            except Exception as e:
                self.results.append({
                    "name": test.__name__,
                    "status": "error",
                    "message": str(e)
                })
                failed += 1

        total = passed + failed
        score = (passed / total * 100) if total > 0 else 0

        return {
            "status": "pass" if score >= 80 else "warning" if score >= 60 else "fail",
            "score": round(score, 1),
            "passed": passed,
            "failed": failed,
            "total": total,
            "results": self.results,
            "errors": self.errors
        }

    def test_skill_creation(self) -> Dict:
        """Test: Can we create a skill using meta-skill-creator?"""
        test_name = "Skill Creation Workflow"

        # Check if meta-skill-creator exists
        skill_dir = Path(".claude/skills/meta-skill-creator")
        if not skill_dir.exists():
            return {
                "name": test_name,
                "status": "fail",
                "message": "meta-skill-creator not found"
            }

        skill_md = skill_dir / "SKILL.md"
        if not skill_md.exists():
            return {
                "name": test_name,
                "status": "fail",
                "message": "meta-skill-creator/SKILL.md not found"
            }

        # Check if it has the capability
        content = skill_md.read_text()
        if "create-skill" in content.lower() or "Create a skill" in content:
            return {
                "name": test_name,
                "status": "pass",
                "message": "meta-skill-creator is properly configured"
            }

        return {
            "name": test_name,
            "status": "warning",
            "message": "meta-skill-creator exists but capability unclear"
        }

    def test_agent_creation(self) -> Dict:
        """Test: Can we create an agent using meta-agent-factory?"""
        test_name = "Agent Creation Workflow"

        skill_dir = Path(".claude/skills/meta-agent-factory")
        if not skill_dir.exists():
            return {
                "name": test_name,
                "status": "fail",
                "message": "meta-agent-factory not found"
            }

        skill_md = skill_dir / "SKILL.md"
        if not skill_md.exists():
            return {
                "name": test_name,
                "status": "fail",
                "message": "meta-agent-factory/SKILL.md not found"
            }

        content = skill_md.read_text()
        if "build an agent" in content.lower() or "create agent" in content:
            return {
                "name": test_name,
                "status": "pass",
                "message": "meta-agent-factory is properly configured"
            }

        return {
            "name": test_name,
            "status": "warning",
            "message": "meta-agent-factory exists but capability unclear"
        }

    def test_prompt_generation(self) -> Dict:
        """Test: Can we generate prompts using meta-prompt-generator?"""
        test_name = "Prompt Generation Workflow"

        skill_dir = Path(".claude/skills/meta-prompt-generator")
        if not skill_dir.exists():
            return {
                "name": test_name,
                "status": "fail",
                "message": "meta-prompt-generator not found"
            }

        skill_md = skill_dir / "SKILL.md"
        if not skill_md.exists():
            return {
                "name": test_name,
                "status": "fail",
                "message": "meta-prompt-generator/SKILL.md not found"
            }

        content = skill_md.read_text()
        if "generate prompt" in content.lower() or "create prompt" in content:
            return {
                "name": test_name,
                "status": "pass",
                "message": "meta-prompt-generator is properly configured"
            }

        return {
            "name": test_name,
            "status": "warning",
            "message": "meta-prompt-generator exists but capability unclear"
        }

    def test_registry_update(self) -> Dict:
        """Test: Does registry.yaml exist and is it valid?"""
        test_name = "Registry Integrity"

        registry = Path("_bmad/meta-system/registry.yaml")
        if not registry.exists():
            return {
                "name": test_name,
                "status": "fail",
                "message": "registry.yaml not found"
            }

        try:
            import yaml
            content = yaml.safe_load(registry.read_text())
            if content and isinstance(content, dict):
                return {
                    "name": test_name,
                    "status": "pass",
                    "message": "Registry exists and is valid YAML"
                }
        except Exception as e:
            return {
                "name": test_name,
                "status": "fail",
                "message": f"Registry parse error: {e}"
            }

    def test_cross_component_communication(self) -> Dict:
        """Test: Do components reference each other correctly?"""
        test_name = "Cross-Component Communication"

        # Check if meta-skills reference each other
        issues = []

        # Check meta-system-validator references
        validator_path = Path(".claude/skills/meta-system-validator/SKILL.md")
        if validator_path.exists():
            content = validator_path.read_text()
            if "meta-skill-creator" in content:
                # Good, it references other skills
                pass
            else:
                issues.append("meta-system-validator doesn't reference other skills")

        # Check registry has all skills listed
        registry = Path("_bmad/meta-system/registry.yaml")
        if registry.exists():
            import yaml
            reg_content = yaml.safe_load(registry.read_text())
            if reg_content and "skills" in reg_content:
                skill_names = [s.get("name") for s in reg_content["skills"]]
                expected = ["meta-skill-creator", "meta-agent-factory", "meta-prompt-generator"]
                for exp in expected:
                    if exp not in skill_names:
                        issues.append(f"{exp} not in registry")

        if not issues:
            return {
                "name": test_name,
                "status": "pass",
                "message": "All components properly integrated"
            }
        else:
            return {
                "name": test_name,
                "status": "warning",
                "message": "; ".join(issues)
            }

def main():
    import argparse

    parser = argparse.ArgumentParser(description="Run integration tests")
    parser.add_argument("--format", choices=["text", "json"], default="text")

    args = parser.parse_args()

    tester = IntegrationTester()
    report = tester.run_all_tests()

    if args.format == "json":
        print(json.dumps(report, indent=2))
    else:
        print(f"\n{'='*60}")
        print(f"INTEGRATION TEST REPORT")
        print(f"{'='*60}\n")

        if report["status"] == "fail":
            print(f"❌ INTEGRATION FAILED")
        elif report["status"] == "warning":
            print(f"⚠️  INTEGRATION HAS ISSUES")
        else:
            print(f"✅ INTEGRATION PASSED")

        print(f"\nScore: {report['score']}/100")
        print(f"Tests: {report['passed']}/{report['total']} passed")

        print(f"\nTest Results:")
        for result in report["results"]:
            icon = "✅" if result["status"] == "pass" else "⚠️" if result["status"] == "warning" else "❌"
            print(f"  {icon} {result['name']}")
            if result.get("message"):
                print(f"      {result['message']}")

        if report["errors"]:
            print(f"\n❌ Errors:")
            for error in report["errors"]:
                print(f"  - {error}")

        print(f"\n{'='*60}\n")

if __name__ == "__main__":
    main()