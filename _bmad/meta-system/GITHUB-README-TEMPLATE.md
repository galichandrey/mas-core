# MAS Marketplace

**Meta Agentic System - Community Skills Registry**

> "The tool that creates tools. The agent that builds agents."

---

## 🚀 Quick Start (30 seconds)

### Install MAS
```bash
curl -sSL https://get.mas.dev | bash
```

### Install a skill
```bash
# Browse marketplace
./_bmad/meta-system/export-tools/marketplace.sh --list

# Install specific skill
./_bmad/meta-system/export-tools/marketplace.sh --install data-validator
```

### Use with Claude
```bash
# Via MCP (recommended)
"Install skill data-validator from marketplace"

# Or via commands
"Search skills for testing"
"Show info about data-validator"
```

---

## 📦 What is MAS Marketplace?

A **centralized registry** of verified skills, agents, and prompts for the Meta Agentic System.

### Features
- ✅ **Verified skills** - Security scanned and validated
- ✅ **One-line install** - `curl | bash` installation
- ✅ **Auto-updates** - Keep skills current
- ✅ **MCP integration** - Voice commands via Claude
- ✅ **Community driven** - Submit your skills

---

## 🎯 Popular Skills

### Data Processing
- **data-validator** - JSON/CSV/XML validation
- **csv-processor** - Advanced CSV operations
- **json-schema** - Schema validation

### Testing
- **frontend-test-gen** - React component tests
- **api-tester** - REST API testing
- **e2e-workflow** - End-to-end tests

### DevOps
- **deploy-helper** - Deployment automation
- **monitor-bot** - System monitoring
- **security-scan** - Vulnerability scanning

### Productivity
- **code-reviewer** - AI code review
- **docs-generator** - Auto documentation
- **refactor-helper** - Code refactoring

---

## 📚 Installation Options

### Option 1: Full System (Recommended)
```bash
curl -sSL https://get.mas.dev | bash
```
Installs: 4 meta-skills + all export tools

### Option 2: Minimal
```bash
curl -sSL https://get.mas.dev | bash -s -- --mode minimal
```
Installs: Export tools only

### Option 3: Specific Skill
```bash
curl -sSL https://get.mas.dev | bash -s -- --mode skill-only
./_bmad/meta-system/export-tools/marketplace.sh --install skill-name
```

### Option 4: From GitHub
```bash
git clone https://github.com/mas-marketplace/mas-core.git ~/.mas
cd ~/.mas
./scripts/installer.sh --target ~/my-project
```

---

## 🔧 Core Tools

### 1. Marketplace Browser
```bash
# List all skills
./marketplace.sh --list

# Search
./marketplace.sh --search "testing"

# Get info
./marketplace.sh --info data-validator

# Validate before install
./marketplace.sh --validate data-validator
```

### 2. Skill Publisher
```bash
# Prepare skill
./publisher.sh --prepare my-skill

# Submit to marketplace
./publisher.sh --submit my-skill

# Local publish
./publisher.sh --local my-skill /shared/marketplace
```

### 3. System Updater
```bash
# Check for updates
./updater.sh --check

# Update
./updater.sh

# Update all projects
./updater.sh --bulk ~/projects/*
```

### 4. MCP Server
```bash
# Start MCP server
node _bmad/meta-system/mcp-server/index.js

# Use with Claude Desktop
# See: _bmad/meta-system/mcp-server/README.md
```

---

## 🤝 Contributing

### Submit a Skill

1. **Create your skill**
   ```bash
   "Create a skill named my-skill for [purpose]"
   ```

2. **Validate it**
   ```bash
   ./_bmad/meta-system/export-tools/publisher.sh --prepare my-skill
   ```

3. **Submit PR**
   ```bash
   ./_bmad/meta-system/export-tools/publisher.sh --submit my-skill
   ```

4. **Wait for review**
   - CI validates automatically
   - Community reviews
   - Merged when approved

### Requirements
- ✅ SKILL.md with all sections
- ✅ Hyphen-case naming
- ✅ No hardcoded secrets
- ✅ Security scan passes
- ✅ Documentation complete

---

## 🏗️ Repository Structure

```
mas-marketplace/
├── skills/                      # Published skills
│   ├── data-validator/
│   ├── frontend-test-gen/
│   └── api-tester/
├── registry.json                # Master registry
├── .github/
│   ├── workflows/
│   │   ├── validate-skill.yml   # CI validation
│   │   └── release.yml          # Auto-release
│   └── scripts/
│       ├── validate_skills.py
│       ├── security_scan.py
│       └── test_integration.py
├── mas-core/                    # MAS system files
│   ├── export-tools/
│   ├── registry.yaml
│   └── README.md
└── mcp-server/                  # MCP integration
    ├── index.js
    └── package.json
```

---

## 🔒 Security

### Validation Pipeline
Every skill submission goes through:

1. **Structure Check** - File organization
2. **Format Validation** - SKILL.md format
3. **Security Scan** - Dangerous patterns
4. **Integration Test** - Does it work?
5. **Manual Review** - Community approval

### Verified Status
- ✅ **Verified** - All checks passed
- ⚠️ **Pending** - Under review
- ❌ **Rejected** - Failed checks

---

## 📊 Statistics

```
Total Skills: 100+
Categories: 7
Downloads: 1M+
Rating: 4.8/5.0
Verified: 95%
```

---

## 💬 Usage Examples

### Example 1: Daily Workflow
```bash
# 1. Check for updates
./updater.sh --check

# 2. Browse new skills
./marketplace.sh --search "new"

# 3. Install useful skill
./marketplace.sh --install data-validator

# 4. Validate installation
./_bmad/meta-system/export-tools/validate-system.sh
```

### Example 2: Team Collaboration
```bash
# 1. Create shared skill
"Create a skill named team-standards for code guidelines"

# 2. Publish to team marketplace
./publisher.sh --local team-standards /shared/marketplace

# 3. Team installs
./install-from-marketplace.sh --local /shared/marketplace team-standards

# 4. Everyone validates
./validate-system.sh
```

### Example 3: Open Source Contribution
```bash
# 1. Fork mas-marketplace
gh repo fork mas-marketplace/mas-core --clone=true

# 2. Create branch
git checkout -b submit/my-awesome-skill

# 3. Add skill
cp -r /path/to/skill skills/my-awesome-skill/

# 4. Update registry
# Edit registry.json

# 5. Submit PR
git add . && git commit -m "Add my-awesome-skill"
git push origin submit/my-awesome-skill
gh pr create --title "Submit my-awesome-skill"
```

---

## 🎓 Learning Resources

### Documentation
- [MAS Core README](mas-core/README.md)
- [MCP Server Guide](mcp-server/README.md)
- [Skill Creation Guide](docs/skill-creation.md)

### Tutorials
- [Creating your first skill](docs/tutorial-1.md)
- [Publishing to marketplace](docs/tutorial-2.md)
- [Building a team workflow](docs/tutorial-3.md)

---

## 🛠️ Development

### Local Setup
```bash
git clone https://github.com/mas-marketplace/mas-core.git
cd mas-core
npm install
```

### Testing
```bash
# Validate all skills
python3 .github/scripts/validate_skills.py

# Security scan
python3 .github/scripts/security_scan.py

# Integration tests
python3 .github/scripts/test_integration.py
```

### Release
```bash
# Create tag
git tag v1.2.0
git push origin v1.2.0

# GitHub Actions will:
# - Validate
# - Create release
# - Upload assets
# - Update registry
```

---

## 📞 Support

### Issues
- Bug reports: [GitHub Issues](https://github.com/mas-marketplace/mas-core/issues)
- Security: security@mas-marketplace.dev

### Community
- Discussions: [GitHub Discussions](https://github.com/mas-marketplace/mas-core/discussions)
- Discord: Coming soon

---

## 📄 License

MIT License - Feel free to use, modify, and share.

---

## 🌟 Contributors

<a href="https://github.com/mas-marketplace/mas-core/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mas-marketplace/mas-core" />
</a>

---

**Status:** 🚀 Active Development
**Version:** 1.1.0
**Last Updated:** 2025-12-29

---
*Built with MAS. For MAS. By MAS.*