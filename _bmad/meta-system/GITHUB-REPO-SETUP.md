# GitHub Repository Setup Guide

## 🎯 Goal
Create centralized MAS Marketplace on GitHub for easy distribution.

---

## 📋 Step-by-Step Setup

### Step 1: Create GitHub Organization
```bash
# Option A: Personal (for testing)
# Create: github.com/yourusername/mas-marketplace

# Option B: Official (production)
# Request: github.com/mas-marketplace
```

### Step 2: Create Core Repository
**Repository:** `mas-marketplace/mas-core`

**Purpose:** Main MAS system + installation scripts

**Structure:**
```
mas-core/
├── .github/
│   ├── workflows/
│   │   ├── validate-skill.yml
│   │   └── release.yml
│   ├── scripts/
│   │   ├── validate_skills.py
│   │   ├── security_scan.py
│   │   └── test_integration.py
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
├── _bmad/meta-system/
│   ├── export-tools/
│   │   ├── installer.sh          ⭐ NEW
│   │   ├── updater.sh            ⭐ NEW
│   │   ├── publisher.sh          ⭐ NEW
│   │   ├── marketplace.sh        ⭐ NEW
│   │   ├── install-from-marketplace.sh
│   │   ├── validate-system.sh
│   │   ├── export-system.sh
│   │   └── export-skill.sh
│   ├── registry.yaml
│   ├── README.md
│   └── docs/
│       ├── STRUCTURE.md
│       ├── USAGE.md
│       └── TROUBLESHOOTING.md
├── .claude/skills/
│   ├── meta-skill-creator/
│   ├── meta-agent-factory/
│   ├── meta-prompt-generator/
│   └── meta-system-validator/
├── mcp-server/
│   ├── index.js
│   ├── package.json
│   └── README.md
├── scripts/
│   └── installer.sh              ⭐ One-line installer
├── marketplace/
│   └── registry.json             ⭐ Master registry
├── README.md                     ⭐ Main documentation
└── CHANGELOG.md
```

**Setup Commands:**
```bash
# Create repository
gh repo create mas-marketplace/mas-core --public --clone

# Add files
cd mas-core
cp -r /path/to/your/project/_bmad/meta-system/* .
cp -r /path/to/your/project/.claude/skills/* .claude/skills/

# Add scripts
mkdir -p scripts
cp /path/to/your/project/_bmad/meta-system/export-tools/installer.sh scripts/

# Add marketplace registry
mkdir -p marketplace
cp /path/to/your/project/_bmad/meta-system/marketplace-registry-template.json marketplace/registry.json

# Add MCP server
mkdir -p mcp-server
cp /path/to/your/project/_bmad/meta-system/mcp-server/* mcp-server/

# Commit
git add .
git commit -m "Initial MAS v1.1.0 release"
git push origin main

# Create first release
git tag v1.1.0
git push origin v1.1.0
```

---

### Step 3: Create Skills Repository (Optional)
**Repository:** `mas-marketplace/mas-skills`

**Purpose:** Community-submitted skills (separate from core)

**Structure:**
```
mas-skills/
├── skills/
│   ├── data-validator/
│   ├── frontend-test-gen/
│   └── [community skills]/
├── registry.json
├── .github/
│   └── workflows/
│       └── validate-skill.yml
├── README.md
└── CONTRIBUTING.md
```

**Why separate?**
- Core stays stable
- Community skills update frequently
- Easier to manage contributions

---

### Step 4: Configure GitHub Actions

**Enable in repository settings:**
- Settings → Actions → General
- Allow all actions
- Enable workflow permissions

**Secrets needed:**
- `GITHUB_TOKEN` (automatic)
- Optional: `NPM_TOKEN` (for npm publishing)

---

### Step 5: Set Up Branch Protection

**Main branch:**
- Settings → Branches → Add rule
- Branch name pattern: `main`
- Require pull request reviews
- Require status checks to pass
- Require branches to be up to date

---

## 🚀 Launch Checklist

### Pre-Launch
- [ ] All scripts tested locally
- [ ] README complete
- [ ] GitHub Actions configured
- [ ] Registry.json created
- [ ] MCP server tested
- [ ] Security scan passes
- [ ] Documentation complete

### Launch Day
- [ ] Create organization/repo
- [ ] Push all files
- [ ] Create v1.1.0 release
- [ ] Test installation: `curl -sSL https://get.mas.dev | bash`
- [ ] Test marketplace: `./marketplace.sh --list`
- [ ] Test MCP: `node mcp-server/index.js`
- [ ] Announce on social media

### Post-Launch
- [ ] Monitor issues
- [ ] Review first PRs
- [ ] Gather feedback
- [ ] Plan v1.2.0

---

## 📢 Promotion

### Where to Share
1. **GitHub** - Release announcement
2. **Twitter/X** - Tag AI/Dev communities
3. **Reddit** - r/programming, r/ArtificialIntelligence
4. **Hacker News** - Show HN post
5. **Dev.to** - Tutorial article
6. **LinkedIn** - Professional network

### Key Messages
- "One-line AI tool installation"
- "Self-building ecosystem"
- "Community-driven marketplace"
- "MCP protocol integration"

---

## 🎯 Success Metrics

### Week 1
- 100+ stars
- 10+ forks
- 5+ issues/discussions
- 1+ community skill submissions

### Month 1
- 500+ stars
- 50+ skills in marketplace
- 10+ active contributors
- 1000+ downloads

### Quarter 1
- 2000+ stars
- 100+ skills
- 50+ contributors
- Integration in 10+ projects

---

## 💰 Costs (GitHub)

**Free tier covers:**
- ✅ Public repositories
- ✅ GitHub Actions (2000 min/month)
- ✅ GitHub Packages
- ✅ Pages hosting

**Paid tier (if needed):**
- Pro: $4/month
- Team: $4/user/month

---

## 🔄 Maintenance

### Weekly
- Review open PRs
- Respond to issues
- Update registry

### Monthly
- Release new version
- Security audit
- Update dependencies

### Quarterly
- Major version release
- Community survey
- Roadmap planning

---

## 🤝 Community Guidelines

### Code of Conduct
- Be respectful
- Welcome newcomers
- Constructive feedback
- No harassment

### Contribution Process
1. Fork repository
2. Create feature branch
3. Add skill/tests
4. Submit PR
5. Wait for review
6. Merge when approved

### Review Criteria
- ✅ Structure valid
- ✅ Security safe
- ✅ Documentation complete
- ✅ Tests pass
- ✅ No breaking changes

---

## 📚 Documentation Strategy

### Core Docs (in mas-core)
- README.md - Main entry point
- CONTRIBUTING.md - How to contribute
- CODE_OF_CONDUCT.md - Community standards
- SECURITY.md - Vulnerability reporting

### Skill Docs (per skill)
- SKILL.md - Usage guide
- examples/ - Usage examples
- references/ - Additional info

### Tutorials (separate repo or docs folder)
- Getting started
- Creating first skill
- Publishing to marketplace
- Building team workflow

---

## 🚀 Advanced Features (Future)

### Phase 2: Enhanced Marketplace
- [ ] Web UI for browsing
- [ ] Rating/review system
- [ ] Download statistics
- [ ] Search with filters
- [ ] Skill comparison

### Phase 3: Automation
- [ ] Auto-update bot
- [ ] Security alerts
- [ ] Dependency updates
- [ ] Performance monitoring

### Phase 4: Integration
- [ ] VS Code extension
- [ ] JetBrains plugin
- [ ] CLI tool
- [ ] Web dashboard

---

## 📊 Expected Timeline

**Week 1:** Setup & Testing
**Week 2:** Launch & Initial promotion
**Week 3-4:** Community building
**Month 2:** First community skills
**Month 3:** 100+ skills milestone

---

## 💡 Pro Tips

### For Fast Adoption
1. **Seed the marketplace** - Add 10+ useful skills at launch
2. **Make it easy** - One-line install is key
3. **Engage early** - Respond to all issues within 24h
4. **Show examples** - Video demos help
5. **Reward contributors** - Recognition, swag, etc.

### For Sustainability
1. **Automate everything** - CI/CD is essential
2. **Clear guidelines** - Reduce confusion
3. **Moderate actively** - Quality over quantity
4. **Listen to users** - Roadmap based on feedback
5. **Document everything** - Reduce support burden

---

## ✅ Final Checklist

Before going live:
- [ ] All files in mas-core repo
- [ ] GitHub Actions working
- [ ] Registry.json complete
- [ ] MCP server tested
- [ ] Installation tested end-to-end
- [ ] Documentation reviewed
- [ ] Security scan passed
- [ ] First release created
- [ ] Promotion plan ready
- [ ] Community guidelines posted

---

**Ready to launch! 🚀**

---
*Last updated: 2025-12-29*