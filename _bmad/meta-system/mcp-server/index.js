#!/usr/bin/env node
/**
 * MAS Marketplace MCP Server
 * Provides MCP tools for MAS marketplace operations
 * Uses safe execFile instead of exec to prevent command injection
 */

const { Server } = require("@modelcontextprotocol/sdk/server");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio");
const { execFile } = require("child_process");
const fs = require("fs");
const path = require("path");
const https = require("https");
const { promisify } = require("util");

const execFileAsync = promisify(execFile);

// Create server
const server = new Server({
  name: "mas-marketplace",
  version: "1.1.0",
  description: "Meta Agentic System Marketplace - Install, search, and publish skills"
});

// Helper: Fetch JSON safely
function fetchJSON(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

// Helper: Execute command safely with execFile
async function safeExec(command, args, cwd = process.cwd()) {
  try {
    const { stdout, stderr } = await execFileAsync(command, args, { cwd });
    return { success: true, stdout, stderr };
  } catch (error) {
    return { success: false, error: error.message, stdout: error.stdout, stderr: error.stderr };
  }
}

// Tool: Search skills
server.addTool({
  name: "mas_search_skills",
  description: "Search for skills in MAS marketplace",
  inputSchema: {
    type: "object",
    properties: {
      query: { type: "string", description: "Search query" },
      tags: { type: "array", items: { type: "string" }, description: "Filter by tags" },
      category: { type: "string", description: "Filter by category" }
    },
    required: ["query"]
  },
  async handler(args) {
    try {
      const registry = await fetchJSON("https://raw.githubusercontent.com/mas-marketplace/mas-core/main/marketplace/registry.json");
      const query = args.query.toLowerCase();

      let skills = registry.skills || [];

      // Filter by query
      skills = skills.filter(s => {
        const name = s.name.toLowerCase();
        const desc = s.description.toLowerCase();
        const tags = (s.tags || []).join(" ").toLowerCase();
        return name.includes(query) || desc.includes(query) || tags.includes(query);
      });

      // Filter by tags
      if (args.tags && args.tags.length > 0) {
        skills = skills.filter(s => {
          const skillTags = (s.tags || []).map(t => t.toLowerCase());
          return args.tags.some(t => skillTags.includes(t.toLowerCase()));
        });
      }

      // Filter by category
      if (args.category) {
        skills = skills.filter(s => s.category === args.category);
      }

      return {
        content: [{
          type: "text",
          text: `Found ${skills.length} skills:\n\n${skills.map(s =>
            `**${s.name}** (v${s.version})\n${s.description}\nTags: ${(s.tags || []).join(", ")}\nStatus: ${s.validation_status || 'unknown'}\n`
          ).join("\n")}`
        }]
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Error: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Install skill
server.addTool({
  name: "mas_install_skill",
  description: "Install a skill from MAS marketplace",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Skill name to install" },
      targetPath: { type: "string", description: "Target directory (default: current)" },
      version: { type: "string", description: "Specific version" }
    },
    required: ["skillName"]
  },
  async handler(args) {
    const targetPath = args.targetPath || process.cwd();
    const skillName = args.skillName;
    const version = args.version || "latest";

    try {
      // Check if install-from-marketplace.sh exists
      const scriptPath = path.join(targetPath, "_bmad/meta-system/export-tools/install-from-marketplace.sh");

      let result;
      if (fs.existsSync(scriptPath)) {
        // Use existing installer
        result = await safeExec(scriptPath, [skillName, targetPath], targetPath);
      } else {
        // Use curl to download and run installer
        // Note: This is safe because we're not passing user input to shell
        const curlResult = await safeExec("curl", ["-sSL", "https://get.mas.dev"]);
        if (!curlResult.success) {
          throw new Error("Failed to download installer");
        }

        // Run the downloaded script with safe args
        const bashResult = await safeExec("bash", ["-s", "--", "--target", targetPath, "--mode", "skill-only"], targetPath);
        result = bashResult;
      }

      if (result.success) {
        return {
          content: [{
            type: "text",
            text: `✅ Skill "${skillName}" installed successfully to ${targetPath}`
          }]
        };
      } else {
        throw new Error(result.error || "Installation failed");
      }
    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Installation failed: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Validate skill
server.addTool({
  name: "mas_validate_skill",
  description: "Validate a skill before installation or after creation",
  inputSchema: {
    type: "object",
    properties: {
      skillPath: { type: "string", description: "Path to skill directory" },
      skillName: { type: "string", description: "Skill name (if in .claude/skills)" }
    },
    required: []
  },
  async handler(args) {
    let skillPath = args.skillPath;

    if (!skillPath && args.skillName) {
      skillPath = path.join(process.cwd(), ".claude/skills", args.skillName);
    }

    if (!skillPath) {
      skillPath = process.cwd();
    }

    try {
      // Check if meta-system-validator exists
      const validatorPath = path.join(process.cwd(), "_bmad/meta-system/export-tools/validate-system.sh");

      if (fs.existsSync(validatorPath)) {
        const result = await safeExec(validatorPath, ["--skill", path.basename(skillPath)], process.cwd());

        if (result.success) {
          return {
            content: [{ type: "text", text: result.stdout }]
          };
        } else {
          return {
            content: [{ type: "text", text: result.stderr || result.error }],
            isError: true
          };
        }
      } else {
        // Manual validation
        const checks = [];

        if (fs.existsSync(path.join(skillPath, "SKILL.md"))) {
          checks.push("✅ SKILL.md exists");
        } else {
          checks.push("❌ SKILL.md missing");
        }

        if (fs.existsSync(path.join(skillPath, "scripts"))) {
          checks.push("✅ scripts/ directory exists");
        }

        return {
          content: [{
            type: "text",
            text: `Validation results for ${skillPath}:\n\n${checks.join("\n")}`
          }]
        };
      }
    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Validation failed: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Update MAS
server.addTool({
  name: "mas_update",
  description: "Update MAS to latest version",
  inputSchema: {
    type: "object",
    properties: {
      targetPath: { type: "string", description: "Project directory" },
      version: { type: "string", description: "Specific version" }
    },
    required: []
  },
  async handler(args) {
    const targetPath = args.targetPath || process.cwd();
    const version = args.version || "";

    try {
      const scriptPath = path.join(targetPath, "_bmad/meta-system/export-tools/updater.sh");

      if (!fs.existsSync(scriptPath)) {
        return {
          content: [{ type: "text", text: "❌ updater.sh not found. Install MAS first." }],
          isError: true
        };
      }

      const argsList = version ? ["--version", version, "--yes"] : ["--yes"];
      const result = await safeExec(scriptPath, argsList, targetPath);

      if (result.success) {
        return {
          content: [{ type: "text", text: `✅ MAS updated:\n${result.stdout}` }]
        };
      } else {
        throw new Error(result.error);
      }
    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Update failed: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Publish skill
server.addTool({
  name: "mas_publish_skill",
  description: "Publish a skill to marketplace",
  inputSchema: {
    type: "object",
    properties: {
      skillPath: { type: "string", description: "Path to skill" },
      repository: { type: "string", description: "Target repository (org/repo)" },
      mode: { type: "string", description: "prepare, submit, or local" }
    },
    required: ["skillPath"]
  },
  async handler(args) {
    const skillPath = args.skillPath;
    const repository = args.repository || "mas-marketplace/mas-core";
    const mode = args.mode || "submit";

    try {
      const scriptPath = path.join(process.cwd(), "_bmad/meta-system/export-tools/publisher.sh");

      if (!fs.existsSync(scriptPath)) {
        return {
          content: [{ type: "text", text: "❌ publisher.sh not found. Install MAS first." }],
          isError: true
        };
      }

      const skillName = path.basename(skillPath);
      const result = await safeExec(scriptPath, ["--" + mode, skillName, "--repo", repository], process.cwd());

      if (result.success) {
        return {
          content: [{ type: "text", text: `✅ Skill published:\n${result.stdout}` }]
        };
      } else {
        throw new Error(result.error);
      }
    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Publication failed: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: List marketplace
server.addTool({
  name: "mas_list_skills",
  description: "List all available skills in marketplace",
  inputSchema: {
    type: "object",
    properties: {
      category: { type: "string", description: "Filter by category" }
    },
    required: []
  },
  async handler(args) {
    try {
      const registry = await fetchJSON("https://raw.githubusercontent.com/mas-marketplace/mas-core/main/marketplace/registry.json");
      let skills = registry.skills || [];

      if (args.category) {
        skills = skills.filter(s => s.category === args.category);
      }

      const text = skills.map(s =>
        `${s.name} (v${s.version}) - ${s.description} [${s.validation_status || 'unknown'}]`
      ).join("\n");

      return {
        content: [{
          type: "text",
          text: `Available skills (${skills.length}):\n\n${text}`
        }]
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Failed to fetch registry: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Get skill info
server.addTool({
  name: "mas_skill_info",
  description: "Get detailed information about a skill",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Skill name" }
    },
    required: ["skillName"]
  },
  async handler(args) {
    try {
      const registry = await fetchJSON("https://raw.githubusercontent.com/mas-marketplace/mas-core/main/marketplace/registry.json");
      const skill = (registry.skills || []).find(s => s.name === args.skillName);

      if (!skill) {
        return {
          content: [{ type: "text", text: `Skill "${args.skillName}" not found` }],
          isError: true
        };
      }

      const info = [
        `**${skill.name}** v${skill.version}`,
        ``,
        `Description: ${skill.description}`,
        `Author: ${skill.author || 'Unknown'}`,
        `Category: ${skill.category || 'General'}`,
        `Status: ${skill.validation_status || 'unknown'}`,
        `Rating: ${skill.rating || 'N/A'}`,
        `Downloads: ${skill.downloads || 0}`,
        `Tags: ${(skill.tags || []).join(", ")}`,
        `Dependencies: ${(skill.dependencies || []).join(", ") || 'None'}`,
        `GitHub: ${skill.github || 'N/A'}`,
        `Last Updated: ${skill.last_updated || 'N/A'}`
      ].join("\n");

      return {
        content: [{ type: "text", text: info }]
      };
    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Failed to get info: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("MAS Marketplace MCP Server running (v1.1.0)");
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});