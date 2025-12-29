---
name: meta-agent-factory
description: Creates specialized subagents with custom commands and capabilities. Generates complete agent packages including configuration files, capability definitions, and workflow integrations. Use when building domain-specific agents, extending agent teams, or creating multi-agent orchestration systems.
---

# Meta Agent Factory

**The factory that builds agents.** Creates specialized subagents with custom commands and capabilities.

## Quick Start

**Create a new agent:**
```
Create an agent named "billing-analyzer" for analyzing subscription invoices and payment patterns.
```

Claude will generate:
- Agent configuration file
- Custom command definitions
- Capability specifications
- Integration patterns

## Agent Creation Workflow

### Step 1: Analyze Agent Requirements

**Questions to answer:**
- What specific domain does this agent handle?
- What commands should it expose?
- What capabilities does it need?
- How does it integrate with other agents?

### Step 2: Choose Agent Pattern

**Pattern A: Specialist Agent**
Deep expertise in one domain.

```
Domain: [Specific area]
Commands:
  - analyze-[domain]
  - report-[domain]
  - optimize-[domain]
```

**Pattern B: Orchestrator Agent**
Coordinates multiple agents.

```
Domain: Multi-agent coordination
Commands:
  - coordinate-[workflow]
  - delegate-[task]
  - synthesize-[results]
```

**Pattern C: Support Agent**
Provides auxiliary capabilities.

```
Domain: [Support function]
Commands:
  - validate-[type]
  - transform-[format]
  - generate-[artifact]
```

### Step 3: Define Agent Configuration

**Configuration Structure:**
```yaml
---
name: [agent-name]
description: [what it does AND when to use it]
commands:
  - name: [command-name]
    description: [what this command does]
    parameters: [required inputs]
  - [additional commands]
capabilities:
  - [capability 1]
  - [capability 2]
integrations:
  - [related agents]
  - [required skills]
---
```

**Description Best Practices:**
- ✅ "Analyzes billing invoices, identifies discrepancies, and generates payment reports. Use when reviewing subscription charges or investigating billing issues."
- ❌ "Helps with billing" (too vague)
- ❌ "I can analyze invoices" (wrong person)

### Step 4: Define Commands

**Command Structure:**
```yaml
commands:
  - name: analyze-invoice
    description: "Analyzes invoice for discrepancies and patterns"
    parameters: "invoice_file, date_range?"
    example: "analyze-invoice invoice.pdf --range 2024-01..2024-12"

  - name: generate-report
    description: "Generates payment trend report"
    parameters: "period, format?"
    example: "generate-report quarterly --format pdf"
```

**Command Naming:**
- Use verb-noun format
- Be specific and descriptive
- Use hyphens for multi-word names
- Include examples

### Step 5: Define Capabilities

**Capability List:**
```yaml
capabilities:
  - Parse PDF invoices
  - Extract line items
  - Calculate totals
  - Compare against subscriptions
  - Generate visualizations
  - Export to multiple formats
```

**Capabilities should be:**
- Action-oriented
- Measurable
- Specific to the domain
- Aligned with commands

### Step 6: Define Integrations

**Integration Types:**
```yaml
integrations:
  # Agent-to-agent
  - payment-processor
  - subscription-manager

  # Skills
  - pdf-extractor
  - data-validator

  # Tools
  - accounting-api
  - notification-system
```

**Integration Patterns:**
```
Agent A → Agent B: Direct delegation
Agent A → Skill: Capability extension
Agent A → Tool: External integration
```

## Complete Example

### Request:
```
Create an agent named "code-reviewer" for reviewing code quality, security, and best practices.
```

### Generated Agent Configuration:

```yaml
---
name: code-reviewer
description: Reviews code for quality, security vulnerabilities, and best practices compliance. Use when needing code analysis, security audits, or quality improvements for pull requests and code changes.

commands:
  - name: review-pr
    description: "Review a pull request for code quality and security"
    parameters: "pr_url, focus_areas?"
    example: "review-pr github.com/project/pull/123 --focus security,performance"

  - name: audit-code
    description: "Audit codebase for security vulnerabilities"
    parameters: "code_path, severity?"
    example: "audit-code ./src --severity high"

  - name: suggest-improvements
    description: "Suggest code improvements and refactoring"
    parameters: "file_path, style_guide?"
    example: "suggest-improvements app.js --style airbnb"

capabilities:
  - Static code analysis
  - Security vulnerability detection
  - Best practices validation
  - Performance optimization suggestions
  - Code style enforcement
  - Documentation quality checks

integrations:
  - git-analyzer
  - security-scanner
  - style-guide-validator
  - documentation-checker
---
```

## Agent Patterns by Use Case

### Pattern 1: Domain Specialist

**For deep expertise in one area:**
```yaml
name: data-analyst
description: Analyzes datasets, generates insights, and creates visualizations. Use when exploring data, finding patterns, or creating reports.

commands:
  - analyze-dataset
  - generate-insights
  - create-visualization

capabilities:
  - Statistical analysis
  - Pattern detection
  - Visualization creation
  - Report generation
```

### Pattern 2: Workflow Orchestrator

**For coordinating multiple agents:**
```yaml
name: project-coordinator
description: Coordinates development workflow across multiple specialized agents. Use when managing complex projects requiring multiple expertise areas.

commands:
  - coordinate-workflow
  - delegate-task
  - synthesize-results

capabilities:
  - Task delegation
  - Workflow management
  - Result synthesis
  - Progress tracking
```

### Pattern 3: Quality Assurance

**For validation and testing:**
```yaml
name: qa-specialist
description: Validates outputs, runs tests, and ensures quality standards. Use when verifying deliverables or checking compliance.

commands:
  - validate-output
  - run-tests
  - check-compliance

capabilities:
  - Output validation
  - Test execution
  - Compliance checking
  - Quality metrics
```

### Pattern 4: Documentation Specialist

**For creating and maintaining docs:**
```yaml
name: tech-writer
description: Creates technical documentation, explanations, and guides. Use when documenting features, APIs, or processes.

commands:
  - create-docs
  - explain-concept
  - generate-guide

capabilities:
  - Documentation creation
  - Technical writing
  - Diagram generation
  - Explanation clarity
```

## Command Design Patterns

### Pattern A: Analysis Commands
```
analyze-[subject] [input] [options]
```

**Examples:**
- `analyze-invoice invoice.pdf`
- `analyze-code ./src --depth deep`
- `analyze-data dataset.csv --stats`

### Pattern B: Generation Commands
```
generate-[artifact] [input] [format]
```

**Examples:**
- `generate-report quarterly --format pdf`
- `generate-summary text.md --length brief`
- `generate-diagram architecture --type mermaid`

### Pattern C: Validation Commands
```
validate-[type] [input] [rules]
```

**Examples:**
- `validate-json data.json --schema schema.json`
- `validate-security ./src --level high`
- `validate-style code.js --guide airbnb`

### Pattern D: Transformation Commands
```
transform-[format] [input] [output]
```

**Examples:**
- `transform-markdown doc.md --format html`
- `transform-data csv.json --format parquet`
- `transform-api openapi.yaml --format postman`

## Capability Design

### Good Capabilities
**Specific and measurable:**
- ✅ Parse PDF invoices
- ✅ Extract line items with 99% accuracy
- ✅ Calculate totals and taxes
- ✅ Compare against subscription database

### Bad Capabilities
**Vague or too broad:**
- ❌ Help with documents
- ❌ Process data
- ❌ Analyze things

## Integration Patterns

### Direct Integration
```
Agent A → Agent B
```
Use when: Agent B's output is Agent A's input

### Skill Integration
```
Agent → Skill
```
Use when: Agent needs specific capability

### Tool Integration
```
Agent → External Tool
```
Use when: Agent needs external data/service

### Multi-Agent Flow
```
Agent A → Agent B → Agent C
```
Use when: Workflow requires multiple steps

## Testing Your Agent

### Test 1: Command Trigger
```
User: "Review this PR: github.com/project/pull/123"
Expected: Agent triggers with correct command
```

### Test 2: Workflow Execution
```
User: "Help me review and improve this code"
Expected: Agent coordinates review → analysis → suggestions
```

### Test 3: Integration
```
User: "Analyze this invoice and process payment"
Expected: Agent coordinates with payment processor
```

### Test 4: Edge Cases
```
User: "What if the invoice is malformed?"
Expected: Agent handles gracefully with clear error
```

## Common Mistakes to Avoid

### ❌ Overlapping Commands
**Bad:**
```yaml
commands:
  - analyze-invoice
  - invoice-analysis  # Duplicate!
```

**Good:**
```yaml
commands:
  - analyze-invoice  # Single clear command
```

### ❌ Vague Descriptions
**Bad:**
```yaml
description: Helps with code
```

**Good:**
```yaml
description: Reviews code for quality, security, and best practices
```

### ❌ Missing Integrations
**Bad:**
```yaml
# No mention of related agents
```

**Good:**
```yaml
integrations:
  - git-analyzer
  - security-scanner
```

### ❌ Too Many Commands
**Bad:**
```yaml
commands:
  - do-1
  - do-2
  - do-3
  - do-4
  - do-5
  - do-6  # Too many!
```

**Good:**
```yaml
commands:
  - analyze-[domain]
  - generate-[output]
  - validate-[type]
```

## Advanced Patterns

### Pattern 1: Hierarchical Agents
```
Manager → Specialist 1
       → Specialist 2
       → Specialist 3
```

**Use when:** Complex domain with sub-specialties

### Pattern 2: Peer Coordination
```
Agent A ↔ Agent B ↔ Agent C
```

**Use when:** Collaborative workflows

### Pattern 3: Chain of Command
```
Agent A → Agent B → Agent C
```

**Use when:** Sequential processing

### Pattern 4: Parallel Processing
```
Agent A → [Agent B, Agent C, Agent D] → Agent E
```

**Use when:** Independent sub-tasks

## Integration with BMAD

### During Planning
```
"Create an agent for requirements gathering"
→ Generates requirements-analyst agent
```

### During Architecture
```
"Create an agent for system design"
→ Generates architect agent
```

### During Implementation
```
"Create an agent for code generation"
→ Generates coder agent
```

### During Testing
```
"Create an agent for test generation"
→ Generates test-agent
```

## Agent Team Patterns

### Small Team (3-5 agents)
```
PM → Architect → Developer → QA
```

### Medium Team (6-10 agents)
```
Analyst → PM → Architect →
[Frontend, Backend, DB] →
QA → Tech Writer → Deployer
```

### Large Team (10+ agents)
```
Business → Product → Architecture →
[Multiple specialized teams] →
Quality → Documentation → Operations
```

## Best Practices Summary

1. **Clear domain** - Each agent has specific expertise
2. **Focused commands** - 3-5 commands per agent
3. **Measurable capabilities** - Specific and testable
4. **Defined integrations** - Know how agents collaborate
5. **Descriptive names** - Verb-noun format
6. **Complete descriptions** - What + when to use
7. **Integration-ready** - Designed for multi-agent workflows

## Quick Reference

### Agent Configuration Template
```yaml
---
name: [agent-name]
description: [what + when]
commands:
  - name: [command]
    description: [what it does]
    parameters: [inputs]
    example: [usage example]
capabilities:
  - [capability 1]
  - [capability 2]
integrations:
  - [related agents/skills]
---
```

### Command Template
```yaml
- name: [verb-noun]
  description: [clear action]
  parameters: [required, optional?]
  example: "command-name input --option value"
```

### Capability Checklist
- [ ] Action-oriented
- [ ] Measurable
- [ ] Domain-specific
- [ ] Aligned with commands

### Integration Checklist
- [ ] Agent relationships defined
- [ ] Skill dependencies listed
- [ ] External tools identified
- [ ] Workflow paths clear

---

**Remember:** The best agents work seamlessly in teams. Design for collaboration, not isolation.
