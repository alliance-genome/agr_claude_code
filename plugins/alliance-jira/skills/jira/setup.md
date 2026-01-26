# Initial Setup

This guide helps you configure Jira API credentials for the first time.

---

## Step 1: Check Current Status

First, let's check if credentials are already configured:

```bash
if [ -f ~/.alliance/jira/.env ]; then
  source ~/.alliance/jira/.env
  echo "Credentials found for: $JIRA_EMAIL"
  echo "Testing connection..."
  curl -s -o /dev/null -w "%{http_code}" -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
    "https://agr-jira.atlassian.net/rest/api/3/myself" \
    -H "Accept: application/json"
else
  echo "No credentials found. Setup required."
fi
```

If you see `200`, you're all set! Otherwise, continue below.

---

## Step 2: Create the Credentials Directory

Run this command to create the secure directory:

```bash
mkdir -p ~/.alliance/jira
```

---

## Step 3: Generate Your Jira API Token

1. **Open your browser** and go to:
   **https://id.atlassian.com/manage-profile/security/api-tokens**

2. **Log in** with your Atlassian account (the email you use for Jira)

3. **Click "Create API token"**

4. **Enter a label** like "Claude Code" or "CLI Access"

5. **Click "Create"**

6. **IMPORTANT: Copy the token immediately!**
   - You will only see it once
   - Save it somewhere safe temporarily (you'll need it in the next step)

---

## Step 4: Create the Credentials File

**SECURITY WARNING**: Do NOT paste your API token into this chat!

Instead, open your terminal and run this command to create and edit the file:

```bash
nano ~/.alliance/jira/.env
```

Then paste this content, replacing the placeholder values:

```
JIRA_EMAIL="your.actual.email@example.com"
JIRA_API_KEY="paste-your-api-token-here"
JIRA_URL="https://agr-jira.atlassian.net"
```

Save the file:
- In nano: Press `Ctrl+O`, then `Enter`, then `Ctrl+X`
- In vim: Press `Esc`, type `:wq`, press `Enter`

### Alternative: Use cat with heredoc

If you prefer, you can run this command and it will prompt you:

```bash
read -p "Enter your Jira email: " email && \
read -sp "Enter your API token: " token && echo && \
cat > ~/.alliance/jira/.env << EOF
JIRA_EMAIL="$email"
JIRA_API_KEY="$token"
JIRA_URL="https://agr-jira.atlassian.net"
EOF
echo "Credentials saved!"
```

---

## Step 5: Secure the File

Set restrictive permissions so only you can read the file:

```bash
chmod 600 ~/.alliance/jira/.env
```

Verify permissions:

```bash
ls -la ~/.alliance/jira/.env
```

You should see `-rw-------` at the start (readable/writable only by owner).

---

## Step 6: Test Your Configuration

Run this test to verify everything works:

```bash
source ~/.alliance/jira/.env
echo "Testing connection for: $JIRA_EMAIL"

# Test 1: Authentication
response=$(curl -s -w "\n%{http_code}" -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/myself" \
  -H "Accept: application/json")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "200" ]; then
  name=$(echo "$body" | grep -o '"displayName":"[^"]*"' | cut -d'"' -f4)
  echo "Authentication successful!"
  echo "Logged in as: $name"

  # Test 2: Can access KANBAN project
  projects=$(curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
    "https://agr-jira.atlassian.net/rest/api/3/project/KANBAN" \
    -H "Accept: application/json")

  if echo "$projects" | grep -q '"key":"KANBAN"'; then
    echo "KANBAN project access: OK"
  else
    echo "Warning: Cannot access KANBAN project"
  fi

  echo ""
  echo "Setup complete! You can now use the Jira skill."
else
  echo "Authentication failed (HTTP $http_code)"
  echo "Please check your email and API token."
fi
```

---

## Troubleshooting

### "401 Unauthorized"
- Verify your email is correct (the one you log into Jira with)
- Regenerate your API token - tokens cannot be viewed after creation
- Ensure no extra spaces or quotes around values in .env

### "403 Forbidden"
- Your account may not have access to Alliance Jira
- Contact the Jira administrator for access

### "Could not resolve host"
- Check your internet connection
- Verify the URL is exactly `https://agr-jira.atlassian.net`

### Need Help?
Contact Christopher Tabone:
- Email: christopher.tabone@jax.org
- Slack: Message directly

---

## Quick Reference

| Item | Value |
|------|-------|
| Credentials file | `~/.alliance/jira/.env` |
| API token page | https://id.atlassian.com/manage-profile/security/api-tokens |
| Jira instance | https://agr-jira.atlassian.net |
| Required permissions | Access to KANBAN, SCRUM, AGRHELP, or MOD projects |
