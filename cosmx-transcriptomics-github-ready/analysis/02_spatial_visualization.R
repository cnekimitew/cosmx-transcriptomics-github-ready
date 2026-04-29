# 02_spatial_visualization.R ------------------------------------------------
# Generate spatial, UMAP, molecule-overlay, and dot-plot figures.

source("R/00_packages.R")
load_required_packages()

source("R/cosmx_io.R")
source("R/cosmx_plotting.R")

cfg <- read_config("config/config.yml")
obj <- read_cosmx_seurat(cfg$paths$prepared_seurat_rds)
Seurat::DefaultAssay(obj) <- cfg$seurat$assay

fig_dir <- cfg$paths$figures_dir

# Slide-level plots.
slide_plots <- plot_all_images(
  obj,
  group_by = cfg$seurat$celltype_publication_col,
  border_color = NA,
  axes = FALSE
)

for (nm in names(slide_plots)) {
  save_plot(slide_plots[[nm]], file.path(fig_dir, paste0("spatial_cells_", nm, ".png")), width = 8, height = 6)
}

# UMAP colored by publication cell type, if UMAP exists.
if ("umap" %in% names(obj@reductions)) {
  p_umap <- Seurat::DimPlot(
    obj,
    reduction = "umap",
    group.by = cfg$seurat$celltype_publication_col,
    label = TRUE,
    repel = TRUE
  ) + ggplot2::theme_classic(base_size = 12)

  save_plot(p_umap, file.path(fig_dir, "umap_celltype_pub.png"), width = 8, height = 6)
}

# Dot plot for marker genes.
p_dot <- plot_marker_dotplot(
  obj,
  genes = unlist(cfg$plotting$dotplot_genes),
  group_by = cfg$seurat$celltype_publication_col
)
save_plot(p_dot, file.path(fig_dir, "dotplot_marker_genes.png"), width = 14, height = 6)

# Optional molecule overlay for a configured FOV/image.
image_use <- cfg$niches$fov
if (image_use %in% Seurat::Images(obj)) {
  p_mols <- plot_spatial_molecules(
    obj,
    image = image_use,
    molecules = unlist(cfg$plotting$molecule_overlay_genes),
    alpha = 0.1,
    mols_size = 0.8,
    nmols = 1e5,
    border_color = NA,
    axes = FALSE
  )

  save_plot(p_mols, file.path(fig_dir, paste0("molecule_overlay_", image_use, ".png")), width = 9, height = 7)
}
