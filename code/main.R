#!/usr/bin/env Rscript

# Code Ocean entry point for OMIX GSEA preranked analysis.

suppressPackageStartupMessages({
  library(optparse)
})

source("functions/GSEA_Preranked.R")
source("functions/input_discovery.R")

if (!requireNamespace("OmixPathwayInputs", quietly = TRUE)) {
  stop(
    "ERROR: OmixPathwayInputs is required for FindMarkers DEG input support. ",
    "Use the configured OMIX r-pathway runtime.",
    call. = FALSE
  )
}

option_list <- list(
  make_option("--deg_table", type = "character", default = NULL, help = "Path to DEG table (TSV/CSV/RDS)"),
  make_option("--pathways_database", type = "character", default = NULL, help = "Optional path to pathways database; blank discovers the attached MSigDB asset"),
  make_option("--gene_names_column", type = "character", default = NULL, help = "Gene-symbol column in DEG table; auto-detect when blank"),
  make_option("--species", type = "character", default = "Mouse", help = "Species in DEG table"),
  make_option("--gene_scores_suffix", type = "character", default = "_tstat", help = "Suffix for gene score columns"),
  make_option("--contrasts", type = "character", default = NULL, help = "Optional comma-separated contrasts, analyzed in this order"),
  make_option("--pathways_species", type = "character", default = "Human", help = "Species in pathways database"),
  make_option("--collections", type = "character", default = "H: hallmark gene sets,C2:CP:REACTOME: Reactome gene sets", help = "Comma-separated collections"),
  make_option("--min_geneset_size", type = "integer", default = 15L, help = "Minimum geneset size"),
  make_option("--max_geneset_size", type = "integer", default = 500L, help = "Maximum geneset size"),
  make_option("--n_permutations", type = "integer", default = 5000L, help = "Number of permutations"),
  make_option("--random_seed", type = "integer", default = 246642L, help = "Random seed"),
  make_option("--fdr_mode", type = "character", default = "within each collection", help = "FDR correction mode"),
  make_option("--collapse_redundancy", type = "character", default = "false", help = "Collapse pathway redundancy"),
  make_option("--sort_by", type = "character", default = "pval", help = "Sort output by"),
  make_option("--image_width", type = "integer", default = 2500L, help = "Image width in pixels"),
  make_option("--image_height", type = "integer", default = 2500L, help = "Image height in pixels"),
  make_option("--image_resolution", type = "integer", default = 300L, help = "Image resolution (dpi)")
)

parser <- OptionParser(
  usage = "Usage: %prog --deg_table PATH --pathways_database PATH [options]",
  option_list = option_list,
  description = "Run GSEA pre-ranked analysis on gene expression data"
)

# Code Ocean passes --param "" for blank optional file uploads. Remove those
# pairs before optparse sees them.
args <- commandArgs(trailingOnly = TRUE)
filtered_args <- character()
i <- 1L
while (i <= length(args)) {
  if (args[[i]] == "") {
    i <- i + 1L
  } else if (i < length(args) && startsWith(args[[i]], "--") && args[[i + 1L]] == "") {
    i <- i + 2L
  } else {
    filtered_args <- c(filtered_args, args[[i]])
    i <- i + 1L
  }
}

opt <- parse_args(parser, args = filtered_args)

collections <- trimws(strsplit(opt$collections, ",", fixed = TRUE)[[1L]])
contrasts <- if (is.null(opt$contrasts) || !nzchar(trimws(opt$contrasts))) {
  character()
} else {
  trimws(strsplit(opt$contrasts, ",", fixed = TRUE)[[1L]])
}
if (anyDuplicated(contrasts)) {
  stop("ERROR: Contrasts must not contain duplicates.", call. = FALSE)
}

opt$deg_table <- resolve_gsea_deg_input(opt$deg_table)
opt$pathways_database <- resolve_gsea_pathways_database(opt$pathways_database)
deg_table <- read_gsea_deg_table(opt$deg_table)
requested_gene_column <- if (
  !is.null(opt$gene_names_column) && tolower(opt$gene_names_column) == "auto"
) {
  NULL
} else {
  opt$gene_names_column
}
findmarkers_profile <- OmixPathwayInputs::normalize_findmarkers_deg_input(
  deg_table,
  gene_column = requested_gene_column,
  comparison_labels = contrasts
)

if (!is.null(findmarkers_profile)) {
  deg_table <- findmarkers_profile$data
  opt$gene_names_column <- findmarkers_profile$gene_column
  contrasts <- findmarkers_profile$comparisons
  # The App Panel supplies _tstat by default. Standard FindMarkers tables
  # provide signed log-fold changes rather than t statistics.
  if (identical(opt$gene_scores_suffix, "_tstat")) {
    opt$gene_scores_suffix <- "_logFC"
  }
  message(
    "Recognized Seurat FindMarkers input; using signed log-fold-change scores ",
    "for contrasts: ", paste(contrasts, collapse = ", ")
  )
} else {
  opt$gene_names_column <- resolve_gsea_gene_names_column(
    deg_table,
    opt$gene_names_column
  )
}

collapse_redundancy <- tolower(opt$collapse_redundancy) == "true"
results_dir <- "/results"
dir.create(results_dir, showWarnings = FALSE, recursive = TRUE)

message("========================================")
message("OMIX GSEA - Pre-ranked Analysis")
message("========================================")
message("DEG Table: ", opt$deg_table)
message("Pathways Database: ", opt$pathways_database)
message("Species: ", opt$species)
message("Gene score suffix: ", opt$gene_scores_suffix)
message("Collections: ", paste(collections, collapse = ", "))
if (length(contrasts) > 0L) {
  message("Contrasts (ordered): ", paste(contrasts, collapse = ", "))
}
message("========================================\n")

results <- GSEA_Preranked(
  DEG_Table = deg_table,
  Pathways_Database = opt$pathways_database,
  Gene_Names_Column = opt$gene_names_column,
  species = opt$species,
  Gene_Scores_Column_s_Suffix = opt$gene_scores_suffix,
  Contrasts = contrasts,
  Contrasts_Filter = if (length(contrasts) > 0L) "keep" else "none",
  Pathways_Database_Species = opt$pathways_species,
  Collections_to_Include = collections,
  Minimum_Gene_Set_Size = opt$min_geneset_size,
  Maximum_Gene_Set_Size = opt$max_geneset_size,
  FDR_Correction_Mode = opt$fdr_mode,
  Number_of_Permutations = opt$n_permutations,
  Random_Seed = opt$random_seed,
  Collapse_Pathway_Redundancy = collapse_redundancy,
  Sort_Output_By = opt$sort_by,
  Image_Width = opt$image_width,
  Image_Height = opt$image_height,
  Image_Resolution = opt$image_resolution,
  Output_Directory = results_dir
)

output_file <- file.path(results_dir, "gsea_results.csv")
write.csv(results, output_file, row.names = FALSE)

message("\n========================================")
message("GSEA analysis complete!")
message("Results saved to: ", output_file)
message("========================================")
