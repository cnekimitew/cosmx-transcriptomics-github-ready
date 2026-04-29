# Spatial neighborhood / niche analysis -------------------------------------

.pick_xy_columns <- function(coords) {
  candidates <- list(
    c("x", "y"),
    c("X", "Y"),
    c("imagecol", "imagerow"),
    c("col", "row"),
    c("pxl_col_in_fullres", "pxl_row_in_fullres")
  )

  for (xy in candidates) {
    if (all(xy %in% colnames(coords))) return(xy)
  }

  stop("Could not identify x/y coordinate columns.", call. = FALSE)
}

.find_cell_id_column <- function(coords, seurat_cells) {
  common <- intersect(
    colnames(coords),
    c("cell", "Cell", "cell_id", "cellID", "barcode", "Barcode", "spot", "Spot")
  )

  for (cc in common) {
    if (sum(as.character(coords[[cc]]) %in% seurat_cells, na.rm = TRUE) > 0) return(cc)
  }

  for (cc in colnames(coords)) {
    v <- coords[[cc]]
    if (!is.character(v) && !is.factor(v)) next
    if (sum(as.character(v) %in% seurat_cells, na.rm = TRUE) > 0) return(cc)
  }

  NULL
}

get_cell_centroids <- function(obj, image) {
  coords <- Seurat::GetTissueCoordinates(obj, image = image)
  if (is.null(coords) || nrow(coords) == 0) {
    stop("No tissue coordinates found for image/FOV: ", image, call. = FALSE)
  }

  seurat_cells <- colnames(obj)
  cell_col <- .find_cell_id_column(coords, seurat_cells)
  if (is.null(cell_col)) {
    stop("Could not find a cell-ID column in tissue coordinates that matches Seurat cell names.", call. = FALSE)
  }

  xy <- .pick_xy_columns(coords)
  coords[[cell_col]] <- as.character(coords[[cell_col]])
  coords <- coords[coords[[cell_col]] %in% seurat_cells, , drop = FALSE]

  centroids <- stats::aggregate(
    coords[, xy, drop = FALSE],
    by = list(cell = coords[[cell_col]]),
    FUN = mean,
    na.rm = TRUE
  )

  colnames(centroids)[2:3] <- c("x", "y")
  rownames(centroids) <- centroids$cell
  centroids
}

.get_knn_index <- function(X, k) {
  if (requireNamespace("FNN", quietly = TRUE)) {
    nn <- FNN::get.knn(X, k = k)
    return(list(index = nn$nn.index, engine = "FNN"))
  }

  if (requireNamespace("RANN", quietly = TRUE)) {
    nn <- RANN::nn2(X, k = k + 1)
    return(list(index = nn$nn.idx[, -1, drop = FALSE], engine = "RANN"))
  }

  stop("Install FNN or RANN before computing niches.", call. = FALSE)
}

compute_spatial_niches <- function(
  obj,
  image,
  celltype_col = "celltype_pub",
  kNN = 50,
  K = 7,
  max_cells = 8000,
  include_self = FALSE,
  seed = 1
) {
  md <- obj@meta.data
  if (!celltype_col %in% colnames(md)) {
    stop("Cell type column '", celltype_col, "' not found.", call. = FALSE)
  }

  centroids <- get_cell_centroids(obj, image = image)
  if (nrow(centroids) < 100) {
    stop("Too few cells for niche analysis: ", nrow(centroids), call. = FALSE)
  }

  set.seed(seed)
  if (nrow(centroids) > max_cells) {
    centroids <- centroids[sample(rownames(centroids), max_cells), , drop = FALSE]
  }

  cells_use <- rownames(centroids)
  celltype <- as.character(md[cells_use, celltype_col])
  celltype[is.na(celltype) | celltype == ""] <- "Unknown"
  celltype_levels <- sort(unique(celltype))

  if (length(celltype_levels) < 2) {
    stop("At least two cell types are required for niche analysis.", call. = FALSE)
  }

  X <- as.matrix(centroids[, c("x", "y"), drop = FALSE])
  rownames(X) <- cells_use

  kNN <- min(kNN, nrow(X) - 1)
  kNN <- max(kNN, 5)
  nn <- .get_knn_index(X, k = kNN)

  composition <- matrix(
    0,
    nrow = nrow(X),
    ncol = length(celltype_levels),
    dimnames = list(cells_use, celltype_levels)
  )

  celltype_named <- stats::setNames(celltype, cells_use)

  for (i in seq_len(nrow(nn$index))) {
    neighbor_cells <- cells_use[nn$index[i, ]]
    if (isTRUE(include_self)) neighbor_cells <- c(neighbor_cells, cells_use[i])
    tab <- table(factor(celltype_named[neighbor_cells], levels = celltype_levels))
    composition[i, ] <- as.numeric(tab)
  }

  composition_prop <- composition / pmax(rowSums(composition), 1)

  K <- min(K, nrow(composition_prop) - 1)
  K <- max(K, 2)

  set.seed(seed)
  km <- stats::kmeans(composition_prop, centers = K, nstart = 25)
  niche <- paste0("Niche_", sprintf("%02d", km$cluster))

  niche_cells <- data.frame(
    cell = cells_use,
    niche = niche,
    celltype = celltype_named[cells_use],
    x = X[, "x"],
    y = X[, "y"],
    stringsAsFactors = FALSE
  )

  list(
    niche_cells = niche_cells,
    composition = composition,
    composition_prop = composition_prop,
    kmeans = km,
    params = list(image = image, kNN = kNN, K = K, max_cells = max_cells, include_self = include_self, seed = seed),
    engine = nn$engine
  )
}

add_niches_to_object <- function(obj, niche_cells, niche_col = "spatial_niche") {
  obj[[niche_col]] <- NA_character_
  obj@meta.data[niche_cells$cell, niche_col] <- niche_cells$niche
  obj@meta.data[[niche_col]] <- factor(obj@meta.data[[niche_col]])
  obj
}

summarize_niche_composition <- function(niche_result) {
  comp_df <- as.data.frame(niche_result$composition_prop)
  comp_df$niche <- niche_result$niche_cells$niche[match(rownames(comp_df), niche_result$niche_cells$cell)]
  comp_summary <- stats::aggregate(. ~ niche, data = comp_df, FUN = mean)
  comp_summary[order(comp_summary$niche), , drop = FALSE]
}

plot_spatial_niches <- function(niche_cells, title = NULL) {
  ggplot2::ggplot(niche_cells, ggplot2::aes(x = x, y = y, color = niche)) +
    ggplot2::geom_point(size = 0.7, alpha = 0.9) +
    ggplot2::coord_fixed() +
    ggplot2::theme_classic(base_size = 14) +
    ggplot2::labs(title = title %||% "Spatial niches", x = "x", y = "y", color = "Niche")
}

`%||%` <- function(x, y) if (is.null(x)) y else x
