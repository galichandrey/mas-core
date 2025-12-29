# GitHub Repository Setup Guide

## Current Status

✅ **Local repository ready:**
- Git initialized
- All files committed (64 files, 16k+ lines)
- Main branch created
- Commit: "feat(mas): Initial MAS v2.0 release"

## Next Steps (Manual)

### 1. Create GitHub Repository

**Option A: Via GitHub Web**
1. Go to https://github.com/new
2. Repository name: `mas-core`
3. Description: `Meta Agentic System - Self-building ecosystem for AI development tools`
4. Visibility: **Public**
5. Initialize with README: **NO** (we have our own)
6. Add .gitignore: **NO** (we have our own)
7. License: **MIT** (optional)
8. Click **Create Repository**

**Option B: Via GitHub CLI** (if working)
```bash
gh repo create mas-core --public --description "Meta Agentic System - Self-building ecosystem for AI development tools" --clone
```

### 2. Push to GitHub

After creating the repository, run:

```bash
cd ~/dev/mas-core

# Add remote (replace YOUR_USERNAME with actual username)
git remote add origin https://github.com/YOUR_USERNAME/mas-core.git

# Verify remote
git remote -v

# Push to GitHub
git push -u origin main
```

### 3. Create First Release

```bash
# Create tag
git tag v2.0.0

# Push tag
git push origin v2.0.0

# Or create via GitHub CLI
gh release create v2.0.0 --title "MAS v2.0 - Initial Release" --notes-file RELEASE-NOTES.md
```

### 4. Configure GitHub Actions (Optional)

**Manual setup:**
1. Go to repository Settings
2. Actions → General
3. Allow all actions
4. Enable workflow permissions

**Or create workflows manually:**

Create `.github/workflows/validate.yml`:
```yaml
name: Validate Skills
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with: { python-version: '3.11' }
      - run: pip install pyyaml
      - run: python3 .claude/skills/meta-system-validator/scripts/validate-skills.py --skills-dir .claude/skills
```

## Release Notes Template

Create `RELEASE-NOTES.md`:

```markdown
# MAS v2.0 - Initial Release

## What's New

### Meta Component Updater ⭐ NEW
- Version management with semantic versioning
- Automatic backup before updates
- Migration script generation
- Rollback capability
- Dependency tracking

### Enhanced Installer
- One-line installation: `curl -sSL https://get.mas.dev | bash`
- Full system or single skill installation
- Update mode for existing installations

### 5 Meta Skills
1. **meta-skill-creator** - Creates complete skill packages
2. **meta-agent-factory** - Builds specialized agents
3. **meta-prompt-generator** - Generates optimized prompts
4. **meta-system-validator** - Validates system integrity
5. **meta-component-updater** - Updates other skills (NEW)

## Installation

```bash
# Full installation
curl -sSL https://get.mas.dev | bash

# Or from GitHub
git clone https://github.com/YOUR_USERNAME/mas-core.git
cd mas-core
./scripts/installer.sh
```

## Usage

```bash
# Create a skill
"Create a skill named data-processor for CSV handling"

# Update a skill
python3 .claude/skills/meta-component-updater/scripts/updater.py skill-name 2.0.0

# Validate system
"Use meta-system-validator to validate current project"
```

## Documentation

- [README.md](README.md) - Overview and quick start
- [CHANGELOG.md](CHANGELOG.md) - Version history
- [USAGE.md](_bmad/meta-system/USAGE.md) - Detailed usage guide

## Next Steps

- Epic 3.2: GitHub Marketplace setup
- Epic 3.3: Enhanced MCP server
- Epic 3.4: Recursive improvement engine

---

**Full changelog:** [CHANGELOG.md](CHANGELOG.md)
```

## Post-Release Checklist

- [ ] Repository is public
- [ ] README renders correctly
- [ ] All files are visible
- [ ] Release v2.0.0 is created
- [ ] GitHub Actions are enabled (optional)
- [ ] Repository URL is shared

## Repository Structure Preview

```
mas-core/
├── .claude/skills/          # 5 meta-skills
├── _bmad/meta-system/       # Core system
├── scripts/                 # Installers
├── .github/                 # GitHub config
├── README.md                # Main docs
├── CHANGELOG.md             # Version history
└── GITHUB-SETUP.md          # This file
```

## Troubleshooting

### Permission denied when pushing
```bash
# Check authentication
gh auth status

# Re-authenticate if needed
gh auth login
```

### Remote already exists
```bash
# Remove existing remote
git remote remove origin

# Add new one
git remote add origin https://github.com/YOUR_USERNAME/mas-core.git
```

### Need to update before pushing
```bash
# Pull latest if repo existed
git pull origin main --allow-unrelated-histories

# Resolve conflicts if any
# Then push
git push origin main
```

---

**Ready to launch! 🚀**