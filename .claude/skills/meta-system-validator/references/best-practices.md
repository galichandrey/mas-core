# Best Practices for MAS Validation

## Overview
Guidelines for maintaining a healthy Meta Agentic System.

## Skill Creation Best Practices

### 1. SKILL.md Structure
Always include these sections in order:

```markdown
# [Skill Name - Clear and Descriptive]

## Overview
[1-2 sentence summary of what it does]

## Purpose
[Why this skill exists, what problem it solves]

## Dependencies
- [skill-name] - [reason for dependency]
- [another-skill] - [reason]

## Capabilities
- [Capability 1] - [Brief description]
- [Capability 2] - [Brief description]
- [Capability 3] - [Brief description]

## Usage Examples
### Example 1: Basic
User: "Command example"
Assistant: [Expected response]

### Example 2: Advanced
User: "Command with parameters"
Assistant: [Expected response with parameters]

## Implementation Notes
[Optional: Technical details, algorithms used]

## Troubleshooting
[Optional: Common issues and fixes]

---
*Author: [Name]*
*Version: [X.Y.Z]*
*Tags: [comma, separated, tags]*
```

### 2. Naming Conventions
- **Skills:** `lowercase-with-dashes` (e.g., `meta-system-validator`)
- **Agents:** `lowercase-with-dashes` (e.g., `meta-skill-builder`)
- **Prompts:** `descriptive-names.md` (e.g., `skill-creation-prompt.md`)

### 3. Directory Structure
```
.claude/skills/[skill-name]/
├── SKILL.md              # Required
├── scripts/              # Optional but recommended
│   ├── *.py              # Python scripts
│   └── *.sh              # Bash scripts
├── references/           # Optional
│   ├── *.md              # Documentation
│   └── *.json            # Data files
└── assets/               # Optional
    ├── templates/        # Templates
    └── examples/         # Examples
```

### 4. Version Management
- Start with `1.0.0`
- Increment for:
  - `1.0.1` - Bug fixes
  - `1.1.0` - New features
  - `2.0.0` - Breaking changes
- Update registry when version changes

## Registry Best Practices

### 1. Organization
```yaml
meta_system:
  version: "1.0.0"
  installed: "2025-12-29"
  project: "enrich-me"

skills:
  # Core meta-skills first
  - name: "meta-skill-creator"
    path: ".claude/skills/meta-skill-creator"
    version: "1.0.0"
    dependencies: []
    tags: ["meta", "core"]

  # Project-specific skills
  - name: "project-utils"
    path: ".claude/skills/project-utils"
    version: "1.0.0"
    dependencies: ["meta-skill-creator"]
    tags: ["project", "utility"]

agents:
  - name: "meta-agent-factory"
    path: "_bmad/_config/agents/meta-agent-factory.yaml"
    version: "1.0.0"
    dependencies: ["meta-skill-creator"]

prompts:
  - name: "skill-creation-prompt"
    path: "_bmad/meta-system/prompts/skill-creation-prompt.md"
    version: "1.0.0"
```

### 2. Dependency Management
- List direct dependencies only
- Avoid circular dependencies
- Mark optional dependencies with `?`
- Keep dependency chains short (<3 levels)

### 3. Metadata Consistency
- Always include version
- Use ISO dates (YYYY-MM-DD)
- Keep tags lowercase
- Use descriptive names

## Validation Best Practices

### 1. Frequency
- **Daily:** Quick validation (Tier 1 only)
- **Weekly:** Full validation (all tiers)
- **Before deployment:** Full validation + integration tests
- **After modifications:** Validate modified components

### 2. Scope Control
```bash
# Validate everything
./validate-system.sh

# Validate specific skill
./validate-system.sh --skill meta-system-validator

# Validate specific tier
./validate-system.sh --tier 1,2

# Quick check (Tier 1 only)
./validate-system.sh --quick
```

### 3. Reporting
- Always save reports to `_bmad/reports/`
- Use timestamps in filenames
- Keep last 10 reports
- Archive old reports monthly

### 4. Action Priority
When validation finds issues:

**Critical (Fix Immediately):**
1. Missing required files
2. Invalid SKILL.md format
3. Registry corruption

**Warning (Fix This Week):**
1. Missing optional files
2. Incomplete metadata
3. Missing documentation

**Optimization (Fix When Convenient):**
1. Add more examples
2. Improve documentation
3. Performance improvements

## Integration Best Practices

### 1. Component Communication
- Skills should reference other skills in Dependencies section
- Agents should list skills they use
- Prompts should specify which components they work with

### 2. Workflow Design
```
Good Workflow:
User Request → Orchestrator → Skill → Result
                     ↓
              Registry Update → Validation → Report

Bad Workflow:
User Request → Random Skill → ? → Result
              (No coordination, no validation)
```

### 3. Error Handling
- Skills should fail gracefully
- Provide actionable error messages
- Log issues to registry
- Generate recovery suggestions

## Maintenance Best Practices

### 1. Regular Cleanup
```bash
# Monthly cleanup script
#!/bin/bash
# cleanup.sh

# Remove old reports (keep last 10)
ls -t _bmad/reports/health-*.md | tail -n +11 | xargs rm -f

# Remove temp files
find .claude/skills/ -name "*.tmp" -delete

# Validate registry
./_bmad/meta-system/export-tools/validate-system.sh --regenerate-registry
```

### 2. Version Updates
```bash
# Update skill version
# 1. Edit SKILL.md: ## Version 1.1.0
# 2. Update registry
# 3. Add changelog entry
# 4. Commit with message: "chore: update [skill-name] to v1.1.0"
```

### 3. Backup Strategy
```bash
# Before major changes
tar -czf mas-backup-$(date +%Y%m%d).tar.gz \
  .claude/skills/ _bmad/ registry.yaml

# Store in _bmad/backups/
mkdir -p _bmad/backups/
mv mas-backup-*.tar.gz _bmad/backups/
```

## Performance Best Practices

### 1. Validation Speed
- Use `--quick` for daily checks
- Validate only changed components
- Cache validation results
- Parallelize when possible

### 2. Resource Usage
- Limit concurrent validations
- Use lightweight checks first
- Stream large reports
- Clean up temp files

### 3. Scalability
- Keep skills focused (one purpose)
- Avoid deep dependency chains
- Use lazy loading for large components
- Archive unused components

## Security Best Practices

### 1. Sensitive Data
- Never hardcode secrets in SKILL.md
- Use environment variables
- Document required env vars
- Validate permissions

### 2. External Dependencies
- Verify source of external skills
- Check for malicious code
- Use version pinning
- Audit regularly

### 3. Access Control
- Limit file permissions (755 for scripts)
- Validate file ownership
- Check for suspicious patterns
- Monitor registry changes

## Collaboration Best Practices

### 1. Team Development
- Use consistent naming
- Document all changes
- Run validation before commits
- Review registry updates

### 2. Sharing Skills
- Use marketplace for distribution
- Include comprehensive examples
- Document dependencies clearly
- Test in isolation first

### 3. Conflict Resolution
```bash
# When registry conflicts occur:
# 1. Backup current state
# 2. Run validation to identify issues
# 3. Merge manually or regenerate
# 4. Validate again
# 5. Commit resolution
```

## Monitoring Best Practices

### 1. Health Metrics
Track these over time:
- Overall validation score
- Number of critical issues
- Integration test pass rate
- Component count

### 2. Alert Thresholds
Set up alerts for:
- Score drops below 70
- Critical issues > 3
- Integration failures
- Registry corruption

### 3. Trend Analysis
```bash
# Generate monthly report
./validate-system.sh --format json > report.json
# Analyze trends in scores over time
```

## Documentation Best Practices

### 1. README Updates
After each major change:
- Update overall system version
- Add to changelog
- Document new capabilities
- Update examples

### 2. Inline Documentation
- Comment complex scripts
- Explain non-obvious decisions
- Link to related components
- Keep examples current

### 3. Version History
```markdown
## Changelog

### v1.1.0 (2025-12-29)
- Added meta-system-validator skill
- Improved validation speed by 40%
- Added marketplace integration

### v1.0.0 (2025-12-28)
- Initial release
- 3 meta-skills
- Basic export tools
```

## Troubleshooting Best Practices

### 1. Systematic Approach
1. Run validation to identify issues
2. Check logs for details
3. Test in isolation
4. Fix one issue at a time
5. Revalidate after each fix

### 2. Common Patterns
- **Missing file:** Check export tools
- **Format error:** Use meta-skill-creator
- **Dependency issue:** Create missing component
- **Integration fail:** Test each part separately

### 3. Recovery
```bash
# When all else fails:
# 1. Backup current state
# 2. Export from known good system
# 3. Reinstall
# 4. Restore custom components
# 5. Validate
```

## Future-Proofing

### 1. Extensibility
- Design skills to be composable
- Use standard interfaces
- Document extension points
- Plan for growth

### 2. Migration Path
- Keep backward compatibility
- Provide migration scripts
- Document breaking changes
- Support multiple versions

### 3. Evolution
- Monitor usage patterns
- Gather feedback
- Plan improvements
- Track deprecations

---

## Quick Reference

### Daily Commands
```bash
# Quick health check
./_bmad/meta-system/export-tools/validate-system.sh --quick

# Create skill
"Create a skill named [name] for [purpose]"

# Create agent
"Build an agent named [name] for [domain]"
```

### Weekly Commands
```bash
# Full validation
./_bmad/meta-system/export-tools/validate-system.sh

# Generate health report
./_bmad/meta-system/export-tools/validate-system.sh --report

# Clean up
./_bmad/meta-system/export-tools/cleanup.sh
```

### Before Deployment
```bash
# Complete validation
./_bmad/meta-system/export-tools/validate-system.sh

# Test integration
python3 .claude/skills/meta-system-validator/scripts/test-integration.py

# Generate report
./_bmad/meta-system/export-tools/validate-system.sh --report --save
```

---

*Last Updated: 2025-12-29*
*Version: 1.0.0*