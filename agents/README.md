# Claude Code Agents

Agents are specialized subagent configurations for the Task tool. They define personas with specific expertise, working processes, and output formats. When you spawn an agent, it operates with fresh context focused on its specialty.

## Available Agents

| Agent | Description | Best For |
|-------|-------------|----------|
| [code-reviewer](./code-reviewer.md) | Code review with severity levels | Reviewing PRs, security audit, quality checks |
| [senior-software-engineer](./senior-software-engineer.md) | Production-ready implementation | Writing features, fixing bugs, refactoring |
| [product-manager](./product-manager.md) | PRD writing | Feature specs, requirements documents |
| [ux-designer](./ux-designer.md) | User interface design | Wireframes, user flows, accessibility |
| [mcp-architect](./mcp-architect.md) | MCP server design | Building API integrations for Claude |

## Installation

Copy agent files to your Claude agents directory:

```bash
cp agents/*.md ~/.claude/agents/
```

Restart Claude Code to load the agents.

## Usage

Agents are invoked through the Task tool. Claude automatically selects appropriate agents based on context, or you can request them explicitly:

```
> Review the authentication module I just wrote
[Claude spawns code-reviewer agent]

> Create a PRD for the new search feature
[Claude spawns product-manager agent]

> Design an MCP server for our internal API
[Claude spawns mcp-architect agent]
```

## Built-in Agent Types

Claude Code also includes built-in agent types that don't require installation:

| Agent | Description |
|-------|-------------|
| `Explore` | Fast codebase exploration and search |
| `Plan` | Implementation planning and architecture design |
| `claude-code-guide` | Questions about Claude Code features |

## Creating New Agents

Agent files use YAML frontmatter to define metadata:

```yaml
---
name: agent-name
description: When and how to use this agent (include examples)
model: opus  # or sonnet, haiku
color: cyan  # terminal color for agent output
---

You are a [role] with expertise in [domain]...
```

See existing agents for complete examples.
