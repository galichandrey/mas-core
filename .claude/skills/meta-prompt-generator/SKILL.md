---
name: meta-prompt-generator
description: Generates optimized prompts for specific tasks and domains. Creates prompt templates, chains, and libraries. Use when building prompt collections, optimizing existing prompts, or creating reusable prompt patterns for different use cases.
---

# Meta Prompt Generator

**The prompt that writes prompts.** Creates optimized, reusable prompt patterns.

## Quick Start

**Create a prompt template:**
```
Generate a prompt template for analyzing business requirements and converting them to user stories.
```

Claude will generate:
- Optimized prompt structure
- Input/output examples
- Parameter definitions
- Validation criteria

## Prompt Creation Workflow

### Step 1: Analyze Prompt Requirements

**Questions to answer:**
- What specific task should the prompt accomplish?
- What inputs does it need?
- What output format is expected?
- What constraints or rules apply?

### Step 2: Choose Prompt Pattern

**Pattern A: Single-Task Prompt**
Focused on one specific operation.

```
Role: [Expert persona]
Task: [Specific action]
Input: [What to provide]
Output: [Expected format]
Constraints: [Rules to follow]
```

**Pattern B: Chain-of-Thought Prompt**
Requires step-by-step reasoning.

```
Role: [Expert persona]
Task: [Complex problem]
Process:
  1. Analyze [aspect]
  2. Evaluate [options]
  3. Decide [approach]
  4. Execute [solution]
Output: [Final result with reasoning]
```

**Pattern C: Template Prompt**
Reusable with variable inputs.

```
Template: [Structure with placeholders]
Variables: [List of replaceable parts]
Examples: [3+ usage examples]
Validation: [Quality criteria]
```

**Pattern D: Multi-Step Workflow**
Sequential operations with dependencies.

```
Step 1: [Action] → Output to Step 2
Step 2: [Action] → Output to Step 3
Step 3: [Action] → Final output
Quality Gates: [Validation at each step]
```

### Step 3: Define Prompt Structure

**Basic Structure:**
```markdown
# [Prompt Name]

## Role & Context
[Who you are and what you know]

## Task
[What you need to do]

## Input
[What user provides]

## Process
[Step-by-step instructions]

## Output Format
[Exact format required]

## Constraints
[Rules and limitations]

## Examples
[Input → Output pairs]
```

### Step 4: Optimize for Clarity

**Good Prompt Characteristics:**
- ✅ Specific and unambiguous
- ✅ Action-oriented language
- ✅ Clear input/output expectations
- ✅ Includes examples
- ✅ Defines constraints

**Bad Prompt Characteristics:**
- ❌ Vague or open-ended
- ❌ Passive language
- ❌ Missing format specifications
- ❌ No examples
- ❌ Unclear boundaries

### Step 5: Add Examples

**Example Structure:**
```markdown
## Examples

### Example 1
**Input:**
```
User request or data
```

**Output:**
```
Expected response
```

### Example 2
**Input:**
```
Another scenario
```

**Output:**
```
Expected response
```
```

**Minimum 3 examples** for complex prompts.

## Complete Example

### Request:
```
Generate a prompt for creating technical specifications from user stories.
```

### Generated Prompt:

```markdown
# Technical Specification Generator

## Role & Context
You are a senior technical architect with expertise in system design, software architecture, and translating business requirements into technical solutions.

## Task
Convert user stories into detailed technical specifications that include data models, API designs, and implementation considerations.

## Input
- User story (with acceptance criteria)
- Technology preferences (optional)
- Scale/performance requirements (optional)

## Process
1. **Analyze the user story**
   - Identify core entities and relationships
   - Determine data storage needs
   - Assess complexity level

2. **Design data model**
   - Define entities and attributes
   - Specify data types and constraints
   - Identify relationships (1:1, 1:N, N:M)

3. **Design API endpoints**
   - Define RESTful endpoints
   - Specify request/response schemas
   - Include validation rules

4. **Consider implementation**
   - Technology stack recommendations
   - Security considerations
   - Performance optimizations
   - Error handling strategy

5. **Document edge cases**
   - Input validation scenarios
   - Error conditions
   - Rate limiting
   - Concurrency issues

## Output Format
```markdown
# Technical Specification: [Feature Name]

## Overview
[Brief description]

## Data Model
### Entities
- **Entity 1**
  - Attributes: [list with types]
  - Constraints: [validations]
  - Relationships: [to other entities]

## API Design
### Endpoints
- **POST /api/resource**
  - Request: [schema]
  - Response: [schema]
  - Errors: [codes and messages]

## Implementation Notes
- Technology stack: [recommendations]
- Security: [measures]
- Performance: [optimizations]
- Testing: [strategy]

## Edge Cases
- [Case 1]: [handling]
- [Case 2]: [handling]
```

## Constraints
- Be specific about data types and formats
- Include validation rules for all inputs
- Consider security from the start
- Account for scalability
- Document assumptions explicitly
- Keep specifications actionable

## Examples

### Example 1
**Input:**
```
User Story: As a customer, I want to reset my password so that I can regain access if I forget it.

Acceptance Criteria:
- User enters email
- System sends reset link
- Link expires after 1 hour
- Link can only be used once
```

**Output:**
```markdown
# Technical Specification: Password Reset

## Overview
Secure password reset flow with email verification and token expiration.

## Data Model
### Entities
- **User**
  - email: string (unique, validated)
  - password_hash: string (hashed)
  - reset_token: string (nullable)
  - token_expiry: datetime (nullable)

## API Design
### Endpoints
- **POST /api/auth/reset-password/request**
  - Request: { email: string }
  - Response: { message: "Reset email sent" }
  - Errors: 404 (user not found), 429 (rate limit)

- **POST /api/auth/reset-password/confirm**
  - Request: { token: string, new_password: string }
  - Response: { success: true }
  - Errors: 400 (invalid/expired token)

## Implementation Notes
- Technology: Node.js, Express, Nodemailer
- Security: JWT tokens, bcrypt hashing, HTTPS only
- Performance: Redis cache for token lookup
- Testing: Unit tests for token generation, expiry

## Edge Cases
- Expired token: Return 400 with clear message
- Used token: Return 400 (prevent replay)
- Same email multiple requests: Overwrite previous token
- Invalid email format: Validate before processing
```

### Example 2
**Input:**
```
User Story: As a admin, I want to view user activity dashboard so that I can monitor engagement.

Acceptance Criteria:
- Show last 7 days activity
- Display user count, active users
- Show top actions
- Filter by date range
```

**Output:**
```markdown
# Technical Specification: Admin Dashboard

## Overview
Analytics dashboard showing user engagement metrics.

## Data Model
### Entities
- **ActivityLog**
  - user_id: ObjectId
  - action: string (enum)
  - timestamp: ISODate
  - metadata: object

## API Design
### Endpoints
- **GET /api/admin/dashboard**
  - Query: { start_date?, end_date? }
  - Response: {
    total_users: number,
    active_users: number,
    top_actions: [{ action, count }],
    daily_activity: [{ date, count }]
  }

## Implementation Notes
- Database: MongoDB aggregation pipeline
- Caching: 5-minute TTL for dashboard data
- Authorization: Admin role required

## Edge Cases
- No data in range: Return empty arrays
- Large date range: Limit to 90 days max
```

## Advanced Patterns

### Pattern 1: Chain-of-Thought Prompts
```markdown
## Process
1. **Analyze** the problem statement
2. **Break down** into components
3. **Evaluate** each component
4. **Synthesize** solution
5. **Validate** against requirements

## Output
Include your reasoning at each step before final answer.
```

### Pattern 2: Few-Shot Learning Prompts
```markdown
## Task
[Task description]

## Examples
[3+ complete examples]

## New Input
[User's actual input]

## Output
[Generate based on pattern]
```

### Pattern 3: Constraint-Based Prompts
```markdown
## Rules
1. Must use [specific format]
2. Must include [required elements]
3. Must not exceed [length limit]
4. Must follow [style guide]

## Validation
[Checklist for output quality]
```

### Pattern 4: Iterative Refinement Prompts
```markdown
## Initial Draft
[Generate first version]

## Critique Phase
[Identify issues]

## Refinement
[Improve based on critique]

## Final Output
[Polished result]
```

## Prompt Optimization Techniques

### 1. Be Specific
**Bad:** "Write about code"
**Good:** "Write a Python function that validates email addresses using regex"

### 2. Define Format
**Bad:** "Give me results"
**Good:** "Return JSON with keys: name, age, email. Format: {\"name\": \"string\", \"age\": number, \"email\": \"string\"}"

### 3. Include Examples
**Bad:** "Follow this pattern"
**Good:** "Follow this pattern: [example 1], [example 2], [example 3]"

### 4. Set Constraints
**Bad:** "Be helpful"
**Good:** "Be concise (under 200 words), use bullet points, include 3 specific recommendations"

### 5. Use Action Verbs
**Bad:** "Think about the problem"
**Good:** "Analyze the problem, identify root causes, propose solutions"

## Testing Your Prompt

### Test 1: Clarity
```
Give the prompt to someone unfamiliar with the task.
Do they understand what to do?
```

### Test 2: Edge Cases
```
Test with:
- Empty input
- Invalid input
- Boundary values
- Ambiguous requests

Does it handle gracefully?
```

### Test 3: Consistency
```
Run the same input 3 times.
Are outputs consistent?
```

### Test 4: Quality
```
Does output match expected format?
Are examples followed correctly?
Are constraints respected?
```

## Common Mistakes to Avoid

### ❌ Vague Instructions
**Bad:** "Make it better"
**Good:** "Improve clarity by adding specific examples and constraints"

### ❌ Missing Format
**Bad:** "Write a response"
**Good:** "Write a response in markdown with: ## Summary, ## Details, ## Recommendations"

### ❌ No Examples
**Bad:** "Follow the pattern"
**Good:** "Follow the pattern: [example 1], [example 2]"

### ❌ Too Many Requirements
**Bad:** "Do A, B, C, D, E, F, G, H, I, J..."
**Good:** "Focus on A, B, C. For D-J, see [detailed guide]"

### ❌ Conflicting Instructions
**Bad:** "Be concise but detailed"
**Good:** "Be concise (under 100 words) but include key details: [list]"

## Prompt Libraries

### Library Structure
```
prompts/
├── analysis/
│   ├── requirements.md
│   └── code-review.md
├── generation/
│   ├── documentation.md
│   └── tests.md
└── transformation/
    ├── format-converter.md
    └── style-enforcer.md
```

### Naming Convention
```
[category]-[action]-[target]
Example: analysis-requirements-business
```

## Integration with Meta System

### Creating Skill Prompts
```
"Generate a prompt for creating SKILL.md files"
→ Creates prompt template for skill creation
```

### Creating Agent Prompts
```
"Generate a prompt for defining agent commands"
→ Creates prompt for agent configuration
```

### Creating Workflow Prompts
```
"Generate a prompt for multi-step workflows"
→ Creates prompt for workflow orchestration
```

## Best Practices Summary

1. **Specific over general** - Clear tasks beat vague goals
2. **Examples over explanations** - Show, don't just tell
3. **Format defined** - Specify exact output structure
4. **Constraints clear** - Set boundaries explicitly
5. **Test thoroughly** - Validate with multiple inputs
6. **Iterate based on feedback** - Refine based on usage
7. **Keep it concise** - Every word must earn its place

## Quick Reference

### Prompt Template
```markdown
# [Prompt Name]

## Role
[Expert persona]

## Task
[Specific action]

## Input
[What user provides]

## Process
[Step-by-step]

## Output
[Exact format]

## Constraints
[Rules]

## Examples
[Input → Output]
```

### Validation Checklist
- [ ] Role is clear
- [ ] Task is specific
- [ ] Input is defined
- [ ] Process is step-by-step
- [ ] Output format is exact
- [ ] Constraints are listed
- [ ] Examples included (3+)

### Optimization Checklist
- [ ] Uses action verbs
- [ ] No ambiguous language
- [ ] Format explicitly defined
- [ ] Examples demonstrate pattern
- [ ] Constraints are measurable
- [ ] Testable with edge cases

---

**Remember:** The best prompts work consistently without clarification. If you need to explain the prompt, it needs improvement.
