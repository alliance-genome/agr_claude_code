# Alliance Jira Statuses & Transitions Reference

## KANBAN Project Statuses

| Status | ID | Category | Description |
|--------|----|----------|-------------|
| **Backlog** | 10308 | To Do | Not yet scheduled |
| **To Do** | 10000 | To Do | Ready to work on |
| **In Progress** | 3 | In Progress | Actively being worked |
| **Ready for UAT** | 10313 | In Progress | Awaiting user testing |
| **Release** | 10321 | In Progress | Ready for release |
| **Done** | 10305 | Done | Work completed |

---

## KANBAN Transition IDs

**All transitions are global** - any ticket can move to any status.

| To Move To | Transition ID |
|------------|---------------|
| **Backlog** | 41 |
| **To Do** | 11 |
| **In Progress** | 21 |
| **Ready for UAT** | 51 |
| **Release** | 2 |
| **Done** | 31 |

**Note:** Done transition (31) has a screen - may prompt for resolution.

---

## SCRUM Project Statuses

| Status | ID | Category |
|--------|----|----------|
| To Do | 10000 | To Do |
| Ready for Work | 10320 | To Do |
| In Progress | 3 | In Progress |
| Code Review | 10314 | In Progress |
| Being Built | 10319 | In Progress |
| Ready for UAT | 10313 | In Progress |
| Ready for Prod | 10318 | In Progress |
| PO Review | 10312 | In Progress |
| Done | 10305 | Done |

---

## Status Categories

| Category | ID | Color | Meaning |
|----------|-----|-------|---------|
| To Do | 2 | blue-gray | Work not started |
| In Progress | 4 | yellow | Work in progress |
| Done | 3 | green | Work completed |

---

## Transition Commands

### Get Available Transitions for a Ticket
```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/{ticketKey}/transitions" \
  -H "Accept: application/json"
```

### Move Ticket to In Progress
```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/{ticketKey}/transitions" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "21"}}'
```

### Move Ticket to Done
```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/{ticketKey}/transitions" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "31"}}'
```

### Move Ticket to Backlog
```bash
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/{ticketKey}/transitions" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "41"}}'
```

---

## Common Workflow Patterns

### Start Working on a Ticket
1. GET ticket to verify you're the assignee
2. Transition to "In Progress" (ID: 21)

### Complete a Ticket
1. Transition to "Ready for UAT" (ID: 51) if needs testing
2. Or directly to "Done" (ID: 31) if no UAT needed

### Send Back to Backlog
1. Transition to "Backlog" (ID: 41)

---

## All Status IDs (Cross-Project)

| Status | ID |
|--------|----|
| Open | 1 |
| In Progress | 3 |
| Reopened | 4 |
| Complete | 5 |
| Closed | 6 |
| To Do | 10000 |
| Resolved | 10001 |
| Ready To Test | 10003 |
| Need Requirements | 10100 |
| Waiting for Developer | 10102 |
| Waiting for customer | 10103 |
| Pending MOD / WG Feedback | 10104 |
| Ready to Build | 10300 |
| To Discuss | 10303 |
| Done | 10305 |
| Backlog | 10308 |
| Information Gathering | 10309 |
| New | 10310 |
| PO Review | 10312 |
| Ready for UAT | 10313 |
| Code Review | 10314 |
| Ready to Decide | 10315 |
| Requested | 10316 |
| Selected for Development | 10317 |
| Ready for Prod | 10318 |
| Being Built | 10319 |
| Ready for Work | 10320 |
| Release | 10321 |
