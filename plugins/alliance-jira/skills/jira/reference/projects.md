# Alliance Jira Projects & Boards Reference

## Projects

| Key | Name | ID | Type |
|-----|------|----|------|
| **KANBAN** | Alliance Kanban | 10109 | software |
| **SCRUM** | Alliance Scrum | 10108 | software |
| **AGRHELP** | Alliance Help Desk | 10104 | service_desk |
| **AGR** | Alliance Software | 10004 | software |
| **MOD** | MOD Transition | 10112 | software |
| **GOAL** | Goals | 10106 | software |
| **DECISION** | Alliance Decision | 10110 | software |
| **TSP** | Test Scrum Project | 10107 | software |
| **TESTHELP** | TESTHELP | 10105 | service_desk |

---

## Boards by Project

### Alliance Kanban (KANBAN)

| Board | ID | Type | Description |
|-------|----|------|-------------|
| **Main Board** | 61 | Kanban | Primary development board |
| **AI Curation** | 169 | Kanban | AI Curation component work |
| **UI Board** | 67 | Kanban | User interface work |
| **AI/ML WG Board** | 68 | Kanban | AI/ML Working Group |
| **BLAST** | 70 | Kanban | BLAST-related tickets |
| **PAVI** | 69 | Kanban | PAVI component |
| **Gene Summaries** | 103 | Kanban | LLM-based gene summaries |

### Alliance Scrum (SCRUM)

| Board | ID | Type | Description |
|-------|----|------|-------------|
| **A-Team Board** | 66 | Scrum | A-Team sprint work |
| **Blue Team Board** | 65 | Scrum | Blue Team sprint work |
| **Unassigned Board** | 60 | Scrum | Unassigned tickets |

### MOD Transition (MOD)

| Board | ID | Type | MOD |
|-------|----|------|-----|
| WormBase | 136 | Kanban | WormBase migration |
| FlyBase | 137 | Kanban | FlyBase migration |
| GOC | 138 | Kanban | Gene Ontology Consortium |
| MGD | 139 | Kanban | Mouse Genome Database |
| RGD | 140 | Kanban | Rat Genome Database |
| SGD | 141 | Kanban | Saccharomyces Genome Database |
| Xenbase | 142 | Kanban | Xenbase migration |
| ZFIN | 143 | Kanban | Zebrafish Information Network |

### Other Projects

| Board | ID | Type | Project |
|-------|----|------|---------|
| DECISION | 63 | Kanban | DECISION |
| AIMS | 53 | Scrum | GOAL |
| DQM Component Tagged | 12 | Scrum | (filter-based) |

---

## API Commands

### List All Projects
```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/project" \
  -H "Accept: application/json"
```

### Get Issues on a Board
```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/agile/1.0/board/{boardId}/issue?maxResults=50" \
  -H "Accept: application/json"
```

### Get Board Configuration
```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/agile/1.0/board/{boardId}/configuration" \
  -H "Accept: application/json"
```

### Get Active Sprints (Scrum boards only)
```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/agile/1.0/board/{boardId}/sprint?state=active" \
  -H "Accept: application/json"
```

---

## Quick Board ID Reference

```
KANBAN Project:
  61  - Main Board
  67  - UI Board
  68  - AI/ML WG Board
  69  - PAVI
  70  - BLAST
  103 - Gene Summaries (LLM-based)
  169 - AI Curation

SCRUM Project:
  60  - Unassigned Board
  65  - Blue Team Board
  66  - A-Team Board

MOD Project:
  136 - WormBase
  137 - FlyBase
  138 - GOC
  139 - MGD
  140 - RGD
  141 - SGD
  142 - Xenbase
  143 - ZFIN
```
