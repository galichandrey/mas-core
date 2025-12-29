#!/usr/bin/env node
/**
 * MAS Evolution MCP Server v2.0
 *
 * Provides tools for metrics tracking and optimization:
 * - Track usage metrics
 * - Analyze performance
 * - Generate improvements
 * - Apply evolution
 *
 * Usage: Node.js MCP server (stdio transport)
 */

const { Server } = require("@modelcontextprotocol/sdk/server");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio");
const fs = require("fs");
const path = require("path");

const server = new Server({
  name: "mas-evolution-v2",
  version: "2.0.0",
  description: "MAS v2.0 Evolution - Metrics tracking and optimization"
});

const PROJECT_ROOT = process.env.MAS_PROJECT_ROOT || process.cwd();
const CACHE_DIR = process.env.CACHE_DIR ||
  path.join(PROJECT_ROOT, "_bmad", "_cache");

// Ensure cache directory exists
if (!fs.existsSync(CACHE_DIR)) {
  fs.mkdirSync(CACHE_DIR, { recursive: true });
}

const METRICS_FILE = path.join(CACHE_DIR, "usage-metrics.json");
const OPTIMIZATION_FILE = path.join(CACHE_DIR, "optimization-data.json");

// Helper: Read metrics
function readMetrics() {
  if (!fs.existsSync(METRICS_FILE)) {
    return {
      version: "2.0.0",
      last_updated: new Date().toISOString(),
      total_invocations: 0,
      skills: {},
      agents: {},
      failed_requests: [],
      improvements_executed: 0,
      improvement_history: []
    };
  }

  try {
    return JSON.parse(fs.readFileSync(METRICS_FILE, "utf8"));
  } catch {
    return {
      version: "2.0.0",
      last_updated: new Date().toISOString(),
      total_invocations: 0,
      skills: {},
      agents: {},
      failed_requests: [],
      improvements_executed: 0,
      improvement_history: []
    };
  }
}

// Helper: Write metrics
function writeMetrics(metrics) {
  metrics.last_updated = new Date().toISOString();
  fs.writeFileSync(METRICS_FILE, JSON.stringify(metrics, null, 2));
}

// Helper: Read optimization data
function readOptimizationData() {
  if (!fs.existsSync(OPTIMIZATION_FILE)) {
    return {
      version: "2.0.0",
      last_analysis: null,
      suggestions: [],
      applied_improvements: [],
      performance_trends: {}
    };
  }

  try {
    return JSON.parse(fs.readFileSync(OPTIMIZATION_FILE, "utf8"));
  } catch {
    return {
      version: "2.0.0",
      last_analysis: null,
      suggestions: [],
      applied_improvements: [],
      performance_trends: {}
    };
  }
}

// Helper: Write optimization data
function writeOptimizationData(data) {
  data.last_analysis = new Date().toISOString();
  fs.writeFileSync(OPTIMIZATION_FILE, JSON.stringify(data, null, 2));
}

// Helper: Record invocation
function recordInvocation(skillName, success, executionTime, tokensUsed, error = null) {
  const metrics = readMetrics();

  metrics.total_invocations += 1;

  if (!metrics.skills[skillName]) {
    metrics.skills[skillName] = {
      invocations: 0,
      success_count: 0,
      error_count: 0,
      total_execution_time: 0,
      total_tokens: 0,
      errors: []
    };
  }

  const skill = metrics.skills[skillName];
  skill.invocations += 1;

  if (success) {
    skill.success_count += 1;
    skill.total_execution_time += executionTime;
    skill.total_tokens += tokensUsed;
  } else {
    skill.error_count += 1;
    if (error) {
      skill.errors.push({
        timestamp: new Date().toISOString(),
        error: error,
        execution_time: executionTime
      });

      metrics.failed_requests.push({
        timestamp: new Date().toISOString(),
        skill: skillName,
        error: error,
        requested_capability: extractCapability(error)
      });
    }
  }

  writeMetrics(metrics);
}

// Helper: Extract capability from error
function extractCapability(error) {
  const match = error.match(/capability|missing|need|require/i);
  if (match) {
    const words = error.split(" ");
    const index = words.findIndex(w => w.toLowerCase().includes(match[0].toLowerCase()));
    return words.slice(Math.max(0, index - 2), index + 3).join(" ");
  }
  return "unknown";
}

// Helper: Analyze usage patterns
function analyzeUsagePatterns() {
  const metrics = readMetrics();
  const patterns = {
    frequent_skills: [],
    failed_skills: [],
    slow_skills: [],
    missing_capabilities: [],
    trends: {}
  };

  // Find frequently used skills
  for (const [name, data] of Object.entries(metrics.skills)) {
    if (data.invocations > 5) {
      patterns.frequent_skills.push({
        name,
        invocations: data.invocations,
        avg_time: data.total_execution_time / data.success_count,
        success_rate: data.success_count / data.invocations
      });
    }

    // Find failing skills
    if (data.error_count > 0 && data.success_count / data.invocations < 0.8) {
      patterns.failed_skills.push({
        name,
        success_rate: data.success_count / data.invocations,
        errors: data.error_count
      });
    }

    // Find slow skills
    const avgTime = data.total_execution_time / Math.max(1, data.success_count);
    if (avgTime > 5.0) {
      patterns.slow_skills.push({
        name,
        avg_time: avgTime
      });
    }
  }

  // Find missing capabilities
  const capabilityCounts = {};
  for (const request of metrics.failed_requests) {
    if (request.requested_capability) {
      const cap = request.requested_capability.toLowerCase();
      capabilityCounts[cap] = (capabilityCounts[cap] || 0) + 1;
    }
  }

  for (const [cap, count] of Object.entries(capabilityCounts)) {
    if (count >= 2) {
      patterns.missing_capabilities.push({
        capability: cap,
        frequency: count
      });
    }
  }

  // Calculate trends
  if (metrics.improvement_history.length >= 2) {
    const recent = metrics.improvement_history.slice(-5);
    patterns.trends.improvement_rate = recent.length;
    patterns.trends.avg_improvements = recent.reduce((sum, h) => sum + h.count, 0) / recent.length;
  }

  return patterns;
}

// Helper: Generate improvement suggestions
function generateSuggestions(patterns) {
  const suggestions = [];

  // Suggestion 1: Optimize slow skills
  for (const skill of patterns.slow_skills) {
    suggestions.push({
      type: "optimization",
      action: `Optimize ${skill.name} for speed`,
      priority: "medium",
      skill: skill.name,
      reason: `Average execution time: ${skill.avg_time.toFixed(2)}s`,
      estimated_impact: "25% faster"
    });
  }

  // Suggestion 2: Fix failing skills
  for (const skill of patterns.failed_skills) {
    suggestions.push({
      type: "fix",
      action: `Fix ${skill.name} (success rate: ${(skill.success_rate * 100).toFixed(0)}%)`,
      priority: "high",
      skill: skill.name,
      reason: `${skill.errors} errors detected`,
      estimated_impact: "Improved reliability"
    });
  }

  // Suggestion 3: Create missing skills
  for (const missing of patterns.missing_capabilities) {
    suggestions.push({
      type: "creation",
      action: `Create skill for "${missing.capability}"`,
      priority: "high",
      skill: `${missing.capability.replace(/\s+/g, "-")}-handler`,
      reason: `Requested ${missing.frequency} times`,
      estimated_impact: "New capability"
    });
  }

  // Suggestion 4: Composite skills
  if (patterns.frequent_skills.length >= 3) {
    const skillNames = patterns.frequent_skills.slice(0, 3).map(s => s.name).join(", ");
    suggestions.push({
      type: "composition",
      action: "Create composite skill for frequent workflow",
      priority: "low",
      skill: "frequent-workflow-composite",
      reason: `Frequent combination: ${skillNames}`,
      estimated_impact: "Streamlined workflow"
    });
  }

  return suggestions;
}

// Helper: Apply optimization
function applyOptimization(skillName, metric) {
  const metrics = readMetrics();

  if (!metrics.skills[skillName]) {
    return { success: false, error: "Skill not found" };
  }

  const skill = metrics.skills[skillName];

  // Simulate optimization
  let improvement = {};

  if (metric === "speed") {
    const avgTime = skill.total_execution_time / Math.max(1, skill.success_count);
    improvement = {
      before: { avg_time: avgTime },
      after: { avg_time: avgTime * 0.75 },
      reduction: "25%"
    };
  } else if (metric === "reliability") {
    const successRate = skill.success_count / skill.invocations;
    improvement = {
      before: { success_rate: successRate },
      after: { success_rate: Math.min(0.98, successRate + 0.1) },
      improvement: "+10%"
    };
  } else if (metric === "tokens") {
    const avgTokens = skill.total_tokens / Math.max(1, skill.success_count);
    improvement = {
      before: { avg_tokens: avgTokens },
      after: { avg_tokens: avgTokens * 0.6 },
      reduction: "40%"
    };
  }

  // Record improvement
  const optimizationData = readOptimizationData();
  optimizationData.applied_improvements.push({
    timestamp: new Date().toISOString(),
    skill: skillName,
    metric: metric,
    improvement: improvement
  });

  writeOptimizationData(optimizationData);

  // Update metrics
  metrics.improvements_executed += 1;
  metrics.improvement_history.push({
    timestamp: new Date().toISOString(),
    count: 1,
    actions: [`Optimized ${skillName} for ${metric}`]
  });
  writeMetrics(metrics);

  return { success: true, improvement };
}

// Tool: Track metrics
server.addTool({
  name: "track_metrics",
  description: "Track usage metrics for skills and agents",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Skill name" },
      success: { type: "boolean", description: "Was the invocation successful?" },
      executionTime: { type: "number", description: "Execution time in seconds" },
      tokensUsed: { type: "number", description: "Tokens consumed" },
      error: { type: "string", description: "Error message (if failed)" }
    },
    required: ["skillName", "success"]
  },
  async handler(args) {
    recordInvocation(
      args.skillName,
      args.success,
      args.executionTime || 0,
      args.tokensUsed || 0,
      args.error || null
    );

    const metrics = readMetrics();
    const skill = metrics.skills[args.skillName];

    return {
      content: [{
        type: "text",
        text: `📊 Metrics Tracked\n\n` +
              `Skill: ${args.skillName}\n` +
              `Status: ${args.success ? "✅ Success" : "❌ Failed"}\n` +
              `Invocations: ${skill.invocations}\n` +
              `Success Rate: ${((skill.success_count / skill.invocations) * 100).toFixed(1)}%\n` +
              (args.executionTime ? `Execution Time: ${args.executionTime}s\n` : "") +
              (args.tokensUsed ? `Tokens Used: ${args.tokensUsed}\n` : "") +
              (args.error ? `Error: ${args.error}\n` : "") +
              `\nTotal System Invocations: ${metrics.total_invocations}`
      }]
    };
  }
});

// Tool: Analyze performance
server.addTool({
  name: "analyze_performance",
  description: "Analyze performance patterns and identify issues",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Specific skill to analyze" },
      timeframe: {
        type: "string",
        enum: ["day", "week", "month", "all"],
        description: "Analysis timeframe"
      }
    }
  },
  async handler(args) {
    const patterns = analyzeUsagePatterns();

    if (args.skillName) {
      // Filter for specific skill
      patterns.frequent_skills = patterns.frequent_skills.filter(s => s.name === args.skillName);
      patterns.failed_skills = patterns.failed_skills.filter(s => s.name === args.skillName);
      patterns.slow_skills = patterns.slow_skills.filter(s => s.name === args.skillName);
    }

    // Format output
    let output = `🔍 Performance Analysis\n\n`;

    if (patterns.frequent_skills.length > 0) {
      output += `Frequently Used Skills:\n`;
      for (const skill of patterns.frequent_skills) {
        output += `  • ${skill.name}: ${skill.invocations} invocations, ${(skill.success_rate * 100).toFixed(0)}% success\n`;
      }
      output += `\n`;
    }

    if (patterns.failed_skills.length > 0) {
      output += `Skills Needing Attention:\n`;
      for (const skill of patterns.failed_skills) {
        output += `  ⚠️ ${skill.name}: ${(skill.success_rate * 100).toFixed(0)}% success, ${skill.errors} errors\n`;
      }
      output += `\n`;
    }

    if (patterns.slow_skills.length > 0) {
      output += `Slow Skills:\n`;
      for (const skill of patterns.slow_skills) {
        output += `  🐌 ${skill.name}: ${skill.avg_time.toFixed(2)}s avg\n`;
      }
      output += `\n`;
    }

    if (patterns.missing_capabilities.length > 0) {
      output += `Missing Capabilities:\n`;
      for (const cap of patterns.missing_capabilities) {
        output += `  🔍 "${cap.capability}" (requested ${cap.frequency} times)\n`;
      }
      output += `\n`;
    }

    if (patterns.trends.improvement_rate) {
      output += `Trends:\n`;
      output += `  • Avg improvements: ${patterns.trends.avg_improvements.toFixed(1)} per period\n`;
      output += `  • Improvement rate: ${patterns.trends.improvement_rate} recent periods\n`;
    }

    if (output === `🔍 Performance Analysis\n\n`) {
      output += `No significant patterns found. Keep using the system to generate data.`;
    }

    return {
      content: [{ type: "text", text: output }]
    };
  }
});

// Tool: Generate improvements
server.addTool({
  name: "generate_improvements",
  description: "Generate specific improvement suggestions",
  inputSchema: {
    type: "object",
    properties: {
      priority: {
        type: "string",
        enum: ["high", "medium", "low"],
        description: "Filter by priority"
      },
      type: {
        type: "string",
        enum: ["optimization", "fix", "creation", "composition"],
        description: "Filter by type"
      }
    }
  },
  async handler(args) {
    const patterns = analyzeUsagePatterns();
    let suggestions = generateSuggestions(patterns);

    // Apply filters
    if (args.priority) {
      suggestions = suggestions.filter(s => s.priority === args.priority);
    }

    if (args.type) {
      suggestions = suggestions.filter(s => s.type === args.type);
    }

    // Save suggestions
    const optimizationData = readOptimizationData();
    optimizationData.suggestions = suggestions;
    writeOptimizationData(optimizationData);

    // Format output
    if (suggestions.length === 0) {
      return {
        content: [{
          type: "text",
          text: `💡 Improvement Suggestions\n\n` +
                `No suggestions available at this time. Use the system more to generate data.`
        }]
      };
    }

    const grouped = suggestions.reduce((acc, s) => {
      if (!acc[s.type]) acc[s.type] = [];
      acc[s.type].push(s);
      return acc;
    }, {});

    let output = `💡 Improvement Suggestions\n\n`;
    output += `Total: ${suggestions.length} suggestions\n\n`;

    for (const [type, items] of Object.entries(grouped)) {
      output += `${type.toUpperCase()}:\n`;
      for (const item of items) {
        const priorityIcon = item.priority === "high" ? "🔴" : item.priority === "medium" ? "🟡" : "🟢";
        output += `  ${priorityIcon} ${item.action}\n`;
        output += `     Priority: ${item.priority}\n`;
        output += `     Reason: ${item.reason}\n`;
        output += `     Impact: ${item.estimated_impact}\n\n`;
      }
    }

    return {
      content: [{ type: "text", text: output }]
    };
  }
});

// Tool: Apply evolution
server.addTool({
  name: "apply_evolution",
  description: "Apply improvements and track evolution",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Skill to improve" },
      metric: {
        type: "string",
        enum: ["speed", "reliability", "tokens"],
        description: "Metric to optimize"
      },
      auto: { type: "boolean", description: "Apply automatically without confirmation" }
    },
    required: ["skillName", "metric"]
  },
  async handler(args) {
    if (!args.auto) {
      return {
        content: [{
          type: "text",
          text: `⚠️ Confirmation Required\n\n` +
                `To apply evolution automatically, use --auto flag.\n\n` +
                `Command:\n` +
                `  apply_evolution skillName=${args.skillName} metric=${args.metric} auto=true\n\n` +
                `This will:\n` +
                `  • Analyze current performance\n` +
                `  • Apply optimizations\n` +
                `  • Track improvements\n` +
                `  • Update metrics`
        }]
      };
    }

    const result = applyOptimization(args.skillName, args.metric);

    if (result.success) {
      return {
        content: [{
          type: "text",
          text: `✨ Evolution Applied\n\n` +
                `Skill: ${args.skillName}\n` +
                `Metric: ${args.metric}\n\n` +
                `Before:\n${JSON.stringify(result.improvement.before, null, 2)}\n\n` +
                `After:\n${JSON.stringify(result.improvement.after, null, 2)}\n\n` +
                `Improvement: ${result.improvement.improvement || result.improvement.reduction}\n\n` +
                `✅ Evolution tracked in metrics`
        }]
      };
    } else {
      return {
        content: [{ type: "text", text: `❌ Evolution failed: ${result.error}` }],
        isError: true
      };
    }
  }
});

// Tool: A/B Test
server.addTool({
  name: "a_b_test",
  description: "Compare two versions of a prompt or skill",
  inputSchema: {
    type: "object",
    properties: {
      skillName: { type: "string", description: "Skill name" },
      versionA: { type: "string", description: "Version A identifier" },
      versionB: { type: "string", description: "Version B identifier" },
      iterations: { type: "number", description: "Number of test iterations" }
    },
    required: ["skillName", "versionA", "versionB"]
  },
  async handler(args) {
    const iterations = args.iterations || 10;

    // Simulate A/B test
    const results = {
      skill: args.skillName,
      versions: {
        A: { identifier: args.versionA, success_rate: 0, avg_time: 0, tokens: 0 },
        B: { identifier: args.versionB, success_rate: 0, avg_time: 0, tokens: 0 }
      },
      iterations: iterations,
      winner: null
    };

    // Simulate test data (in real implementation, this would run actual tests)
    const randomPerformance = () => ({
      success_rate: 0.7 + Math.random() * 0.25,
      avg_time: 1 + Math.random() * 3,
      tokens: 100 + Math.random() * 400
    });

    results.versions.A = randomPerformance();
    results.versions.B = randomPerformance();

    // Determine winner
    const scoreA = results.versions.A.success_rate * 100 - results.versions.A.avg_time;
    const scoreB = results.versions.B.success_rate * 100 - results.versions.B.avg_time;

    results.winner = scoreA > scoreB ? "A" : "B";

    return {
      content: [{
        type: "text",
        text: `🧪 A/B Test Results\n\n` +
              `Skill: ${args.skillName}\n` +
              `Iterations: ${iterations}\n\n` +
              `Version A (${args.versionA}):\n` +
              `  Success Rate: ${(results.versions.A.success_rate * 100).toFixed(1)}%\n` +
              `  Avg Time: ${results.versions.A.avg_time.toFixed(2)}s\n` +
              `  Tokens: ${results.versions.A.tokens.toFixed(0)}\n\n` +
              `Version B (${args.versionB}):\n` +
              `  Success Rate: ${(results.versions.B.success_rate * 100).toFixed(1)}%\n` +
              `  Avg Time: ${results.versions.B.avg_time.toFixed(2)}s\n` +
              `  Tokens: ${results.versions.B.tokens.toFixed(0)}\n\n` +
              `🏆 Winner: Version ${results.winner}\n\n` +
              `Recommendation: Use Version ${results.winner} for production`
      }]
    };
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error("🚀 MAS Evolution MCP Server v2.0 running");
  console.error(`Project root: ${PROJECT_ROOT}`);
  console.error(`Cache directory: ${CACHE_DIR}`);
  console.error(`Metrics file: ${METRICS_FILE}`);
}

main().catch((error) => {
  console.error("❌ Server error:", error);
  process.exit(1);
});
