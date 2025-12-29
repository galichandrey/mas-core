#!/usr/bin/env python3
"""
Meta Component Updater - Updates MAS skills with version management
"""

import os
import sys
import json
import shutil
import yaml
from datetime import datetime
from pathlib import Path

class SkillUpdater:
    def __init__(self, skill_name, target_version, source_dir):
        self.skill_name = skill_name
        self.target_version = target_version
        self.source_dir = Path(source_dir)
        self.skill_dir = self.source_dir / ".claude" / "skills" / skill_name
        self.backup_dir = self.source_dir / ".meta-backups" / f"{skill_name}-{datetime.now().strftime('%Y%m%d-%H%M%S')}"

    def backup_current(self):
        """Create backup of current skill version"""
        if not self.skill_dir.exists():
            print(f"❌ Skill {self.skill_name} not found")
            return False

        self.backup_dir.mkdir(parents=True, exist_ok=True)
        shutil.copytree(self.skill_dir, self.backup_dir / "skill")

        # Save current version info
        version_info = {
            "skill": self.skill_name,
            "version": self.get_current_version(),
            "timestamp": datetime.now().isoformat(),
            "backup_path": str(self.backup_dir)
        }

        with open(self.backup_dir / "version-info.json", "w") as f:
            json.dump(version_info, f, indent=2)

        print(f"✅ Backup created: {self.backup_dir}")
        return True

    def get_current_version(self):
        """Extract current version from SKILL.md"""
        skill_md = self.skill_dir / "SKILL.md"
        if not skill_md.exists():
            return "1.0.0"

        content = skill_md.read_text()
        # Look for version in frontmatter or comments
        if "version:" in content:
            for line in content.split("\n"):
                if "version:" in line:
                    return line.split(":")[1].strip()
        return "1.0.0"

    def update_version_info(self, new_version, changelog):
        """Update SKILL.md with new version"""
        skill_md = self.skill_dir / "SKILL.md"
        content = skill_md.read_text()

        # Add version to frontmatter if not exists
        lines = content.split("\n")
        frontmatter_end = -1

        for i, line in enumerate(lines):
            if line.strip() == "---" and i > 0:
                frontmatter_end = i
                break

        if frontmatter_end > 0:
            # Insert version after description
            for i in range(1, frontmatter_end):
                if "description:" in lines[i]:
                    lines.insert(i + 1, f"version: {new_version}")
                    break

        # Add changelog section
        lines.extend([
            "",
            "## Version History",
            "",
            f"### {new_version}",
            f"Released: {datetime.now().strftime('%Y-%m-%d')}",
            "",
            changelog
        ])

        skill_md.write_text("\n".join(lines))
        print(f"✅ Version updated to {new_version}")

    def create_migration_script(self, old_version, new_version):
        """Generate migration script"""
        migration_dir = self.skill_dir / "migrations"
        migration_dir.mkdir(exist_ok=True)

        script_path = migration_dir / f"migrate-{old_version}-to-{new_version}.sh"

        script_content = f"""#!/bin/bash
# Migration script: {self.skill_name} {old_version} → {new_version}
# Generated: {datetime.now().isoformat()}

set -e

echo "Migrating {self.skill_name} from {old_version} to {new_version}..."

# Backup current state
BACKUP_DIR="./backup-{self.skill_name}-{old_version}"
mkdir -p "$BACKUP_DIR"
cp -r .claude/skills/{self.skill_name}/* "$BACKUP_DIR/"

# Apply changes
echo "Applying updates..."

# TODO: Add specific migration steps here
# Example:
# 1. Update SKILL.md structure
# 2. Migrate scripts if needed
# 3. Update references
# 4. Handle breaking changes

echo "Migration complete!"
echo "Backup saved to: $BACKUP_DIR"
echo "To rollback: run rollback-{old_version}.sh"
"""

        script_path.write_text(script_content)
        script_path.chmod(0o755)

        # Also create rollback script
        rollback_path = migration_dir / f"rollback-{new_version}-to-{old_version}.sh"
        rollback_content = f"""#!/bin/bash
# Rollback script: {self.skill_name} {new_version} → {old_version}
# Generated: {datetime.now().isoformat()}

set -e

echo "Rolling back {self.skill_name} from {new_version} to {old_version}..."

if [ ! -d "./backup-{self.skill_name}-{old_version}" ]; then
    echo "❌ Backup not found!"
    exit 1
fi

# Restore from backup
rm -rf .claude/skills/{self.skill_name}
cp -r "./backup-{self.skill_name}-{old_version}" .claude/skills/{self.skill_name}

echo "✅ Rollback complete!"
echo "Restored to version {old_version}"
"""

        rollback_path.write_text(rollback_content)
        rollback_path.chmod(0o755)

        print(f"✅ Migration scripts created:")
        print(f"   - {script_path}")
        print(f"   - {rollback_path}")

    def validate_update(self):
        """Validate the updated skill"""
        checks = []

        # Check SKILL.md exists
        if (self.skill_dir / "SKILL.md").exists():
            checks.append(("SKILL.md exists", True))
        else:
            checks.append(("SKILL.md exists", False))

        # Check frontmatter
        skill_md = self.skill_dir / "SKILL.md"
        if skill_md.exists():
            content = skill_md.read_text()
            if "---" in content and "name:" in content:
                checks.append(("Valid frontmatter", True))
            else:
                checks.append(("Valid frontmatter", False))

        # Check resource directories
        for subdir in ["scripts", "references", "assets"]:
            if (self.skill_dir / subdir).exists():
                checks.append((f"{subdir}/ exists", True))
            else:
                checks.append((f"{subdir}/ exists", False))

        # Print results
        print("\n📊 Validation Results:")
        all_passed = True
        for check, passed in checks:
            status = "✅" if passed else "❌"
            print(f"  {status} {check}")
            if not passed:
                all_passed = False

        return all_passed

    def update(self, changelog=""):
        """Main update workflow"""
        print(f"\n🔄 Updating {self.skill_name} to v{self.target_version}")

        # Step 1: Backup
        if not self.backup_current():
            return False

        # Step 2: Update version info
        self.update_version_info(self.target_version, changelog)

        # Step 3: Create migration scripts
        old_version = self.get_current_version()
        self.create_migration_script(old_version, self.target_version)

        # Step 4: Validate
        if self.validate_update():
            print(f"\n✅ Update complete! {self.skill_name} is now v{self.target_version}")
            print(f"   Backup: {self.backup_dir}")
            return True
        else:
            print(f"\n⚠️ Update completed with warnings")
            return False

    def rollback(self, version=None):
        """Rollback to previous version"""
        print(f"\n🔄 Rolling back {self.skill_name}")

        # Find latest backup
        backups = list((self.source_dir / ".meta-backups").glob(f"{self.skill_name}-*"))
        if not backups:
            print("❌ No backups found")
            return False

        latest_backup = max(backups, key=os.path.getmtime)
        info_file = latest_backup / "version-info.json"

        if not info_file.exists():
            print("❌ Backup info not found")
            return False

        with open(info_file) as f:
            info = json.load(f)

        # Restore
        shutil.rmtree(self.skill_dir)
        shutil.copytree(latest_backup / "skill", self.skill_dir)

        print(f"✅ Rolled back to version {info['version']}")
        print(f"   From: {latest_backup}")
        return True

def main():
    if len(sys.argv) < 3:
        print("Usage: updater.py <skill-name> <target-version> [changelog]")
        sys.exit(1)

    skill_name = sys.argv[1]
    target_version = sys.argv[2]
    changelog = sys.argv[3] if len(sys.argv) > 3 else "Version update"

    updater = SkillUpdater(skill_name, target_version, ".")

    if "rollback" in sys.argv:
        updater.rollback()
    else:
        updater.update(changelog)

if __name__ == "__main__":
    main()