# Input/output and Seurat object preparation --------------------------------

read_cosmx_seurat <- function(path) {
  if (!file.exists(path)) {
    stop("Seurat object not found: ", path, call. = FALSE)
  }
  readRDS(path)
}

prepare_nanostring_assay <- function(
  obj,
  assay = "Nanostring",
  join_layers = TRUE,
  normalize = TRUE,
  normalization_method = "LogNormalize",
  scale_factor = 1e4
) {
  if (!assay %in% names(obj@assays)) {
    stop("Assay '", assay, "' not found. Available assays: ", paste(names(obj@assays), collapse = ", "), call. = FALSE)
  }

  Seurat::DefaultAssay(obj) <- assay

  if (isTRUE(join_layers) && "JoinLayers" %in% getNamespaceExports("Seurat")) {
    obj <- Seurat::JoinLayers(obj, assay = assay)
  }

  if (isTRUE(normalize)) {
    obj <- Seurat::NormalizeData(
      obj,
      assay = assay,
      normalization.method = normalization_method,
      scale.factor = scale_factor,
      verbose = FALSE
    )
  }

  obj
}

save_cosmx_object <- function(obj, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  saveRDS(obj, path)
  invisible(path)
}

write_session_info <- function(path = "outputs/sessionInfo.txt") {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  capture.output(sessionInfo(), file = path)
  invisible(path)
}
