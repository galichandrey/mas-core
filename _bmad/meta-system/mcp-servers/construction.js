#!/usr/bin/env node
/**
 * MAS Construction MCP Server v2.0
 *
 * Provides tools for building MAS components:
 * - Construct skills from specifications
 * - Construct agents from configurations
 * - Construct systems from blueprints
 * - Validate components
 *
 * Usage: Node.js MCP server (stdio transport)
 */

const { Server } = require("@modelcontextprotocol/sdk/server");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio");
const fs = require("fs");
const path = require("path");
const { execFile } = require("child_process");
const { promisify } = require("util");

const execFileAsync = promisify(execFile);

const server = new Server({
  name: "mas-construction-v2",
  version: "2.0.0",
  description: "MAS v2.0 Construction - Build and validate components"
});

const PROJECT_ROOT = process.env.MAS_PROJECT_ROOT || process.cwd();
const SKILLS_DIR = path.join(PROJECT_ROOT, ".claude", "skills");
const AGENTS_DIR = path.join(PROJECT_ROOT, "_bmad", "_config", "agents");
const TEMPLATES_DIR = path.join(PROJECT_ROOT, "_bmad", "meta-system", "templates");

// Helper: Create directory structure
function ensureDirectory(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

// Helper: Write file with content
function writeFile(filePath, content) {
  const dir = path.dirname(filePath);
  ensureDirectory(dir);
  fs.writeFileSync(filePath, content);
}

// Helper: Generate skill.json
function generateSkillJson(name, type, description, capabilities = []) {
  const baseJson = {
    name: name,
    version: "1.0.0",
    type: type,
    description: description,
    tags: [type, "generated"],
    capabilities: capabilities.length > 0 ? capabilities : ["capability-1", "capability-2"],
    type_specific: {},
    dependencies: {
      skills: [],
      agents: [],
      tools: []
    },
    compatibility: {
      mas: "^2.0.0",
      claude: ">=3.5",
      platforms: ["linux", "macos", "windows"]
    },
    author: "MAS Construction Server",
    license: "MIT",
    repository: `https://github.com/your-org/${name}`,
    metadata: {
      token_usage: "medium",
      execution_time: "fast",
      difficulty: "intermediate",
      auto_trigger: true,
      cost_credits: 0
    },
    quality: {
      validation_status: "unverified",
      test_coverage: 0,
      security_score: 0,
      docs_quality: "basic"
    }
  };

  // Add type-specific fields
  if (type === "base") {
    baseJson.type_specific = {
      base: {
        atomic: true,
        dependencies: []
      }
    };
  } else if (type === "meta") {
    baseJson.type_specific = {
      meta: {
        creates: ["skill"],
        self_improvement: true
      }
    };
  } else if (type === "composite") {
    baseJson.type_specific = {
      composite: {
        composition_type: "sequential",
        base_skills: [
          { name: "base-skill-1", role: "input", optional: false },
          { name: "base-skill-2", role: "processing", optional: false },
          { name: "base-skill-3", role: "output", optional: false }
        ]
      }
    };
  }

  return baseJson;
}

// Helper: Generate SKILL.md
function generateSkillMd(name, type, description) {
  const title = name.split("-").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");

  if (type === "base") {
    return `---
name: ${name}
description: ${description}
type: base
version: 1.0.0
---

# ${title}

## Overview
${description}

## Quick Start
[Basic usage example]

## Core Capabilities

### 1. [Capability Name]
- What it does
- When to use
- Example

### 2. [Capability Name]
- What it does
- When to use
- Example

## Resources

### scripts/
- \`main.py\` - Core logic
- \`helpers.sh\` - Utilities

### references/
- \`patterns.md\` - Common patterns
- \`api-docs.md\` - API reference

### assets/
- \`template.json\` - Output template

## Validation Checklist
- [ ] SKILL.md exists with valid YAML frontmatter
- [ ] Name is hyphen-case
- [ ] Description includes "what" and "when to use"
- [ ] Description < 1024 characters
- [ ] Resource directories created
- [ ] No deeply nested references (max 2 levels)
- [ ] All paths use forward slashes
- [ ] No absolute paths
`;
  } else if (type === "meta") {
    return `---
name: ${name}
description: ${description}
type: meta
version: 1.0.0
---

# Meta Skill: ${title}

**The skill that creates/modifies other skills.**

## Overview
${description}

## Quick Start

### Create a new skill
\`\`\`
Create a skill named [name] for [purpose]
\`\`\`

### Optimize an existing skill
\`\`\`
Optimize [skill-name] for [metric]
\`\`\`

## Core Capabilities

### 1. Skill Creation
[How it creates skills from scratch]

### 2. Skill Analysis
[How it analyzes existing skills]

### 3. Skill Optimization
[How it improves skills]

## Meta-Capabilities

### Self-Improvement
This meta-skill can improve itself:
\`\`\`
"Analyze and optimize ${name} for better token efficiency"
\`\`\`

### Pattern Learning
Can learn from existing skills:
\`\`\`
"Analyze these skills and extract common patterns"
\`\`\`

## Resources

### scripts/
- \`create.py\` - Skill creation logic
- \`analyze.py\` - Skill analysis
- \`optimize.py\` - Optimization engine

### references/
- \`skill-patterns.md\` - Common patterns
- \`best-practices.md\` - Meta-skill best practices
- \`templates.md\` - Template library

### assets/
- \`skill-template.json\` - Base template
- \`validation-rules.json\` - Validation rules

## Integration

### With Other Meta-Skills
- Uses \`meta-prompt-generator\` for prompt creation
- Uses \`meta-system-validator\` for validation

### With Marketplace
- Can publish created skills
- Can update existing skills

## Meta-Loops

### Creation Loop
\`\`\`
User Request → Analyze → Generate → Validate → Deploy → Learn → Improve
\`\`\`

### Optimization Loop
\`\`\`
Usage Metrics → Analyze → Optimize → Validate → Deploy → Measure
\`\`\`

## Best Practices

1. **Start Simple** - Create basic skills first
2. **Validate Everything** - Always validate before deploying
3. **Learn from Patterns** - Extract and reuse patterns
4. **Self-Improve** - Use your own capabilities to improve yourself
5. **Document** - Keep clear documentation of changes
`;
  } else { // composite
    return `---
name: ${name}
description: ${description}
type: composite
version: 1.0.0
---

# Composite Skill: ${title}

**Orchestrates multiple base skills into a complete workflow.**

## Overview
${description}

## Quick Start
\`\`\`
User: [Example request]
Result: [Complete workflow execution]
\`\`\`

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
\`\`\`
Input → Validate → Transform → Output
  ↓       ↓         ↓         ↓
Step1 → Step2 → Step3 → Final Result
\`\`\`

## Resources

### scripts/
- \`orchestrator.py\` - Main workflow coordinator
- \`router.py\` - Data routing logic
- \`error-handler.py\` - Error handling

### references/
- \`composition-guide.md\` - How to compose skills
- \`workflow-patterns.md\` - Common patterns
- \`troubleshooting.md\` - Common issues

### assets/
- \`workflow-template.json\` - Workflow configuration template

## Testing

### Test 1: Complete Workflow
\`\`\`
Input: [Test data]
Expected: [Complete result]
Steps: 3
\`\`\`

### Test 2: Error Recovery
\`\`\`
Input: [Invalid data]
Expected: [Clear error message]
\`\`\`

## Quick Reference

### Composition Definition
\`\`\`json
{
  "composition_type": "sequential",
  "base_skills": [
    {"name": "skill-1", "role": "input"},
    {"name": "skill-2", "role": "process"},
    {"name": "skill-3", "role": "output"}
  ]
}
\`\`\`

### Validation Checklist
- [ ] All base skills exist
- [ ] Workflow logic tested
- [ ] Error handling implemented
- [ ] Data flow validated
- [ ] Performance acceptable
`;
  }
}

// Helper: Generate agent configuration
function generateAgentConfig(name, domain, capabilities = []) {
  return {
    name: name,
    version: "1.0.0",
    description: `Specialized agent for ${domain} operations`,
    type: "specialized",
    capabilities: capabilities.length > 0 ? capabilities : ["analysis", "generation", "validation"],
    commands: [
      {
        name: `${name}-analyze`,
        description: `Analyze ${domain} requirements`,
        trigger_patterns: [`analyze ${domain}`, `review ${domain}`, `${domain} analysis`]
      },
      {
        name: `${name}-generate`,
        description: `Generate ${domain} outputs`,
        trigger_patterns: [`create ${domain}`, `generate ${domain}`, `build ${domain}`]
      },
      {
        name: `${name}-validate`,
        description: `Validate ${domain} results`,
        trigger_patterns: [`validate ${domain}`, `check ${domain}`, `verify ${domain}`]
      }
    ],
    integrations: {
      skills: ["meta-system-validator", "meta-prompt-generator"],
      agents: []
    },
    configuration: {
      auto_trigger: false,
      priority: "medium",
      project_specific: true
    },
    metadata: {
      created: new Date().toISOString(),
      last_used: null,
      usage_count: 0
    }
  };
}

// Tool: Construct skill
server.addTool({
  name: "construct_skill",
  description: "Construct a complete skill package from specification",
  inputSchema: {
    type: "object",
    properties: {
      name: { type: "string", description: "Skill name (hyphen-case)" },
      type: { type: "string", enum: ["base", "meta", "composite"], description: "Skill type" },
      description: { type: "string", description: "What it does and when to use" },
      capabilities: {
        type: "array",
        items: { type: "string" },
        description: "List of capabilities"
      },
      targetDir: { type: "string", description: "Override target directory" }
    },
    required: ["name", "type", "description"]
  },
  async handler(args) {
    const targetDir = args.targetDir || SKILLS_DIR;
    const skillPath = path.join(targetDir, args.name);

    // Validate name
    if (!/^[a-z0-9-]+$/.test(args.name)) {
      return {
        content: [{ type: "text", text: `❌ Invalid name: ${args.name}. Must be lowercase, digits, hyphens only.` }],
        isError: true
      };
    }

    // Check if exists
    if (fs.existsSync(skillPath)) {
      return {
        content: [{ type: "text", text: `⚠️ Skill already exists: ${args.name}\nPath: ${skillPath}` }],
        isError: false
      };
    }

    try {
      // Create skill directory
      ensureDirectory(skillPath);

      // Generate skill.json
      const skillJson = generateSkillJson(
        args.name,
        args.type,
        args.description,
        args.capabilities || []
      );

      writeFile(
        path.join(skillPath, "skill.json"),
        JSON.stringify(skillJson, null, 2)
      );

      // Generate SKILL.md
      const skillMd = generateSkillMd(args.name, args.type, args.description);

      writeFile(
        path.join(skillPath, "SKILL.md"),
        skillMd
      );

      // Create directory structure
      ensureDirectory(path.join(skillPath, "scripts"));
      ensureDirectory(path.join(skillPath, "references"));
      ensureDirectory(path.join(skillPath, "assets"));

      // Create basic script template
      const scriptContent = `#!/usr/bin/env python3
\"\"\"
${args.name} - ${args.description}
\"\"\"

def main():
    \"\"\"Main function\"\"\n    pass

if __name__ == "__main__":
    main()
`;

      writeFile(
        path.join(skillPath, "scripts", "main.py"),
        scriptContent
      );

      // Create README
      const readme = `# ${args.name}\n\n**Type:** ${args.type}\n**Version:** 1.0.0\n\n## What is this?\n\n${args.description}\n\n## Installation\n\n\`\`\`bash\nmas_install_skill ${args.name} source=local --target ${targetDir}\n\`\`\`\n\n## Usage\n\nSee SKILL.md\n\n## Development\n\n\`\`\`bash\n# Validate\nmas_validate_skill ${args.name}\n\n# Test\npython scripts/main.py\n\`\`\`\n`;

      writeFile(
        path.join(skillPath, "README.md"),
        readme
      );

      return {
        content: [{
          type: "text",
          text: `✅ Skill Constructed Successfully\n\n` +
                `Name: ${args.name}\n` +
                `Type: ${args.type}\n` +
                `Path: ${skillPath}\n\n` +
                `Files created:\n` +
                `  ✓ skill.json (v2.0 spec)\n` +
                `  ✓ SKILL.md (documentation)\n` +
                `  ✓ scripts/main.py (template)\n` +
                `  ✓ README.md (quick start)\n` +
                `  ✓ scripts/, references/, assets/ (directories)\n\n` +
                `Next steps:\n` +
                `  1. Edit SKILL.md with detailed documentation\n` +
                `  2. Add implementation to scripts/\n` +
                `  3. Add reference docs to references/\n` +
                `  4. Validate: mas_validate_skill ${args.name}\n` +
                `  5. Publish: mas_publish_skill ${args.name} mode=local`
        }]
      };

    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Construction failed: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Construct agent
server.addTool({
  name: "construct_agent",
  description: "Construct agent configuration from specification",
  inputSchema: {
    type: "object",
    properties: {
      name: { type: "string", description: "Agent name" },
      domain: { type: "string", description: "Specialization domain" },
      capabilities: {
        type: "array",
        items: { type: "string" },
        description: "Agent capabilities"
      },
      targetDir: { type: "string", description: "Override target directory" }
    },
    required: ["name", "domain"]
  },
  async handler(args) {
    const targetDir = args.targetDir || AGENTS_DIR;
    const agentPath = path.join(targetDir, `${args.name}.yaml`);

    try {
      // Generate agent config
      const config = generateAgentConfig(
        args.name,
        args.domain,
        args.capabilities || []
      );

      // Ensure directory
      ensureDirectory(targetDir);

      // Write YAML
      const yamlContent = `# ${args.name} Agent Configuration\n` +
                          `# Generated: ${new Date().toISOString()}\n\n` +
                          `name: ${config.name}\n` +
                          `version: ${config.version}\n` +
                          `description: ${config.description}\n` +
                          `type: ${config.type}\n\n` +
                          `capabilities:\n` +
                          config.capabilities.map(c => `  - ${c}`).join("\n") + `\n\n` +
                          `commands:\n` +
                          config.commands.map(cmd =>
                            `  - name: ${cmd.name}\n` +
                            `    description: ${cmd.description}\n` +
                            `    trigger_patterns:\n` +
                            cmd.trigger_patterns.map(p => `      - "${p}"`).join("\n")
                          ).join("\n\n") + `\n\n` +
                          `integrations:\n` +
                          `  skills:\n` +
                          config.integrations.skills.map(s => `    - ${s}`).join("\n") + `\n` +
                          `  agents:\n` +
                          config.integrations.agents.map(a => `    - ${a}`).join("\n") + `\n\n` +
                          `configuration:\n` +
                          `  auto_trigger: ${config.configuration.auto_trigger}\n` +
                          `  priority: ${config.configuration.priority}\n` +
                          `  project_specific: ${config.configuration.project_specific}\n\n` +
                          `metadata:\n` +
                          `  created: ${config.metadata.created}\n` +
                          `  last_used: ${config.metadata.last_used}\n` +
                          `  usage_count: ${config.metadata.usage_count}\n`;

      writeFile(agentPath, yamlContent);

      return {
        content: [{
          type: "text",
          text: `✅ Agent Constructed Successfully\n\n` +
                `Name: ${args.name}\n` +
                `Domain: ${args.domain}\n` +
                `Path: ${agentPath}\n\n` +
                `Capabilities:\n${config.capabilities.map(c => `  • ${c}`).join("\n")}\n\n` +
                `Commands:\n${config.commands.map(c => `  • ${c.name} - ${c.description}`).join("\n")}\n\n` +
                `Ready to use in BMAD workflows!`
        }]
      };

    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Agent construction failed: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Construct system
server.addTool({
  name: "construct_system",
  description: "Construct complete system from blueprint",
  inputSchema: {
    type: "object",
    properties: {
      blueprint: { type: "string", description: "System blueprint (JSON or path)" },
      name: { type: "string", description: "System name" },
      targetDir: { type: "string", description: "Target directory" }
    },
    required: ["blueprint", "name"]
  },
  async handler(args) {
    let blueprint;

    // Parse blueprint
    if (fs.existsSync(args.blueprint)) {
      blueprint = JSON.parse(fs.readFileSync(args.blueprint, "utf8"));
    } else {
      try {
        blueprint = JSON.parse(args.blueprint);
      } catch {
        return {
          content: [{ type: "text", text: `❌ Invalid blueprint format. Must be valid JSON or file path.` }],
          isError: true
        };
      }
    }

    const targetDir = args.targetDir || path.join(PROJECT_ROOT, args.name);
    const results = [];

    try {
      // Construct skills
      if (blueprint.skills) {
        for (const skill of blueprint.skills) {
          const result = await constructSkillInternal(
            skill.name,
            skill.type,
            skill.description,
            skill.capabilities || [],
            path.join(targetDir, ".claude", "skills")
          );
          results.push({ type: "skill", name: skill.name, status: result.success });
        }
      }

      // Construct agents
      if (blueprint.agents) {
        for (const agent of blueprint.agents) {
          const result = await constructAgentInternal(
            agent.name,
            agent.domain,
            agent.capabilities || [],
            path.join(targetDir, "_bmad", "_config", "agents")
          );
          results.push({ type: "agent", name: agent.name, status: result.success });
        }
      }

      // Create system README
      const readme = `# ${args.name} System\n\n` +
                     `Generated: ${new Date().toISOString()}\n\n` +
                     `## Components\n\n` +
                     results.map(r => `- ${r.type}: ${r.name} (${r.status ? "✅" : "❌"})`).join("\n") + `\n\n` +
                     `## Structure\n\n` +
                     `\`\`\`\n${args.name}/\n` +
                     `├── .claude/skills/\n` +
                     `│   └── [constructed skills]\n` +
                     `└── _bmad/_config/agents/\n` +
                     `    └── [constructed agents]\n` +
                     `\`\`\`\n`;

      writeFile(path.join(targetDir, "README.md"), readme);

      return {
        content: [{
          type: "text",
          text: `✅ System Constructed\n\n` +
                `Name: ${args.name}\n` +
                `Location: ${targetDir}\n\n` +
                `Components:\n${results.map(r => `  ${r.status ? "✅" : "❌"} ${r.type}: ${r.name}`).join("\n")}\n\n` +
                `Total: ${results.length} components`
        }]
      };

    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ System construction failed: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Validate component
server.addTool({
  name: "validate_component",
  description: "Validate any MAS component (skill, agent, system)",
  inputSchema: {
    type: "object",
    properties: {
      path: { type: "string", description: "Path to component" },
      type: { type: "string", enum: ["skill", "agent", "system"], description: "Component type" },
      strict: { type: "boolean", description: "Strict validation" }
    },
    required: ["path", "type"]
  },
  async handler(args) {
    if (!fs.existsSync(args.path)) {
      return {
        content: [{ type: "text", text: `❌ Path not found: ${args.path}` }],
        isError: true
      };
    }

    const checks = [];
    let passed = 0;
    let total = 0;

    if (args.type === "skill") {
      // Validate skill
      total += 1;
      if (fs.existsSync(path.join(args.path, "skill.json"))) {
        checks.push({ check: "skill.json", status: "✅" });
        passed += 1;
      } else {
        checks.push({ check: "skill.json", status: "❌" });
      }

      total += 1;
      if (fs.existsSync(path.join(args.path, "SKILL.md"))) {
        checks.push({ check: "SKILL.md", status: "✅" });
        passed += 1;
      } else {
        checks.push({ check: "SKILL.md", status: "❌" });
      }

      if (args.strict) {
        total += 1;
        try {
          const skillJson = JSON.parse(fs.readFileSync(path.join(args.path, "skill.json"), "utf8"));
          if (skillJson.name && skillJson.version && skillJson.type && skillJson.description) {
            checks.push({ check: "v2.0 schema", status: "✅" });
            passed += 1;
          } else {
            checks.push({ check: "v2.0 schema", status: "❌" });
          }
        } catch {
          checks.push({ check: "v2.0 schema", status: "❌" });
        }
      }

    } else if (args.type === "agent") {
      // Validate agent
      total += 1;
      if (fs.existsSync(args.path) && args.path.endsWith(".yaml")) {
        checks.push({ check: "YAML config", status: "✅" });
        passed += 1;
      } else {
        checks.push({ check: "YAML config", status: "❌" });
      }

      total += 1;
      try {
        const content = fs.readFileSync(args.path, "utf8");
        if (content.includes("name:") && content.includes("commands:")) {
          checks.push({ check: "Required fields", status: "✅" });
          passed += 1;
        } else {
          checks.push({ check: "Required fields", status: "❌" });
        }
      } catch {
        checks.push({ check: "Required fields", status: "❌" });
      }

    } else if (args.type === "system") {
      // Validate system
      total += 1;
      if (fs.existsSync(path.join(args.path, ".claude", "skills"))) {
        checks.push({ check: "Skills directory", status: "✅" });
        passed += 1;
      } else {
        checks.push({ check: "Skills directory", status: "⚠️" });
      }

      total += 1;
      if (fs.existsSync(path.join(args.path, "_bmad", "_config", "agents"))) {
        checks.push({ check: "Agents directory", status: "✅" });
        passed += 1;
      } else {
        checks.push({ check: "Agents directory", status: "⚠️" });
      }

      total += 1;
      if (fs.existsSync(path.join(args.path, "README.md"))) {
        checks.push({ check: "README", status: "✅" });
        passed += 1;
      } else {
        checks.push({ check: "README", status: "⚠️" });
      }
    }

    const score = Math.round((passed / total) * 100);
    const quality = score >= 90 ? "Excellent" : score >= 75 ? "Good" : score >= 60 ? "Fair" : "Needs work";

    return {
      content: [{
        type: "text",
        text: `🔍 Component Validation\n\n` +
              `Type: ${args.type}\n` +
              `Path: ${args.path}\n` +
              `Score: ${passed}/${total} (${score}%)\n` +
              `Quality: ${quality}\n\n` +
              `Checks:\n${checks.map(c => `  ${c.status} ${c.check}`).join("\n")}`
      }]
    };
  }
});

// Internal helper functions
async function constructSkillInternal(name, type, description, capabilities, targetDir) {
  try {
    const skillPath = path.join(targetDir, name);
    ensureDirectory(skillPath);

    const skillJson = generateSkillJson(name, type, description, capabilities);
    writeFile(path.join(skillPath, "skill.json"), JSON.stringify(skillJson, null, 2));

    const skillMd = generateSkillMd(name, type, description);
    writeFile(path.join(skillPath, "SKILL.md"), skillMd);

    ensureDirectory(path.join(skillPath, "scripts"));
    ensureDirectory(path.join(skillPath, "references"));
    ensureDirectory(path.join(skillPath, "assets"));

    return { success: true };
  } catch {
    return { success: false };
  }
}

async function constructAgentInternal(name, domain, capabilities, targetDir) {
  try {
    const config = generateAgentConfig(name, domain, capabilities);
    const yamlContent = `name: ${config.name}\nversion: ${config.version}\ndescription: ${config.description}\n`;

    writeFile(path.join(targetDir, `${name}.yaml`), yamlContent);
    return { success: true };
  } catch {
    return { success: false };
  }
}

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error("🚀 MAS Construction MCP Server v2.0 running");
  console.error(`Project root: ${PROJECT_ROOT}`);
  console.error(`Skills dir: ${SKILLS_DIR}`);
  console.error(`Agents dir: ${AGENTS_DIR}`);
}

main().catch((error) => {
  console.error("❌ Server error:", error);
  process.exit(1);
});
