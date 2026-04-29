# 04_differential_expression.R ---------------------------------------------
# Pairwise differential expression and volcano plotting.

source("R/00_packages.R")
load_required_packages()

source("R/cosmx_io.R")
source("R/cosmx_de.R")
source("R/cosmx_plotting.R")

cfg <- read_config("config/config.yml")
obj <- read_cosmx_seurat(cfg$paths$prepared_seurat_rds)
Seurat::DefaultAssay(obj) <- cfg$seurat$assay

de_results <- run_pairwise_de(
  obj,
  group_col = cfg$differential_expression$group_col,
  ident_1 = cfg$differential_expression$ident_1,
  ident_2 = cfg$differential_expression$ident_2,
  assay = cfg$seurat$assay,
  test_use = "wilcox",
  logfc_threshold = 0,
  min_pct = 0.1
)

readr::write_csv(de_results, file.path(cfg$paths$tables_dir, "pairwise_differential_expression.csv"))

p_volcano <- plot_volcano(
  de_results,
  genes_to_label = unlist(cfg$differential_expression$genes_to_label),
  title = paste(cfg$differential_expression$ident_1, "vs", cfg$differential_expression$ident_2)
)

save_plot(p_volcano, file.path(cfg$paths$figures_dir, "volcano_plot.png"), width = 7, height = 6)
