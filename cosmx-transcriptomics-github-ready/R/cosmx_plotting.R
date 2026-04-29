# Spatial and expression plotting helpers ----------------------------------

plot_all_images <- function(obj, group_by = NULL, border_color = NA, axes = TRUE) {
  fovs <- Seurat::Images(obj)
  plots <- lapply(fovs, function(fov) {
    Seurat::ImageDimPlot(
      obj,
      fov = fov,
      group.by = group_by,
      border.color = border_color,
      axes = axes
    ) + ggplot2::ggtitle(fov)
  })
  names(plots) <- fovs
  plots
}

get_fov_bounds <- function(obj, image, fov_value, metadata_fov_col = "fov", sample_col = NULL, sample_value = NULL) {
  md <- obj@meta.data

  keep <- md[[metadata_fov_col]] == fov_value
  if (!is.null(sample_col) && !is.null(sample_value)) {
    keep <- keep & md[[sample_col]] == sample_value
  }

  cells <- rownames(md)[keep]
  if (length(cells) == 0) {
    stop("No cells found for selected FOV.", call. = FALSE)
  }

  centroids <- obj@images[[image]]$centroids
  coords <- centroids@coords[centroids@cells %in% cells, , drop = FALSE]
  if (nrow(coords) == 0) {
    stop("No centroid coordinates found for selected cells.", call. = FALSE)
  }

  apply(coords, 2, range, na.rm = TRUE)
}

plot_spatial_molecules <- function(
  obj,
  image,
  molecules,
  bounds = NULL,
  alpha = 0.1,
  mols_size = 0.5,
  nmols = 1e5,
  border_color = NA,
  axes = FALSE
) {
  p <- Seurat::ImageDimPlot(
    obj,
    fov = image,
    border.color = border_color,
    alpha = alpha,
    molecules = molecules,
    mols.size = mols_size,
    nmols = nmols,
    axes = axes
  )

  if (!is.null(bounds)) {
    p <- p + ggplot2::coord_cartesian(
      xlim = bounds[, 2],
      ylim = bounds[, 1],
      expand = FALSE
    )
  }

  p
}

plot_marker_dotplot <- function(obj, genes, group_by = NULL) {
  genes <- genes[genes %in% rownames(obj)]
  if (length(genes) == 0) {
    stop("None of the requested genes were found in the object.", call. = FALSE)
  }
  Seurat::DotPlot(obj, features = genes, group.by = group_by) +
    Seurat::RotatedAxis() +
    ggplot2::theme_classic(base_size = 12)
}

save_plot <- function(plot, filename, width = 8, height = 6, dpi = 300) {
  dir.create(dirname(filename), recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(filename, plot, width = width, height = height, dpi = dpi)
  invisible(filename)
}
