# Search Tickets with JQL

## Overview

Use JQL (Jira Query Language) to search for issues. The enhanced search endpoint (`/rest/api/3/search/jql`) is recommended over the deprecated `/rest/api/3/search`.

---

## Basic JQL Search

```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/search/jql" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "jql": "project = KANBAN ORDER BY created DESC",
    "maxResults": 50,
    "fields": ["key", "summary", "status", "assignee", "priority", "created"]
  }'
```

---

## Common JQL Queries

### My Assigned Tickets
```json
{"jql": "assignee = currentUser() ORDER BY updated DESC"}
```

### Tickets in Progress
```json
{"jql": "project = KANBAN AND status = \"In Progress\" ORDER BY updated DESC"}
```

### Recent Tickets
```json
{"jql": "project = KANBAN AND created >= -7d ORDER BY created DESC"}
```

### By Component
```json
{"jql": "project = KANBAN AND component = \"AI Curation\" ORDER BY created DESC"}
```

### Text Search
```json
{"jql": "project = KANBAN AND text ~ \"JBrowse\" ORDER BY updated DESC"}
```

### Unassigned Tickets
```json
{"jql": "project = KANBAN AND assignee IS EMPTY ORDER BY priority DESC"}
```

### High Priority
```json
{"jql": "project = KANBAN AND priority IN (Highest, High) AND status != Done"}
```

### Specific Assignee
```json
{"jql": "project = KANBAN AND assignee = \"ACCOUNT_ID_HERE\""}
```

---

## Request Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `jql` | string | JQL query (required) |
| `maxResults` | integer | Max items per page (default: 50) |
| `fields` | array | Fields to return (or `*all`, `*navigable`) |
| `nextPageToken` | string | Token for next page (from previous response) |
| `expand` | string | Extra data: `renderedFields`, `names`, `schema`, `transitions` |

---

## Common Fields to Request

```json
"fields": [
  "key",
  "summary",
  "status",
  "assignee",
  "priority",
  "created",
  "updated",
  "description",
  "components",
  "labels",
  "issuetype",
  "resolution"
]
```

---

## Response Format

```json
{
  "issues": [
    {
      "id": "12345",
      "key": "KANBAN-123",
      "fields": {
        "summary": "Issue title",
        "status": {"name": "In Progress"},
        "assignee": {"displayName": "John Doe", "accountId": "..."},
        "priority": {"name": "Medium"}
      }
    }
  ],
  "nextPageToken": "<token-from-previous-response>",
  "isLast": false
}
```

---

## Pagination

Use `nextPageToken` from the response for subsequent pages:

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/search/jql" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "jql": "project = KANBAN",
    "maxResults": 50,
    "nextPageToken": "<token-from-previous-response>"
  }'
```

---

## Get Issue Count Only

Use approximate count for statistics without fetching issues:

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/search/approximate-count" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"jql": "project = KANBAN AND status = \"In Progress\""}'
```

Response: `{"count": 42}`

---

## JQL Syntax Reference

### Operators
| Operator | Example |
|----------|---------|
| `=` | `status = "Done"` |
| `!=` | `status != "Done"` |
| `~` | `summary ~ "bug"` (contains) |
| `!~` | `summary !~ "test"` |
| `IN` | `priority IN (High, Highest)` |
| `NOT IN` | `status NOT IN (Done, Closed)` |
| `IS EMPTY` | `assignee IS EMPTY` |
| `IS NOT EMPTY` | `component IS NOT EMPTY` |

### Date Functions
| Function | Example |
|----------|---------|
| `now()` | `created < now()` |
| `-7d` | `updated >= -7d` (last 7 days) |
| `startOfDay()` | `created >= startOfDay()` |
| `startOfWeek()` | `created >= startOfWeek()` |
| `startOfMonth()` | `created >= startOfMonth()` |

### User Functions
| Function | Description |
|----------|-------------|
| `currentUser()` | Authenticated user |
| `membersOf("group")` | Members of a group |

---

## Board-Based Queries

For board-specific listings, use the Agile API:

```bash
# Get issues on Main Board (ID: 61)
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/agile/1.0/board/61/issue?maxResults=50" \
  -H "Accept: application/json"

# With JQL filter
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/agile/1.0/board/61/issue?jql=status='In Progress'" \
  -H "Accept: application/json"
```

---

## Bulk Fetch Known Issues

When you have specific issue keys, use bulk fetch:

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/bulkfetch" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "issueIdsOrKeys": ["KANBAN-1", "KANBAN-2", "KANBAN-3"],
    "fields": ["key", "summary", "status", "assignee"]
  }'
```

- Maximum 100 issues per request
- More efficient than multiple single-issue GETs
