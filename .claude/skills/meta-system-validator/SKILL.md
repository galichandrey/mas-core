# Meta System Validator Skill

## Overview
A comprehensive validation system for Meta Agentic System (MAS) installations. Checks integrity, structure, and functionality of all MAS components.

## Purpose
Validate MAS installations to ensure:
- All required files exist and are properly structured
- Registry integrity and consistency
- Skill and agent dependencies are resolved
- Integration points work correctly
- System is ready for production use

## Author
MAS Meta-System (Auto-generated)

## Version
1.0.0

## Tags
meta-system, validation, integrity, testing, diagnostics

## Dependencies
- meta-skill-creator (for creating validation reports)
- meta-prompt-generator (for generating recommendations)

## Capabilities

### 1. validate-system-integrity
**Description:** Performs complete system validation
**Usage:** `Use meta-system-validator to validate current project`
**Output:** Detailed report with pass/fail status for each check

**Checks performed:**
- ✅ File structure validation
- ✅ SKILL.md format compliance
- ✅ Registry.yaml integrity
- ✅ Dependency resolution
- ✅ Integration testing
- ✅ Version consistency

### 2. check-skill-structure
**Description:** Validates individual skill structure
**Usage:** `Use meta-system-validator to check .claude/skills/[skill-name]`
**Output:** Skill-specific validation report

**Validates:**
- SKILL.md presence and format
- Required sections (Overview, Purpose, Capabilities)
- Optional sections (Dependencies, Examples)
- File organization (scripts/, references/, assets/)

### 3. validate-registry
**Description:** Checks registry.yaml integrity
**Usage:** `Use meta-system-validator to validate registry`
**Output:** Registry validation report

**Validates:**
- YAML syntax
- Required fields
- Duplicate entries
- Version consistency
- Dependency chains

### 4. test-integration
**Description:** Tests integration between components
**Usage:** `Use meta-system-validator to test integration`
**Output:** Integration test results

**Tests:**
- Skill creation workflow
- Agent creation workflow
- Prompt generation workflow
- Cross-component communication

### 5. generate-health-report
**Description:** Creates comprehensive health report
**Usage:** `Use meta-system-validator to generate health report`
**Output:** Markdown report with recommendations

**Includes:**
- Overall health score
- Critical issues (must fix)
- Warnings (should fix)
- Optimizations (nice to have)
- Action items with priority

## Usage Examples

### Basic System Validation
```
User: "Use meta-system-validator to validate current project"
Assistant: [Runs full validation, returns report]
```

### Check Specific Skill
```
User: "Use meta-system-validator to check meta-skill-creator"
Assistant: [Validates meta-skill-creator structure, returns findings]
```

### Validate Registry Only
```
User: "Use meta-system-validator to validate registry"
Assistant: [Checks registry.yaml, returns validation results]
```

### Deep Integration Test
```
User: "Use meta-system-validator to test integration"
Assistant: [Runs integration tests, returns test results]
```

### Generate Health Report
```
User: "Use meta-system-validator to generate health report"
Assistant: [Creates detailed report, saves to _bmad/reports/health-YYYY-MM-DD.md]
```

## Output Format

### Success Example
```
✅ SYSTEM VALIDATION PASSED

Overall Health: 95/100

Checks:
✅ File Structure: PASS (12/12 files)
✅ SKILL.md Format: PASS (5/5 skills)
✅ Registry Integrity: PASS (no issues)
✅ Dependencies: PASS (all resolved)
✅ Integration: PASS (3/3 tests)

Recommendations:
- Consider updating meta-skill-creator to v1.1.0
- Add examples to meta-prompt-generator

Report saved to: _bmad/reports/health-2025-12-29.md
```

### Failure Example
```
❌ SYSTEM VALIDATION FAILED

Overall Health: 42/100

Checks:
✅ File Structure: PASS (11/12 files)
❌ SKILL.md Format: FAIL (2/5 skills)
✅ Registry Integrity: PASS (no issues)
❌ Dependencies: FAIL (1 unresolved)
❌ Integration: FAIL (1/3 tests)

Critical Issues:
1. Missing SKILL.md in .claude/skills/test-skill/
   → Action: Run "Create SKILL.md for test-skill"

2. Dependency 'meta-component-updater' not found
   → Action: Create skill or remove from dependencies

3. Integration test failed: Agent creation
   → Action: Check meta-agent-factory logs

Report saved to: _bmad/reports/health-2025-12-29.md
```

## Implementation Notes

### Validation Logic
The skill uses a tiered validation approach:
1. **Tier 1: Basic** - File existence and structure
2. **Tier 2: Format** - Content validation
3. **Tier 3: Semantic** - Logic and relationships
4. **Tier 4: Integration** - End-to-end testing

### Error Handling
- Non-critical errors: Logged, system continues
- Critical errors: Halt validation, report immediately
- Warnings: Logged, recommendations provided

### Reporting
All reports are saved to `_bmad/reports/` with timestamps:
- `health-YYYY-MM-DD.md` - Full health report
- `validation-YYYY-MM-DD-HH-MM.md` - Detailed validation
- `issues-YYYY-MM-DD.json` - Machine-readable issues

## Examples

### Example 1: Daily Health Check
```
User: "Run daily health check on the system"
Assistant: "I'll use meta-system-validator to perform a daily health check."
[Runs: validate-system-integrity + generate-health-report]
Result: "✅ Health check complete. Score: 92/100. Report: _bmad/reports/health-2025-12-29.md"
```

### Example 2: Pre-Deployment Validation
```
User: "Validate system before deployment"
Assistant: "Running pre-deployment validation..."
[Runs: validate-system-integrity + test-integration + generate-health-report]
Result: "✅ Ready for deployment. All checks passed. No critical issues."
```

### Example 3: Debugging Failed Skill Creation
```
User: "Why is my skill not working?"
Assistant: "Let me check the skill structure..."
[Runs: check-skill-structure on the skill]
Result: "Found issue: SKILL.md missing 'Capabilities' section. Run 'Update skill with capabilities' to fix."
```

## Advanced Features

### Custom Validation Rules
Users can add custom validation rules in `_bmad/meta-system/validation-rules.yaml`:
```yaml
rules:
  - name: "custom-file-check"
    path: ".claude/skills/*/custom-file.txt"
    required: true
    severity: warning
```

### Ignoring Issues
Add to `_bmad/meta-system/ignore-list.yaml`:
```yaml
ignored:
  - path: ".claude/skills/legacy-skill"
    reason: "Deprecated, pending removal"
    until: "2026-01-01"
```

### Auto-Fix Mode
```
User: "Use meta-system-validator to validate and auto-fix issues"
Assistant: [Validates, identifies fixable issues, applies fixes, reports changes]
```

## Troubleshooting

### Issue: Validation always fails
**Solution:** Check if `_bmad/meta-system/` directory exists

### Issue: Registry not found
**Solution:** Run `./_bmad/meta-system/export-tools/validate-system.sh` to regenerate

### Issue: Integration tests fail
**Solution:** Ensure all meta-skills are installed and functional

## Related Skills
- meta-component-updater - Updates components when issues found
- meta-workflow-orchestrator - Runs validation as part of workflows
- marketplace-publisher - Validates before publishing

## Future Enhancements
- [ ] AI-powered issue diagnosis
- [ ] Automated fix suggestions
- [ ] Historical trend analysis
- [ ] Performance benchmarking
- [ ] Security scanning

---
*Generated by MAS Meta-System*
*Last updated: 2025-12-29*