# Update Tickets

## Change Status (Transition)

### Get Available Transitions First

```bash
source ~/.alliance/jira/.env
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/transitions" \
  -H "Accept: application/json"
```

### Perform Transition

```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/transitions" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "21"}}'
```

### KANBAN Transition IDs

| Target Status | Transition ID |
|---------------|---------------|
| Backlog | 41 |
| To Do | 11 |
| In Progress | 21 |
| Ready for UAT | 51 |
| Release | 2 |
| Done | 31 |

### Close Issue with Resolution

The "Done" transition (31) has a screen and requires resolution:

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/transitions" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "transition": {"id": "31"},
    "fields": {
      "resolution": {"name": "Done"}
    }
  }'
```

### Transition with Comment

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/transitions" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "transition": {"id": "31"},
    "fields": {"resolution": {"name": "Done"}},
    "update": {
      "comment": [
        {
          "add": {
            "body": {
              "type": "doc",
              "version": 1,
              "content": [
                {
                  "type": "paragraph",
                  "content": [{"type": "text", "text": "Completed and verified."}]
                }
              ]
            }
          }
        }
      ]
    }
  }'
```

---

## Update Issue Fields

```bash
source ~/.alliance/jira/.env
curl -s -X PUT -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "summary": "Updated title",
      "priority": {"id": "2"}
    }
  }'
```

### Update Description

```bash
curl -s -X PUT -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "description": {
        "type": "doc",
        "version": 1,
        "content": [
          {
            "type": "paragraph",
            "content": [{"type": "text", "text": "New description"}]
          }
        ]
      }
    }
  }'
```

### Add/Remove Labels

```bash
curl -s -X PUT -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "update": {
      "labels": [
        {"add": "new-label"},
        {"remove": "old-label"}
      ]
    }
  }'
```

---

## Assign Issue

```bash
curl -s -X PUT -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/assignee" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"accountId": "ACCOUNT_ID_HERE"}'
```

### Unassign

```bash
curl -s -X PUT -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/assignee" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"accountId": null}'
```

### Find Assignable Users

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/user/assignable/search?issueKey=KANBAN-123&query=chris" \
  -H "Accept: application/json"
```

---

## Add Comment

```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/comment" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "body": {
      "type": "doc",
      "version": 1,
      "content": [
        {
          "type": "paragraph",
          "content": [{"type": "text", "text": "This is my comment."}]
        }
      ]
    }
  }'
```

### Comment with Formatting

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/comment" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "body": {
      "type": "doc",
      "version": 1,
      "content": [
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": "Fixed in "},
            {"type": "text", "text": "commit abc123", "marks": [{"type": "code"}]}
          ]
        }
      ]
    }
  }'
```

---

## Link Issues

### Create Issue Link

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issueLink" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "type": {"name": "Relates"},
    "inwardIssue": {"key": "KANBAN-123"},
    "outwardIssue": {"key": "KANBAN-456"}
  }'
```

### Link Types

| Type | Inward | Outward |
|------|--------|---------|
| Relates | is related to | relates to |
| Blocks | is blocked by | blocks |
| Duplicate | is duplicated by | duplicates |
| Clones | is cloned by | clones |

---

## Add Remote Link (External URL)

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/remotelink" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "object": {
      "url": "https://github.com/alliance-genome/repo/pull/123",
      "title": "PR #123: Fix the bug"
    }
  }'
```

---

## Add Attachment

**Important:** Requires `X-Atlassian-Token: no-check` header.

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/attachments" \
  -H "Accept: application/json" \
  -H "X-Atlassian-Token: no-check" \
  -F "file=@/path/to/file.txt"
```

---

## Add Watcher

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/watchers" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '"ACCOUNT_ID_HERE"'
```

### Remove Watcher

```bash
curl -s -X DELETE -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/watchers?accountId=ACCOUNT_ID_HERE" \
  -H "Accept: application/json"
```

---

## Bulk Transition

Transition up to 1,000 issues at once:

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/bulk/issues/transition" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "bulkTransitionInputs": [
      {
        "selectedIssueIdsOrKeys": ["KANBAN-1", "KANBAN-2"],
        "transitionId": "21"
      }
    ],
    "sendBulkNotification": false
  }'
```

---

## Resolution IDs

| Resolution | ID |
|------------|-----|
| Done | 10000 |
| Won't Do | 10001 |
| Duplicate | 10002 |
| Cannot Reproduce | 10003 |
| As Designed | 10100 |

---

## Response Codes

| Code | Meaning |
|------|---------|
| 200/204 | Success |
| 400 | Invalid input or missing required fields |
| 401 | Authentication failed |
| 403 | No permission |
| 404 | Issue not found |
| 409 | Conflict (concurrent edit) |
