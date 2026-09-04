# Alliance of Genome Resources - Claude Code Resources

Shared Claude Code configurations, plugins, and best practices for Alliance of Genome Resources developers.

> [!IMPORTANT]
> **Claude Code runs in a regular terminal, not in the Claude web UI.**
> Alliance access is for the Claude Code command-line tool only. If the Claude website or Claude desktop chat app still shows a personal `Free` plan, that is expected. To use Alliance-provided Claude Code access, open a normal terminal window on your computer (for example Terminal, iTerm, Windows Terminal, or PowerShell) and run Claude Code there.

## Table of Contents

- [What is Claude Code?](#what-is-claude-code)
- [Getting Started](#getting-started)
- [Essential Tips](#essential-tips)
- [Extending Claude Code](#extending-claude-code)
  - [Plugins](#plugins)
  - [MCP Servers](#mcp-servers)
- [Tips & Best Practices](#tips--best-practices)
- [Advanced Usage](#advanced-usage)
- [Contributing](#contributing)

---

## What is Claude Code?

Claude Code is a command-line tool that brings Claude AI directly into your terminal. Instead of copying code back and forth from a chat window, Claude Code can:

- **Read and edit files** in your project directly
- **Run commands** like tests, builds, and git operations
- **Understand your codebase** by exploring files and dependencies
- **Make changes** across multiple files to implement features or fix bugs

You interact with it through natural conversation in your terminal:

```
You:    Can you add error handling to the API client?
Claude: I'll add try/catch blocks and proper error messages. Let me read the current
        implementation first...
        [Claude reads files, makes edits, runs tests]
```

---

## Getting Started

### Step 1: Request Access to the Alliance Anthropic Group

To get started with Claude Code at the Alliance, you need to be added to our Anthropic organization:

1. **Message Chris T on the Alliance Slack**
2. **Include in your message:**
   - A request to be added to the Alliance Anthropic group
   - The email address you want to use for your Claude account

You'll receive an email invitation to join the Alliance Anthropic organization once your request is processed.

### Step 2: Read the Official Quickstart

⚠️ **Please take 10 minutes to read this:** [Claude Code Quickstart Guide](https://code.claude.com/docs/en/quickstart)

The official guide covers essential workflows that will save you hours:
- How to ask Claude effective questions
- Git integration (commits, branches, merge conflicts)
- Debugging and feature implementation patterns
- Pro tips that make a real difference

You'll get far more out of Claude Code if you understand its capabilities upfront.

### Step 3: Install Claude Code

As mentioned in the quickstart guide, once you've received your invitation and created your account, install the Claude Code CLI:

**macOS, Linux, WSL:**
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows PowerShell:**
```powershell
irm https://claude.ai/install.ps1 | iex
```

**Alternative: Homebrew (macOS/Linux):**
```bash
brew install --cask claude-code
```

> **One-time installation:** Claude Code only needs to be installed once per computer. After installation, you can run `claude` from any directory - you don't need to install it separately for each project or repository.

> Note: Native installations auto-update automatically. Homebrew requires manual updates via `brew upgrade claude-code`.

### Step 4: Log In and Start Using Claude Code

1. **Open your terminal** in any project directory
2. **Start Claude Code:**
   ```bash
   claude
   ```
3. **Log in** when prompted:
   - Use the email you provided in Step 1
   - **Important:** When asked to choose an account type, select the **second option**: **"Anthropic Console Account"** (API Usage Billing). Don't select the first option (Claude Pro/Max subscription).
4. **Start coding!** Try asking:
   ```
   > what does this project do?
   ```

### Step 5: Set Your Model to Opus

⚠️ **Important:** Make sure your model is set to Opus for the best results.

**Check and set your model:**
```
/model
```

Select **Opus** from the list. This setting persists across sessions.

**Why Opus?** Opus is Claude's most capable model - it handles complex codebases better, makes fewer mistakes, and produces higher quality code. If you're finding Claude's suggestions unhelpful or off-target, check that you're using Opus.

### Step 6: Customize Claude for Your Workflow (Especially for Curators)

> [!TIP]
> **If you're a curator and not a programmer, do this right after you install.** Claude Code is a developer tool by default, but you can teach it to behave like a curator-friendly assistant — in plain English, no coding required.

**Save your preferences once, for every project on this machine.**

Open Claude in any folder and tell it (you can copy-paste this and edit it to your taste):

> *"Please update my global Claude memory at `~/.claude/CLAUDE.md` so that, in every future session on this machine, you remember: I'm a biological curator, not a programmer. Explain things in plain English, ask before running terminal commands, don't show raw code unless I ask, and prefer biology terminology over programming jargon."*

Claude will create or edit that file for you. It is loaded automatically every time you start Claude Code on this computer, so you only have to do this once. You can come back any time and ask Claude to add, change, or remove instructions.

#### About those "Do you want me to proceed?" prompts

By default, Claude asks permission before editing files or running terminal commands. **This is a safety feature, not a sign that something is wrong** — Claude is checking with you before doing something it can't easily undo. You can always say no and Claude will adjust.

A few things that make those prompts less frequent and less stressful:

- **Pick "Yes, don't ask again"** when the prompt appears. Claude remembers that choice and won't ask about that same action again.
- **Press `Shift+Tab`** to switch into **accept-edits mode**. Claude will auto-approve safe file reads and edits but still ask before running terminal commands. Press `Shift+Tab` again to cycle back. This is a good middle ground for most curator work.
- **Run `/permissions`** any time to view or remove things you've previously allowed.

### Additional Resources

- [CLI Reference](https://code.claude.com/docs/en/cli-reference) - All commands and options
- [Common Workflows](https://code.claude.com/docs/en/common-workflows) - Step-by-step guides

---

## Essential Tips

**These three habits will dramatically improve your experience with Claude Code.** They're simple but make a huge difference in the quality and reliability of the code Claude produces.

### 1. Make a Plan Before Coding

If your changes involve more than a few lines of code, **have Claude write a plan first**. Ask Claude to:

1. Explore the relevant parts of the codebase
2. Understand what you're trying to accomplish
3. Write out a plan as a markdown file (e.g., `docs/plans/my-feature.md`)

This gives Claude a reference to work from and gives you a chance to review the approach before any code is written. You can correct misunderstandings early rather than after Claude has written 500 lines in the wrong direction.

Example:
```
You: I want to add caching to the API client. Before writing any code, please explore
     the codebase and write a plan to docs/plans/api-caching.md
```

> **For complex or large projects:** Install the [Superpowers plugin](#superpowers-plugin) which automates this entire workflow with `/superpowers:brainstorming` and `/superpowers:writing-plans`.

### 2. Request Code Reviews After Major Changes

After completing a significant chunk of code, have Claude review the work. This catches bugs, security issues, and style problems before they make it into your commits.

**Install the code-review plugin** ([plugins are explained in more detail below](#plugins)):
```
/plugin install code-review@claude-plugins-official
```

Then ask Claude to review your changes:
```
You: Please spawn a sub-agent to review the changes I just made to the authentication module.
```

**Why a sub-agent?** The sub-agent starts with *completely fresh context* - it hasn't seen the hours of back-and-forth that led to the current code. This means it can objectively evaluate the work without the "tunnel vision" that comes from having written it. Fresh eyes catch things tired eyes miss.

### 3. Clear Your Context When Switching Tasks

Claude has a **context window** - the amount of conversation history it can "see" at once. When you start a new task, old context from previous work can confuse Claude or reduce the space available for your new task.

**Use `/clear` when:**
- Starting a new feature or bug fix
- Switching to a different part of the codebase
- Claude seems confused or is referencing old, irrelevant information

```
/clear
```

This gives Claude a fresh start with its full context window available for your new task.

### 4. Set Up Your Repository with /init

When you start working in a new repository, run `/init` to create a `CLAUDE.md` file. Claude will analyze the codebase and document:

- **Build and test commands** - How to run, test, and lint the project
- **Architecture overview** - Key directories, patterns, and design decisions
- **Project-specific context** - Important details that require reading multiple files to understand

Future Claude sessions in this repository will read `CLAUDE.md` automatically, giving them a head start instead of exploring from scratch.

```
/init
```

This is especially valuable for:
- Repositories you'll work in repeatedly
- Projects with non-obvious build systems or conventions
- Codebases where you want consistent Claude behavior across sessions

---

## Extending Claude Code

Claude Code can be extended in two ways: **Plugins** and **MCP Servers**. Both add new capabilities, but they work differently.

### Plugins

**What are plugins?** Plugins add "skills" to Claude - predefined workflows that Claude can follow when you ask it to do specific tasks. For example, the Jira plugin teaches Claude how to create and manage Jira tickets using our Alliance projects.

**What are skills?** Skills are step-by-step instructions that tell Claude how to accomplish a task. When you type `/jira` or ask Claude to "create a Jira ticket", the plugin's skill guides Claude through the exact steps needed.

#### Alliance Plugins

These are plugins built specifically for Alliance developers.

**Installation:**
```
/plugin marketplace add alliance-genome/agr_claude_code
/plugin install alliance-jira@alliance-plugins
/plugin install git-safety@alliance-plugins
/plugin install linkml-reviewer@alliance-plugins
```

**alliance-jira**: Manages Jira tickets across Alliance projects (KANBAN, SCRUM, AGRHELP, MOD). On first use, it will guide you through setting up your Jira API credentials (you'll need a Jira API token from your Atlassian account).

Example requests:
- "Find all my tickets from the last two days."
- "Did we already make a ticket about the gene page bug?"
- "Create an epic for the new search feature with 4 subtasks."
- "Move SCRUM-1234 to In Progress."

**git-safety**: Installs git pre-commit and pre-push hooks that scan for secrets using [Gitleaks](https://github.com/gitleaks/gitleaks), [TruffleHog](https://github.com/trufflesecurity/trufflehog), and dangerous-filename checks. If you accidentally try to commit or push an API key or password, the operation is blocked. Run `/secure-repo` to set it up on any repository.

**linkml-reviewer**: Expert schema reviewer for the Alliance LinkML curation schema (`agr_curation_schema`). Reviews new or modified schema files for correctness, consistency, and adherence to Alliance conventions. Includes a full reviewer checklist, convention severity levels (ENFORCED/ADVISORY/TECH-DEBT), DTO suffix mappings, and reference data for the complete class hierarchy and import graph. Use `/linkml-review` when reviewing schema PRs or proposing changes.

Example requests:
- "Review the changes I made to allele.yaml"
- "I'm adding a new ExpressionPattern class - check it follows Alliance conventions"
- "Does this new DTO slot use the correct suffix convention?"

---

#### Dictation with Whispering

Typing long prompts gets tiring. [Whispering](https://github.com/EpicenterHQ/epicenter/tree/main/apps/whispering) is a free, open-source dictation app that transcribes speech and copies it to your clipboard - press a hotkey, speak, paste into Claude Code.

**Setup:**

1. **Download Whispering** from the [releases page](https://github.com/EpicenterHQ/epicenter/releases) (~22MB)
2. **Get a Groq API key** (free) at [console.groq.com](https://console.groq.com)
3. **Configure Whispering** to use Groq with the `whisper-large-v3-turbo` model

**Cost:** Groq is pay-as-you-go (not a subscription) at ~$0.04/hour. Most developers spend less than $1/month.

**Why Groq?** It's the fastest cloud option and extremely cheap. Local transcription (Whisper C++) is free but slower.

---

#### Browsing Available Plugins

You can browse all available plugins through Claude Code's interactive menu:

1. Run `/plugin` to open the plugin manager
2. Go to the **Discover** tab to browse plugins from all your marketplaces
3. Select a plugin to view details and install it

For more details, see [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins) in the official docs.

#### Updating Plugins

```
/plugin update superpowers@claude-plugins-official
/plugin marketplace update alliance-plugins
/plugin update alliance-jira@alliance-plugins
```

---

### MCP Servers

**What are MCP servers?** MCP (Model Context Protocol) servers are external services that give Claude new abilities - like accessing databases, browsing documentation, or connecting to APIs. Unlike plugins (which are instructions), MCP servers are actual running programs that Claude can call.

#### Recommended: Context7

[Context7](https://context7.com) fetches up-to-date documentation for libraries and frameworks. Instead of Claude relying on potentially outdated training data, Context7 pulls current docs directly into your conversation.

**Why use it:**
- Get current API documentation (React, FastAPI, AWS SDKs, etc.)
- Avoid outdated code patterns from Claude's training data
- Access version-specific documentation

**Installation:**

```bash
# Basic installation (works without an account)
claude mcp add context7 -- npx -y @upstash/context7-mcp

# With API key (optional, for higher rate limits)
claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY
```

**Getting a free API key (optional, for higher rate limits):**

1. Visit [context7.com/dashboard](https://context7.com/dashboard)
2. Create a free account
3. Generate an API key (format: `ctx7sk-...`)

**Usage:**

Just include "use context7" in your prompt when you want current documentation:

```
> How do I set up streaming with FastAPI? use context7
```

For more details, see the [Context7 documentation](https://context7.com/docs).

---

#### Alliance: AGR MCP Server

[AGR MCP Server](https://github.com/alliance-genome/agr-mcp-server-js) provides direct access to Alliance of Genome Resources genomics data. Query genes, diseases, orthologs, expression data, and more across 8 model organisms.

**Why use it:**
- Search genes across human, mouse, rat, zebrafish, fly, worm, yeast, and xenopus
- Get disease associations, phenotypes, and alleles for genes
- Find cross-species orthologs
- Access expression data across tissues and developmental stages

**Installation:**

```bash
claude mcp add agr-genomics -- npx -y agr-mcp-server
```

**Usage:**

Ask questions naturally about Alliance data:

```
> Search for BRCA1 genes in human
> What diseases are associated with TP53?
> Find orthologs of the insulin gene
> Show me expression data for daf-2 in worm
```

**Available Tools:**

| Tool | Description |
|------|-------------|
| `search_genes` | Search genes with optional species filter |
| `get_gene_info` | Detailed gene information (symbol, location, synonyms) |
| `get_gene_diseases` | Disease associations for a gene |
| `search_diseases` | Search diseases by name |
| `get_gene_expression` | Expression data across tissues/stages |
| `find_orthologs` | Cross-species homologs |
| `get_gene_phenotypes` | Phenotype annotations |
| `get_gene_interactions` | Molecular and genetic interactions |
| `get_gene_alleles` | Alleles/variants for a gene |

For more details, see the [AGR MCP Server repository](https://github.com/alliance-genome/agr-mcp-server-js).

---

## Tips & Best Practices

### Speed Up with Auto Mode

By default, Claude Code asks for permission before running commands, editing files, or performing other actions. This is safe but can slow you down when you're in the flow.

**Auto mode** lets Claude work continuously without stopping for routine confirmations, while still blocking irreversible or destructive actions through a built-in safety classifier.

**How to turn it on:**

- **Press `Shift+Tab`** to cycle through permission modes until you see `auto` in the status bar (`default → acceptEdits → plan → auto`).
- Or start Claude with the flag: `claude --permission-mode auto`
- Or set it as your default in `~/.claude/settings.json`:
  ```json
  {
    "permissions": {
      "defaultMode": "auto"
    }
  }
  ```

**Why it's faster:** Claude can read files, make edits, run tests, and execute routine commands without stopping to ask "Is this okay?" after every action. This dramatically speeds up multi-step work.

**Why it's safe:** Auto mode routes every action through a safety classifier that still blocks things like force pushes, mass deletions, `curl | bash`, production deploys, and changes to systems Claude doesn't recognize. Your `deny` rules and any explicit instructions you've given (e.g., *"don't push to main"*) are still respected. If the classifier blocks too many actions in a row, auto mode automatically pauses and goes back to prompting.

**Recommendations:**
- Use it for feature branches, test projects, and exploratory work
- Be more cautious when working with production code or sensitive data
- Make sure you have recent commits or backups before starting
- Run `/secure-repo` first to install [git-safety hooks](#alliance-plugins) - this gives you another layer of protection against accidentally committing secrets

> [!NOTE]
> Auto mode is a research preview and requires a Max, Team, Enterprise, or API plan plus a recent Claude model (Sonnet 4.6+ or Opus 4.6+). If `auto` doesn't appear when you cycle with `Shift+Tab`, your account may not be eligible yet — `acceptEdits` mode is the next-best alternative.

---

### More Tips Coming Soon

- Working with Alliance APIs (AGR APIs, JBrowse, etc.)
- Code review workflows
- Debugging strategies
- Recommended settings and CLAUDE.md templates

---

## Advanced Usage

These tools are for developers who want to push Claude Code further. They require more setup but provide powerful capabilities for complex projects.

### Superpowers Plugin

Superpowers transforms Claude from an eager junior developer into a disciplined senior engineer that plans before coding, tests before shipping, and can work autonomously for hours without drifting off course.

**Installation** (from official Claude marketplace):
```
/plugin install superpowers@claude-plugins-official
```

**Why use it?**
- Claude brainstorms with you before writing any code
- Work gets broken into small, verifiable tasks
- Fresh subagents handle each task with built-in code review
- Progress is saved to markdown files, so you never lose context between sessions
- Enforces test-driven development (TDD) automatically

**Key commands:**

| Command | What it does |
|---------|--------------|
| `/superpowers:brainstorming` | Interactive design refinement. Claude asks questions one at a time to fully understand what you want to build before any code is written. |
| `/superpowers:writing-plans` | Creates detailed implementation plans with bite-sized tasks, file paths, and verification steps. |
| `/superpowers:executing-plans` | Executes plans in batches with checkpoints for your review between each batch. |
| `/superpowers:writing-skills` | For creating or editing new skills (advanced usage). |

The plugin also includes additional skills for debugging, TDD, code review, and git workflows that activate automatically when needed.

**The typical workflow:**

1. **Brainstorm** - You describe what you want. Claude asks questions, explores design alternatives, and presents ideas in digestible chunks.
2. **Plan** - Claude writes a detailed plan, breaking work into small tasks with exact file paths and verification steps.
3. **Execute** - Fresh subagents work through each task. Each task gets a two-stage review: first against the specification, then for code quality.
4. **Review** - Claude reviews completed work against the original plan. Critical issues block progress until resolved.

**When to use it:**
- Starting a new feature or project
- Refactoring complex code
- Any task that would take more than 30 minutes
- When you want Claude to work autonomously without going off-track

For more details, see the [Superpowers GitHub repository](https://github.com/obra/superpowers).

---

### Frontend Design with Claude

Claude Code includes a built-in **frontend-design** skill that creates distinctive, production-grade frontend interfaces. Use this when building web components, pages, or applications that need polished visual design.

**Installation:** None required - this skill is built into Claude Code.

**Usage:**

Run the skill directly:
```
/frontend-design
```

Or ask Claude to use it when building UI:
```
> Build a dashboard component for displaying gene expression data. Use frontend-design for this.
> Create a search results page with filtering. Please use the frontend-design skill.
```

The skill generates creative, polished code that avoids generic AI aesthetics.

**Best for:**
- Building new UI components or pages
- Creating landing pages or marketing sites
- Any frontend work where design quality matters

---

### Alliance Agents Plugin

For advanced workflows, the Alliance Agents plugin provides specialized agents for specific tasks.

**Installation:**
```
/plugin install alliance-agents@alliance-plugins
```

**Available agents:**

| Agent | What it does |
|-------|--------------|
| `mcp-architect` | Designs and implements MCP servers that connect Claude to external APIs. Use when you need to give Claude access to a new data source or service. |
| `product-manager` | Creates comprehensive Product Requirements Documents (PRDs) from high-level feature requests. Produces executive-ready specs with metrics, requirements, and rollout plans. |

**When to use:**
- **mcp-architect**: You want Claude to query your internal database, connect to a third-party API, or build any MCP integration
- **product-manager**: You need to turn a vague feature idea into a structured PRD before implementation

**Usage:**

Ask Claude to spawn a subagent for the task:
```
> Please spawn a subagent to create a PRD for adding user authentication to the curation tool.
> Spawn a subagent to design an MCP server that connects to our internal strain database.
```

---

## Contributing

We welcome contributions from Alliance developers! Here's how to get involved:

**Have an idea or found a bug?**
- Open an issue in this repository to start a discussion

**Want to contribute code?**
1. Create a branch from `main`
2. Make your changes (new plugin, improvement, documentation, etc.)
3. Submit a pull request for review

**Adding a new plugin:**
1. Create your plugin in `plugins/<plugin-name>/`
2. Add your plugin to `.claude-plugin/marketplace.json`
3. Submit a pull request

### Version Bumps

When updating a plugin, you **must** bump the version number in both places:

1. **`plugins/<plugin-name>/.claude-plugin/plugin.json`** — the plugin manifest
2. **`.claude-plugin/marketplace.json`** — the marketplace registry entry

Both must match. The version check in SKILL.md reads the installed version automatically from the plugin cache directory, so no manual update is needed there.

### Plugin Structure

```
plugins/your-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (bump version here)
└── skills/
    └── your-skill/
        └── SKILL.md          # Skill instructions
```

See the `alliance-jira` plugin for a complete example.

---

## Support

- **Questions**: Contact Chris T on Alliance Slack
- **Email**: christopher.tabone@jax.org
- **Issues**: Open an issue in this repository
