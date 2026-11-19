# Code Ocean input resolution for the GSEA preranked deployment adapter.
#
# This file owns mounted-path discovery only. FindMarkers profile recognition
# remains in the shared OmixPathwayInputs package used by the canonical CLI.

is_supported_deg_table <- function(path) {
  tolower(tools::file_ext(path)) %in% c("csv", "tsv", "txt", "rds")
}

list_supported_deg_tables <- function(path) {
  if (!dir.exists(path)) {
    return(character())
  }
  files <- list.files(path, recursive = TRUE, full.names = TRUE, all.files = FALSE)
  sort(files[vapply(files, is_supported_deg_table, logical(1))])
}

is_supported_pathways_database <- function(path) {
  tolower(tools::file_ext(path)) %in% c("csv", "tsv", "txt", "rds", "rda", "rdata")
}

list_supported_pathways_databases <- function(path) {
  if (!dir.exists(path)) {
    return(character())
  }
  files <- list.files(path, recursive = TRUE, full.names = TRUE, all.files = FALSE)
  sort(files[vapply(files, is_supported_pathways_database, logical(1))])
}

format_input_candidates <- function(paths) {
  paste(paths, collapse = "\n")
}

resolve_gsea_pathways_database <- function(
    pathways_database = NULL,
    data_root = "/data",
    mounts = c("msigdb_1", "msigdb")) {
  if (!is.null(pathways_database) && nzchar(trimws(pathways_database))) {
    if (!file.exists(pathways_database)) {
      stop(
        "ERROR: Pathways database was not found: ", pathways_database,
        call. = FALSE
      )
    }
    return(pathways_database)
  }

  for (mount in mounts) {
    mount_root <- file.path(data_root, mount)
    candidates <- list_supported_pathways_databases(mount_root)

    if (length(candidates) == 1L) {
      message("Using attached pathways database: ", candidates[[1L]])
      return(candidates[[1L]])
    }
    if (length(candidates) > 1L) {
      stop(
        "ERROR: Multiple pathway database candidates were found under ",
        mount_root, ":\n",
        format_input_candidates(candidates),
        "\nSelect a file explicitly with --pathways_database.",
        call. = FALSE
      )
    }
  }

  stop(
    "ERROR: No supported pathways database was found under ", data_root,
    ". Attach the MSigDB asset with mount name 'msigdb_1' or 'msigdb', ",
    "or select a file explicitly with --pathways_database.",
    call. = FALSE
  )
}

resolve_gsea_deg_input <- function(deg_table = NULL, data_root = "/data") {
  if (!is.null(deg_table) && nzchar(trimws(deg_table))) {
    return(deg_table)
  }

  attached_root <- file.path(data_root, "deg_table")
  all_candidates <- list_supported_deg_tables(data_root)
  attached_candidates <- list_supported_deg_tables(attached_root)
  workflow_candidates <- setdiff(all_candidates, attached_candidates)
  pathway_roots <- file.path(data_root, c("msigdb", "msigdb_1"))
  workflow_candidates <- workflow_candidates[
    !vapply(
      workflow_candidates,
      function(path) any(startsWith(path, paste0(pathway_roots, "/"))),
      logical(1)
    )
  ]
  workflow_candidates <- workflow_candidates[
    grepl("(deg|marker)", basename(workflow_candidates), ignore.case = TRUE)
  ]

  if (length(workflow_candidates) == 1L) {
    message("Using workflow DEG table: ", workflow_candidates[[1L]])
    return(workflow_candidates[[1L]])
  }
  if (length(workflow_candidates) > 1L) {
    stop(
      "ERROR: Multiple workflow DEG candidates were found under ", data_root, ":\n",
      format_input_candidates(workflow_candidates),
      "\nSelect a file explicitly with --deg_table.",
      call. = FALSE
    )
  }

  if (length(attached_candidates) == 1L) {
    message("Using attached DEG table: ", attached_candidates[[1L]])
    return(attached_candidates[[1L]])
  }
  if (length(attached_candidates) > 1L) {
    stop(
      "ERROR: Multiple supported DEG tables were found under ", attached_root, ":\n",
      format_input_candidates(attached_candidates),
      "\nSelect a file explicitly with --deg_table.",
      call. = FALSE
    )
  }

  stop(
    "ERROR: No supported DEG table was found. Attach one table with mount name ",
    "'deg_table', select a file explicitly, or connect one workflow result whose ",
    "filename contains 'deg' or 'marker'. Visible files under ", data_root, ":\n",
    format_input_candidates(list.files(data_root, recursive = TRUE, full.names = TRUE)),
    call. = FALSE
  )
}

read_gsea_deg_table <- function(path) {
  if (!file.exists(path)) {
    stop("ERROR: DEG table was not found: ", path, call. = FALSE)
  }
  extension <- tolower(tools::file_ext(path))
  if (extension == "rds") {
    object <- readRDS(path)
    if (is.list(object) && !is.data.frame(object)) {
      data_frames <- Filter(is.data.frame, object)
      if (length(data_frames) == 0L) {
        stop("ERROR: DEG RDS does not contain a data frame: ", path, call. = FALSE)
      }
      object <- data_frames[[1L]]
    }
    if (!is.data.frame(object)) {
      stop("ERROR: DEG RDS does not contain a data frame: ", path, call. = FALSE)
    }
    return(object)
  }
  if (extension == "csv") {
    return(utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE))
  }
  if (extension %in% c("tsv", "txt")) {
    return(utils::read.delim(path, stringsAsFactors = FALSE, check.names = FALSE))
  }
  stop("ERROR: Unsupported DEG table format: ", path, call. = FALSE)
}

resolve_gsea_gene_names_column <- function(data, requested) {
  if (!is.null(requested) && nzchar(requested) && tolower(requested) != "auto") {
    if (!requested %in% names(data)) {
      stop(
        "ERROR: Requested gene-name column was not found: ", requested,
        ". Available columns: ", paste(names(data), collapse = ", "),
        call. = FALSE
      )
    }
    return(requested)
  }

  candidates <- c("GeneName", "Gene Symbols", "Gene", "gene_name", "GeneSymbol", "gene_symbol")
  detected <- candidates[candidates %in% names(data)]
  if (length(detected) == 0L) {
    stop(
      "ERROR: Could not auto-detect the gene-name column. Specify Gene Names Column. ",
      "Available columns: ", paste(names(data), collapse = ", "),
      call. = FALSE
    )
  }

  message("Auto-detected gene-name column: ", detected[[1L]])
  detected[[1L]]
}
