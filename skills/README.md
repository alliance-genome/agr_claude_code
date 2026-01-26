# Claude Code Skills

Skills are specialized prompt configurations that give Claude expert knowledge in specific domains. When invoked, skills provide Claude with detailed instructions, best practices, and workflows for handling particular types of tasks.

## Available Skills

| Skill | Description |
|-------|-------------|
| [intermine-specialist](./intermine-specialist/) | InterMine bioinformatics platform - setup, data integration, PathQuery API, BlueGenes deployment |
| [bluegenes-clojurescript](./bluegenes-clojurescript/) | BlueGenes development, ClojureScript, re-frame architecture, Reagent components |

## Installation

### Option 1: Copy to your Claude skills directory

```bash
# Copy individual skills
cp -r skills/intermine-specialist ~/.claude/skills/
cp -r skills/bluegenes-clojurescript ~/.claude/skills/

# Restart Claude Code to load the skills
```

### Option 2: Symlink the entire directory

```bash
# If you want all skills from this repo
ln -s /path/to/agr_claude_code/skills/* ~/.claude/skills/
```

## Usage

Once installed, skills activate automatically based on context. You can also invoke them explicitly:

```
> Help me set up a new InterMine instance
[InterMine Specialist skill activates]

> Create a BlueGenes tool for gene expression visualization
[BlueGenes/ClojureScript skill activates]
```

## Creating New Skills

Each skill is a directory containing a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: My Skill Name
description: When this skill should be triggered
allowed-tools:
  - Read
  - Write
  - Bash
---

# My Skill Name

## Instructions
Detailed instructions for Claude...
```

See existing skills for complete examples.
