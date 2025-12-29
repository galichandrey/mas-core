#!/usr/bin/env python3
"""
Security scan for submitted skills
"""

import os
import sys
import re
from pathlib import Path

# Patterns that indicate potential security issues
DANGEROUS_PATTERNS = [
    (r"os\.system\(", "os.system() is dangerous, use subprocess"),
    (r"eval\(", "eval() is dangerous"),
    (r"exec\(", "exec() is dangerous"),
    (r"subprocess\.call\(", "Use subprocess.run() with shell=False"),
    (r"shell=True", "shell=True is dangerous"),
    (r"input\(", "input() can cause blocking"),
    (r"__import__\(", "Dynamic imports are risky"),
    (r"open\([^)]*['\"]w['\"]", "File writing operations"),
    (r"https?://[^\s'\"<>]*token", "Potential token leak"),
    (r"password\s*=\s*['\"]", "Hardcoded passwords"),
    (r"secret\s*=\s*['\"]", "Hardcoded secrets"),
]

# Allowed external domains
ALLOWED_DOMAINS = [
    "raw.githubusercontent.com",
    "github.com",
    "api.github.com",
]

def scan_file(filepath):
    """Scan a file for security issues"""
    issues = []

    try:
        content = filepath.read_text()
    except:
        return issues

    for pattern, message in DANGEROUS_PATTERNS:
        if re.search(pattern, content, re.IGNORECASE):
            issues.append(f"{filepath.name}: {message}")

    # Check for external URLs
    urls = re.findall(r'https?://[^\s\'"<>]+', content)
    for url in urls:
        domain = url.split("/")[2] if "/" in url else ""
        if domain and domain not in ALLOWED_DOMAINS:
            issues.append(f"{filepath.name}: External URL {url} (not in whitelist)")

    return issues

def main():
    skills_dir = Path("skills")

    if not skills_dir.exists():
        print("No skills directory")
        sys.exit(0)

    all_issues = []

    for skill_path in skills_dir.rglob("*"):
        if skill_path.is_file() and skill_path.suffix in [".py", ".sh", ".js"]:
            issues = scan_file(skill_path)
            all_issues.extend(issues)

    if all_issues:
        print("❌ SECURITY ISSUES FOUND:")
        for issue in all_issues:
            print(f"  - {issue}")
        sys.exit(1)
    else:
        print("✅ No security issues found")
        sys.exit(0)

if __name__ == "__main__":
    main()