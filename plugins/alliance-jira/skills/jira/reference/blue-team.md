# Blue Team Workflow Reference

The Blue Team uses the SCRUM project with specific workflow conventions that differ from standard Jira practices.

## Board Information

| Property | Value |
|----------|-------|
| Board ID | 65 |
| Project | SCRUM |
| Sprint Naming | `Blue-Team Release X Sprint Y` or `Blue Team Release X Sprint Y` |

---

## Status Workflow

### Status Flow (Blue Team)
```
To Do → Ready for Work → In Progress → Ready for UAT → Ready for Prod → PO Review → Done
```

### Status Meanings

| Status | ID | Transition ID | Blue Team Meaning |
|--------|----|--------------|--------------------|
| **To Do** | 10000 | 11 | Ticket exists but not yet refined |
| **Ready for Work** | 10320 | 91 | **Backlog refined and truly ready to start.** For Spikes: meeting has been scheduled |
| **In Progress** | 3 | 21 | Developer actively working on the ticket |
| **Ready for UAT** | 10313 | 51 | **Waiting for curators and testers to test the feature/story** |
| **Ready for Prod** | 10318 | 61 | Tested and approved, awaiting production deployment |
| **PO Review** | 10312 | 41 | **For PO to test on production environment** |
| **Done** | 10305 | 31 | Complete and verified |

### Important Status Notes

- **"Ready for Work" is NOT the same as "To Do"**: Ready for Work means the ticket has been backlog refined during sprint planning and has clear requirements
- **Spikes in "Ready for Work"**: Indicates a meeting has been scheduled to discuss the topic
- **"Ready for UAT"**: The developer's work is complete; now awaiting curator/tester validation
- **"PO Review"**: This happens AFTER production deployment - the PO tests the feature in the live environment

### Deprecated Statuses (Not Used by Blue Team)

| Status | ID | Note |
|--------|-----|------|
| ~~Being Built~~ | 10319 | Not used - use "In Progress" instead |
| ~~Code Review~~ | 10314 | Not used - PRs are handled outside Jira workflow |

---

## Issue Types

| Type | ID | Common Use |
|------|-----|------------|
| Story | 10003 | User-facing features, larger work items |
| Task | 10000 | Technical work, smaller items |
| Bug | 10004 | Defects and issues |
| Spike | 10203 | **Research/discussion tickets - often involve scheduling meetings** |
| Feature | 10005 | Major new functionality |
| Sub-task | 10001 | Child tasks under a parent |
| Epic | 10002 | Large initiatives spanning multiple sprints |

### Spike Ticket Patterns

Spikes often follow naming patterns:
- "Discuss [topic]" - e.g., "Discuss library access for synonym types"
- "Figure out [topic]" - e.g., "Figure out how to integrate Gene Descriptions"
- "Explore [topic]" - e.g., "Explore converting excel and doc files into TEI"
- "Investigate [topic]" - e.g., "Investigate how to manage genes with multiple sources"

When a Spike moves to "Ready for Work", it typically means a meeting has been scheduled.

---

## Story Points

The Blue Team uses the **Fibonacci scale** for story point estimation.

### Point Scale Reference

| Points | Meaning | Typical Scope |
|--------|---------|---------------|
| **1** | Very easy | Trivial change, minimal effort |
| **2** | Easy | Small, well-understood task |
| **3** | Small | Straightforward work, minor complexity |
| **5** | Medium | Moderate complexity, may have some unknowns |
| **8** | Large | Significant work, multiple components |
| **13** | Very large | Complex work, spans multiple days |
| **21** | Half to full sprint | Major feature for a single developer |
| **34** | 1-2 sprints | Large initiative, significant effort |
| **>34** | Needs splitting | Too large - must be broken down during refinement |

### Estimation Guidelines

- **1-13 points**: Suitable for individual stories/tasks in a sprint
- **21 points**: Usually represents half a sprint to a full sprint of work for a single developer
- **34 points**: A lot of work but still achievable in 1-2 sprints
- **>34 points**: Used only for high-level release planning; must be split into smaller stories/tasks during backlog refinement

### When Estimating

- Points represent **relative complexity**, not hours
- Consider: code changes, testing, documentation, dependencies
- If unsure, discuss with the team during refinement
- Spikes typically don't get points (they're time-boxed research)

---

## Common JQL Queries

### Current Sprint Tickets
```jql
project = SCRUM AND sprint in openSprints() ORDER BY priority ASC
```

### Using Board Sprint Endpoint (More Reliable)
```bash
# Get active sprint for Blue Team board
source ~/.alliance/jira/.env
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/agile/1.0/board/65/sprint?state=active" \
  -H "Accept: application/json"

# Get sprint issues (replace SPRINT_ID)
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/agile/1.0/sprint/{SPRINT_ID}/issue" \
  -H "Accept: application/json"
```

### Tickets Awaiting Tester Review
```jql
project = SCRUM AND status = "Ready for UAT" ORDER BY updated DESC
```

### Tickets Ready for PO Review on Prod
```jql
project = SCRUM AND status = "PO Review" ORDER BY updated DESC
```

### Open Spikes (Meetings to Schedule)
```jql
project = SCRUM AND issuetype = Spike AND status != Done ORDER BY updated DESC
```

### Backlog (Refined and Ready)
```jql
project = SCRUM AND status = "Ready for Work" ORDER BY priority ASC
```

---

## Domain Knowledge

### Model Organism Databases (MODs)

| Abbreviation | Full Name | Notes |
|--------------|-----------|-------|
| WB | WormBase | C. elegans |
| FB | FlyBase | Drosophila |
| MGI | Mouse Genome Informatics | Mouse |
| SGD | Saccharomyces Genome Database | Yeast |
| RGD | Rat Genome Database | Rat |
| ZFIN | Zebrafish Information Network | Zebrafish |
| XB | Xenbase | Xenopus (frog) |

### Key Systems/Components

| Term | Meaning |
|------|---------|
| ABC | Alliance Bibliographic Central - the literature management system |
| A-Team | Alliance Team - maintains persistent store/curation system |
| DQM | Data Quality Management - MOD data ingestion pipeline |
| TEI | Text Encoding Initiative - PDF text extraction format |
| TET | Topic Entity Tags - classification tags for papers |
| GROBID | PDF parsing library for extracting structured text |

### Common Ticket Themes

- **Tag loading/transfer**: Moving curation tags from MODs to ABC
- **Entity extraction**: Extracting genes, alleles, etc. from paper text
- **Classifiers**: ML models for paper classification
- **Gene descriptions**: Automated gene summary generation
- **Workflow tags**: Curation workflow status management

---

## Relevant Components

| Component | ID | Description |
|-----------|-----|-------------|
| Literature Acq | 10730 | Literature acquisition and processing |
| DQM | 10741 | Data Quality Management |
| GeneDescr | 10736 | Gene descriptions |
| Search | 10720 | Search functionality |
| A-Team work for Blue Team | 10801 | Cross-team dependencies |

---

## Sprint Goal Generation

When generating sprint goals from Blue Team tickets, look for:

1. **Themes by MOD**: Group work by organism database (WB, FB, SGD, etc.)
2. **Pipeline work**: Data loading, processing, transfer scripts
3. **Infrastructure**: API changes, database cleanup, search improvements
4. **Cross-team work**: A-Team dependencies, unified library integration
5. **Bug fixes**: Data quality issues, ORCID/identifier problems

**Good sprint goal format:**
> "[Major feature/initiative]; [secondary work area]; [data quality/cleanup work]"

**Example:**
> "Enable WB and FB tag data loading; integrate gene descriptions with unified library pipeline; improve search with data novelty filtering and clean up resource records"

---

## Workflow Transition Examples

### Move ticket to In Progress
```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/SCRUM-XXXX/transitions" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "21"}}'
```

### Move ticket to Ready for UAT (after code complete)
```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/SCRUM-XXXX/transitions" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "51"}}'
```

### Move ticket to Done (with resolution)
```bash
source ~/.alliance/jira/.env
curl -s -X POST -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/issue/SCRUM-XXXX/transitions" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "31"}, "fields": {"resolution": {"name": "Done"}}}'
```

---

## Safety Rules for Blue Team

1. **Only transition your own assigned tickets** unless explicitly requested
2. **Don't close Spikes without checking** - they may have follow-up action items
3. **Ready for UAT requires tested code** - don't transition without working implementation
4. **PO Review is post-production** - only use after deployment to prod
