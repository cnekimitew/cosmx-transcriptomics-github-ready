# Package loading utilities -------------------------------------------------

required_packages <- c(
  "Seurat", "SeuratObject", "dplyr", "ggplot2", "ggrepel", "Matrix",
  "pheatmap", "readr", "tibble", "yaml", "FNN", "viridis"
)

check_required_packages <- function(packages = required_packages) {
  missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    stop(
      "Install missing packages before running the workflow: ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

load_required_packages <- function(packages = required_packages) {
  check_required_packages(packages)
  invisible(lapply(packages, library, character.only = TRUE))
}

read_config <- function(path = "config/config.yml") {
  if (!file.exists(path)) {
    stop(
      "Config file not found: ", path,
      "\nCopy config/config_template.yml to config/config.yml and edit it.",
      call. = FALSE
    )
  }
  yaml::read_yaml(path)
}
