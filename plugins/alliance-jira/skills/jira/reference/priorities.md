# Alliance Jira Priorities & Resolutions Reference

## Priorities

| Priority | ID | Description | Color |
|----------|-----|-------------|-------|
| **Show Stopper** | 10000 | Must resolve before release | #ff0000 |
| **Highest** | 1 | Will block progress | #ff0000 |
| **High** | 2 | Serious, could block progress | #f15C75 |
| **Medium** | 3 | May affect progress (default) | #f79232 |
| **Low** | 4 | Minor, easily worked around | #009933 |
| **Lowest** | 5 | Trivial, little impact | #999999 |
| **Blocked** | 10001 | Blocked by something else | #ff0000 |
| **Unprioritized** | 10002 | Not yet prioritized | #bbbbbb |

---

## Setting Priority in API

```json
"priority": {"id": "3"}
```

Examples:
- Show Stopper: `{"id": "10000"}`
- Highest: `{"id": "1"}`
- High: `{"id": "2"}`
- Medium: `{"id": "3"}` (default)
- Low: `{"id": "4"}`
- Lowest: `{"id": "5"}`

---

## Resolutions

| Resolution | ID | Description |
|------------|-----|-------------|
| **Done** | 10000 | Work completed |
| **Won't Do** | 10001 | Will not be actioned |
| **Duplicate** | 10002 | Duplicate of existing issue |
| **Cannot Reproduce** | 10003 | Unable to reproduce issue |
| **As Designed** | 10100 | Working as intended |
| **Declined** | 10200 | Not approved |
| **Known Error** | 10201 | Documented with workaround |
| **Developer Ticket Opened** | 10204 | JSD → SW escalation |
| **Rejected / Spam** | 10205 | Invalid request |
| **No Customer Response** | 10206 | Customer did not respond |

---

## API Commands

### Get All Priorities
```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/priority" \
  -H "Accept: application/json"
```

### Get All Resolutions
```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/resolution" \
  -H "Accept: application/json"
```

---

## Common Priority Usage

| Scenario | Recommended Priority |
|----------|---------------------|
| Production is down | Show Stopper (10000) |
| Major feature broken | Highest (1) |
| Important bug | High (2) |
| Normal work | Medium (3) |
| Nice to have | Low (4) |
| Cosmetic issues | Lowest (5) |
