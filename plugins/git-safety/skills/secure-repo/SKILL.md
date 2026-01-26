---
name: secure-repo
description: Use when asked to add secret scanning, install git hooks, protect against committing API keys/passwords/tokens, set up security for a repo, or after running git clone on a new repository.
---

# Secure Repository - Secret Scanning Hooks

Installs git pre-commit hooks that scan for secrets before each commit.

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

# Copy the pre-commit hook
cp "${CLAUDE_PLUGIN_ROOT}/scripts/pre-commit" .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Verify installation
echo "Hook installed:" && ls -la .git/hooks/pre-commit
```

### To a Specific Repository

```bash
# Replace REPO_PATH with the target directory
REPO_PATH="path/to/repo"
cp "${CLAUDE_PLUGIN_ROOT}/scripts/pre-commit" "${REPO_PATH}/.git/hooks/pre-commit"
chmod +x "${REPO_PATH}/.git/hooks/pre-commit"
```

---

## What the Hook Does

On every `git commit`, the pre-commit hook:

1. **Gitleaks scan** - Detects API keys, passwords, tokens, private keys
2. **TruffleHog scan** - Detects AWS keys, Slack webhooks, other secrets

If either tool finds potential secrets, the commit is **blocked**.

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
