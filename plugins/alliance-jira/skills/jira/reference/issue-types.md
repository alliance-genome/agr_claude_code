# Alliance Jira Issue Types & Fields Reference

## Issue Types

| Type | ID | Description | Subtask | Hierarchy |
|------|----|-------------|---------|-----------|
| **Task** | 10000 | A task that needs to be done | No | Standard |
| **Bug** | 10004 | Problem impairs or prevents product functions | No | Standard |
| **Story** | 10003 | User story for a feature | No | Standard |
| **Feature** | 10005 | Request new functionality | No | Standard |
| **Epic** | 10002 | Parent container for related work | No | Parent |
| **Spike** | 10203 | Time-boxed research activity | No | Standard |
| **Sub-task** | 10001 | Child task of another issue | Yes | Child |
| **Decision** | 10204 | Decision record (DECISION project) | No | Standard |
| **Goal** | 10202 | High-level goal (GOAL project) | No | Top-level |
| **Support** | 10101 | Service desk request (AGRHELP) | No | Standard |
| **Deliverable** | 10100 | Service desk deliverable | No | Standard |
| **Proposal** | 10200 | Ideas requiring team review | No | Standard |

---

## Issue Types by Project

### KANBAN
Task, Bug, Story, Epic, Feature, Sub-task, Spike

### SCRUM
Story, Task, Epic, Bug, Sub-task, Feature, Spike

### AGRHELP (Service Desk)
Deliverable, Support, Bug

### MOD
Task, Sub-task, Story, Bug, Epic

### DECISION
Decision

### GOAL
Goal, Epic, Story, Task, Bug

---

## Key Custom Fields

### Epic & Hierarchy

| Field ID | Name | Usage |
|----------|------|-------|
| customfield_10000 | Epic Link | Link issue to parent Epic |
| customfield_10002 | Epic Name | Display name for Epic |
| customfield_10102 | Parent Link | Hierarchy parent link |

### Estimation

| Field ID | Name | Usage |
|----------|------|-------|
| customfield_10012 | Story Points | Sprint estimation |
| customfield_10004 | Sprint | Sprint assignment |

### Alliance-Specific

| Field ID | Name | Usage |
|----------|------|-------|
| customfield_10628 | Triage Required? | Issue triage status |
| customfield_10629 | PI Priority | Program Increment priority |
| customfield_10719 | MOD | Model Organism Database |
| customfield_10646 | Working Group | Assigned working group |
| customfield_10624 | Team | Team assignment |
| customfield_10622 | Acceptance Criteria | Story acceptance criteria |
| customfield_10623 | Steps to Recreate | Bug reproduction steps |

---

## Creating Issues

### Task Example
```bash
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
        "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Description here"}]}]
      },
      "issuetype": {"id": "10000"},
      "priority": {"id": "3"}
    }
  }'
```

### Bug Example (with Steps to Recreate)
```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "KANBAN"},
      "summary": "Bug title here",
      "description": {...},
      "issuetype": {"id": "10004"},
      "priority": {"id": "2"},
      "customfield_10623": "1. Step one\n2. Step two\n3. Observe error"
    }
  }'
```

### Link to Epic
Add this field to link a ticket to an Epic:
```json
"customfield_10000": "KANBAN-XXX"
```

---

## Custom Field Value Formats

| Type | Format |
|------|--------|
| Select field | `{"id": "optionId"}` |
| Multi-select | `[{"id": "id1"}, {"id": "id2"}]` |
| User picker | `{"accountId": "account-id"}` |
| Date | `"2025-01-15"` |
| Text | `"plain text value"` |
