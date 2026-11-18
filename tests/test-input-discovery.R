#!/usr/bin/env Rscript

file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
test_file <- if (length(file_arg) == 1L) {
  normalizePath(sub("^--file=", "", file_arg))
} else {
  normalizePath("tests/test-input-discovery.R")
}
source(file.path(dirname(test_file), "..", "code", "functions", "input_discovery.R"))

expect_identical <- function(actual, expected, message) {
  if (!identical(actual, expected)) {
    stop(message, "\nExpected: ", expected, "\nActual: ", actual, call. = FALSE)
  }
}

expect_error <- function(expression, pattern) {
  error <- tryCatch(
    {
      force(expression)
      NULL
    },
    error = identity
  )
  if (is.null(error) || !grepl(pattern, conditionMessage(error), fixed = TRUE)) {
    stop("Expected error containing: ", pattern, call. = FALSE)
  }
}

write_deg_csv <- function(path) {
  utils::write.csv(
    data.frame(Gene = "Actb", C_1_vs_2_logFC = 1.2, check.names = FALSE),
    path,
    row.names = FALSE
  )
}

fixture_root <- tempfile("gsea-input-discovery-")
on.exit(unlink(fixture_root, recursive = TRUE, force = TRUE), add = TRUE)

workflow_root <- file.path(fixture_root, "workflow-data")
workflow_dir <- file.path(workflow_root, "upstream")
dir.create(workflow_dir, recursive = TRUE)
workflow_file <- file.path(workflow_dir, "deg_gene_expression_markers.csv")
write_deg_csv(workflow_file)
expect_identical(
  suppressMessages(resolve_gsea_deg_input(data_root = workflow_root)),
  workflow_file,
  "Expected lowercase FindMarkers workflow filename to be discovered."
)

attached_root <- file.path(fixture_root, "attached-data")
attached_dir <- file.path(attached_root, "deg_table")
dir.create(attached_dir, recursive = TRUE)
attached_file <- file.path(attached_dir, "input.tsv")
utils::write.table(
  data.frame(Gene = "Actb", C_1_vs_2_logFC = 1.2, check.names = FALSE),
  attached_file,
  row.names = FALSE,
  quote = FALSE,
  sep = "\t"
)
expect_identical(
  suppressMessages(resolve_gsea_deg_input(data_root = attached_root)),
  attached_file,
  "Expected a single attached table to be discovered."
)

ambiguous_root <- file.path(fixture_root, "ambiguous-data")
ambiguous_dir <- file.path(ambiguous_root, "upstream")
dir.create(ambiguous_dir, recursive = TRUE)
write_deg_csv(file.path(ambiguous_dir, "deg_first.csv"))
write_deg_csv(file.path(ambiguous_dir, "marker_second.csv"))
expect_error(
  resolve_gsea_deg_input(data_root = ambiguous_root),
  "Multiple workflow DEG candidates"
)

cat("GSEA input-discovery checks passed.\n")
