# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is the Alliance of Genome Resources Claude Code plugin marketplace repository. It contains:
- Claude Code plugins for Alliance developers
- Documentation and best practices for using Claude Code at the Alliance
- A plugin marketplace configuration for distributing Alliance-specific plugins

## Repository Structure

```
.claude-plugin/
  marketplace.json     # Marketplace registry listing all available plugins
plugins/
  alliance-jira/       # Jira ticket management plugin
    .claude-plugin/plugin.json
    skills/jira/SKILL.md        # Main skill with API reference
    skills/jira/setup.md        # Credential setup guide
    skills/jira/operations/     # CRUD operations documentation
    skills/jira/reference/      # Reference data (projects, statuses, etc.)
  git-safety/          # Secret scanning pre-commit hooks
    .claude-plugin/plugin.json
    skills/secure-repo/SKILL.md
    scripts/pre-commit          # Git hook script
    scripts/setup.sh            # Tool installation checker
```

## Plugin Development

### Creating a New Plugin

1. Create directory under `plugins/<plugin-name>/`
2. Add `.claude-plugin/plugin.json` manifest
3. Create skills under `skills/<skill-name>/SKILL.md`
4. Register in `.claude-plugin/marketplace.json`

### Plugin Manifest (plugin.json)

```json
{
  "name": "plugin-name",
  "description": "Short description",
  "version": "1.0.0",
  "author": { "name": "Name", "email": "email" },
  "homepage": "https://github.com/alliance-genome/agr_claude_code",
  "keywords": ["keyword1", "keyword2"]
}
```

### SKILL.md Format

Skills use YAML frontmatter:
```yaml
---
name: skill-name
description: When this skill should be triggered
argument-hint: [optional arguments]
---
```

The skill body contains instructions Claude follows when the skill is invoked.

## Marketplace Configuration

The marketplace is defined in `.claude-plugin/marketplace.json`. To add a plugin:

```json
{
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugins/plugin-name",
      "skills": ["./skills/skill-name"],
      "description": "Plugin description",
      "version": "1.0.0",
      "keywords": ["tag1", "tag2"]
    }
  ]
}
```

## Testing Plugins Locally

Install from local path during development:
```bash
/plugin install alliance-jira@alliance-plugins
```

To refresh marketplace after changes:
```bash
/plugin marketplace update alliance-plugins
```

## Alliance Jira Plugin Notes

- Credentials stored at `~/.alliance/jira/.env`
- Uses Jira REST API v3 with Basic Auth
- Safety rule: Only modify tickets assigned to authenticated user (exception: AGRHELP)
- JQL searches use `/rest/api/3/search/jql` (GET or POST)
- Description/comment fields require Atlassian Document Format (ADF)

## Git Safety Plugin Notes

- Requires Gitleaks and TruffleHog installed
- Hook blocks commits containing detected secrets
- Uses `$CLAUDE_PLUGIN_ROOT` to reference scripts directory
