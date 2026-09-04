---
name: secure-repo
description: Use when asked to add secret scanning, install git hooks, protect against committing API keys/passwords/tokens, set up security for a repo, or after running git clone on a new repository.
argument-hint: [repo-path]
---

# Secure Repository - Secret Scanning Hooks

Installs git pre-commit hooks that scan for secrets before each commit.

## MANDATORY: Version Check (Run on Skill Load)

> **CRITICAL: You MUST run this bash block when the skill is first loaded, before doing anything else.**

```bash
# Check for skill updates
PLUGIN_JSON=$(ls -t ~/.claude/plugins/cache/alliance-plugins/git-safety/*/.claude-plugin/plugin.json 2>/dev/null | head -1)
INSTALLED_VERSION=$(grep -o '"version": "[^"]*"' "$PLUGIN_JSON" 2>/dev/null | cut -d'"' -f4)
LATEST_VERSION=$(curl -sf --max-time 3 https://raw.githubusercontent.com/alliance-genome/agr_claude_code/main/plugins/git-safety/.claude-plugin/plugin.json 2>/dev/null | grep -o '"version": "[^"]*"' | cut -d'"' -f4)
if [ -z "$LATEST_VERSION" ]; then
  echo "Skill version: ${INSTALLED_VERSION} (could not check for updates)"
elif [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
  echo "*** UPDATE AVAILABLE *** Installed v${INSTALLED_VERSION}, latest v${LATEST_VERSION}"
  echo "Run: /plugin marketplace update alliance-plugins"
else
  echo "Skill version: ${INSTALLED_VERSION} (up to date)"
fi
```

## Step 1: Check/Install Tools

First, check if the required tools are installed:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/setup.sh"
```

If tools are missing, the script will show installation instructions.

### Quick Install (macOS with Homebrew)

```bash
brew install gitleaks trufflehog
```

### Quick Install (Linux)

**Gitleaks:**
```bash
GITLEAKS_VERSION=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep tag_name | cut -d'"' -f4)
curl -sSL "https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION#v}_linux_x64.tar.gz" | sudo tar -xz -C /usr/local/bin gitleaks
```

**TruffleHog:**
```bash
TRUFFLEHOG_VERSION=$(curl -s https://api.github.com/repos/trufflesecurity/trufflehog/releases/latest | grep tag_name | cut -d'"' -f4)
curl -sSL "https://github.com/trufflesecurity/trufflehog/releases/download/${TRUFFLEHOG_VERSION}/trufflehog_${TRUFFLEHOG_VERSION#v}_linux_amd64.tar.gz" | sudo tar -xz -C /usr/local/bin trufflehog
```

After installing, verify with:
```bash
gitleaks version && trufflehog --version
```

---

## Step 2: Install Git Hooks

Once tools are installed, add the pre-commit hook to your repository.

### To Current Repository

```bash
# Verify you're in a git repo
git rev-parse --show-toplevel

# Resolve the effective hooks directory (including linked worktrees and
# core.hooksPath) instead of assuming .git is a directory.
HOOK_DIR=$(git rev-parse --git-path hooks)
mkdir -p "$HOOK_DIR"

# Copy the shared library FIRST - the hooks fail closed without it
cp "${CLAUDE_PLUGIN_ROOT}/scripts/lib/git-safety-lib.sh" "$HOOK_DIR/git-safety-lib.sh"
cp "${CLAUDE_PLUGIN_ROOT}/scripts/pre-commit"            "$HOOK_DIR/pre-commit"
cp "${CLAUDE_PLUGIN_ROOT}/scripts/pre-push"              "$HOOK_DIR/pre-push"
chmod +x "$HOOK_DIR/pre-commit" "$HOOK_DIR/pre-push"

# Verify installation
echo "Hooks installed:" && ls -la "$HOOK_DIR/pre-commit" "$HOOK_DIR/pre-push"
```

### To a Specific Repository

```bash
# Replace REPO_PATH with the target directory
REPO_PATH="path/to/repo"
(
  cd "$REPO_PATH"
  HOOK_DIR=$(git rev-parse --git-path hooks)
  mkdir -p "$HOOK_DIR"
  cp "${CLAUDE_PLUGIN_ROOT}/scripts/lib/git-safety-lib.sh" "$HOOK_DIR/git-safety-lib.sh"
  cp "${CLAUDE_PLUGIN_ROOT}/scripts/pre-commit"            "$HOOK_DIR/pre-commit"
  cp "${CLAUDE_PLUGIN_ROOT}/scripts/pre-push"              "$HOOK_DIR/pre-push"
  chmod +x "$HOOK_DIR/pre-commit" "$HOOK_DIR/pre-push"
)
```

---

## What the Hooks Do

`pre-commit` runs four gates in order:

1. **Parent directory protection** - staged paths must not escape the repo root
2. **Dangerous file check** - blocks by filename, before any content scan:
   - Tier 1: `.bash*` / `*.bash*` (deliberately broad - catches `.bash_history`)
   - Tier 2: shell and REPL histories (`.zsh_history`, `.python_history`, ...)
   - Tier 3a: keystores by name (`.p12`, `.pfx`, `.jks`, `.kdbx`, `.p8`, ...)
   - Tier 3b: `.pem` / `.key` / `id_rsa` blocked **only if content holds a private key**
   - Tier 4: credential files (`.netrc`, `.pgpass`, `.aws/credentials`, ...)
   - `*.pub` is never blocked. Matching is case-insensitive.
3. **Gitleaks** - content scan
4. **TruffleHog** - content scan

`pre-push` re-runs gate 2 over the commits being pushed, catching anything that
reached a commit via `--no-verify`. There tier 3b blocks on name alone, so
known public CA bundles such as `ca-certs.pem` are exempt at push only -
`pre-commit` still content-checks them.

## The `.gitsafety-allow` Escape Hatch

Tier 1 is broad by design and will hit legitimate files such as
`scripts/setup.bash`. Allowlist them in a repo-root `.gitsafety-allow`, one
glob per line:

```
# ROS build script, not a secret
scripts/setup.bash
docs/*.bash
```

- **It must be tracked.** The hook reads the *index blob*, so an unstaged edit
  has no effect and every exemption is reviewable in the diff.
- **Over-broad patterns are refused** (`*`, `?*`, `*.pem`, `.ssh/*`, ...).
- **It suppresses the filename gate only.** Gitleaks and TruffleHog still scan
  allowlisted files.

## Optional Configuration

`~/.config/git-safety/config` may set:

- `GIT_SAFETY_PRIVATE_PARENT` - a repo path that must never be pushed
- `GIT_SAFETY_BLOCKED_REMOTES` - space-separated remote substrings to refuse
- `GIT_SAFETY_CONTACT` - who the escalation banner names (default: "the repository owner")

All default to empty, so the hooks contain no machine-specific values.

## Requirements

Bash 3.2 or newer - macOS system bash is 3.2, and the hooks are tested against
it. They fail closed: a missing library, an unreadable index, or a failed range
enumeration blocks rather than silently skipping a gate.

---

## Test the Hook

To verify the hook works, create a test file with a fake secret pattern:

```bash
# Generate a fake AWS-style key for testing (don't use real keys!)
echo 'AWS_KEY="AKIA'$(openssl rand -hex 8 | tr '[:lower:]' '[:upper:]')'"' > test-secret.txt
git add test-secret.txt
git commit -m "test"  # Should be blocked!

# Clean up
git reset HEAD test-secret.txt
rm test-secret.txt
```

---

## If a Commit is Blocked

1. **Review the findings** - Check if it's a real secret or false positive
2. **Remove the secret** - If real, remove it from the staged files
3. **For false positives** - Add pattern to `.gitleaksignore`

### Bypass (Use With Extreme Caution)

Only after confirming a detection is a false positive:

```bash
git commit --no-verify
```
