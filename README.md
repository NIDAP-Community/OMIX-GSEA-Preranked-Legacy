# OMIX GSEA

Gene Set Enrichment Analysis (GSEA) for pre-ranked gene lists using the fgsea package.

## What Does This Do?

GSEA assesses whether predefined gene sets show statistically significant, concordant differences between two biological states. This implementation uses **pre-ranked gene lists** (e.g., from differential expression analysis) and evaluates enrichment at the top or bottom of the ranking.

## Quick Start

### Required Inputs

1. **DEG Table** (TSV/CSV/RDS)
   - Genes with ranking scores (e.g., t-statistic, log fold-change)
   - Columns: Gene names + score columns for each contrast
   - Example column names: `Gene`, `A-B_tstat`, `C-D_logFC`

2. **Pathways Database** (TSV/CSV/RDS)
   - Gene set membership information
   - Required columns: `collection`, `gene_set_name`, `gene_symbol`, `species`
   - Default: MSigDB v2023.2 (if available as data asset)

### Run from Command Line

```bash
Rscript code/main.R \
  --deg_table /data/deg_results.tsv \
  --pathways_database /data/msigdb_v2023_2.rds \
  --gene_names_column Gene \
  --species Human \
  --gene_scores_suffix _tstat \
  --pathways_species Human \
  --collections "H: hallmark gene sets,C2:CP:REACTOME: Reactome gene sets"
```

See "Available MSigDB Collections" section below for complete list of collection names.

## Available MSigDB Collections

### Human Collections (Pathways Species = Human)

Use these collection names with `--pathways_species Human`:

**H/C-Prefix Collections:**
- `H: hallmark gene sets` - Core biological processes and pathways (50 gene sets)
- `C1: positional gene sets` - Genes organized by chromosomal position
- `C2:CGP: chemical and genetic pertubations` - Chemical and genetic perturbation gene sets
- `C2:CP:BIOCARTA: BioCarta gene sets` - BioCarta pathways
- `C2:CP:KEGG_LEGACY: KEGG Legacy gene sets` - KEGG pathways (legacy version)
- `C2:CP:REACTOME: Reactome gene sets` - Reactome pathways
- `C2:CP:WIKIPATHWAYS: WikiPathways gene sets` - WikiPathways collection
- `C3:TFT:GTRD: GTRD transcription factor targets` - GTRD TF target gene sets
- `C3:MIR:MIRDB: miRDB microRNA targets` - miRDB predicted microRNA targets
- `C5:GO:BP: GO biological process` - Gene Ontology Biological Process terms
- `C5:GO:CC: GO cellular component` - Gene Ontology Cellular Component terms
- `C5:GO:MF: GO molecular function` - Gene Ontology Molecular Function terms
- `C6: oncogenic signature gene sets` - Oncogenic signatures from cancer studies
- `C7: immunologic signature gene sets` - Immunologic cell states and perturbations
- `C8: cell type signature gene sets` - Cell type marker gene sets

### Mouse Collections (Pathways Species = Mouse)

Use these collection names with `--pathways_species Mouse`:

**M-Prefix Collections (Orthology-Mapped):**
- `MH: orthology-mapped hallmark gene sets` - Hallmark gene sets mapped to mouse orthologs
- `M1: positional gene sets` - Mouse genes by chromosomal position
- `M2:CGP: chemical and genetic pertubations` - Perturbation gene sets (mouse)
- `M2:CP:BIOCARTA: BioCarta gene sets` - BioCarta pathways (mouse orthologs)
- `M2:CP:REACTOME: Reactome gene sets` - Reactome pathways (mouse orthologs)
- `M2:CP:WIKIPATHWAYS: WikiPathways gene sets` - WikiPathways (mouse orthologs)
- `M3:GTRD: GTRD transcription factor targets` - TF targets (mouse)
- `M3:MIRDB: miRDB microRNA targets` - microRNA targets (mouse)
- `M5:GO:BP: GO biological process` - GO Biological Process (mouse genes)
- `M5:GO:CC: GO cellular component` - GO Cellular Component (mouse genes)
- `M5:GO:MF: GO molecular function` - GO Molecular Function (mouse genes)
- `M5:MPT: Mouse Phenotype Ontology MP Tumor` - Mouse tumor phenotype gene sets
- `M8: cell type signature gene sets` - Mouse cell type markers

### Usage Examples

**Single collection:**
```bash
--collections "H: hallmark gene sets" --pathways_species Human
```

**Multiple collections (comma-separated):**
```bash
--collections "H: hallmark gene sets,C2:CP:REACTOME: Reactome gene sets" --pathways_species Human
```

**Mouse analysis:**
```bash
--collections "MH: orthology-mapped hallmark gene sets,M2:CP:REACTOME: Reactome gene sets" --pathways_species Mouse
```

> **Important:** Match the collection prefix (H/C or M) with the Pathways Species parameter:
> - H/C-prefix collections → `--pathways_species Human`
> - M-prefix collections → `--pathways_species Mouse`

## Key Parameters

- `--gene_scores_suffix` - Column suffix for ranking scores (`_tstat`, `_logFC`)
- `--collections` - MSigDB collections to test (comma-separated, see above)
- `--pathways_species` - Species in pathways database (`Human` or `Mouse`)
- `--min_geneset_size` - Minimum gene set size (default: 15)
- `--max_geneset_size` - Maximum gene set size (default: 500)
- `--n_permutations` - Number of permutations for p-value estimation (default: 5000)
- `--fdr_mode` - FDR correction: `"within each collection"` or `"over all collections"`

## Outputs

- `gsea_results.csv` - Enrichment results with NES, p-values, adjusted p-values, leading edge genes
- Plots (if generated by function)

## Method

Uses the **fgsea** R Bioconductor package for fast pre-ranked GSEA with adaptive multi-level split Monte-Carlo scheme.

## References

- Korotkevich G et al. (2021). Fast gene set enrichment analysis. bioRxiv. doi:10.1101/060012
- Subramanian A et al. (2005). Gene set enrichment analysis: A knowledge-based approach for interpreting genome-wide expression profiles. PNAS. doi:10.1073/pnas.0506580102

## Contact

CCBR: NCICCBRNIDAP@mail.nih.gov
