# Metadata harmonization ----------------------------------------------------

normalize_sample_id <- function(x) {
  gsub("_", ".", as.character(x))
}

ensure_celltype_column <- function(
  obj,
  source_col = "nb_clus",
  target_col = "celltype_pub",
  label_map = NULL,
  unknown_label = "Unknown"
) {
  md <- obj@meta.data

  if (!source_col %in% colnames(md)) {
    stop("Column '", source_col, "' not found in metadata.", call. = FALSE)
  }

  celltype <- as.character(md[[source_col]])
  celltype[is.na(celltype) | celltype == ""] <- unknown_label

  if (!is.null(label_map)) {
    matched <- celltype %in% names(label_map)
    celltype[matched] <- unname(label_map[celltype[matched]])
  }

  md[[target_col]] <- factor(celltype)
  obj@meta.data <- md
  Seurat::Idents(obj) <- target_col
  obj
}

add_sample_metadata <- function(
  obj,
  sample_metadata,
  object_sample_col = "Run_Tissue_name",
  metadata_sample_col = "sample_id"
) {
  md <- obj@meta.data

  if (!object_sample_col %in% colnames(md)) {
    stop("Object sample column '", object_sample_col, "' not found.", call. = FALSE)
  }
  if (!metadata_sample_col %in% colnames(sample_metadata)) {
    stop("Metadata sample column '", metadata_sample_col, "' not found.", call. = FALSE)
  }

  md$.sample_id_norm <- normalize_sample_id(md[[object_sample_col]])
  sample_metadata$.sample_id_norm <- normalize_sample_id(sample_metadata[[metadata_sample_col]])

  extra_cols <- setdiff(colnames(sample_metadata), c(metadata_sample_col, ".sample_id_norm"))
  map_df <- sample_metadata[, c(".sample_id_norm", extra_cols), drop = FALSE]
  map_df <- map_df[!duplicated(map_df$.sample_id_norm), , drop = FALSE]

  md$.row_id <- rownames(md)
  md <- dplyr::left_join(md, map_df, by = ".sample_id_norm")
  rownames(md) <- md$.row_id
  md$.row_id <- NULL

  obj@meta.data <- md
  obj
}

summarize_metadata_mapping <- function(obj, cols = c("HIV_status", "plaque_type")) {
  available <- intersect(cols, colnames(obj@meta.data))
  lapply(available, function(x) table(obj@meta.data[[x]], useNA = "ifany")) |>
    stats::setNames(available)
}
