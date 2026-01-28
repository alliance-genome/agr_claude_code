---
name: jira
description: Use when asked to create, search, update, or transition Jira tickets. Use when user mentions KANBAN, SCRUM, AGRHELP, or MOD projects. Use when needing ticket status, assignments, or board views.
argument-hint: [ticket-key or search query]
---

# Alliance Jira Skill

Manage Jira tickets across all Alliance of Genome Resources projects.

> **CRITICAL: DO NOT pipe curl output to python3, jq, or any other process.**
> Piping causes intermittent empty-stdin failures that silently break JSON parsing.
> Always run curl commands standalone and read the raw JSON output directly.

## First-Time Setup Check

Before any operation, verify credentials and check for skill updates:

```bash
if [ -f ~/.alliance/jira/.env ]; then
  source ~/.alliance/jira/.env
  echo "Credentials loaded for: $JIRA_EMAIL"
else
  echo "ERROR: Jira credentials not configured"
  echo "Run the full setup guide"
fi

# Check for skill updates
INSTALLED_VERSION="1.1.0"
LATEST_VERSION=$(curl -sf --max-time 3 https://raw.githubusercontent.com/alliance-genome/agr_claude_code/main/plugins/alliance-jira/.claude-plugin/plugin.json 2>/dev/null | grep -o '"version": "[^"]*"' | cut -d'"' -f4)
if [ -n "$LATEST_VERSION" ] && [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
  echo "UPDATE AVAILABLE: Installed v${INSTALLED_VERSION}, latest v${LATEST_VERSION}"
  echo "Run: /plugin marketplace update alliance-plugins"
else
  echo "Skill version: ${INSTALLED_VERSION} (up to date)"
fi
```

### If Credentials Missing

**SECURITY**: Never paste your API token into the chat. Edit files directly.

See setup.md for the complete guided setup process, which includes:
1. Creating the credentials directory
2. Getting your API token from Atlassian
3. Securely saving credentials to a file
4. Testing your configuration

**Need help?** Contact Christopher Tabone (christopher.tabone@jax.org) or Slack.

---

## Quick Navigation

Load these files only when needed for the specific task:

| Task | File |
|------|------|
| **First-time setup** | [setup.md](setup.md) |
| Search with JQL | [operations/search-tickets.md](operations/search-tickets.md) |
| Get/view a ticket | [operations/read-tickets.md](operations/read-tickets.md) |
| Create a ticket | [operations/create-tickets.md](operations/create-tickets.md) |
| Change status | [operations/update-tickets.md](operations/update-tickets.md) |
| Add comments/links | [operations/update-tickets.md](operations/update-tickets.md) |
| Projects & boards | [reference/projects.md](reference/projects.md) |
| Issue types & fields | [reference/issue-types.md](reference/issue-types.md) |
| Statuses & transitions | [reference/statuses.md](reference/statuses.md) |
| Components | [reference/components.md](reference/components.md) |
| Priorities | [reference/priorities.md](reference/priorities.md) |

---

## Safety Rules

1. **ONLY modify tickets assigned to the authenticated user** (verify assignee first)
2. **Exception: AGRHELP tickets** - can close/comment on any AGRHELP ticket
3. **NEVER expose API credentials** in output
4. **Always GET ticket first** before any modification to verify ownership
5. **NEVER pipe curl output through python3** - this causes intermittent empty-stdin failures. Read raw JSON output from curl directly. You can parse JSON without python.

---

## API Quick Reference

### Endpoints

| Purpose | Endpoint | Method |
|---------|----------|--------|
| Search with JQL | `/rest/api/3/search/jql` | POST |
| Get issue count | `/rest/api/3/search/approximate-count` | POST |
| Get single issue | `/rest/api/3/issue/{key}` | GET |
| Bulk fetch issues | `/rest/api/3/issue/bulkfetch` | POST |
| Create issue | `/rest/api/3/issue` | POST |
| Update issue | `/rest/api/3/issue/{key}` | PUT |
| Transition issue | `/rest/api/3/issue/{key}/transitions` | POST |
| Add comment | `/rest/api/3/issue/{key}/comment` | POST |
| Board issues (via JQL) | `/rest/api/3/search/jql` | GET/POST |

### Authentication

All requests use Basic Auth:
```bash
-u "${JIRA_EMAIL}:${JIRA_API_KEY}"
```

---

## Common Operations

### Search with JQL (Recommended)
```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/search/jql" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "jql": "project = KANBAN AND status = \"In Progress\" ORDER BY created DESC",
    "maxResults": 20,
    "fields": ["key", "summary", "status", "assignee", "priority"]
  }'
```

### Get a Ticket
```bash
source ~/.alliance/jira/.env
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123" \
  -H "Accept: application/json"
```

### List Tickets by Component
```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/search/jql" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "jql": "project = KANBAN AND component = \"AI Curation\" ORDER BY updated DESC",
    "maxResults": 20,
    "fields": ["key", "summary", "status", "assignee", "priority"]
  }'
```

### Change Status (e.g., to "In Progress")
```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/transitions" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "21"}}'
```

See reference/statuses.md for all transition IDs.

---

## Key IDs

### Board IDs
| Board | ID | Project |
|-------|-----|---------|
| Main Board | 61 | KANBAN |
| AI Curation | 169 | KANBAN |
| A-Team | 66 | SCRUM |
| Blue Team | 65 | SCRUM |

### Transition IDs (KANBAN)
| Transition | ID |
|------------|-----|
| Backlog | 41 |
| To Do | 11 |
| In Progress | 21 |
| Ready for UAT | 51 |
| Release | 2 |
| Done | 31 |

### Issue Type IDs
| Type | ID |
|------|-----|
| Task | 10000 |
| Story | 10003 |
| Bug | 10004 |
| Epic | 10002 |

### Priority IDs
| Priority | ID |
|----------|-----|
| Highest | 1 |
| High | 2 |
| Medium | 3 |
| Low | 4 |
| Lowest | 5 |

See reference files for complete lists.

---

## Atlassian Document Format (ADF)

Description and comment fields use ADF:

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [
        {"type": "text", "text": "Your text here"}
      ]
    }
  ]
}
```

See operations/create-tickets.md for full ADF examples.

---

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Piping curl output to `python3` for JSON parsing | **NEVER do this** - causes intermittent empty-stdin failures. Read raw curl JSON output directly. |
| Plain text in description/comment fields | Use Atlassian Document Format (ADF) - see above |
| Transitioning to Done without resolution | Include `"fields": {"resolution": {"name": "Done"}}` |
| Modifying tickets not assigned to you | Always GET ticket first to verify assignee |
| Pasting API token in chat | Edit `~/.alliance/jira/.env` directly |
| Missing `X-Atlassian-Token` on attachments | Add header: `X-Atlassian-Token: no-check` |
