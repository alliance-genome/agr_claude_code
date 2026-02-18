---
name: linkml-review
description: Use when reviewing new or modified LinkML schema files (.yaml) in agr_curation_schema, or when proposing changes to Alliance of Genome Resources schema classes, slots, enums, or associations
argument-hint: describe the new additions to the curation schema
---

# LinkML Schema Reviewer

Expert review guide for the Alliance of Genome Resources LinkML schema (`agr_curation_schema`). Reviews changes for correctness, consistency, and convention compliance.

## MANDATORY: Version Check (Run on Skill Load)

> **CRITICAL: You MUST run this bash block when the skill is first loaded, before doing anything else.**

```bash
# Check for skill updates
PLUGIN_JSON=$(ls -t ~/.claude/plugins/cache/alliance-plugins/linkml-reviewer/*/.claude-plugin/plugin.json 2>/dev/null | head -1)
INSTALLED_VERSION=$(grep -o '"version": "[^"]*"' "$PLUGIN_JSON" 2>/dev/null | cut -d'"' -f4)
LATEST_VERSION=$(curl -sf --max-time 3 https://raw.githubusercontent.com/alliance-genome/agr_claude_code/main/plugins/linkml-reviewer/.claude-plugin/plugin.json 2>/dev/null | grep -o '"version": "[^"]*"' | cut -d'"' -f4)
if [ -z "$LATEST_VERSION" ]; then
  echo "Skill version: ${INSTALLED_VERSION} (could not check for updates)"
elif [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
  echo "*** UPDATE AVAILABLE *** Installed v${INSTALLED_VERSION}, latest v${LATEST_VERSION}"
  echo "Run: /plugin marketplace update alliance-plugins"
else
  echo "Skill version: ${INSTALLED_VERSION} (up to date)"
fi
```

> **Before reviewing**: Read the reference files in `reference/` for current schema inventory data (class counts, inheritance tree, import graph, DTO suffix mappings).

## Severity Levels

Every convention below is tagged:

| Tag | Meaning | Review Action |
|-----|---------|---------------|
| **ENFORCED** | Schema validates this; violations cause build failures | Flag as **error** |
| **ADVISORY** | Documented convention, not machine-enforced | Flag as **warning** |
| **TECH-DEBT** | Known issue in existing schema; flag only in **new** code | Flag as **info** |

## Schema Architecture

- **27 YAML files** in `model/schema/`, ~12,118 lines, 358 classes (38 abstract), 13 enums
- **Root**: `allianceModel.yaml` -- aggregates all sub-schemas via imports; has NO classes/slots/enums
- **Core**: `core.yaml` -- base classes, common slots (imported by 26/27 files)
- **Ingest**: `ingest.yaml` -- `Ingest` class (`tree_root: true`) with ~50 `*_ingest_set` slots
- **Import graph**: 16-file strongly connected component (intentionally interdependent)
- **Build**: `gen-json-schema --indent 4 --closed -t Ingest` **[ENFORCED]**
- **Tests**: `test/data/*.json` (32 valid) + `test/data/invalid/*.json` (4 invalid)

### Core Inheritance Chain

```
AuditedObject -> CurieObject -> SubmittedObject -> BiologicalEntity [abstract] -> GenomicEntity -> Gene, Allele, Variant, AGM...
```

Parallel DTO hierarchy: `AuditedObjectDTO -> SubmittedObjectDTO -> BiologicalEntityDTO [abstract] -> GenomicEntityDTO -> GeneDTO...`

See [inheritance-tree.md](reference/inheritance-tree.md) for the complete tree.

## Key Conventions

### Classes

| Convention | Status |
|-----------|--------|
| CamelCase names | ADVISORY |
| Must have `is_a` pointing to valid parent | ADVISORY |
| Must have meaningful `description` | ADVISORY |
| New YAML file -> add to `allianceModel.yaml` imports | ENFORCED |
| Abstract classes marked `abstract: true` | ENFORCED |
| New domain class -> add corresponding DTO class | ADVISORY |
| New entity type -> add `*_ingest_set` slot to `ingest.yaml` | ADVISORY |
| Test data added to `test/data/` | ADVISORY |

### Slots

| Convention | Status |
|-----------|--------|
| snake_case names | ADVISORY |
| Multivalued -> plural name; single-valued -> singular | ADVISORY |
| `range` set explicitly (don't rely on `default_range: string`) | ADVISORY |
| Entity-prefixed names (`gene_symbol`, `allele_full_name`) | ADVISORY |
| `slot_usage` for inheritance customization | ADVISORY |
| `internal` is `required: true` on AuditedObject | ENFORCED |
| For inlined DTOs: `inlined: true` + `inlined_as_list: true` | ADVISORY |

### DTO Suffix Conventions [ADVISORY]

| Non-DTO Range | DTO Suffix | Example |
|--------------|-----------|---------|
| OntologyTerm subclass (single) | `_curie` | `taxon` -> `taxon_curie` |
| Reference/Person (single) | `_curie` | `created_by` -> `created_by_curie` |
| Reference (multi) | `_curies` | `references` -> `reference_curies` |
| VocabularyTerm (single) | `_name` | `genetic_sex` -> `genetic_sex_name` |
| VocabularyTerm (multi) | `_names` | `disease_qualifiers` -> `disease_qualifier_names` |
| Entity (single) | `_identifier` | subject -> `gene_identifier` |
| Entity (multi) | `_identifiers` | -> `with_gene_identifiers` |
| Inlined DTO (single) | `_dto` | `data_provider` -> `data_provider_dto` |
| Inlined DTOs (multi) | `_dtos` | `cross_references` -> `cross_reference_dtos` |
| String/boolean/integer | same name | `is_extinct` -> `is_extinct` |

See [dto-suffix-reference.md](reference/dto-suffix-reference.md) for complete mapping.

### The Triad: Enum vs OntologyTerm vs VocabularyTerm

| Type | When to Use | Examples |
|------|------------|---------|
| **Enum** | Small, stable, technical/system values that will NOT change | `strand_enum`, `pubmed_publication_status_enum` |
| **OntologyTerm** | Externally maintained ontology terms | `SOTerm`, `DOTerm`, `GOTerm`, `ZECOTerm` |
| **VocabularyTerm** | Alliance-curated biological/curation values | `genetic_sex`, `disease_qualifiers`, note types |

> **Rule**: Biological/curation values MUST use VocabularyTerms, not enums. **[ADVISORY]**

> **Note**: CV names are documented in comments only (`# CV 'Genetic Sex'`), not enforced by schema. **[ADVISORY]**

### Associations

| Convention | Status |
|-----------|--------|
| Inherit from `Association`, `SingleReferenceAssociation`, or `EvidenceAssociation` | ADVISORY |
| `relation` slot present and constrained via `slot_usage` | ADVISORY |
| Entity-prefixed subject/object names (NOT generic `subject`/`object`) | ADVISORY |
| Corresponding AssociationDTO class for ingest | ADVISORY |

### Ingest

| Convention | Status |
|-----------|--------|
| `Ingest` is sole `tree_root: true` class | ENFORCED |
| All `*_ingest_set` slots use `mixins: [object_set]` | ENFORCED |
| Ingest set `range` is a DTO class | ADVISORY |

### Schema File Boilerplate [ADVISORY]

Every schema file should include:

```yaml
default_prefix: alliance
default_range: string
default_curi_maps:
  - obo_context
  - idot_context
  - semweb_context
  - monarch_context
emit_prefixes:
  - rdf
  - rdfs
  - xsd
```

Check consistency with existing files.

## Reviewer Checklist

### Class Changes

- [ ] `is_a` points to valid parent? [ADVISORY]
- [ ] CamelCase name? [ADVISORY]
- [ ] `abstract: true` if abstract? [ENFORCED]
- [ ] New YAML file imported in `allianceModel.yaml`? [ENFORCED]
- [ ] Has meaningful `description` (not "Dummy" or placeholder)? [ADVISORY]
- [ ] Correct parent in hierarchy? [ADVISORY]
- [ ] Corresponding DTO class added? [ADVISORY]
- [ ] `*_ingest_set` slot added to `ingest.yaml`? [ADVISORY]
- [ ] Test data added to `test/data/`? [ADVISORY]

### Slot Changes

- [ ] snake_case name? [ADVISORY]
- [ ] `multivalued` set? Plural if multivalued, singular if not? [ADVISORY]
- [ ] `range` set explicitly? [ADVISORY]
- [ ] `required` set where needed? [ADVISORY]
- [ ] For inlined DTOs: `inlined: true` and `inlined_as_list: true`? [ADVISORY]
- [ ] Entity prefix where appropriate? [ADVISORY]
- [ ] Corresponding DTO slot with correct suffix? [ADVISORY]

### Association Changes

- [ ] Inherits from correct Association base? [ADVISORY]
- [ ] `relation` slot present and constrained? [ADVISORY]
- [ ] Entity-prefixed subject/object names? [ADVISORY]
- [ ] Corresponding AssociationDTO class? [ADVISORY]

### Vocabulary / Ontology / Enum Usage

- [ ] Biological values use VocabularyTerm (not enum)? [ADVISORY]
- [ ] Specific OntologyTerm subclass (not generic `OntologyTerm`)? [ADVISORY]
- [ ] CV name documented in comment? [ADVISORY]
- [ ] DTO uses correct suffix (`_name`/`_curie`)? [ADVISORY]

### Ingest / DTO Changes

- [ ] `*_ingest_set` uses `mixins: [object_set]`? [ENFORCED]
- [ ] DTO suffix convention followed? [ADVISORY]
- [ ] `internal` explicitly required at every nesting level? [ENFORCED]

### Schema Infrastructure

- [ ] `default_prefix`, `default_range`, `default_curi_maps` present? [ADVISORY]
- [ ] File imports all schemas it references? [ENFORCED]
- [ ] Test JSON includes `"linkml_version": "2.0.0"`? [ADVISORY]
- [ ] Test passes `gen-json-schema --closed` validation? [ENFORCED]

## Common Mistakes

| Mistake | Why It Matters |
|---------|---------------|
| Adding slot to class but not to corresponding DTO | Ingest will miss the field |
| Using `range: OntologyTerm` instead of specific subclass (`SOTerm`) | Loses type safety |
| Forgetting `*_ingest_set` slot in both `slots:` section AND `Ingest` class | Ingest won't include the data |
| Using enum for values that should be VocabularyTerms | Enums can't be managed at runtime |
| Missing `internal: required: true` when overriding AuditedObject | Breaks validation |
| Wrong DTO suffix convention | Inconsistent ingest API |
| `multivalued: true` with singular name (or vice versa) | Confusing API surface |
| Association without entity-prefixed subject/object names | Breaks persistence conventions |
| Missing `inlined: true` + `inlined_as_list: true` for inlined DTO collections | JSON Schema won't inline correctly |
| New YAML file not added to `allianceModel.yaml` imports | File is invisible to build |
| Inconsistent prefix declarations vs other schema files | Subtle resolution bugs |

## Known Anti-Patterns

### Critical [TECH-DEBT]

- **`internal` required but no `ifabsent` default**: Every ingest object at every depth must explicitly set `"internal": false/true`. The `notes` say "Default value is true" but this is documentation only.
- **16-file circular import SCC**: LinkML resolves it, but cross-module implications are hard to reason about. Avoid introducing new cycles unless necessary.

### Important

- **CV names are comments only** [ADVISORY]: `# CV 'Genetic Sex'` has no technical enforcement.
- **`domain` constraints are documentation only** [ADVISORY]: A slot with `domain: Gene` can still be used elsewhere.
- **DTO classes can intentionally diverge from non-DTO** [ADVISORY]: Check README for documented exceptions.
- **`evidence` vs `evidence_item` near-duplication** [TECH-DEBT]: Difference is multivalued vs single-valued; naming doesn't make this obvious.
- **`AnatomicalSiteDTO` inherits from `AuditedObject` not `AuditedObjectDTO`** [TECH-DEBT]: Diverges from standard DTO pattern.

### Minor [TECH-DEBT]

- Boilerplate duplication across files (some inconsistencies in `emit_prefixes`)
- Missing/placeholder descriptions ("Dummy cell line class", empty descriptions)
- Commented-out code in several files
- `interactor_A/B_*` naming breaks snake_case
- No `ifabsent` defaults used anywhere
- Legacy IDs and metadata inconsistencies (e.g., `curationReport.yaml` ID mismatch)

## Reference Files

| File | Contents |
|------|----------|
| [schema-inventory.md](reference/schema-inventory.md) | File inventory with class/slot/enum counts |
| [inheritance-tree.md](reference/inheritance-tree.md) | Complete class hierarchy with source files |
| [import-graph.md](reference/import-graph.md) | Mermaid import dependency graph |
| [dto-suffix-reference.md](reference/dto-suffix-reference.md) | Complete slot-to-DTO suffix mappings |
