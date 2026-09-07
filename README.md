# Alliance of Genome Resources - Claude Code resources

Shared Claude Code configurations, plugins, and best practices for Alliance of Genome Resources developers.

> [!IMPORTANT]
> Your Alliance seat is on the Claude Team plan. One account covers Claude Code in your terminal, the Claude desktop app, and Claude on the web at [claude.ai](https://claude.ai). Sign in with your Alliance email everywhere.
>
> If the website or the desktop app shows a personal `Free` plan, you are signed in with a different account. Switch accounts, or ask Chris T on Slack if your Alliance account isn't listed.

## Table of contents

- [What is Claude Code?](#what-is-claude-code)
- [Where you can use it](#where-you-can-use-it)
- [Getting started](#getting-started)
  - [Migrating from an API key](#migrating-from-an-api-key)
- [Essential tips](#essential-tips)
- [Extending Claude Code](#extending-claude-code)
  - [Plugins](#plugins)
  - [MCP servers](#mcp-servers)
- [Tips and best practices](#tips-and-best-practices)
- [Advanced usage](#advanced-usage)
- [Contributing](#contributing)

---

## What is Claude Code?

Claude Code puts Claude in your terminal. Rather than copying code back and forth from a chat window, it reads and edits the files in your project, runs your tests and builds and git commands, explores the codebase to work out how things fit together, and makes changes across many files at once.

You talk to it in ordinary language:

```
You:    Can you add error handling to the API client?
Claude: I'll add try/catch blocks and proper error messages. Let me read the current
        implementation first...
        [Claude reads files, makes edits, runs tests]
```

---

## Where you can use it

Your Team seat covers all of these. They share one account, so sign in once per device and pick whichever suits the task.

### The terminal

Run `claude` in any project directory. This is the version most of us use day to day, and the rest of this guide assumes it. See [Getting started](#getting-started) to install it.

### The desktop app

A graphical version for anyone who would rather not live in a terminal. It has a file editor, a visual diff view, an integrated terminal, a browser pane for previewing your app, and a sidebar for running several sessions side by side.

Download it for [macOS](https://claude.ai/api/desktop/darwin/universal/dmg/latest/redirect), [Windows](https://claude.ai/api/desktop/win32/x64/setup/latest/redirect), or [Windows on ARM64](https://claude.ai/api/desktop/win32/arm64/setup/latest/redirect). Linux is in beta and installs [with apt](https://code.claude.com/docs/en/desktop-linux).

Sign in after installing, then click the **Code** tab. The app has three tabs:

- **Chat** is ordinary conversation with no file access, the same as claude.ai.
- **Code** is Claude Code with access to your local files.
- **Cowork** runs an agent in a sandboxed virtual machine while you do something else.

The desktop app bundles Claude Code, so it works without the CLI installed. If you install both, they run the same engine and read the same configuration: your `CLAUDE.md` files, MCP servers, hooks, skills, and settings all carry over, and you can run both on one project at once.

On Windows, [Git](https://git-scm.com/downloads/win) must be installed for local sessions to work. Most Macs already have it.

The [desktop quickstart](https://code.claude.com/docs/en/desktop-quickstart) has the full walkthrough.

### The web

[claude.ai/code](https://claude.ai/code) runs sessions on Anthropic's machines instead of yours. A session keeps going after you close the browser, and you can check on it from the Claude mobile app. Connect your GitHub account during onboarding, since cloud sessions clone your repository and push branches back.

This suits work you want to start and then walk away from. You can also drive it from your terminal:

```bash
# Start a cloud session for the current repo
claude --cloud "Fix the flaky test in auth.spec.ts"

# Pull a cloud session back down to your terminal
claude --teleport
```

Cloud sessions share your account's rate limits, so several at once will use them up faster.

> [!NOTE]
> Claude Code on the web is a research preview. The Team plan has access, but expect rough edges. Repository cloning and pull requests need GitHub. You can upload a GitLab or Bitbucket repo as a bundle, but the session cannot push results back.

### claude.ai and the IDE extensions

Your seat also covers ordinary Claude conversations at [claude.ai](https://claude.ai), which is handy for questions that have nothing to do with a codebase. There are extensions for [VS Code](https://code.claude.com/docs/en/vs-code) and [JetBrains IDEs](https://code.claude.com/docs/en/jetbrains) if you would rather stay in your editor.

---

## Getting started

### Step 1: Request access to the Alliance Claude Team

You need a seat on our Claude Team plan. Message Chris T on the Alliance Slack and include:

- A request for a seat on the Alliance Claude Team plan
- The email address you want to use for your Claude account

You'll get an email invitation once the request goes through. Accept it before you go any further.

> [!NOTE]
> The Alliance moved from API keys to the Claude Team plan. Claude Code authenticates through your Team account now, so you need no Anthropic Console account and no API key. If you set up Claude Code before the move, see [Migrating from an API key](#migrating-from-an-api-key).

### Step 2: Read the official quickstart

Please take ten minutes for the [Claude Code quickstart guide](https://code.claude.com/docs/en/quickstart). It covers how to ask Claude questions that get good answers, how git integration handles commits, branches, and merge conflicts, and the debugging and feature workflows most people settle into. Ten minutes there saves hours later.

### Step 3: Install Claude Code

**macOS, Linux, WSL:**
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows PowerShell:**
```powershell
irm https://claude.ai/install.ps1 | iex
```

**Homebrew (macOS and Linux):**
```bash
brew install --cask claude-code
```

Install once per computer. After that `claude` runs from any directory, and you do not repeat this for each project or repository.

Native installs update themselves in the background. Homebrew installs do not, so run `brew upgrade claude-code` now and then.

### Step 4: Log in

Open a terminal in any project directory and start Claude Code:

```bash
claude
```

Claude Code asks you to `Select login method:`. Choose the first option, **Claude account with subscription**, then finish the login in the browser that opens. Use the email you gave in Step 1.

```
Select login method:

> Claude account with subscription   Pro, Max, Team, or Enterprise
  Anthropic Console account          API usage billing
  3rd-party platform                 Amazon Bedrock, Microsoft Foundry, or Vertex AI
```

> [!WARNING]
> Do not select **Anthropic Console account**. That option bills through an Anthropic API key. The Alliance disabled its API keys when we moved to the Team plan, so that path fails with a `401 API key is invalid` error.

Then ask it something:

```
> what does this project do?
```

### Step 5: Check your model

Run `/model` to see which model you are on and to change it:

```
/model
```

| Model | What Claude Code says about it |
|-------|--------------------------------|
| Sonnet 5 | Efficient for routine tasks. Generally recommended for most coding tasks. |
| Opus 5 | Best for everyday, complex tasks. |
| Fable 5.1 | Most capable for your hardest and longest-running tasks. |

Your starting model depends on the Team tier your seat is on. Sonnet 5 handles most day-to-day work. Switch to Opus 5 for large codebases, tricky debugging, or any time Claude's suggestions feel off-target. The setting sticks across sessions.

Fable 5.1 is the most capable of the three and suits long autonomous runs, but it is not the default on any plan and its usage can bill to extra usage credits. Ask Chris T before you make it your default.

### Step 6: Set up your preferences (especially for curators)

> [!TIP]
> If you're a curator rather than a programmer, do this right after you install. Claude Code assumes a developer by default. You can teach it to behave otherwise in plain English, with no coding.

Open Claude in any folder and tell it something like this, edited to your taste:

> *"Please update my global Claude memory at `~/.claude/CLAUDE.md` so that, in every future session on this machine, you remember: I'm a biological curator, not a programmer. Explain things in plain English, ask before running terminal commands, don't show raw code unless I ask, and prefer biology terminology over programming jargon."*

Claude writes that file for you. It loads automatically every time you start Claude Code on this computer, so you only do it once. Come back any time and ask Claude to add, change, or remove instructions.

#### About permission prompts

On the Team plan, terminal sessions start in auto mode. Claude reads files, makes edits, and runs routine commands without checking with you each time. A separate safety model reviews each action in the background and blocks the risky ones, such as force pushes, mass deletions, and production deploys. The status bar shows `⏵⏵ auto mode on`.

You will still get a prompt now and then. That is a safety feature rather than a sign that something has gone wrong. Claude is checking before it does something it cannot easily undo, and you can say no any time.

If you want Claude to check with you more often, press `Shift+Tab` to leave auto mode. The first press puts you in Manual mode, where Claude asks before every edit and command. Keep pressing to cycle through `Manual → accept edits → plan → auto`, and the status bar names the active mode. You can also pick "Yes, don't ask again" when a prompt appears, and run `/permissions` to see or remove what you previously allowed.

[Auto mode](#auto-mode) below has the full picture.

### Migrating from an API key

If you set up Claude Code before the move to the Claude Team plan, you authenticated with an Anthropic API key. Those keys are disabled.

You'll know this applies to you if `claude` fails with `401 API key is invalid`, or if `/status` shows an `API key` row.

1. **Accept your Claude Team invitation.** Ask Chris T on Slack if one never arrived.
2. **Clear the old API key out of your environment.** Look in your shell profile (`~/.zshrc`, `~/.bashrc`, or `~/.bash_profile`) and delete any line that sets `ANTHROPIC_API_KEY`. Check the `env` block of `~/.claude/settings.json` for the same variable. Then run:
   ```bash
   unset ANTHROPIC_API_KEY
   ```
   An API key in your environment outranks your Team login, so Claude Code keeps failing until the key is gone. This is the step that trips most people up.
3. **Log out**, which clears the stored credentials:
   ```
   /logout
   ```
4. **Log back in**, select "Claude account with subscription", and sign in with your Alliance email:
   ```
   /login
   ```
5. **Check it worked:**
   ```
   /status
   ```
   The `Login method` row should name your Claude account, and no `API key` row should appear.

One thing that confuses people: platform.claude.com is the Anthropic Console, which the Alliance no longer uses. Sign in there and you'll see *"You are not a member of any organizations under your domain."* Nothing is broken. Claude Code and Claude on the web both live at [claude.ai](https://claude.ai) now.

### Further reading

- [CLI reference](https://code.claude.com/docs/en/cli-reference) covers every command and option
- [Common workflows](https://code.claude.com/docs/en/common-workflows) has step-by-step guides

---

## Essential tips

Four habits that make the biggest difference to what Claude produces.

### 1. Make a plan before coding

For anything longer than a few lines, have Claude write a plan first. Ask it to explore the relevant parts of the codebase, work out what you're trying to accomplish, and write the plan to a markdown file such as `docs/plans/my-feature.md`.

The plan gives Claude something to work from, and gives you a chance to correct a misunderstanding early instead of after 500 lines have gone the wrong direction.

```
You: I want to add caching to the API client. Before writing any code, please explore
     the codebase and write a plan to docs/plans/api-caching.md
```

For larger projects, the [Superpowers plugin](#superpowers-plugin) automates this with `/superpowers:brainstorming` and `/superpowers:writing-plans`.

### 2. Ask for a code review after major changes

After a significant chunk of work, have Claude review it. This catches bugs, security problems, and style issues before they reach your commits.

Claude Code ships with `/code-review`, so there is nothing to install:

```
/code-review
```

It reviews your current diff for correctness bugs and cleanup opportunities. Add `--fix` to apply what it finds, or pass a PR number or branch to review that instead.

You can also ask in your own words:

```
You: Please spawn a sub-agent to review the changes I just made to the authentication module.
```

A sub-agent is worth asking for because it starts with fresh context. It hasn't sat through the hours of back-and-forth that produced the code, so it evaluates the work without the tunnel vision that comes from having written it.

### 3. Clear your context when you switch tasks

Claude's context window is the amount of conversation it can see at once. When you move to a new task, leftover context from the last one can confuse it and eats space you'd rather spend on the new work.

Run `/clear` when you start a new feature or bug fix, move to a different part of the codebase, or notice Claude referring to something stale.

```
/clear
```

### 4. Set up your repository with /init

The first time you work in a repository, run `/init`. Claude reads the codebase and writes a `CLAUDE.md` documenting the build, test, and lint commands, the key directories and design decisions, and the project details that would otherwise take reading several files to work out.

```
/init
```

Later sessions in that repository read `CLAUDE.md` automatically and start with that context instead of exploring from scratch. It pays off most in repositories you return to often, projects with an unusual build system, and codebases where you want Claude behaving consistently.

---

## Extending Claude Code

Plugins and MCP servers both add capabilities, in different ways.

### Plugins

Plugins add skills to Claude: step-by-step instructions for a particular task. The Jira plugin, for instance, teaches Claude how to create and manage tickets in our Alliance projects. When you type `/jira` or ask Claude to "create a Jira ticket", the skill walks it through the steps.

#### Alliance plugins

Built specifically for Alliance developers:

```
/plugin marketplace add alliance-genome/agr_claude_code
/plugin install alliance-jira@alliance-plugins
/plugin install git-safety@alliance-plugins
/plugin install linkml-reviewer@alliance-plugins
```

**alliance-jira** manages tickets across the Alliance projects (KANBAN, SCRUM, AGRHELP, MOD). On first use it walks you through setting up your Jira credentials, for which you'll need an API token from your Atlassian account.

```
"Find all my tickets from the last two days."
"Did we already make a ticket about the gene page bug?"
"Create an epic for the new search feature with 4 subtasks."
"Move SCRUM-1234 to In Progress."
```

**git-safety** installs pre-commit and pre-push hooks that scan for secrets using [Gitleaks](https://github.com/gitleaks/gitleaks) and [TruffleHog](https://github.com/trufflesecurity/trufflehog), plus a check for dangerous filenames. Try to commit or push an API key or password and the operation stops. Run `/secure-repo` to set it up on any repository.

**linkml-reviewer** reviews the Alliance LinkML curation schema (`agr_curation_schema`). It checks new or modified schema files for correctness, consistency, and Alliance conventions, and includes the reviewer checklist, the convention severity levels (ENFORCED, ADVISORY, TECH-DEBT), the DTO suffix mappings, and reference data for the class hierarchy and import graph. Run `/linkml-review` when you review a schema PR or propose a change.

```
"Review the changes I made to allele.yaml"
"I'm adding a new ExpressionPattern class - check it follows Alliance conventions"
"Does this new DTO slot use the correct suffix convention?"
```

---

#### Dictation with Whispering

Typing long prompts gets tiring. [Whispering](https://github.com/EpicenterHQ/epicenter/tree/main/apps/whispering) is a free, open-source dictation app: press a hotkey, speak, and it puts the transcript on your clipboard to paste into Claude Code.

To set it up, download Whispering from the [releases page](https://github.com/EpicenterHQ/epicenter/releases) (about 22MB), get a free [Groq API key](https://console.groq.com), and point Whispering at Groq with the `whisper-large-v3-turbo` model.

Groq is pay-as-you-go at roughly $0.04 an hour. Most people spend under $1 a month. It is the fastest cloud option and very cheap. Local transcription with Whisper C++ is free but slower.

---

#### Browsing available plugins

Run `/plugin` to open the plugin manager, then go to the **Discover** tab to browse everything from your marketplaces. Select a plugin to see details and install it. The official docs cover this in [Discover and install plugins](https://code.claude.com/docs/en/discover-plugins).

#### Updating plugins

```
/plugin update superpowers@claude-plugins-official
/plugin marketplace update alliance-plugins
/plugin update alliance-jira@alliance-plugins
```

---

### MCP servers

MCP (Model Context Protocol) servers are external programs Claude can call, giving it access to databases, documentation, and APIs. Plugins are instructions; MCP servers are running software.

#### Context7

[Context7](https://context7.com) fetches current documentation for libraries and frameworks, so Claude works from today's API rather than whatever was in its training data. Useful for React, FastAPI, the AWS SDKs, and anything else that changes often, including version-specific docs.

```bash
# Basic installation (works without an account)
claude mcp add context7 -- npx -y @upstash/context7-mcp

# With API key (optional, for higher rate limits)
claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_API_KEY
```

The API key is optional and only raises your rate limit. To get one, create a free account at [context7.com/dashboard](https://context7.com/dashboard) and generate a key, which looks like `ctx7sk-...`.

Add "use context7" to a prompt when you want current documentation:

```
> How do I set up streaming with FastAPI? use context7
```

The [Context7 documentation](https://context7.com/docs) has more.

---

#### AGR MCP server

The [AGR MCP server](https://github.com/alliance-genome/agr-mcp-server-js) connects Claude to Alliance of Genome Resources data across our eight model organisms: human, mouse, rat, zebrafish, fly, worm, yeast, and xenopus. You can search genes, pull disease associations and phenotypes and alleles, find cross-species orthologs, and look up expression data across tissues and developmental stages.

```bash
claude mcp add agr-genomics -- npx -y agr-mcp-server
```

Then ask about the data in plain language:

```
> Search for BRCA1 genes in human
> What diseases are associated with TP53?
> Find orthologs of the insulin gene
> Show me expression data for daf-2 in worm
```

| Tool | Description |
|------|-------------|
| `search_genes` | Search genes with optional species filter |
| `get_gene_info` | Detailed gene information (symbol, location, synonyms) |
| `get_gene_diseases` | Disease associations for a gene |
| `search_diseases` | Search diseases by name |
| `get_gene_expression` | Expression data across tissues and stages |
| `find_orthologs` | Cross-species homologs |
| `get_gene_phenotypes` | Phenotype annotations |
| `get_gene_interactions` | Molecular and genetic interactions |
| `get_gene_alleles` | Alleles and variants for a gene |

See the [AGR MCP server repository](https://github.com/alliance-genome/agr-mcp-server-js) for details.

---

## Tips and best practices

### Auto mode

Terminal sessions on the Team plan start in auto mode, so there is nothing to turn on. The status bar shows `⏵⏵ auto mode on`.

In auto mode Claude reads files, makes edits, runs tests, and executes routine commands without stopping after every action. A second model, the classifier, reviews each action in the background in your place.

If your sessions still start in Manual mode, check `claude --version`. Auto mode became the starting mode in v2.1.228 on macOS, Linux, and WSL, and v2.1.233 on native Windows. Native installs update themselves; Homebrew and WinGet do not.

The classifier still blocks force pushes, mass deletions, `curl | bash`, production deploys, sending secrets outside the repository, and changes to systems Claude doesn't recognize. Your `deny` rules and anything you said in conversation, such as *"don't push to main"*, still apply. If the classifier blocks 3 actions in a row, or 20 across the session, auto mode pauses and Claude Code goes back to asking you.

| Mode | Runs without asking | Best for |
|------|---------------------|----------|
| `auto` | Everything, with background safety checks | Long tasks, fewer prompts. The default. |
| Manual (`default`) | Reads only | Reviewing every action yourself, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code you're reviewing |
| `plan` | Reads, plus classifier-approved commands | Exploring a codebase before changing it |

Press `Shift+Tab` to switch. From auto, the first press drops you to Manual, and the cycle then runs `Manual → acceptEdits → plan → auto`.

To start every session in a different mode, set it in `~/.claude/settings.json`:

```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

> [!NOTE]
> `"auto"` only takes effect from `~/.claude/settings.json`. Put it in a project's `.claude/settings.json` and the session quietly starts in Manual instead, with no error. Every other value works from any settings file.

Auto mode suits feature branches, test projects, and exploratory work. Drop to Manual with `Shift+Tab` for production code or sensitive data, and make sure you have recent commits or a backup before a long autonomous run. Running `/secure-repo` to install the [git-safety hooks](#alliance-plugins) adds another layer against committing secrets by accident.

> [!NOTE]
> Auto mode needs Opus 4.6 or later, Sonnet 4.6 or later, or a Fable model. It does not work on Sonnet 4.5, Opus 4.5, or any Haiku model. If `auto` never appears as you cycle with `Shift+Tab`, check `/model` first.

### More to come

Still to write up: working with the Alliance APIs (AGR APIs, JBrowse), code review workflows, debugging strategies, and recommended settings and CLAUDE.md templates.

---

## Advanced usage

These take more setup and suit bigger projects.

### Superpowers plugin

Superpowers makes Claude plan before it codes, test before it ships, and stay on course through long autonomous runs.

```
/plugin install superpowers@claude-plugins-official
```

It brainstorms with you before writing code, breaks work into small verifiable tasks, hands each one to a fresh subagent with built-in review, enforces test-driven development, and saves progress to markdown files so nothing is lost between sessions.

| Command | What it does |
|---------|--------------|
| `/superpowers:brainstorming` | Interactive design refinement. Claude asks one question at a time until it understands what you want built. |
| `/superpowers:writing-plans` | Creates implementation plans with bite-sized tasks, file paths, and verification steps. |
| `/superpowers:executing-plans` | Executes plans in batches, pausing for your review between each one. |
| `/superpowers:writing-skills` | Creates or edits skills. Advanced usage. |

The plugin also carries skills for debugging, TDD, code review, and git workflows that activate on their own when relevant.

The workflow runs in four stages. You describe what you want, and Claude asks questions and explores alternatives. Claude then writes a detailed plan with exact file paths and verification steps. Fresh subagents work through each task, and every task gets reviewed twice, first against the specification and then for code quality. Claude finally reviews the finished work against the original plan, and critical issues block progress until they're resolved.

Reach for it when you start a new feature or project, refactor something complicated, take on anything longer than half an hour, or want Claude working on its own without drifting.

See the [Superpowers repository](https://github.com/obra/superpowers) for details.

---

### Frontend design

The frontend-design plugin produces distinctive, production-grade interfaces rather than the generic look that AI-generated frontends tend toward. Use it for web components, pages, and applications where the design matters.

```
/plugin install frontend-design@claude-plugins-official
```

Run it directly with `/frontend-design`, or ask for it while building:

```
> Build a dashboard component for displaying gene expression data. Use frontend-design for this.
> Create a search results page with filtering. Please use the frontend-design skill.
```

It suits new UI components and pages, landing pages, and marketing sites.

---

### Alliance agents plugin

Specialized agents for particular jobs:

```
/plugin install alliance-agents@alliance-plugins
```

| Agent | What it does |
|-------|--------------|
| `mcp-architect` | Designs and implements MCP servers connecting Claude to external APIs. Use it when Claude needs access to a new data source or service. |
| `product-manager` | Turns a high-level feature request into a Product Requirements Document, with metrics, requirements, and a rollout plan. |

Ask Claude to spawn a subagent for the task:

```
> Please spawn a subagent to create a PRD for adding user authentication to the curation tool.
> Spawn a subagent to design an MCP server that connects to our internal strain database.
```

---

## Contributing

Contributions from Alliance developers are welcome.

Found a bug or have an idea? Open an issue in this repository.

To contribute code, branch from `main`, make your changes, and open a pull request. To add a plugin, create it in `plugins/<plugin-name>/`, add it to `.claude-plugin/marketplace.json`, and open a pull request.

### Version bumps

When you update a plugin, bump the version in both places:

1. `plugins/<plugin-name>/.claude-plugin/plugin.json`, the plugin manifest
2. `.claude-plugin/marketplace.json`, the marketplace registry entry

The two must match. The version check in SKILL.md reads the installed version from the plugin cache directory, so there's nothing to update there by hand.

### Plugin structure

```
plugins/your-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (bump version here)
└── skills/
    └── your-skill/
        └── SKILL.md          # Skill instructions
```

The `alliance-jira` plugin is a complete example to work from.

---

## Support

- Questions: contact Chris T on Alliance Slack
- Email: christopher.tabone@jax.org
- Issues: open one in this repository
