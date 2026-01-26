# Alliance Jira Components Reference

## KANBAN Project Components

| Component | ID | Lead |
|-----------|-----|------|
| AI Curation | 10871 | Christopher Tabone |
| AllianceMine | 10785 | |
| API | 10784 | |
| Architecture | 10783 | |
| Basic Gene Info (BGI) | 10782 | |
| BioSchemas | 10781 | |
| BLAST | 10793 | Pravija Krishna |
| DevOps | 10780 | |
| DIOPT | 10779 | |
| Disease | 10778 | |
| DQM | 10777 | |
| Expression | 10776 | |
| Expression - LTP | 10775 | |
| GeneDescr | 10772 | |
| Genome Features | 10771 | |
| Harmonization | 10797 | |
| Interactions | 10768 | |
| JBrowse | 10794 | Scott Cain |
| LinkML | 10792 | Sierra Moxon |
| Literature Acq | 10766 | |
| Loader | 10765 | |
| MOD-Migration | 10764 | |
| Monitoring | 10795 | |
| Orthology | 10761 | |
| Pathways | 10760 | |
| PersistentStore | 10759 | |
| Product/PAVI | 10802 | Manuel Luypaert |
| Reports / Files | 10758 | |
| Ribbons | 10757 | |
| Search | 10756 | |
| Textpresso | 10838 | |
| UI | 10755 | |
| User Exp (UX) | 10754 | |
| User Support | 10753 | |
| Variants | 10752 | |
| WordPress | 10750 | |
| Xenbase onboarding | 10791 | |

---

## SCRUM Project Components

| Component | ID | Lead |
|-----------|-----|------|
| A-Team Data Loading | 10799 | |
| A-Team Deployments | 10790 | Chris Grove |
| A-Team LinkML | 10798 | Mark Quinton-Tulloch |
| A-Team work for Blue Team | 10801 | |
| AllianceMine | 10749 | |
| API | 10748 | |
| API Changes | 10805 | |
| Architecture | 10747 | |
| Curation | 10787 | |
| DevOps | 10744 | |
| Phenotype | 10803 | |
| Public Website | 10789 | |
| Search | 10720 | |
| Support | 10788 | |
| Swagger | 10804 | |
| UI | 10715 | |

---

## AGRHELP Components (Service Desk)

| Component | ID | Lead |
|-----------|-----|------|
| API | 10683 | Sian Gramates |
| Data Problem | 10654 | Sian Gramates |
| Data Request | 10656 | Sian Gramates |
| Disease | 10661 | Sian Gramates |
| Documentation | 10690 | Sian Gramates |
| Expression | 10660 | Sian Gramates |
| FlyBase | 10650 | Sian Gramates |
| General | 10663 | Sian Gramates |
| GO | 10651 | Sian Gramates |
| MGI | 10653 | Sian Gramates |
| Ontology | 10658 | Sian Gramates |
| Orthology | 10657 | Sian Gramates |
| Phenotype | 10659 | Sian Gramates |
| RGD | 10652 | Sian Gramates |
| SGD | 10647 | Sian Gramates |
| Site Functionality | 10655 | Sian Gramates |
| Variants | 10662 | Sian Gramates |
| WormBase | 10649 | Sian Gramates |
| ZFIN | 10648 | Sian Gramates |

---

## GOAL Project Components

| Component | ID |
|-----------|-----|
| Aim 1A - Data ingest | 10696 |
| Aim 1B - Harmonization | 10697 |
| Aim 1C - Literature curation | 10698 |
| Aim 2A - Cloud | 10699 |
| Aim 2B - API | 10700 |
| Aim 2C - Search | 10701 |
| Aim 2D - Downloads | 10702 |
| Aim 2E - JBrowse | 10703 |
| Aim 2F - InterMine | 10704 |
| Aim 3A - Portal | 10705 |
| Aim 3B - Applications | 10706 |
| Aim 4B - User Engagement | 10707 |

---

## Adding Components to Tickets

### By ID (preferred)
```json
"components": [{"id": "10871"}]
```

### By Name
```json
"components": [{"name": "AI Curation"}]
```

### Multiple Components
```json
"components": [{"id": "10871"}, {"id": "10755"}]
```

---

## API Commands

### Get Components for a Project
```bash
curl -s -u "${JIRA_EMAIL}:${JIRA_API_KEY}" \
  "https://agr-jira.atlassian.net/rest/api/3/project/{projectId}/components" \
  -H "Accept: application/json"
```

**Project IDs:**
- KANBAN: 10109
- SCRUM: 10108
- AGRHELP: 10104
- AGR: 10004
- GOAL: 10106
