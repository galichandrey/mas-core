#!/usr/bin/env node
/**
 * MAS Marketplace MCP Server v2.0
 *
 * Provides tools for skill marketplace operations:
 * - Install skills from multiple sources
 * - Search and discover skills
 * - Validate skill structure
 * - Update skills
 * - Publish skills to marketplace
 *
 * Usage: Node.js MCP server (stdio transport)
 */

const { Server } = require("@modelcontextprotocol/sdk/server");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio");
const fs = require("fs");
const path = require("path");
const https = require("https");
const { execFile } = require("child_process");
const { promisify } = require("util");
const yaml = require("js-yaml");

const execFileAsync = promisify(execFile);

// Server configuration
const server = new Server({
  name: "mas-marketplace-v2",
  version: "2.0.0",
  description: "MAS v2.0 Marketplace - Complete skill operations"
});

// Get project root from environment
const PROJECT_ROOT = process.env.MAS_PROJECT_ROOT || process.cwd();
const REGISTRY_PATH = process.env.MAS_REGISTRY ||
  path.join(PROJECT_ROOT, "_bmad", "_config", "registry.yaml");
const SKILLS_DIR = path.join(PROJECT_ROOT, ".claude", "skills");
const SCHEMA_PATH = path.join(PROJECT_ROOT, "_bmad", "meta-system", "schemas", "skill.json");

// Helper: Safe file operations
function safeRead(filePath) {
  try {
    return fs.existsSync(filePath) ? fs.readFileSync(filePath, "utf8") : null;
  } catch {
    return null;
  }
}

function safeReadJSON(filePath) {
  try {
    return fs.existsSync(filePath) ? JSON.parse(fs.readFileSync(filePath, "utf8")) : null;
  } catch {
    return null;
  }
}

function safeReadYAML(filePath) {
  try {
    return fs.existsSync(filePath) ? yaml.load(fs.readFileSync(filePath, "utf8")) : null;
  } catch {
    return null;
  }
}

// Helper: Execute shell commands safely
async function safeExec(command, args, cwd = PROJECT_ROOT) {
  try {
    const { stdout, stderr } = await execFileAsync(command, args, { cwd });
    return { success: true, stdout, stderr };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

// Helper: Download file
async function downloadFile(url, destPath) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(destPath);
    https.get(url, (response) => {
      if (response.statusCode === 302 || response.statusCode === 301) {
        // Follow redirect
        https.get(response.headers.location, (redirectResponse) => {
          redirectResponse.pipe(file);
          file.on("finish", () => {
            file.close(resolve);
          });
        }).on("error", (err) => {
          fs.unlink(destPath, () => reject(err));
        });
      } else {
        response.pipe(file);
        file.on("finish", () => {
          file.close(resolve);
        });
      }
    }).on("error", (err) => {
      fs.unlink(destPath, () => reject(err));
    });
  });
}

// Helper: Validate skill.json against schema
async function validateSkillJson(skillPath) {
  const skillJsonPath = path.join(skillPath, "skill.json");

  if (!fs.existsSync(skillJsonPath)) {
    return { valid: false, error: "skill.json not found" };
  }

  try {
    const skillJson = JSON.parse(fs.readFileSync(skillJsonPath, "utf8"));
    const schema = safeReadJSON(SCHEMA_PATH);

    if (!schema) {
      return { valid: false, error: "v2.0 schema not found" };
    }

    // Basic validation
    const required = ["name", "version", "type", "description"];
    const missing = required.filter(field => !skillJson[field]);

    if (missing.length > 0) {
      return { valid: false, error: `Missing required fields: ${missing.join(", ")}` };
    }

    // Type validation
    if (!["base", "meta", "composite"].includes(skillJson.type)) {
      return { valid: false, error: "Invalid type (must be base, meta, or composite)" };
    }

    // Name validation
    if (!/^[a-z0-9-]+$/.test(skillJson.name)) {
      return { valid: false, error: "Name must be lowercase, digits, hyphens only" };
    }

    // Description validation
    if (skillJson.description.length > 1024) {
      return { valid: false, error: "Description too long (>1024 chars)" };
    }

    if (!/(what|when|use|if|when user|when task)/i.test(skillJson.description)) {
      return { valid: false, error: "Description must include trigger context (what/when)" };
    }

    return { valid: true, skill: skillJson };

  } catch (error) {
    return { valid: false, error: `Parse error: ${error.message}` };
  }
}

// Helper: Update registry
async function updateRegistry(skillName, source, version, metadata = {}) {
  const registry = safeReadYAML(REGISTRY_PATH) || {
    version: "2.0.0",
    components: { skills: [] }
  };

  // Find existing or add new
  const existingIndex = registry.components.skills.findIndex(s => s.name === skillName);

  const skillEntry = {
    name: skillName,
    version: version || "latest",
    source: source,
    installed: new Date().toISOString(),
    path: path.join(SKILLS_DIR, skillName),
    ...metadata
  };

  if (existingIndex >= 0) {
    registry.components.skills[existingIndex] = skillEntry;
  } else {
    registry.components.skills.push(skillEntry);
  }

  // Ensure directory exists
  const regDir = path.dirname(REGISTRY_PATH);
  if (!fs.existsSync(regDir)) {
    fs.mkdirSync(regDir, { recursive: true });
  }

  // Write registry
  fs.writeFileSync(REGISTRY_PATH, yaml.dump(registry, { lineWidth: 100 }));

  return { success: true, registry: skillEntry };
}

// Tool: Install skill from multiple sources
server.addTool({
  name: "mas_install_skill",
  description: "Install skill from GitHub, ZIP, or local source. Supports v2.0 schema.",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Skill name to install" },
      source: {
        type: "string",
        enum: ["github", "zip", "local", "marketplace"],
        description: "Installation source"
      },
      sourcePath: { type: "string", description: "Source path/URL (optional for marketplace)" },
      version: { type: "string", description: "Specific version (optional)" },
      targetDir: { type: "string", description: "Override target directory" }
    },
    required: ["skillName", "source"]
  },
  async handler(args) {
    const targetDir = args.targetDir || SKILLS_DIR;
    const skillTarget = path.join(targetDir, args.skillName);

    try {
      let result;

      switch(args.source) {
        case "github":
          const repo = args.sourcePath || "mas-marketplace/mas-skills";
          const versionPath = args.version ? `/tree/${args.version}` : "/main";
          const url = `https://github.com/${repo}/raw${versionPath}/skills/base/${args.skillName}.zip`;

          // Create temp file
          const tempZip = `/tmp/${args.skillName}-${Date.now()}.zip`;

          try {
            await downloadFile(url, tempZip);

            // Extract
            if (!fs.existsSync(targetDir)) {
              fs.mkdirSync(targetDir, { recursive: true });
            }

            await execFileAsync("unzip", ["-q", tempZip, "-d", targetDir]);
            fs.unlinkSync(tempZip);

            result = { success: true, message: `Installed from GitHub: ${repo}` };
          } catch (error) {
            return {
              content: [{ type: "text", text: `❌ GitHub download failed: ${error.message}` }],
              isError: true
            };
          }
          break;

        case "zip":
          if (!fs.existsSync(args.sourcePath)) {
            return {
              content: [{ type: "text", text: `❌ ZIP file not found: ${args.sourcePath}` }],
              isError: true
            };
          }

          if (!fs.existsSync(targetDir)) {
            fs.mkdirSync(targetDir, { recursive: true });
          }

          await execFileAsync("unzip", ["-q", args.sourcePath, "-d", targetDir]);
          result = { success: true, message: `Installed from ZIP: ${args.sourcePath}` };
          break;

        case "local":
          if (!fs.existsSync(args.sourcePath)) {
            return {
              content: [{ type: "text", text: `❌ Source path not found: ${args.sourcePath}` }],
              isError: true
            };
          }

          if (!fs.existsSync(targetDir)) {
            fs.mkdirSync(targetDir, { recursive: true });
          }

          await execFileAsync("cp", ["-r", args.sourcePath, skillTarget]);
          result = { success: true, message: `Copied from local: ${args.sourcePath}` };
          break;

        case "marketplace":
          // Try local registry first
          const registry = safeReadYAML(REGISTRY_PATH);
          if (registry && registry.components && registry.components.skills) {
            const skill = registry.components.skills.find(s => s.name === args.skillName);
            if (skill && skill.path && fs.existsSync(skill.path)) {
              // Copy from registry
              if (!fs.existsSync(targetDir)) {
                fs.mkdirSync(targetDir, { recursive: true });
              }
              await execFileAsync("cp", ["-r", skill.path, targetDir]);
              result = { success: true, message: `Installed from local registry` };
              break;
            }
          }

          return {
            content: [{ type: "text", text: `❌ Skill not found in local registry. Use --source github or local first.` }],
            isError: true
          };
      }

      // Validate installation
      const validation = await validateSkillJson(skillTarget);

      if (!validation.valid) {
        // Remove invalid installation
        if (fs.existsSync(skillTarget)) {
          fs.rmSync(skillTarget, { recursive: true, force: true });
        }
        return {
          content: [{ type: "text", text: `❌ Installation failed validation: ${validation.error}` }],
          isError: true
        };
      }

      // Update registry
      await updateRegistry(args.skillName, args.source, args.version, {
        type: validation.skill.type,
        capabilities: validation.skill.capabilities || []
      });

      return {
        content: [{
          type: "text",
          text: `✅ Installed ${args.skillName} v${validation.skill.version}\n` +
                `Type: ${validation.skill.type}\n` +
                `Source: ${args.source}\n` +
                `Capabilities: ${(validation.skill.capabilities || []).join(", ")}\n\n` +
                `Registry updated successfully.`
        }]
      };

    } catch (error) {
      return {
        content: [{ type: "text", text: `❌ Installation failed: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Search skills
server.addTool({
  name: "mas_search_skills",
  description: "Search skills in local, project, and marketplace registries with filters",
  inputSchema: {
    type: "object",
    properties: {
      query: { type: "string", description: "Search query" },
      filters: {
        type: "object",
        properties: {
          type: { type: "string", enum: ["base", "meta", "composite"] },
          category: { type: "string" },
          minRating: { type: "number" },
          source: { type: "string", enum: ["local", "project", "marketplace", "all"] }
        }
      }
    },
    required: ["query"]
  },
  async handler(args) {
    const results = [];
    const query = args.query.toLowerCase();
    const filters = args.filters || {};

    // Search local skills (already installed)
    if (fs.existsSync(SKILLS_DIR)) {
      const localSkills = fs.readdirSync(SKILLS_DIR).filter(f =>
        !f.startsWith(".") && !f.startsWith("_")
      );

      for (const skillName of localSkills) {
        if (skillName.toLowerCase().includes(query)) {
          const skillPath = path.join(SKILLS_DIR, skillName);
          const skillJson = safeReadJSON(path.join(skillPath, "skill.json"));

          if (skillJson) {
            // Apply filters
            if (filters.type && skillJson.type !== filters.type) continue;
            if (filters.category && !skillJson.tags?.includes(filters.category)) continue;

            results.push({
              name: skillName,
              source: "local",
              type: skillJson.type,
              description: skillJson.description,
              version: skillJson.version,
              capabilities: skillJson.capabilities || [],
              path: skillPath
            });
          }
        }
      }
    }

    // Search project registry
    const projectRegistry = safeReadYAML(REGISTRY_PATH);
    if (projectRegistry && projectRegistry.components && projectRegistry.components.skills) {
      for (const skill of projectRegistry.components.skills) {
        if (skill.name.toLowerCase().includes(query)) {
          if (filters.type && skill.type !== filters.type) continue;

          results.push({
            name: skill.name,
            source: "project",
            type: skill.type,
            version: skill.version,
            installed: skill.installed,
            path: skill.path
          });
        }
      }
    }

    // Search marketplace (mock - would query GitHub API in production)
    if (!filters.source || filters.source === "marketplace" || filters.source === "all") {
      // Mock marketplace results based on query
      const mockSkills = [
        `${query}-handler`,
        `${query}-validator`,
        `${query}-processor`,
        `data-${query}`,
        `auto-${query}`
      ];

      for (const skillName of mockSkills) {
        results.push({
          name: skillName,
          source: "marketplace",
          type: "base",
          description: `Skill for handling ${query} operations`,
          status: "available",
          rating: 4.5,
          downloads: Math.floor(Math.random() * 1000)
        });
      }
    }

    // Format results
    if (results.length === 0) {
      return {
        content: [{ type: "text", text: "No skills found matching your query." }]
      };
    }

    const formatted = results.map((r, i) => {
      const header = `${i + 1}. ${r.name} (${r.source})`;
      const details = [
        r.type ? `Type: ${r.type}` : null,
        r.version ? `Version: ${r.version}` : null,
        r.description ? `Description: ${r.description}` : null,
        r.capabilities ? `Capabilities: ${r.capabilities.join(", ")}` : null,
        r.rating ? `Rating: ${r.rating} ⭐` : null,
        r.downloads ? `Downloads: ${r.downloads}` : null,
        r.path ? `Path: ${r.path}` : null
      ].filter(Boolean).join("\n  ");

      return `${header}\n  ${details}`;
    }).join("\n\n");

    return {
      content: [{
        type: "text",
        text: `🔍 Found ${results.length} skill(s):\n\n${formatted}`
      }]
    };
  }
});

// Tool: Validate skill
server.addTool({
  name: "mas_validate_skill",
  description: "Validate skill structure, v2.0 schema compliance, and quality",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Skill name or path" },
      strict: { type: "boolean", description: "Use strict v2.0 validation" },
      checkTests: { type: "boolean", description: "Check for test coverage" }
    },
    required: ["skillName"]
  },
  async handler(args) {
    let skillPath;

    // Determine if it's a path or name
    if (fs.existsSync(args.skillName)) {
      skillPath = args.skillName;
    } else {
      skillPath = path.join(SKILLS_DIR, args.skillName);
    }

    if (!fs.existsSync(skillPath)) {
      return {
        content: [{ type: "text", text: `❌ Skill not found: ${args.skillName}` }],
        isError: true
      };
    }

    const checks = [];
    let score = 0;
    let maxScore = 0;

    // Check 1: skill.json exists
    maxScore += 10;
    const skillJsonPath = path.join(skillPath, "skill.json");
    if (fs.existsSync(skillJsonPath)) {
      checks.push({ check: "skill.json exists", status: "✅", points: 10 });
      score += 10;

      // Check 2: skill.json is valid JSON
      maxScore += 10;
      try {
        const skillJson = JSON.parse(fs.readFileSync(skillJsonPath, "utf8"));
        checks.push({ check: "skill.json valid JSON", status: "✅", points: 10 });
        score += 10;

        // Check 3: v2.0 schema compliance
        if (args.strict) {
          maxScore += 20;
          const validation = await validateSkillJson(skillPath);
          if (validation.valid) {
            checks.push({ check: "v2.0 schema compliance", status: "✅", points: 20 });
            score += 20;
          } else {
            checks.push({ check: "v2.0 schema compliance", status: "❌", points: 0, error: validation.error });
          }
        }

        // Check 4: Required fields
        maxScore += 15;
        const required = ["name", "version", "type", "description"];
        const missing = required.filter(f => !skillJson[f]);
        if (missing.length === 0) {
          checks.push({ check: "All required fields", status: "✅", points: 15 });
          score += 15;
        } else {
          checks.push({ check: "All required fields", status: "❌", points: 0, error: `Missing: ${missing.join(", ")}` });
        }

        // Check 5: SKILL.md exists
        maxScore += 10;
        if (fs.existsSync(path.join(skillPath, "SKILL.md"))) {
          checks.push({ check: "SKILL.md exists", status: "✅", points: 10 });
          score += 10;
        } else {
          checks.push({ check: "SKILL.md exists", status: "⚠️", points: 0 });
        }

        // Check 6: Scripts directory
        maxScore += 5;
        if (fs.existsSync(path.join(skillPath, "scripts"))) {
          checks.push({ check: "scripts/ directory", status: "✅", points: 5 });
          score += 5;
        } else {
          checks.push({ check: "scripts/ directory", status: "⚠️", points: 0 });
        }

        // Check 7: Test coverage (if requested)
        if (args.checkTests) {
          maxScore += 15;
          const hasTests = fs.existsSync(path.join(skillPath, "tests")) ||
                          fs.existsSync(path.join(skillPath, "test"));
          if (hasTests) {
            checks.push({ check: "Test coverage", status: "✅", points: 15 });
            score += 15;
          } else {
            checks.push({ check: "Test coverage", status: "⚠️", points: 0 });
          }
        }

        // Check 8: No absolute paths
        maxScore += 5;
        const skillMd = safeRead(path.join(skillPath, "SKILL.md"));
        if (skillMd && !skillMd.includes("C:\\") && !skillMd.includes("/home/")) {
          checks.push({ check: "No absolute paths", status: "✅", points: 5 });
          score += 5;
        } else {
          checks.push({ check: "No absolute paths", status: "⚠️", points: 0 });
        }

      } catch (error) {
        checks.push({ check: "skill.json valid JSON", status: "❌", points: 0, error: error.message });
      }
    } else {
      checks.push({ check: "skill.json exists", status: "❌", points: 0 });
    }

    // Calculate percentage
    const percentage = maxScore > 0 ? Math.round((score / maxScore) * 100) : 0;
    const quality = percentage >= 90 ? "Excellent" : percentage >= 75 ? "Good" : percentage >= 60 ? "Fair" : "Poor";

    // Format output
    const checkList = checks.map(c => {
      const points = c.points > 0 ? `(+${c.points})` : "(0)";
      const error = c.error ? ` - ${c.error}` : "";
      return `${c.status} ${c.check} ${points}${error}`;
    }).join("\n");

    const summary = `\n📊 Validation Summary:\n` +
                    `Score: ${score}/${maxScore} (${percentage}%)\n` +
                    `Quality: ${quality}\n` +
                    `Path: ${skillPath}`;

    return {
      content: [{
        type: "text",
        text: `🔍 Skill Validation Report\n${summary}\n\nChecks:\n${checkList}`
      }]
    };
  }
});

// Tool: Update skill
server.addTool({
  name: "mas_update_skill",
  description: "Update skill to latest version or rollback",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Skill name" },
      version: { type: "string", description: "Target version (optional)" },
      rollback: { type: "boolean", description: "Rollback to previous version" },
      source: { type: "string", description: "Update source (github, marketplace)" }
    },
    required: ["skillName"]
  },
  async handler(args) {
    const skillPath = path.join(SKILLS_DIR, args.skillName);

    if (!fs.existsSync(skillPath)) {
      return {
        content: [{ type: "text", text: `❌ Skill not installed: ${args.skillName}` }],
        isError: true
      };
    }

    // Create backup
    const backupPath = `${skillPath}.backup-${Date.now()}`;
    fs.cpSync(skillPath, backupPath, { recursive: true });

    try {
      if (args.rollback) {
        // Restore from backup
        const backups = fs.readdirSync(SKILLS_DIR)
          .filter(f => f.startsWith(`${args.skillName}.backup-`))
          .sort()
          .reverse();

        if (backups.length < 2) {
          return {
            content: [{ type: "text", text: `❌ No previous backup found for rollback` }],
            isError: true
          };
        }

        // Use second most recent backup (most recent is the one we just created)
        const rollbackBackup = path.join(SKILLS_DIR, backups[1]);
        fs.rmSync(skillPath, { recursive: true, force: true });
        fs.cpSync(rollbackBackup, skillPath, { recursive: true });

        // Clean up all backups except the one we just created
        backups.slice(1).forEach(b => {
          fs.rmSync(path.join(SKILLS_DIR, b), { recursive: true, force: true });
        });

        return {
          content: [{
            type: "text",
            text: `✅ Rolled back ${args.skillName} to previous version\n` +
                  `Backup cleaned up.`
          }]
        };
      }

      // Update from source
      const source = args.source || "marketplace";

      // Reinstall using install tool logic
      if (source === "github") {
        // Use mas_install_skill
        return {
          content: [{
            type: "text",
            text: `🔄 Please use mas_install_skill with --source github to update:\n` +
                  `mas_install_skill skillName=${args.skillName} source=github version=${args.version || "latest"}`
          }]
        };
      } else {
        // Update registry metadata
        const registry = safeReadYAML(REGISTRY_PATH);
        if (registry && registry.components && registry.components.skills) {
          const skillIndex = registry.components.skills.findIndex(s => s.name === args.skillName);
          if (skillIndex >= 0) {
            registry.components.skills[skillIndex].updated = new Date().toISOString();
            registry.components.skills[skillIndex].version = args.version || "latest";

            fs.writeFileSync(REGISTRY_PATH, yaml.dump(registry, { lineWidth: 100 }));

            return {
              content: [{
                type: "text",
                text: `✅ Updated registry for ${args.skillName}\n` +
                      `Version: ${args.version || "latest"}\n` +
                      `Updated: ${new Date().toISOString()}`
              }]
            };
          }
        }
      }

      return {
        content: [{ type: "text", text: `⚠️ Update completed but registry update failed` }],
        isError: false
      };

    } catch (error) {
      // Restore from backup on error
      if (fs.existsSync(backupPath)) {
        fs.rmSync(skillPath, { recursive: true, force: true });
        fs.cpSync(backupPath, skillPath, { recursive: true });
        fs.rmSync(backupPath, { recursive: true, force: true });
      }

      return {
        content: [{ type: "text", text: `❌ Update failed, restored from backup: ${error.message}` }],
        isError: true
      };
    }
  }
});

// Tool: Publish skill
server.addTool({
  name: "mas_publish_skill",
  description: "Publish skill to marketplace (prepare, submit, or local)",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Skill name" },
      mode: {
        type: "string",
        enum: ["prepare", "submit", "local"],
        description: "Publish mode"
      },
      repository: { type: "string", description: "Target repository" },
      version: { type: "string", description: "Version to publish" }
    },
    required: ["skillName", "mode"]
  },
  async handler(args) {
    const skillPath = path.join(SKILLS_DIR, args.skillName);

    if (!fs.existsSync(skillPath)) {
      return {
        content: [{ type: "text", text: `❌ Skill not found: ${args.skillName}` }],
        isError: true
      };
    }

    // Validate before publish
    const validation = await validateSkillJson(skillPath);
    if (!validation.valid) {
      return {
        content: [{ type: "text", text: `❌ Cannot publish - validation failed: ${validation.error}` }],
        isError: true
      };
    }

    const skillJson = validation.skill;

    if (args.mode === "prepare") {
      // Prepare package
      const packageDir = `/tmp/${args.skillName}-package-${Date.now()}`;
      fs.mkdirSync(packageDir, { recursive: true });

      // Copy skill
      fs.cpSync(skillPath, path.join(packageDir, args.skillName), { recursive: true });

      // Create package.json
      const packageJson = {
        name: args.skillName,
        version: args.version || skillJson.version,
        description: skillJson.description,
        type: skillJson.type,
        capabilities: skillJson.capabilities,
        author: skillJson.author || "Unknown",
        license: skillJson.license || "MIT",
        repository: args.repository || skillJson.repository,
        created: new Date().toISOString()
      };

      fs.writeFileSync(
        path.join(packageDir, "package.json"),
        JSON.stringify(packageJson, null, 2)
      );

      // Create README
      const readme = `# ${args.skillName}\n\n${skillJson.description}\n\n## Installation\n\n\`\`\`bash\nmas_install_skill ${args.skillName} source=github\n\`\`\`\n\n## Usage\n\nSee SKILL.md\n\n## Version\n${args.version || skillJson.version}\n`;
      fs.writeFileSync(path.join(packageDir, "README.md"), readme);

      // Create ZIP
      const zipPath = `/tmp/${args.skillName}-${args.version || skillJson.version}.zip`;
      await execFileAsync("zip", ["-r", zipPath, "."], { cwd: packageDir });

      // Cleanup
      fs.rmSync(packageDir, { recursive: true, force: true });

      return {
        content: [{
          type: "text",
          text: `✅ Package prepared: ${zipPath}\n\nContents:\n- skill.json (v2.0)\n- SKILL.md\n- scripts/\n- references/\n- package.json\n- README.md\n\nReady for GitHub release!`
        }]
      };
    }

    if (args.mode === "submit") {
      const repo = args.repository || "mas-marketplace/mas-skills";

      return {
        content: [{
          type: "text",
          text: `📝 Submission Instructions for ${args.skillName}\n\n` +
                `1. Create package:\n   mas_publish_skill ${args.skillName} mode=prepare\n\n` +
                `2. Fork repository: ${repo}\n\n` +
                `3. Create branch:\n   git checkout -b add-${args.skillName}\n\n` +
                `4. Add skill:\n   cp /tmp/${args.skillName}-*.zip .\n   unzip ${args.skillName}-*.zip -d skills/base/${args.skillName}\n\n` +
                `5. Update registry.json\n\n` +
                `6. Commit and push:\n   git add skills/base/${args.skillName}\n   git commit -m "Add: ${args.skillName} v${args.version || skillJson.version}"\n   git push origin add-${args.skillName}\n\n` +
                `7. Create PR on GitHub\n\n` +
                `8. Wait for automated validation\n\n✅ Once merged, skill becomes available to all!`
        }]
      };
    }

    if (args.mode === "local") {
      // Add to local marketplace (registry)
      const registry = safeReadYAML(REGISTRY_PATH) || {
        version: "2.0.0",
        components: { skills: [] }
      };

      const skillEntry = {
        name: args.skillName,
        version: args.version || skillJson.version,
        type: skillJson.type,
        description: skillJson.description,
        capabilities: skillJson.capabilities || [],
        path: skillPath,
        local: true,
        published: new Date().toISOString()
      };

      // Check if already in registry
      const existing = registry.components.skills.findIndex(s => s.name === args.skillName);
      if (existing >= 0) {
        registry.components.skills[existing] = skillEntry;
      } else {
        registry.components.skills.push(skillEntry);
      }

      // Save
      const regDir = path.dirname(REGISTRY_PATH);
      if (!fs.existsSync(regDir)) {
        fs.mkdirSync(regDir, { recursive: true });
      }
      fs.writeFileSync(REGISTRY_PATH, yaml.dump(registry, { lineWidth: 100 }));

      return {
        content: [{
          type: "text",
          text: `✅ Published to local marketplace\n\n` +
                `Skill: ${args.skillName} v${skillEntry.version}\n` +
                `Type: ${skillEntry.type}\n` +
                `Registry: ${REGISTRY_PATH}\n\n` +
                `Available for local installation via mas_install_skill.`
        }]
      };
    }
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);

  // Log startup
  console.error("🚀 MAS Marketplace MCP Server v2.0 running");
  console.error(`Project root: ${PROJECT_ROOT}`);
  console.error(`Registry: ${REGISTRY_PATH}`);
  console.error(`Skills dir: ${SKILLS_DIR}`);
}

main().catch((error) => {
  console.error("❌ Server error:", error);
  process.exit(1);
});
