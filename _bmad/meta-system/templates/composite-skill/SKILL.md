---
name: composite-skill-name
description: Orchestrates [base skills] for [workflow purpose]. Use when [specific workflow scenario]
type: composite
version: 1.0.0
---

# Composite Skill: Workflow Title

**Orchestrates multiple base skills into a complete workflow.**

## Overview
[What this composite skill does and the workflow it orchestrates]

## Quick Start
```
User: [Example request]
Result: [Complete workflow execution]
```

## Composition

### Base Skills
This composite skill orchestrates the following base skills:

| Skill | Role | Optional |
|-------|------|----------|
| base-skill-1 | Input/Reading | No |
| base-skill-2 | Validation/Processing | No |
| base-skill-3 | Output/Writing | No |

### Workflow Type
**Sequential** - Skills execute in order, passing data between them

## Workflow Steps

### Step 1: [Input]
- Skill: base-skill-1
- Purpose: Read and prepare data
- Input: [User request]
- Output: [Prepared data]

### Step 2: [Processing]
- Skill: base-skill-2
- Purpose: Validate and transform
- Input: [Output from Step 1]
- Output: [Processed data]

### Step 3: [Output]
- Skill: base-skill-3
- Purpose: Write results
- Input: [Output from Step 2]
- Output: [Final result]

## Integration Patterns

### Error Handling
If any step fails:
1. Stop execution
2. Report error with context
3. Provide recovery suggestions

### Data Flow
```
Input → Validate → Transform → Output
  ↓       ↓         ↓         ↓
Step1 → Step2 → Step3 → Final Result
```

## Configuration

### Customization
You can customize the workflow by:
- Modifying skill configurations
- Adding conditional logic
- Changing execution order

### Advanced Usage
See `references/workflows.md` for advanced patterns.

## Resources

### scripts/
- `orchestrator.py` - Main workflow coordinator
- `router.py` - Data routing logic
- `error-handler.py` - Error handling

### references/
- `composition-guide.md` - How to compose skills
- `workflow-patterns.md` - Common patterns
- `troubleshooting.md` - Common issues

### assets/
- `workflow-template.json` - Workflow configuration template

## Testing

### Test 1: Complete Workflow
```
Input: [Test data]
Expected: [Complete result]
Steps: 3
```

### Test 2: Error Recovery
```
Input: [Invalid data]
Expected: [Clear error message]
```

### Test 3: Edge Cases
- Empty input
- Large files
- Invalid formats

## Performance

### Optimization Tips
1. **Parallel execution** - Independent skills can run in parallel
2. **Caching** - Cache intermediate results
3. **Streaming** - Stream large data

### Benchmarks
- Small files: < 1s
- Medium files: 1-5s
- Large files: 5-30s

## Troubleshooting

### Issue: Workflow fails at Step 2
**Solution:** Check input format from Step 1

### Issue: Slow performance
**Solution:** Enable streaming mode

### Issue: Memory issues
**Solution:** Process in chunks

## Best Practices

### 1. Keep Skills Modular
Each base skill should be independently useful

### 2. Clear Data Contracts
Define input/output formats clearly

### 3. Error Propagation
Errors should include context from all steps

### 4. Logging
Log each step for debugging

### 5. Validation
Validate at each step boundary

## Quick Reference

### Composition Definition
```json
{
  "composition_type": "sequential",
  "base_skills": [
    {"name": "skill-1", "role": "input"},
    {"name": "skill-2", "role": "process"},
    {"name": "skill-3", "role": "output"}
  ]
}
```

### Workflow Execution
```
1. Input: base-skill-1
2. Process: base-skill-2
3. Output: base-skill-3
4. Aggregate results
```

### Validation Checklist
- [ ] All base skills exist
- [ ] Workflow logic tested
- [ ] Error handling implemented
- [ ] Data flow validated
- [ ] Performance acceptable
