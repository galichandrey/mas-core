#!/usr/bin/env node
/**
 * MAS Prompt Manager MCP Server v2.0
 *
 * Provides tools for prompt lifecycle management:
 * - Create optimized prompts
 * - Validate prompt structure
 * - Compose prompts from templates
 * - Optimize existing prompts
 *
 * Usage: Node.js MCP server (stdio transport)
 */

const { Server } = require("@modelcontextprotocol/sdk/server");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio");
const fs = require("fs");
const path = require("path");

const server = new Server({
  name: "mas-prompt-manager-v2",
  version: "2.0.0",
  description: "MAS v2.0 Prompt Manager - Create, validate, and optimize prompts"
});

const PROJECT_ROOT = process.env.MAS_PROJECT_ROOT || process.cwd();
const PROMPT_DIR = path.join(PROJECT_ROOT, "_bmad", "_config", "prompts");

// Ensure prompt directory exists
if (!fs.existsSync(PROMPT_DIR)) {
  fs.mkdirSync(PROMPT_DIR, { recursive: true });
}

// Helper: Read template
function readTemplate(name) {
  const templates = {
    "skill-creation": `# Skill Creation Prompt

## Role
Expert skill architect specializing in MAS-compatible skill design.

## Task
Create a complete skill package following MAS v2.0 standards.

## Input
- Skill name: [hyphen-case]
- Purpose: [what it does]
- Triggers: [when to activate]

## Process
1. Analyze requirements
2. Choose design pattern (workflow/task/reference/capabilities)
3. Generate SKILL.md with proper frontmatter
4. Create resource directories
5. Add validation checklist

## Output Format
Complete skill directory with:
- skill.json (v2.0 spec)
- SKILL.md (validated structure)
- scripts/ (optional)
- references/ (optional)
- assets/ (optional)

## Constraints
- Name: lowercase, digits, hyphens only
- Description: < 1024 chars, includes "what" and "when"
- Body: < 500 lines
- No absolute paths
- Forward slashes only

## Examples
[Include 3+ complete skill examples]`,

    "agent-creation": `# Agent Creation Prompt

## Role
Agent architect specializing in multi-agent coordination.

## Task
Generate complete agent configuration with commands and capabilities.

## Input
- Agent name: [verb-noun format]
- Domain: [specialization area]
- Integration needs: [related agents/skills]

## Process
1. Define domain and scope
2. Design 3-5 focused commands
3. Specify measurable capabilities
4. Map integrations
5. Create configuration YAML

## Output Format
\`\`\`yaml
---
name: [agent-name]
description: [what + when]
commands: [...]
capabilities: [...]
integrations: [...]
---
\`\`\`

## Constraints
- Commands: 3-5 maximum
- Descriptions: complete (what + when)
- Capabilities: action-oriented and measurable
- Integrations: explicit relationships`,

    "prompt-optimization": `# Prompt Optimization Prompt

## Role
Prompt optimization specialist.

## Task
Analyze and improve prompts for clarity, efficiency, and effectiveness.

## Input
- Current prompt: [full text]
- Optimization goals: [speed, clarity, tokens, etc.]

## Process
1. Analyze for inefficiencies
2. Identify ambiguity
3. Check token usage
4. Suggest improvements
5. Create optimized version

## Output Format
- Analysis report
- Optimized prompt
- Improvement metrics
- Validation checklist`,

    "workflow-composition": `# Workflow Composition Prompt

## Role
Workflow designer for complex multi-step processes.

## Task
Compose workflows from multiple skills and agents.

## Input
- Workflow goal: [end-to-end objective]
- Available skills: [list]
- Available agents: [list]
- Constraints: [limitations]

## Process
1. Break down into steps
2. Map skills to steps
3. Assign agents
4. Define data flow
5. Add error handling

## Output Format
\`\`\`yaml
workflow:
  name: [workflow-name]
  steps:
    - step: 1
      action: [skill/agent]
      input: [source]
      output: [destination]
      validation: [check]
  error_handling: [strategy]
\`\`\``
  };

  return templates[name] || null;
}

// Helper: Validate prompt structure
function validatePrompt(promptText) {
  const checks = [];

  // Check for role
  if (promptText.includes("## Role") || promptText.includes("Role:")) {
    checks.push({ check: "Role definition", status: "✅" });
  } else {
    checks.push({ check: "Role definition", status: "❌", error: "Missing role" });
  }

  // Check for task
  if (promptText.includes("## Task") || promptText.includes("Task:")) {
    checks.push({ check: "Task definition", status: "✅" });
  } else {
    checks.push({ check: "Task definition", status: "❌", error: "Missing task" });
  }

  // Check for input
  if (promptText.includes("## Input") || promptText.includes("Input:")) {
    checks.push({ check: "Input specification", status: "✅" });
  } else {
    checks.push({ check: "Input specification", status: "⚠️", error: "Optional but recommended" });
  }

  // Check for process
  if (promptText.includes("## Process") || promptText.includes("Process:")) {
    checks.push({ check: "Process steps", status: "✅" });
  } else {
    checks.push({ check: "Process steps", status: "❌", error: "Missing process" });
  }

  // Check for output format
  if (promptText.includes("## Output") || promptText.includes("Output Format")) {
    checks.push({ check: "Output format", status: "✅" });
  } else {
    checks.push({ check: "Output format", status: "⚠️", error: "No output format specified" });
  }

  // Check for constraints
  if (promptText.includes("## Constraints") || promptText.includes("Constraints:")) {
    checks.push({ check: "Constraints", status: "✅" });
  } else {
    checks.push({ check: "Constraints", status: "⚠️", error: "No constraints" });
  }

  // Check length
  const lines = promptText.split("\n").length;
  if (lines > 10 && lines < 200) {
    checks.push({ check: "Length", status: "✅" });
  } else {
    checks.push({ check: "Length", status: "⚠️", error: `Too ${lines < 10 ? "short" : "long"} (${lines} lines)` });
  }

  return checks;
}

// Helper: Optimize prompt
function optimizePrompt(promptText) {
  const lines = promptText.split("\n");
  const optimized = [];
  const improvements = [];

  let inCodeBlock = false;

  for (let line of lines) {
    // Skip empty lines at start
    if (optimized.length === 0 && line.trim() === "") {
      continue;
    }

    // Track code blocks
    if (line.includes("```")) {
      inCodeBlock = !inCodeBlock;
      optimized.push(line);
      continue;
    }

    // Inside code blocks, keep as-is
    if (inCodeBlock) {
      optimized.push(line);
      continue;
    }

    // Remove redundant whitespace
    const trimmed = line.trim();

    // Remove multiple spaces
    const singleSpace = line.replace(/\s+/g, " ");

    // Keep structure but clean up
    if (trimmed.length > 0) {
      optimized.push(singleSpace);
    } else if (optimized[optimized.length - 1] !== "") {
      optimized.push(""); // Keep single blank lines
    }
  }

  // Remove trailing blank lines
  while (optimized.length > 0 && optimized[optimized.length - 1] === "") {
    optimized.pop();
  }

  // Analyze improvements
  const originalLength = promptText.length;
  const optimizedLength = optimized.join("\n").length;
  const reduction = Math.round((1 - optimizedLength / originalLength) * 100);

  if (reduction > 0) {
    improvements.push(`Reduced length by ${reduction}%`);
  }

  // Check for clarity improvements
  if (promptText.includes("##")) {
    improvements.push("Clear section headers");
  }

  if (promptText.includes("Example")) {
    improvements.push("Includes examples");
  }

  return {
    optimized: optimized.join("\n"),
    improvements: improvements,
    metrics: {
      originalLength,
      optimizedLength,
      lineCount: optimized.length,
      reduction: `${reduction}%`
    }
  };
}

// Helper: Compose from template
function composeFromTemplate(templateName, variables) {
  let template = readTemplate(templateName);

  if (!template) {
    return null;
  }

  // Replace variables
  for (const [key, value] of Object.entries(variables)) {
    const placeholder = `[${key}]`;
    template = template.split(placeholder).join(value);
  }

  return template;
}

// Tool: Create prompt
server.addTool({
  name: "prompt_create",
  description: "Create a new prompt from template or scratch",
  inputSchema: {
    type: "object",
    properties: {
      template: {
        type: "string",
        enum: ["skill-creation", "agent-creation", "prompt-optimization", "workflow-composition", "custom"],
        description: "Template to use"
      },
      variables: {
        type: "object",
        description: "Variables to fill in template"
      },
      name: { type: "string", description: "Prompt name for saving" }
    },
    required: ["template"]
  },
  async handler(args) {
    let prompt;

    if (args.template === "custom") {
      // Create custom prompt
      prompt = `# Custom Prompt

## Role
[Define the role]

## Task
[Define the task]

## Input
[Specify inputs]

## Process
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Output Format
[Describe expected output]

## Constraints
[Add constraints]

## Examples
[Add examples]
`;
    } else {
      // Use template
      const variables = args.variables || {};
      prompt = composeFromTemplate(args.template, variables);

      if (!prompt) {
        return {
          content: [{ type: "text", text: `❌ Template not found: ${args.template}` }],
          isError: true
        };
      }
    }

    // Validate
    const validation = validatePrompt(prompt);

    // Save if name provided
    if (args.name) {
      const promptPath = path.join(PROMPT_DIR, `${args.name}.md`);
      fs.writeFileSync(promptPath, prompt);
    }

    // Format output
    const validationText = validation.map(c => `${c.status} ${c.check}${c.error ? ` - ${c.error}` : ""}`).join("\n");

    return {
      content: [{
        type: "text",
        text: `✅ Prompt created\n\n` +
              `Template: ${args.template}\n` +
              (args.name ? `Saved as: ${args.name}.md\n` : "") +
              `\nValidation:\n${validationText}\n\n` +
              `Prompt:\n\`\`\`\n${prompt}\n\`\`\``
      }]
    };
  }
});

// Tool: Optimize prompt
server.addTool({
  name: "prompt_optimize",
  description: "Optimize existing prompt for clarity and efficiency",
  inputSchema: {
    type: "object",
    properties: {
      prompt: { type: "string", description: "Prompt text or file path" },
      goals: {
        type: "array",
        items: { type: "string", enum: ["clarity", "tokens", "speed", "structure"] },
        description: "Optimization goals"
      }
    },
    required: ["prompt"]
  },
  async handler(args) {
    let promptText;

    // Check if it's a file path
    if (fs.existsSync(args.prompt)) {
      promptText = fs.readFileSync(args.prompt, "utf8");
    } else {
      promptText = args.prompt;
    }

    // Optimize
    const result = optimizePrompt(promptText);

    // Apply goal-specific optimizations
    const goals = args.goals || [];

    if (goals.includes("clarity")) {
      // Add clarity improvements
      result.optimized = result.optimized
        .replace(/## Process/g, "## Process Steps")
        .replace(/## Input/g, "## Required Input");
      result.improvements.push("Enhanced clarity with specific headers");
    }

    if (goals.includes("tokens")) {
      // Aggressive token reduction
      result.optimized = result.optimized
        .split("\n")
        .filter(line => !line.includes("##") || line.startsWith("##"))
        .join("\n");
      result.improvements.push("Aggressive token optimization");
    }

    if (goals.includes("structure")) {
      // Ensure proper structure
      if (!result.optimized.includes("## Role")) {
        result.optimized = "## Role\n[Role description]\n\n" + result.optimized;
      }
      result.improvements.push("Added missing structure elements");
    }

    return {
      content: [{
        type: "text",
        text: `✨ Prompt Optimized\n\n` +
              `Metrics:\n` +
              `  Original: ${result.metrics.originalLength} chars\n` +
              `  Optimized: ${result.metrics.optimizedLength} chars\n` +
              `  Reduction: ${result.metrics.reduction}\n` +
              `  Lines: ${result.metrics.lineCount}\n\n` +
              `Improvements:\n${result.improvements.map(i => `  ✓ ${i}`).join("\n")}\n\n` +
              `Optimized Prompt:\n\`\`\`\n${result.optimized}\n\`\`\``
      }]
    };
  }
});

// Tool: Validate prompt
server.addTool({
  name: "prompt_validate",
  description: "Validate prompt structure and effectiveness",
  inputSchema: {
    type: "object",
    properties: {
      prompt: { type: "string", description: "Prompt text or file path" },
      strict: { type: "boolean", description: "Use strict validation" }
    },
    required: ["prompt"]
  },
  async handler(args) {
    let promptText;

    if (fs.existsSync(args.prompt)) {
      promptText = fs.readFileSync(args.prompt, "utf8");
    } else {
      promptText = args.prompt;
    }

    const checks = validatePrompt(promptText);

    if (args.strict) {
      // Strict mode requires all elements
      const requiredChecks = checks.filter(c => c.status === "❌");
      if (requiredChecks.length > 0) {
        return {
          content: [{
            type: "text",
            text: `❌ Validation Failed (Strict Mode)\n\n` +
                  `Missing elements:\n${requiredChecks.map(c => `  ✗ ${c.check}: ${c.error}`).join("\n")}`
          }],
          isError: true
        };
      }
    }

    const passed = checks.filter(c => c.status === "✅").length;
    const total = checks.length;
    const score = Math.round((passed / total) * 100);

    const quality = score >= 90 ? "Excellent" : score >= 75 ? "Good" : score >= 60 ? "Fair" : "Needs Work";

    const checkList = checks.map(c => `${c.status} ${c.check}${c.error ? ` - ${c.error}` : ""}`).join("\n");

    return {
      content: [{
        type: "text",
        text: `🔍 Prompt Validation Report\n\n` +
              `Score: ${passed}/${total} (${score}%)\n` +
              `Quality: ${quality}\n\n` +
              `Checks:\n${checkList}`
      }]
    };
  }
});

// Tool: Compose prompt
server.addTool({
  name: "prompt_compose",
  description: "Compose prompts from templates and variables",
  inputSchema: {
    type: "object",
    properties: {
      template: { type: "string", description: "Template name" },
      variables: {
        type: "object",
        description: "Variables to inject"
      },
      validate: { type: "boolean", description: "Validate after composition" }
    },
    required: ["template", "variables"]
  },
  async handler(args) {
    const template = readTemplate(args.template);

    if (!template) {
      return {
        content: [{ type: "text", text: `❌ Template not found: ${args.template}` }],
        isError: true
      };
    }

    // Compose
    let composed = template;
    for (const [key, value] of Object.entries(args.variables)) {
      const placeholder = `[${key}]`;
      composed = composed.split(placeholder).join(value);
    }

    // Validate if requested
    let validationText = "";
    if (args.validate) {
      const checks = validatePrompt(composed);
      validationText = checks.map(c => `${c.status} ${c.check}`).join("\n") + "\n\n";
    }

    // Save to prompts directory
    const filename = `${args.template}-${Date.now()}.md`;
    const filepath = path.join(PROMPT_DIR, filename);
    fs.writeFileSync(filepath, composed);

    return {
      content: [{
        type: "text",
        text: `✅ Composed Prompt\n\n` +
              `Template: ${args.template}\n` +
              `Saved: ${filename}\n\n` +
              (validationText ? `Validation:\n${validationText}` : "") +
              `Prompt:\n\`\`\`\n${composed}\n\`\`\``
      }]
    };
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error("🚀 MAS Prompt Manager MCP Server v2.0 running");
  console.error(`Project root: ${PROJECT_ROOT}`);
  console.error(`Prompt directory: ${PROMPT_DIR}`);
}

main().catch((error) => {
  console.error("❌ Server error:", error);
  process.exit(1);
});
