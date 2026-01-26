# Create Tickets

## Basic Task Creation

```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "KANBAN"},
      "summary": "Task title here",
      "description": {
        "type": "doc",
        "version": 1,
        "content": [
          {
            "type": "paragraph",
            "content": [{"type": "text", "text": "Task description here"}]
          }
        ]
      },
      "issuetype": {"id": "10000"},
      "priority": {"id": "3"}
    }
  }'
```

### Response

```json
{
  "id": "12345",
  "key": "KANBAN-456",
  "self": "https://agr-jira.atlassian.net/rest/api/3/issue/12345"
}
```

---

## Required Fields

| Field | Format | Notes |
|-------|--------|-------|
| `project` | `{"key": "KANBAN"}` or `{"id": "10109"}` | Required |
| `summary` | string | Required |
| `issuetype` | `{"id": "10000"}` | Required (Task=10000) |

## Common Optional Fields

| Field | Format |
|-------|--------|
| `description` | ADF document |
| `priority` | `{"id": "3"}` |
| `assignee` | `{"accountId": "..."}` |
| `labels` | `["label1", "label2"]` |
| `components` | `[{"id": "10784"}]` |
| `customfield_10628` | `{"id": "10351"}` (Triage: No) |

---

## Issue Type IDs

| Type | ID |
|------|-----|
| Task | 10000 |
| Sub-task | 10001 |
| Epic | 10002 |
| Story | 10003 |
| Bug | 10004 |
| Feature | 10005 |
| Spike | 10203 |

---

## Priority IDs

| Priority | ID |
|----------|-----|
| Show Stopper | 10000 |
| Highest | 1 |
| High | 2 |
| Medium | 3 |
| Low | 4 |
| Lowest | 5 |

---

## Atlassian Document Format (ADF)

All rich text fields (description, comment) use ADF.

### Basic Paragraph

```json
{
  "type": "doc",
  "version": 1,
  "content": [
    {
      "type": "paragraph",
      "content": [
        {"type": "text", "text": "Plain text here"}
      ]
    }
  ]
}
```

### Bold and Italic

```json
{
  "type": "paragraph",
  "content": [
    {"type": "text", "text": "This is "},
    {"type": "text", "text": "bold", "marks": [{"type": "strong"}]},
    {"type": "text", "text": " and "},
    {"type": "text", "text": "italic", "marks": [{"type": "em"}]}
  ]
}
```

### Bullet List

```json
{
  "type": "bulletList",
  "content": [
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [{"type": "text", "text": "Item 1"}]
        }
      ]
    },
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [{"type": "text", "text": "Item 2"}]
        }
      ]
    }
  ]
}
```

### Numbered List

```json
{
  "type": "orderedList",
  "content": [
    {
      "type": "listItem",
      "content": [
        {
          "type": "paragraph",
          "content": [{"type": "text", "text": "Step 1"}]
        }
      ]
    }
  ]
}
```

### Code Block

```json
{
  "type": "codeBlock",
  "attrs": {"language": "python"},
  "content": [
    {"type": "text", "text": "def hello():\n    print('Hello')"}
  ]
}
```

### Link

```json
{
  "type": "text",
  "text": "Click here",
  "marks": [
    {"type": "link", "attrs": {"href": "https://example.com"}}
  ]
}
```

### Heading

```json
{
  "type": "heading",
  "attrs": {"level": 2},
  "content": [
    {"type": "text", "text": "Section Title"}
  ]
}
```

---

## Full Example: Create Bug with Details

```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "KANBAN"},
      "summary": "API returns 500 error on gene lookup",
      "description": {
        "type": "doc",
        "version": 1,
        "content": [
          {
            "type": "paragraph",
            "content": [
              {"type": "text", "text": "When looking up gene MGI:12345, the API returns a 500 error."}
            ]
          },
          {
            "type": "heading",
            "attrs": {"level": 3},
            "content": [{"type": "text", "text": "Steps to Reproduce"}]
          },
          {
            "type": "orderedList",
            "content": [
              {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Call GET /api/gene/MGI:12345"}]}]},
              {"type": "listItem", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Observe 500 error response"}]}]}
            ]
          }
        ]
      },
      "issuetype": {"id": "10004"},
      "priority": {"id": "2"},
      "labels": ["api", "bug"],
      "components": [{"id": "10784"}]
    }
  }'
```

---

## Create Story with Component

```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "KANBAN"},
      "summary": "Add gene summary display to gene page",
      "description": {
        "type": "doc",
        "version": 1,
        "content": [
          {
            "type": "paragraph",
            "content": [
              {"type": "text", "text": "As a user, I want to see gene summaries on gene pages."}
            ]
          }
        ]
      },
      "issuetype": {"id": "10003"},
      "priority": {"id": "3"},
      "components": [{"id": "10871"}]
    }
  }'
```

---

## Link to Epic

Add this field to link a new issue to an Epic:

```json
"customfield_10000": "KANBAN-100"
```

---

## Bulk Create Issues

Create up to 50 issues at once:

```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/bulk" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "issueUpdates": [
      {
        "fields": {
          "project": {"key": "KANBAN"},
          "summary": "Task 1",
          "issuetype": {"id": "10000"}
        }
      },
      {
        "fields": {
          "project": {"key": "KANBAN"},
          "summary": "Task 2",
          "issuetype": {"id": "10000"}
        }
      }
    ]
  }'
```

---

## Common Component IDs (KANBAN)

| Component | ID |
|-----------|-----|
| AI Curation | 10871 |
| API | 10784 |
| UI | 10755 |
| JBrowse | 10794 |
| Search | 10756 |
| LinkML | 10792 |

See @reference/components.md for full list.
