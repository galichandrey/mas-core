# Composition Guide

## What is a Composite Skill?

A composite skill orchestrates multiple **base skills** into a complete workflow. Think of it as a conductor coordinating an orchestra.

## Composition Types

### 1. Sequential (Pipeline)
```
Skill A → Skill B → Skill C → Result
```

**Use when:** Each step depends on the previous one

**Example:** Read → Validate → Transform → Write

---

### 2. Parallel (Fan-out/Fan-in)
```
        → Skill A ↘
Input → → Skill B → Aggregator → Result
        → Skill C ↗
```

**Use when:** Steps are independent

**Example:** Validate multiple formats simultaneously

---

### 3. Conditional (Router)
```
Input → Router → [Skill A if condition X]
                → [Skill B if condition Y]
                → [Skill C if condition Z]
```

**Use when:** Different logic for different cases

**Example:** Different validators for different file types

---

### 4. Recursive (Nested)
```
Composite Skill 1
  └─ Base Skill A
  └─ Composite Skill 2
      └─ Base Skill B
      └─ Base Skill C
```

**Use when:** Complex hierarchical workflows

**Example:** Enterprise data pipelines

## Creating a Composite Skill

### Step 1: Identify Base Skills
List the base skills you need:

```python
base_skills = [
    "file-reader",
    "json-validator",
    "data-transformer",
    "file-writer"
]
```

### Step 2: Define Roles
Assign each skill a role:

```python
roles = {
    "file-reader": "input",
    "json-validator": "validation",
    "data-transformer": "processing",
    "file-writer": "output"
}
```

### Step 3: Choose Composition Type
Based on dependencies:

- **Sequential** if: A → B → C
- **Parallel** if: A, B, C independent
- **Conditional** if: Different paths
- **Recursive** if: Nested workflows

### Step 4: Define Workflow
Create the orchestration logic:

```python
workflow = {
    "composition_type": "sequential",
    "base_skills": [
        {"name": "file-reader", "role": "input", "optional": False},
        {"name": "json-validator", "role": "validation", "optional": False},
        {"name": "data-transformer", "role": "processing", "optional": False},
        {"name": "file-writer", "role": "output", "optional": False}
    ]
}
```

### Step 5: Implement Orchestrator
Create the coordination logic:

```python
class Orchestrator:
    def execute(self, input):
        # 1. Read
        data = file_reader.read(input)

        # 2. Validate
        validated = json_validator.validate(data)
        if not validated["valid"]:
            return {"error": validated["errors"]}

        # 3. Transform
        transformed = data_transformer.transform(validated["data"])

        # 4. Write
        result = file_writer.write(transformed)

        return result
```

## Data Flow Patterns

### Pattern 1: Pass-through
```
Input → Skill A → Output A → Skill B → Output B
```
Each skill passes data to the next

### Pattern 2: Aggregation
```
Input A → Skill A ↘
Input B → Skill B → Aggregator → Output
Input C → Skill C ↗
```
Combine multiple inputs

### Pattern 3: Transformation Chain
```
Input → Skill A → Transform 1 → Skill B → Transform 2 → Output
```
Data evolves through each step

### Pattern 4: Validation Chain
```
Input → Skill A → Valid? → Skill B → Valid? → Output
                      ↓              ↓
                   Error          Error
```
Stop on first error

## Error Handling

### Strategy 1: Fail Fast
Stop immediately on any error

```python
for step in steps:
    result = execute(step)
    if result.error:
        return {"status": "failed", "step": step, "error": result.error}
```

### Strategy 2: Continue on Error
Collect all errors, continue execution

```python
errors = []
for step in steps:
    result = execute(step)
    if result.error:
        errors.append({"step": step, "error": result.error})
        continue
```

### Strategy 3: Retry Logic
Retry failed steps

```python
for step in steps:
    for attempt in range(3):
        result = execute(step)
        if not result.error:
            break
    else:
        return {"error": f"Step {step} failed after 3 attempts"}
```

## Performance Optimization

### 1. Parallel Execution
```python
from concurrent.futures import ThreadPoolExecutor

def execute_parallel(skills, input_data):
    with ThreadPoolExecutor() as executor:
        futures = [executor.submit(s.execute, input_data) for s in skills]
        results = [f.result() for f in futures]
    return results
```

### 2. Caching
```python
from functools import lru_cache

@lru_cache(maxsize=100)
def cached_execute(skill_name, input_hash):
    return execute_skill(skill_name, input_hash)
```

### 3. Streaming
```python
def stream_process(input_stream):
    for chunk in input_stream:
        yield process_chunk(chunk)
```

## Testing Composite Skills

### Test 1: Happy Path
```python
def test_complete_workflow():
    result = orchestrator.execute("test.json")
    assert result["status"] == "success"
    assert "final_output" in result
```

### Test 2: Error at Each Step
```python
def test_error_handling():
    # Test error at step 1
    result = orchestrator.execute("invalid.json")
    assert result["status"] == "error"
    assert result["failed_step"] == "file-reader"
```

### Test 3: Edge Cases
```python
def test_edge_cases():
    # Empty input
    # Large file
    # Invalid format
    # Missing dependencies
```

## Common Composite Skills

### 1. Data Pipeline
```
file-reader → validator → transformer → file-writer
```

### 2. Report Generator
```
data-reader → analyzer → formatter → report-writer
```

### 3. API Integration
```
api-client → authenticator → request-builder → response-processor
```

### 4. Quality Checker
```
file-reader → linter → tester → reporter
```

## Best Practices

### 1. Keep Skills Independent
Each base skill should work on its own

### 2. Clear Data Contracts
Define input/output formats

### 3. Minimal Dependencies
Don't over-couple skills

### 4. Comprehensive Logging
Log each step for debugging

### 5. Graceful Degradation
Handle partial failures

### 6. Performance Monitoring
Track execution time per step

## Troubleshooting

### Problem: Workflow hangs
**Solution:** Add timeouts to each step

### Problem: Data format mismatch
**Solution:** Validate data between steps

### Problem: Memory overflow
**Solution:** Stream data instead of loading all at once

### Problem: Slow execution
**Solution:** Profile each step, optimize bottlenecks

## Quick Reference

### Composition Template
```json
{
  "name": "workflow-name",
  "type": "composite",
  "composition": {
    "type": "sequential",
    "skills": [
      {"name": "skill-1", "role": "input"},
      {"name": "skill-2", "role": "process"},
      {"name": "skill-3", "role": "output"}
    ]
  }
}
```

### Execution Flow
```
1. Validate composition
2. Check dependencies
3. Execute steps in order
4. Aggregate results
5. Return output
```

### Error Codes
- `E001`: Skill not found
- `E002`: Dependency missing
- `E003`: Data validation failed
- `E004`: Execution timeout
- `E005`: Output validation failed
