# MAS Validation Checklist

## Pre-Validation Checklist

### Environment Setup
- [ ] `.claude/skills/` directory exists
- [ ] `_bmad/meta-system/` directory exists
- [ ] Python 3.6+ is installed
- [ ] PyYAML is installed (`pip install pyyaml`)
- [ ] Git repository is initialized
- [ ] Claude Code is configured

### Component Verification
- [ ] meta-skill-creator exists and is functional
- [ ] meta-agent-factory exists and is functional
- [ ] meta-prompt-generator exists and is functional
- [ ] export-tools are executable
- [ ] registry.yaml exists and is valid

### Backup
- [ ] Current state is backed up
- [ ] Critical files are versioned
- [ ] Recovery plan is documented

---

## Tier 1: Basic Structure Checklist

### Required Files
- [ ] `.claude/skills/` exists
- [ ] `_bmad/meta-system/` exists
- [ ] `_bmad/meta-system/registry.yaml` exists
- [ ] `_bmad/meta-system/export-tools/` exists

### Required Tools
- [ ] `export-system.sh` exists and is executable
- [ ] `export-skill.sh` exists and is executable
- [ ] `validate-system.sh` exists and is executable

### Directory Structure
- [ ] Each skill has its own directory
- [ ] Each skill has SKILL.md
- [ ] Skills are organized in `.claude/skills/`
- [ ] Agents are in `_bmad/_config/agents/`
- [ ] Prompts are in `_bmad/meta-system/prompts/`

**Tier 1 Score: ___/20**

---

## Tier 2: SKILL.md Format Checklist

### Required Sections (for each skill)
- [ ] `# [Skill Name]` header
- [ ] `## Overview` section
- [ ] `## Purpose` section
- [ ] `## Capabilities` section
- [ ] `## Usage Examples` section

### Metadata (for each skill)
- [ ] `## Author` field
- [ ] `## Version` field
- [ ] `## Tags` field (optional but recommended)
- [ ] `## Dependencies` field (optional but recommended)

### Content Quality
- [ ] Overview is clear and concise
- [ ] Purpose explains why skill exists
- [ ] Capabilities are actionable
- [ ] Examples are realistic
- [ ] Language is consistent

### Optional Components
- [ ] `scripts/` directory with executable files
- [ ] `references/` directory with documentation
- [ ] `assets/` directory with templates/examples

**Tier 2 Score: ___/30**

---

## Tier 3: Registry Integrity Checklist

### YAML Structure
- [ ] File is valid YAML
- [ ] `meta_system` section exists
- [ ] `skills` section exists (even if empty)
- [ ] `agents` section exists (even if empty)
- [ ] `prompts` section exists (even if empty)

### Metadata
- [ ] Version is specified
- [ ] Installation date is present
- [ ] Project name is included

### Skills Section
- [ ] All skills are listed
- [ ] Each skill has `name`
- [ ] Each skill has `path`
- [ ] Each skill has `version`
- [ ] Dependencies are listed
- [ ] No duplicate names

### Agents Section
- [ ] All agents are listed
- [ ] Each agent has `name`
- [ ] Each agent has `path`
- [ ] Each agent has `version`

### Prompts Section
- [ ] All prompts are listed
- [ ] Each prompt has `name`
- [ ] Each prompt has `path`
- [ ] Each prompt has `version`

### Dependency Resolution
- [ ] All dependencies exist
- [ ] No circular dependencies
- [ ] No broken references

**Tier 3 Score: ___/25**

---

## Tier 4: Integration Testing Checklist

### Skill Creation Workflow
- [ ] Can create new skill using meta-skill-creator
- [ ] New skill has proper structure
- [ ] Registry can be updated
- [ ] Validation passes for new skill

### Agent Creation Workflow
- [ ] Can create new agent using meta-agent-factory
- [ ] New agent has proper structure
- [ ] Registry can be updated
- [ ] Validation passes for new agent

### Prompt Generation Workflow
- [ ] Can generate prompts using meta-prompt-generator
- [ ] Prompts are properly formatted
- [ ] Registry can be updated
- [ ] Validation passes for new prompts

### Cross-Component Communication
- [ ] Skills can reference each other
- [ ] Agents can use skills
- [ ] Prompts integrate with components
- [ ] No broken references

**Tier 4 Score: ___/25**

---

## Post-Validation Checklist

### Reporting
- [ ] Report is generated
- [ ] Report is saved to `_bmad/reports/`
- [ ] Report is readable
- [ ] Issues are clearly identified

### Action Planning
- [ ] Critical issues are prioritized
- [ ] Action items are created
- [ ] Assignees are identified
- [ ] Timeline is set

### Follow-up
- [ ] Issues are tracked
- [ ] Fixes are tested
- [ ] Re-validation is scheduled
- [ ] Results are documented

---

## Daily Maintenance Checklist

### Quick Health Check (5 minutes)
- [ ] Run quick validation
- [ ] Check overall score
- [ ] Review critical issues
- [ ] Address immediate problems

### Weekly Deep Check (30 minutes)
- [ ] Run full validation
- [ ] Review all tiers
- [ ] Generate health report
- [ ] Plan improvements

### Monthly Review (1 hour)
- [ ] Analyze trends
- [ ] Archive old reports
- [ ] Update documentation
- [ ] Plan major updates

---

## Pre-Deployment Checklist

### Final Validation
- [ ] All tiers pass validation
- [ ] Integration tests pass
- [ ] Health score ≥ 80
- [ ] No critical issues

### Documentation
- [ ] README is updated
- [ ] Changelog is current
- [ ] Examples are tested
- [ ] Migration guide exists (if needed)

### Backup & Recovery
- [ ] Full system backup created
- [ ] Recovery procedure documented
- [ ] Rollback plan prepared
- [ ] Team is notified

---

## Marketplace Readiness Checklist

### Skill Quality
- [ ] SKILL.md is comprehensive
- [ ] Examples are complete
- [ ] Dependencies are minimal
- [ ] Documentation is clear

### Packaging
- [ ] All required files included
- [ ] No sensitive data
- [ ] Version is specified
- [ ] License is included (if applicable)

### Testing
- [ ] Works in isolation
- [ ] Works with other skills
- [ ] Validation passes
- [ ] Integration tests pass

---

## Troubleshooting Checklist

### If Validation Fails
- [ ] Check error messages
- [ ] Identify failed tier
- [ ] Review common errors
- [ ] Fix one issue at a time
- [ ] Revalidate after each fix

### If Integration Fails
- [ ] Test each component separately
- [ ] Check dependencies
- [ ] Verify registry
- [ ] Review logs
- [ ] Test workflow step-by-step

### If Registry Corrupts
- [ ] Restore from backup
- [ ] Regenerate from skills
- [ ] Validate manually
- [ ] Commit fix
- [ ] Document cause

---

## Quick Reference

### Commands
```bash
# Full validation
./_bmad/meta-system/export-tools/validate-system.sh

# Quick check
./_bmad/meta-system/export-tools/validate-system.sh --quick

# Specific skill
./_bmad/meta-system/export-tools/validate-system.sh --skill [name]

# Generate report
./_bmad/meta-system/export-tools/validate-system.sh --report

# JSON output
./_bmad/meta-system/export-tools/validate-system.sh --format json
```

### Scores
- **90-100:** Excellent ✅
- **80-89:** Good ✅
- **60-79:** Fair ⚠️
- **40-59:** Poor ❌
- **0-39:** Critical ❌

### Priorities
1. **Critical:** Fix immediately
2. **Warning:** Fix this week
3. **Optimization:** Fix when convenient

---

*Use this checklist before every validation run to ensure consistent results.*

*Last Updated: 2025-12-29*