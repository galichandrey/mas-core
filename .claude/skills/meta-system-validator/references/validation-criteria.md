# Validation Criteria

## Overview
This document defines the validation criteria used by meta-system-validator to assess MAS installations.

## Tier 1: Basic Structure (20 points)

### File Existence
| File/Directory | Required | Weight | Failure Impact |
|----------------|----------|--------|----------------|
| `.claude/skills/` | Yes | 5 | Critical |
| `_bmad/meta-system/` | Yes | 5 | Critical |
| `registry.yaml` | Yes | 5 | Critical |
| `export-tools/` | Yes | 5 | Critical |

### Directory Structure
```
.claude/skills/
├── meta-skill-creator/
│   ├── SKILL.md (Required)
│   ├── scripts/ (Optional)
│   ├── references/ (Optional)
│   └── assets/ (Optional)
└── [other skills]/
```

**Pass Criteria:** All required directories exist with proper structure
**Warning Criteria:** Optional directories missing
**Fail Criteria:** Required files/directories missing

## Tier 2: SKILL.md Format (30 points)

### Required Sections
```markdown
# [Skill Name]

## Overview
[Purpose description]

## Purpose
[Why this skill exists]

## Capabilities
- [List of capabilities]

## Usage Examples
[Examples of usage]
```

**Pass Criteria:** All required sections present
**Warning Criteria:** 1-2 sections missing
**Fail Criteria:** More than 2 sections missing

### Metadata Fields
| Field | Required | Weight |
|-------|----------|--------|
| ## Author | Yes | 5 |
| ## Version | Yes | 5 |
| ## Tags | No | 3 |
| ## Dependencies | No | 3 |

**Pass Criteria:** ≥2 required fields + ≥1 optional field
**Warning Criteria:** Only required fields
**Fail Criteria:** Missing required fields

### Content Quality
- **Pass:** Clear, actionable, well-structured
- **Warning:** Some ambiguity or missing details
- **Fail:** Incomprehensible or incomplete

## Tier 3: Registry Integrity (25 points)

### YAML Structure
```yaml
meta_system:
  version: "1.0.0"
  installed: "2025-12-29"

skills:
  - name: "meta-skill-creator"
    path: ".claude/skills/meta-skill-creator"
    version: "1.0.0"
    dependencies: []

agents:
  - name: "meta-agent-factory"
    path: "_bmad/_config/agents/meta-agent-factory.yaml"

prompts:
  - name: "skill-creation-prompt"
    path: "_bmad/meta-system/prompts/skill-creation-prompt.md"
```

**Pass Criteria:** Valid YAML + all top-level keys + no duplicates
**Warning Criteria:** Valid YAML but missing optional sections
**Fail Criteria:** Invalid YAML or missing required keys

### Dependency Resolution
For each skill/agent:
- All listed dependencies must exist
- No circular dependencies
- Version compatibility

**Pass:** All dependencies resolved
**Warning:** Some optional dependencies missing
**Fail:** Critical dependencies missing

### Version Consistency
- Skills list versions
- Registry tracks versions
- No version conflicts

## Tier 4: Integration Testing (25 points)

### Workflow Tests
| Test | Pass Criteria | Weight |
|------|---------------|--------|
| Skill Creation | Can create new skill | 7 |
| Agent Creation | Can create new agent | 7 |
| Prompt Generation | Can generate prompts | 6 |
| Registry Update | Can update registry | 5 |

**Pass Criteria:** ≥3 tests pass
**Warning Criteria:** 2 tests pass
**Fail Criteria:** ≤1 test passes

### Cross-Component Communication
- Skills reference each other correctly
- Agents use skills properly
- Prompts integrate with components

**Pass:** All references valid
**Warning:** Some references missing
**Fail:** Broken references

## Scoring System

### Overall Score Calculation
```
Score = (Tier1 + Tier2 + Tier3 + Tier4) / 4
```

### Health Categories
- **90-100:** Excellent - Production ready
- **80-89:** Good - Minor improvements recommended
- **60-79:** Fair - Several issues to address
- **40-59:** Poor - Major problems, not production ready
- **0-39:** Critical - System broken

### Issue Severity

#### Critical (Must Fix Immediately)
- Missing required files
- Invalid SKILL.md format
- Registry corruption
- Integration failures

#### Warning (Should Fix Soon)
- Missing optional files
- Incomplete metadata
- Missing documentation
- Minor inconsistencies

#### Optimization (Nice to Have)
- Performance improvements
- Additional examples
- Enhanced documentation
- Code cleanup

## Reporting Format

### Success Report
```
✅ VALIDATION PASSED (92/100)

Tier 1: ✅ 20/20
Tier 2: ✅ 28/30
Tier 3: ✅ 25/25
Tier 4: ✅ 23/25

Recommendations:
- Add examples to meta-prompt-generator
- Update version to 1.1.0
```

### Failure Report
```
❌ VALIDATION FAILED (45/100)

Tier 1: ⚠️ 15/20 (Missing export-tools/)
Tier 2: ❌ 10/30 (SKILL.md format issues)
Tier 3: ✅ 25/25
Tier 4: ❌ 5/25 (Integration broken)

Critical Issues:
1. Missing .claude/skills/meta-system-validator/
2. SKILL.md missing Capabilities section
3. Integration test failed

Actions:
1. Run: "Create meta-system-validator skill"
2. Run: "Update SKILL.md with capabilities"
3. Run: "meta-system-validator test-integration"
```

## Common Validation Patterns

### Pattern 1: New Installation
```
1. Check Tier 1 (structure)
2. If pass → Check Tier 2 (SKILL.md)
3. If pass → Check Tier 3 (registry)
4. If pass → Check Tier 4 (integration)
5. Generate health report
```

### Pattern 2: After Modification
```
1. Validate modified skill only
2. Check dependent components
3. Run integration tests
4. Update registry if needed
5. Generate delta report
```

### Pattern 3: Pre-Deployment
```
1. Full validation (all tiers)
2. Security scan (future)
3. Performance check (future)
4. Generate deployment report
5. Approve or reject
```

## Troubleshooting Validation Failures

### Issue: Tier 1 Fails
**Symptoms:** Missing files/directories
**Solution:** Run export-system.sh to restore structure

### Issue: Tier 2 Fails
**Symptoms:** SKILL.md format errors
**Solution:** Use meta-skill-creator to regenerate

### Issue: Tier 3 Fails
**Symptoms:** Registry errors
**Solution:** Run validate-system.sh to rebuild registry

### Issue: Tier 4 Fails
**Symptoms:** Integration tests fail
**Solution:** Check each component individually, fix broken references

## Future Enhancements

### Planned Checks
- [ ] Security scanning (secrets, vulnerabilities)
- [ ] Performance benchmarking
- [ ] Code quality metrics
- [ ] Documentation coverage
- [ ] Test coverage analysis
- [ ] Dependency vulnerability scanning

### Advanced Features
- [ ] AI-powered issue diagnosis
- [ ] Automated fix suggestions
- [ ] Historical trend analysis
- [ ] Custom validation rules
- [ ] Plugin system for validators

---
*Last Updated: 2025-12-29*