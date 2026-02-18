#!/usr/bin/env python3
"""Generate LinkML reviewer reference files from Alliance curation schema YAML.

Usage: python update-schema-inventory.py <schema-dir> <output-dir>

Reads all *.yaml files from <schema-dir> and generates four reference files
in <output-dir> for the linkml-reviewer skill:

  - schema-inventory.md    (file/class/slot/enum counts)
  - inheritance-tree.md    (complete class hierarchy)
  - import-graph.md        (Mermaid import diagram + SCC analysis)
  - dto-suffix-reference.md (DTO slot suffix conventions)

Dependencies: PyYAML only (no LinkML library needed).
"""

import sys
import os
from pathlib import Path
from collections import defaultdict

import yaml


# ─── Static Configuration ───────────────────────────────────────────────────

DOMAIN_LOOKUP = {
    'affectedGenomicModel.yaml': 'AGMs',
    'agent.yaml': 'People/Orgs',
    'allele.yaml': 'Alleles',
    'allianceMember.yaml': 'Alliance members',
    'allianceModel.yaml': 'Root aggregator',
    'biologicalEntitySet.yaml': 'Entity sets',
    'bulkload.yaml': 'Bulk loading',
    'controlledVocabulary.yaml': 'Vocabularies',
    'core.yaml': 'Foundation',
    'curationReport.yaml': 'Reports',
    'expression.yaml': 'Expression',
    'gene.yaml': 'Genes',
    'geneInteraction.yaml': 'Interactions',
    'highThroughputExpression.yaml': 'HTP expression',
    'homology.yaml': 'Orthology/Paralogy',
    'image.yaml': 'Images',
    'ingest.yaml': 'Data loading',
    'modCorpusAssociation.yaml': 'MOD corpus',
    'ontologyTerm.yaml': 'Ontology terms',
    'phenotypeAndDiseaseAnnotation.yaml': 'Annotations',
    'reagent.yaml': 'Reagents',
    'reference.yaml': 'Publications',
    'resource.yaml': 'Resources',
    'resourceDescriptor.yaml': 'URL templates',
    'variantConsequence.yaml': 'VEP predictions',
    'variantDTO.yaml': 'Variant ingest',
    'variation.yaml': 'Variants',
}

# DTO suffix patterns to scan for in slot names
DTO_SUFFIXES = [
    '_curie', '_dto', '_dtos', '_identifier', '_identifiers',
    '_curies', '_ingest_set', '_name', '_names',
]

# Display order for suffix summary table (matches hand-written reference)
SUFFIX_DISPLAY_ORDER = [
    '_curie', '_dto', '_identifier', '_dtos', '_curies',
    '_identifiers', '_ingest_set', '_name', '_names',
]

SUFFIX_PURPOSES = {
    '_curie': 'Ontology term or entity curie reference',
    '_dto': 'Single inlined DTO object',
    '_dtos': 'Multiple inlined DTO objects',
    '_identifier': 'Entity identifier string',
    '_identifiers': 'Multiple entity identifiers',
    '_curies': 'Multiple curie references',
    '_ingest_set': 'Ingest envelope array',
    '_name': 'VocabularyTerm name string',
    '_names': 'Multiple VocabularyTerm name strings',
}

# Suffixes where count is ambiguous (regular names vs DTO suffix patterns)
VARIES_SUFFIXES = {'_name', '_names'}

# Static key files section
KEY_FILES_SECTION = """\
## Key Files

| Purpose | File Path |
|---------|-----------|
| Root schema | `model/schema/allianceModel.yaml` |
| Core base classes | `model/schema/core.yaml` |
| Ingest definition | `model/schema/ingest.yaml` |
| Generated JSON Schema | `generated/jsonschema/allianceModel.schema.json` |
| Build system | `Makefile` |
| Valid test data | `test/data/*.json` (32 files) |
| Invalid test data | `test/data/invalid/*.json` (4 files) |"""

# Curated mapping table (semantic mapping beyond simple YAML parsing)
MAPPING_TABLE_SECTION = """\
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
| String/boolean/integer | (same name) | date_created | date_created |"""

AUDIT_BACKBONE_SECTION = """\
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
| obsolete | obsolete | Deprecation flag |"""


# ─── YAML Parsing Helpers ───────────────────────────────────────────────────

def load_schema_files(schema_dir):
    """Load all YAML files from schema directory.

    Returns dict mapping filename -> {data: parsed_yaml, lines: line_count}.
    """
    schema_path = Path(schema_dir)
    files = {}
    for yaml_file in sorted(schema_path.glob('*.yaml')):
        with open(yaml_file) as f:
            content = f.read()
        data = yaml.safe_load(content) or {}
        line_count = content.count('\n') + (1 if content and not content.endswith('\n') else 0)
        files[yaml_file.name] = {
            'data': data,
            'lines': line_count,
        }
    return files


def get_classes(data):
    """Extract classes dict from YAML data."""
    return data.get('classes', {}) or {}


def get_slots(data):
    """Extract top-level slots dict from YAML data."""
    return data.get('slots', {}) or {}


def get_enums(data):
    """Extract enums dict from YAML data."""
    return data.get('enums', {}) or {}


def get_imports(data):
    """Extract imports list, filtering out linkml:types."""
    imports = data.get('imports', []) or []
    return [i for i in imports if i != 'linkml:types']


# ─── Schema Inventory Generator ─────────────────────────────────────────────

def generate_schema_inventory(files_data):
    """Generate schema-inventory.md content."""
    lines = []
    total_classes = 0
    total_enums = 0
    total_lines = 0

    rows = []
    for filename in sorted(files_data.keys()):
        info = files_data[filename]
        data = info['data']
        n_classes = len(get_classes(data))
        n_slots = len(get_slots(data))
        n_enums = len(get_enums(data))
        domain = DOMAIN_LOOKUP.get(filename, 'Unknown')

        total_classes += n_classes
        total_enums += n_enums
        total_lines += info['lines']

        rows.append((filename, n_classes, n_slots, n_enums, domain))

    n_files = len(rows)

    lines.append('# Schema Inventory')
    lines.append('')
    lines.append(
        'File inventory for `agr_curation_schema/model/schema/` '
        'with class, slot, and enum counts per file.'
    )
    lines.append('')
    lines.append(
        f'**Total**: {n_files} files, {total_classes} classes, '
        f'{total_enums} enums, ~{total_lines:,} lines'
    )
    lines.append('')
    lines.append('| File | Classes | Slots | Enums | Domain |')
    lines.append('|------|--------:|------:|------:|--------|')

    for filename, n_classes, n_slots, n_enums, domain in rows:
        lines.append(
            f'| {filename} | {n_classes} | {n_slots} | {n_enums} | {domain} |'
        )

    # Enum inventory
    lines.append('')
    lines.append('## Enum Inventory')
    lines.append('')
    lines.append('| Enum Name | File | Values |')
    lines.append('|-----------|------|-------:|')

    for filename in sorted(files_data.keys()):
        data = files_data[filename]['data']
        enums = get_enums(data)
        for enum_name in sorted(enums.keys()):
            enum_data = enums[enum_name]
            if enum_data is None:
                enum_data = {}
            pv = enum_data.get('permissible_values', {}) or {}
            lines.append(f'| {enum_name} | {filename} | {len(pv)} |')

    # Key files (static)
    lines.append('')
    lines.append(KEY_FILES_SECTION)
    lines.append('')

    return '\n'.join(lines)


# ─── Inheritance Tree Generator ──────────────────────────────────────────────

def generate_inheritance_tree(files_data):
    """Generate inheritance-tree.md content."""
    # Gather all classes with metadata
    class_info = {}  # class_name -> {is_a, abstract, file}
    for filename in sorted(files_data.keys()):
        data = files_data[filename]['data']
        classes = get_classes(data)
        for cls_name, cls_data in classes.items():
            if cls_data is None:
                cls_data = {}
            class_info[cls_name] = {
                'is_a': cls_data.get('is_a'),
                'abstract': bool(cls_data.get('abstract', False)),
                'tree_root': bool(cls_data.get('tree_root', False)),
                'file': filename,
            }

    # Build parent -> children map
    children = defaultdict(list)
    for cls_name, info in class_info.items():
        parent = info['is_a']
        if parent and parent in class_info:
            children[parent].append(cls_name)

    # Sort children alphabetically
    for parent in children:
        children[parent].sort()

    # Find root classes (no in-repo parent)
    roots = sorted(
        cls_name for cls_name, info in class_info.items()
        if info['is_a'] is None or info['is_a'] not in class_info
    )

    # Compute max depth via DFS
    depth_memo = {}

    def get_depth(cls_name):
        if cls_name in depth_memo:
            return depth_memo[cls_name]
        child_list = children.get(cls_name, [])
        if not child_list:
            depth_memo[cls_name] = 1
            return 1
        max_child = max(get_depth(c) for c in child_list)
        depth_memo[cls_name] = 1 + max_child
        return depth_memo[cls_name]

    max_depth = max((get_depth(r) for r in roots), default=0)
    abstract_count = sum(1 for info in class_info.values() if info['abstract'])

    # Separate roots with children from standalone
    tree_roots = [r for r in roots if children.get(r)]
    standalone_roots = [r for r in roots if not children.get(r)]

    # DFS tree rendering
    def render_tree(root, indent=0):
        tree_lines = []
        info = class_info[root]
        abstract_marker = ' [abstract]' if info['abstract'] else ''
        prefix = '  ' * indent
        tree_lines.append(f'{prefix}{root}{abstract_marker} ({info["file"]})')
        for child in children.get(root, []):
            tree_lines.extend(render_tree(child, indent + 1))
        return tree_lines

    # Build output
    lines = []
    lines.append('# Complete Inheritance Tree')
    lines.append('')
    lines.append(
        'Generated from all classes in `agr_curation_schema/model/schema/*.yaml`. '
        'Includes source file and `[abstract]` markers.'
    )
    lines.append('')
    root_names = ', '.join(roots)
    lines.append(
        f'**{len(roots)} root classes** (no in-repo parent): {root_names}'
    )
    lines.append('')
    lines.append(f'**Max depth**: {max_depth} | **Abstract classes**: {abstract_count}')

    # Render each tree root as its own section
    for root in tree_roots:
        lines.append('')
        lines.append(f'## {root} Tree')
        lines.append('')
        lines.append('```')
        lines.extend(render_tree(root))
        lines.append('```')

    # Standalone roots
    if standalone_roots:
        lines.append('')
        lines.append('## Standalone Root Classes')
        lines.append('')
        lines.append('```')
        for root in standalone_roots:
            info = class_info[root]
            abstract_marker = ' [abstract]' if info['abstract'] else ''
            if info['tree_root']:
                tag = ' -- tree_root: true'
            else:
                tag = ' -- standalone root'
            lines.append(f'{root}{abstract_marker} ({info["file"]}){tag}')
        lines.append('```')

    lines.append('')
    return '\n'.join(lines)


# ─── Import Graph Generator ─────────────────────────────────────────────────

def tarjan_scc(graph):
    """Compute strongly connected components using Tarjan's algorithm.

    Args:
        graph: dict mapping node -> list of successor nodes

    Returns:
        list of sets, each set is an SCC
    """
    index_counter = [0]
    stack = []
    lowlink = {}
    index = {}
    on_stack = {}
    sccs = []

    def strongconnect(node):
        index[node] = index_counter[0]
        lowlink[node] = index_counter[0]
        index_counter[0] += 1
        stack.append(node)
        on_stack[node] = True

        for successor in graph.get(node, []):
            if successor not in index:
                strongconnect(successor)
                lowlink[node] = min(lowlink[node], lowlink[successor])
            elif on_stack.get(successor, False):
                lowlink[node] = min(lowlink[node], index[successor])

        if lowlink[node] == index[node]:
            scc = set()
            while True:
                w = stack.pop()
                on_stack[w] = False
                scc.add(w)
                if w == node:
                    break
            sccs.append(scc)

    for node in sorted(graph.keys()):
        if node not in index:
            strongconnect(node)

    return sccs


def generate_import_graph(files_data):
    """Generate import-graph.md content."""
    all_stems = {Path(f).stem for f in files_data.keys()}

    # Build directed graph and collect edges
    graph = defaultdict(list)
    edges = []

    for filename in sorted(files_data.keys()):
        data = files_data[filename]['data']
        imports = get_imports(data)
        source = Path(filename).stem

        # Ensure every file is a node even if it imports nothing
        if source not in graph:
            graph[source] = []

        for imp in sorted(imports):
            if imp in all_stems:
                graph[source].append(imp)
                edges.append((source, imp))
                if imp not in graph:
                    graph[imp] = []

    # Compute SCC
    sccs = tarjan_scc(dict(graph))
    large_sccs = [scc for scc in sccs if len(scc) > 1]

    # Build output
    lines = []
    lines.append('# Import Dependency Graph')
    lines.append('')
    lines.append(
        'Mermaid diagram of all import relationships between schema files '
        'in `agr_curation_schema/model/schema/`.'
    )
    lines.append('')

    if large_sccs:
        largest = max(large_sccs, key=len)
        scc_members = sorted(largest)
        lines.append(
            f'**Note**: A {len(largest)}-file strongly connected component (SCC) exists. '
            'The import graph is intentionally interdependent, not layered/DAG-style. '
            'Reviewers must reason about cross-module implications.'
        )
        lines.append('')
        lines.append(f'**SCC members**: {", ".join(scc_members)}')
    else:
        lines.append(
            '**Note**: No strongly connected components found. '
            'The import graph is a DAG.'
        )

    lines.append('')
    lines.append('```mermaid')
    lines.append('graph TD')

    # Sort edges alphabetically by source, then target
    for source, target in sorted(edges):
        lines.append(f'  {source} --> {target}')

    lines.append('```')
    lines.append('')

    return '\n'.join(lines)


# ─── DTO Suffix Reference Generator ─────────────────────────────────────────

def generate_dto_suffix_reference(files_data):
    """Generate dto-suffix-reference.md content."""
    # Scan all top-level slot names for DTO suffix patterns
    suffix_counts = defaultdict(int)

    for filename in sorted(files_data.keys()):
        data = files_data[filename]['data']
        slots = get_slots(data)
        for slot_name in slots:
            for suffix in DTO_SUFFIXES:
                if slot_name.endswith(suffix):
                    suffix_counts[suffix] += 1
                    break  # count each slot once under its first matching suffix

    # Build output
    lines = []
    lines.append('# DTO Suffix Reference')
    lines.append('')
    lines.append(
        'Complete mapping of non-DTO ranges to their DTO slot suffix conventions.'
    )
    lines.append('')
    lines.append('## Suffix Pattern Summary')
    lines.append('')
    lines.append('| Suffix | Count | Purpose |')
    lines.append('|--------|------:|---------|')

    for suffix in SUFFIX_DISPLAY_ORDER:
        purpose = SUFFIX_PURPOSES[suffix]
        if suffix in VARIES_SUFFIXES:
            lines.append(f'| `{suffix}` | varies | {purpose} |')
        else:
            count = suffix_counts.get(suffix, 0)
            lines.append(f'| `{suffix}` | {count} | {purpose} |')

    # Curated sections
    lines.append('')
    lines.append(MAPPING_TABLE_SECTION)
    lines.append('')
    lines.append(AUDIT_BACKBONE_SECTION)
    lines.append('')

    return '\n'.join(lines)


# ─── Main ───────────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <schema-dir> <output-dir>', file=sys.stderr)
        sys.exit(1)

    schema_dir = sys.argv[1]
    output_dir = sys.argv[2]

    if not os.path.isdir(schema_dir):
        print(f'Error: schema directory not found: {schema_dir}', file=sys.stderr)
        sys.exit(1)

    os.makedirs(output_dir, exist_ok=True)

    print(f'Loading schema files from {schema_dir}...')
    files_data = load_schema_files(schema_dir)
    print(f'  Found {len(files_data)} YAML files')

    generators = {
        'schema-inventory.md': generate_schema_inventory,
        'inheritance-tree.md': generate_inheritance_tree,
        'import-graph.md': generate_import_graph,
        'dto-suffix-reference.md': generate_dto_suffix_reference,
    }

    for out_filename, generator in generators.items():
        output_path = os.path.join(output_dir, out_filename)
        print(f'Generating {out_filename}...')
        content = generator(files_data)
        with open(output_path, 'w') as f:
            f.write(content)
        print(f'  Written to {output_path}')

    print('Done!')


if __name__ == '__main__':
    main()
