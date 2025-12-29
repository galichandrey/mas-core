# MAS Marketplace MCP Server

**Version:** 1.1.0
**Purpose:** Protocol-based marketplace access for MAS

---

## 🎯 What is MCP?

**Model Context Protocol (MCP)** is a standard that allows AI assistants like Claude to interact with external tools and data sources.

This MCP server provides MAS marketplace functionality through protocol-based commands.

---

## 🚀 Installation

### Option 1: Install via npm (recommended)
```bash
npm install -g mas-marketplace-mcp
```

### Option 2: Use directly from MAS
```bash
# Already included in MAS v1.1.0
cd _bmad/meta-system/mcp-server
npm install
```

---

## 🔌 Configuration

### For Claude Desktop

Add to your Claude Desktop configuration:

```json
{
  "mcpServers": {
    "mas-marketplace": {
      "command": "node",
      "args": ["/path/to/mas-marketplace-mcp/index.js"],
      "env": {
        "MAS_REGISTRY": "https://raw.githubusercontent.com/mas-marketplace/mas-core/main/marketplace/registry.json"
      }
    }
  }
}
```

### For VS Code

Add to `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "mas-marketplace": {
      "command": "node",
      "args": ["/path/to/mas-marketplace-mcp/index.js"]
    }
  }
}
```

---

## 🛠️ Available Tools

### 1. mas_search_skills
Search for skills in the marketplace.

**Usage:**
```
Search for skills: "testing"
Search for skills with tags: "validation"
```

**Parameters:**
- `query` (required): Search term
- `tags` (optional): Filter by tags
- `category` (optional): Filter by category

---

### 2. mas_install_skill
Install a skill from marketplace.

**Usage:**
```
Install skill data-validator
Install skill data-validator to /path/to/project
```

**Parameters:**
- `skillName` (required): Skill to install
- `targetPath` (optional): Target directory
- `version` (optional): Specific version

---

### 3. mas_validate_skill
Validate a skill before installation or after creation.

**Usage:**
```
Validate my skill at .claude/skills/my-skill
Validate skill data-validator
```

**Parameters:**
- `skillPath` (optional): Path to skill
- `skillName` (optional): Skill name in .claude/skills

---

### 4. mas_update
Update MAS to latest version.

**Usage:**
```
Update MAS
Update MAS to version 1.2.0
```

**Parameters:**
- `targetPath` (optional): Project directory
- `version` (optional): Specific version

---

### 5. mas_publish_skill
Publish a skill to marketplace.

**Usage:**
```
Publish my-skill to marketplace
Publish my-skill locally to /shared/marketplace
```

**Parameters:**
- `skillPath` (required): Path to skill
- `repository` (optional): Target repository
- `mode` (optional): prepare/submit/local

---

### 6. mas_list_skills
List all available skills.

**Usage:**
```
List all skills
List skills in testing category
```

**Parameters:**
- `category` (optional): Filter by category

---

### 7. mas_skill_info
Get detailed information about a skill.

**Usage:**
```
Show info for data-validator
```

**Parameters:**
- `skillName` (required): Skill name

---

## 💬 Example Conversations

### Scenario 1: Find and install a skill
```
User: "I need a skill for validating JSON files"

Claude: [Uses mas_search_skills with query="json validation"]
Found 3 skills:
- json-validator (v1.2.0)
- data-validator (v2.0.0)
- schema-validator (v1.0.0)

User: "Install data-validator"

Claude: [Uses mas_install_skill with skillName="data-validator"]
✅ Installed successfully
```

### Scenario 2: Validate a custom skill
```
User: "I created a skill, can you check it?"

Claude: [Uses mas_validate_skill with skillPath=".claude/skills/my-skill"]
✅ Validation passed
Recommendations: Add examples to SKILL.md
```

### Scenario 3: Update MAS
```
User: "Is my MAS up to date?"

Claude: [Uses mas_update with check mode]
Current: v1.1.0
Latest: v1.2.0
Update available!

User: "Update it"

Claude: [Uses mas_update]
✅ Updated to v1.2.0
```

---

## 🔒 Security

### Safe Command Execution
This MCP server uses `execFile` instead of `exec` to prevent command injection:
- Arguments are passed as array, not concatenated strings
- No shell interpretation
- Input validation on all parameters

### Registry Validation
All skills from marketplace are validated:
- Structure checks
- Security scans
- Dependency verification

---

## 📊 Example MCP Messages

### Search
```json
{
  "method": "tools/call",
  "params": {
    "name": "mas_search_skills",
    "arguments": {
      "query": "testing",
      "tags": ["unit", "integration"]
    }
  }
}
```

### Install
```json
{
  "method": "tools/call",
  "params": {
    "name": "mas_install_skill",
    "arguments": {
      "skillName": "data-validator",
      "targetPath": "/home/user/project"
    }
  }
}
```

---

## 🐛 Troubleshooting

### Server won't start
```bash
# Check Node version
node --version  # Should be >= 18.0.0

# Install dependencies
npm install

# Test directly
node index.js
```

### Commands not working
```bash
# Check if MAS is installed
ls _bmad/meta-system/export-tools/

# If not, install MAS first
curl -sSL https://get.mas.dev | bash
```

### Claude can't connect
```bash
# Check configuration
cat ~/.config/claude-desktop/config.json

# Verify path to index.js
which node
```

---

## 🔄 Integration with MAS

### How it works
```
Claude Desktop
    ↓ (MCP protocol)
mas-marketplace-mcp server
    ↓ (calls scripts)
export-tools/installer.sh
    ↓
MAS installed
```

### Benefits
- **Standardized**: Uses MCP protocol
- **Secure**: Safe command execution
- **Flexible**: Works with any MCP client
- **Integrated**: Seamless with MAS workflow

---

## 📦 Development

### Local development
```bash
cd _bmad/meta-system/mcp-server
npm install
npm run start
```

### Testing
```bash
# Test search
echo '{"method":"tools/call","params":{"name":"mas_search_skills","arguments":{"query":"test"}}}' | node index.js

# Test list
echo '{"method":"tools/call","params":{"name":"mas_list_skills","arguments":{}}}' | node index.js
```

---

## 🚀 Roadmap

### v1.2.0 (Planned)
- [ ] WebSocket support for real-time updates
- [ ] Skill version rollback
- [ ] Bulk operations
- [ ] Private registry support

### v1.3.0 (Future)
- [ ] AI-powered recommendations
- [ ] Skill dependency visualization
- [ ] Performance metrics
- [ ] Team collaboration features

---

## 📚 References

- [MCP Specification](https://modelcontextprotocol.io)
- [MAS Documentation](../README.md)
- [Marketplace Registry](https://github.com/mas-marketplace/mas-core)

---

**Status:** ✅ Production Ready
**Version:** 1.1.0
**Last Updated:** 2025-12-29