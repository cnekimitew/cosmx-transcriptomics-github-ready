# 03_spatial_niches.R -------------------------------------------------------
# Compute and visualize spatial niches using kNN neighborhood composition.

source("R/00_packages.R")
load_required_packages()

source("R/cosmx_io.R")
source("R/cosmx_niches.R")
source("R/cosmx_plotting.R")

cfg <- read_config("config/config.yml")
obj <- read_cosmx_seurat(cfg$paths$prepared_seurat_rds)

niche_result <- compute_spatial_niches(
  obj,
  image = cfg$niches$fov,
  celltype_col = cfg$seurat$celltype_publication_col,
  kNN = cfg$niches$kNN,
  K = cfg$niches$K,
  max_cells = cfg$niches$max_cells,
  include_self = cfg$niches$include_self,
  seed = cfg$niches$seed
)

niche_cells <- niche_result$niche_cells
niche_summary <- summarize_niche_composition(niche_result)

readr::write_csv(niche_cells, file.path(cfg$paths$tables_dir, "spatial_niche_cell_assignments.csv"))
readr::write_csv(niche_summary, file.path(cfg$paths$tables_dir, "spatial_niche_composition.csv"))

p_niche <- plot_spatial_niches(
  niche_cells,
  title = paste0("CosMx spatial niches: ", cfg$niches$fov)
)
save_plot(p_niche, file.path(cfg$paths$figures_dir, "spatial_niches.png"), width = 8, height = 7)

obj <- add_niches_to_object(obj, niche_cells, niche_col = "spatial_niche")
save_cosmx_object(obj, cfg$paths$prepared_seurat_rds)
