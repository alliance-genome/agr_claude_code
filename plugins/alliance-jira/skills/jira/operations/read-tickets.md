# Read Tickets

## Get Single Issue

```bash
source ~/.alliance/jira/.env
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123" \
  -H "Accept: application/json"
```

### With Specific Fields

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123?fields=summary,status,assignee,description" \
  -H "Accept: application/json"
```

### With Expanded Data

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123?expand=transitions,changelog" \
  -H "Accept: application/json"
```

---

## Response Structure

```json
{
  "id": "12345",
  "key": "KANBAN-123",
  "self": "https://agr-jira.atlassian.net/rest/api/3/issue/12345",
  "fields": {
    "summary": "Issue title here",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [...]
    },
    "status": {
      "id": "3",
      "name": "In Progress",
      "statusCategory": {"name": "In Progress"}
    },
    "assignee": {
      "accountId": "ACCOUNT_ID_HERE",
      "displayName": "John Doe"
    },
    "reporter": {
      "accountId": "ACCOUNT_ID_HERE",
      "displayName": "Jane Smith"
    },
    "priority": {"id": "3", "name": "Medium"},
    "issuetype": {"id": "10000", "name": "Task"},
    "project": {"key": "KANBAN", "name": "Alliance Kanban"},
    "created": "2024-01-15T10:30:00.000+0000",
    "updated": "2024-01-16T14:20:00.000+0000",
    "labels": ["api", "backend"],
    "components": [{"id": "10784", "name": "API"}],
    "comment": {
      "comments": [...],
      "total": 5
    }
  }
}
```

---

## Expand Options

| Option | Description |
|--------|-------------|
| `renderedFields` | HTML-rendered field values |
| `names` | Display names of fields |
| `schema` | Field type schemas |
| `transitions` | Available status transitions |
| `operations` | Available operations |
| `editmeta` | How fields can be edited |
| `changelog` | Recent changes (max 40) |

### Get Available Transitions

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123?expand=transitions" \
  -H "Accept: application/json" | jq '.transitions'
```

---

## Get Comments

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/comment" \
  -H "Accept: application/json"
```

### Response

```json
{
  "comments": [
    {
      "id": "10000",
      "author": {"displayName": "John Doe"},
      "body": {
        "type": "doc",
        "version": 1,
        "content": [...]
      },
      "created": "2024-01-15T10:30:00.000+0000"
    }
  ],
  "startAt": 0,
  "maxResults": 100,
  "total": 1
}
```

---

## Get Changelog (History)

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/changelog" \
  -H "Accept: application/json"
```

### Response

```json
{
  "histories": [
    {
      "id": "10001",
      "author": {"displayName": "John Doe"},
      "created": "2024-01-15T10:30:00.000+0000",
      "items": [
        {
          "field": "status",
          "fromString": "To Do",
          "toString": "In Progress"
        }
      ]
    }
  ],
  "startAt": 0,
  "maxResults": 100,
  "total": 5
}
```

---

## Get Watchers

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/watchers" \
  -H "Accept: application/json"
```

---

## Get Remote Links

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/remotelink" \
  -H "Accept: application/json"
```

---

## Get Issue Links

Issue links are in the main issue response:

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123?fields=issuelinks" \
  -H "Accept: application/json"
```

---

## Bulk Fetch Multiple Issues

More efficient than multiple single requests:

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/bulkfetch" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "issueIdsOrKeys": ["KANBAN-1", "KANBAN-2", "KANBAN-3"],
    "fields": ["key", "summary", "status", "assignee", "description"]
  }'
```

- Max 100 issues per request
- Can mix issue keys and IDs
- Issues returned in ascending ID order

---

## Get Attachments

Attachments are in the main issue response:

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123?fields=attachment" \
  -H "Accept: application/json"
```

### Download Attachment

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/attachment/content/10001" \
  -o downloaded_file.txt
```

---

## Check If User Can Edit Issue

```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/KANBAN-123/editmeta" \
  -H "Accept: application/json"
```

Returns fields that can be edited and their allowed values.
