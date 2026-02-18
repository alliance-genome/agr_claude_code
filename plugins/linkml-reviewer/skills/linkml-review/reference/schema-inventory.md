# Schema Inventory

File inventory for `agr_curation_schema/model/schema/` with class, slot, and enum counts per file.

**Total**: 27 files, 358 classes, 13 enums, ~12,118 lines

| File | Classes | Slots | Enums | Domain |
|------|--------:|------:|------:|--------|
| affectedGenomicModel.yaml | 12 | 20 | 1 | AGMs |
| agent.yaml | 6 | 9 | 0 | People/Orgs |
| allele.yaml | 51 | 74 | 0 | Alleles |
| allianceMember.yaml | 1 | 1 | 0 | Alliance members |
| allianceModel.yaml | 0 | 0 | 0 | Root aggregator |
| biologicalEntitySet.yaml | 9 | 10 | 0 | Entity sets |
| bulkload.yaml | 8 | 27 | 4 | Bulk loading |
| controlledVocabulary.yaml | 3 | 5 | 0 | Vocabularies |
| core.yaml | 56 | 127 | 1 | Foundation |
| curationReport.yaml | 3 | 10 | 0 | Reports |
| expression.yaml | 11 | 43 | 0 | Expression |
| gene.yaml | 13 | 47 | 0 | Genes |
| geneInteraction.yaml | 8 | 28 | 0 | Interactions |
| highThroughputExpression.yaml | 15 | 39 | 3 | HTP expression |
| homology.yaml | 4 | 14 | 0 | Orthology/Paralogy |
| image.yaml | 4 | 16 | 0 | Images |
| ingest.yaml | 1 | 53 | 0 | Data loading |
| modCorpusAssociation.yaml | 1 | 3 | 1 | MOD corpus |
| ontologyTerm.yaml | 54 | 16 | 0 | Ontology terms |
| phenotypeAndDiseaseAnnotation.yaml | 22 | 53 | 0 | Annotations |
| reagent.yaml | 42 | 57 | 0 | Reagents |
| reference.yaml | 6 | 32 | 3 | Publications |
| resource.yaml | 1 | 8 | 0 | Resources |
| resourceDescriptor.yaml | 2 | 6 | 0 | URL templates |
| variantConsequence.yaml | 1 | 0 | 0 | VEP predictions |
| variantDTO.yaml | 12 | 10 | 0 | Variant ingest |
| variation.yaml | 12 | 31 | 0 | Variants |

## Enum Inventory

| Enum Name | File | Values |
|-----------|------|-------:|
| strand_enum | core.yaml | 4 |
| subtype_values | affectedGenomicModel.yaml | 3 |
| pubmed_publication_status_enum | reference.yaml | 3 |
| pubmed_type_enum | reference.yaml | 79 |
| reference_category_enum | reference.yaml | 12 |
| sample_type_values | highThroughputExpression.yaml | 8 |
| sequencing_format_values | highThroughputExpression.yaml | 2 |
| high_throughput_expression_assay_values | highThroughputExpression.yaml | 8 |
| bulk_load_status_enum | bulkload.yaml | 10 |
| backend_bulk_load_type_enum | bulkload.yaml | 10 |
| ontology_bulk_load_type_enum | bulkload.yaml | 13 |
| backend_bulk_data_type_enum | bulkload.yaml | 7 |
| mod_corpus_sort_source_enum | modCorpusAssociation.yaml | 4 |

## Key Files

| Purpose | File Path |
|---------|-----------|
| Root schema | `model/schema/allianceModel.yaml` |
| Core base classes | `model/schema/core.yaml` |
| Ingest definition | `model/schema/ingest.yaml` |
| Generated JSON Schema | `generated/jsonschema/allianceModel.schema.json` |
| Build system | `Makefile` |
| Valid test data | `test/data/*.json` (32 files) |
| Invalid test data | `test/data/invalid/*.json` (4 files) |
