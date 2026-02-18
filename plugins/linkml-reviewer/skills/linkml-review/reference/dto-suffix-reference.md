# DTO Suffix Reference

Complete mapping of non-DTO ranges to their DTO slot suffix conventions.

## Suffix Pattern Summary

| Suffix | Count | Purpose |
|--------|------:|---------|
| `_curie` | 50 | Ontology term or entity curie reference |
| `_dto` | 29 | Single inlined DTO object |
| `_identifier` | 27 | Entity identifier string |
| `_dtos` | 22 | Multiple inlined DTO objects |
| `_curies` | 13 | Multiple curie references |
| `_identifiers` | 7 | Multiple entity identifiers |
| `_ingest_set` | 50 | Ingest envelope array |
| `_name` | varies | VocabularyTerm name string |
| `_names` | varies | Multiple VocabularyTerm name strings |

## Complete Mapping Table

| Non-DTO Range | DTO Suffix | Example Non-DTO Slot | Example DTO Slot |
|---------------|-----------|---------------------|-----------------|
| Person (single) | `_curie` | created_by | created_by_curie |
| Person (single) | `_curie` | updated_by | updated_by_curie |
| Reference (single) | `_curie` | single_reference | reference_curie |
| Reference (multi) | `_curies` | references | reference_curies |
| ECOTerm (multi) | `_curies` | evidence_codes | evidence_code_curies |
| VocabularyTerm (single) | `_name` | genetic_sex | genetic_sex_name |
| VocabularyTerm (single) | `_name` | annotation_type | annotation_type_name |
| VocabularyTerm (single) | `_name` | relation | relation_name |
| VocabularyTerm (multi) | `_names` | disease_qualifiers | disease_qualifier_names |
| DOTerm (single) | `_curie` | disease_annotation_object | do_term_curie |
| SOTerm (single) | `_curie` | variant_type | variant_type_curie |
| NCBITaxonTerm (single) | `_curie` | taxon | taxon_curie |
| ZECOTerm (single) | `_curie` | condition_class | condition_class_curie |
| GOTerm (single) | `_curie` | (ontology reference) | go_term_curie |
| Gene (single) | `_identifier` | (association subject) | gene_identifier |
| Allele (single) | `_identifier` | (association subject) | allele_identifier |
| AffectedGenomicModel (single) | `_identifier` | (association subject) | agm_identifier |
| Gene (multi) | `_identifiers` | with_or_from | with_gene_identifiers |
| NoteDTO (multi) | `_dtos` | related_notes | note_dtos |
| DataProviderDTO (single) | `_dto` | data_provider | data_provider_dto |
| CrossReferenceDTO (multi) | `_dtos` | cross_references | cross_reference_dtos |
| NameSlotAnnotationDTO (single) | `_dto` | gene_symbol | gene_symbol_dto |
| NameSlotAnnotationDTO (multi) | `_dtos` | gene_synonyms | gene_synonym_dtos |
| ConditionRelationDTO (multi) | `_dtos` | condition_relations | condition_relation_dtos |
| ExperimentalConditionDTO (multi) | `_dtos` | conditions | condition_dtos |
| String/boolean/integer | (same name) | is_extinct | is_extinct |
| String/boolean/integer | (same name) | internal | internal |
| String/boolean/integer | (same name) | date_created | date_created |

## Audit Backbone Mapping

The AuditedObject/AuditedObjectDTO mapping is used by all classes:

| AuditedObject Slot | AuditedObjectDTO Slot | Purpose |
|-------------------|----------------------|---------|
| created_by | created_by_curie | Who created |
| updated_by | updated_by_curie | Who last updated |
| date_created | date_created | Creation timestamp |
| date_updated | date_updated | Update timestamp |
| db_date_created | db_date_created | DB creation timestamp |
| db_date_updated | db_date_updated | DB update timestamp |
| internal | internal | Private/public flag (required) |
| obsolete | obsolete | Deprecation flag |
