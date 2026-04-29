# 01_prepare_object.R -------------------------------------------------------
# Prepare a CosMx/NanoString Seurat object for downstream analysis.

source("R/00_packages.R")
load_required_packages()

source("R/cosmx_io.R")
source("R/cosmx_metadata.R")

cfg <- read_config("config/config.yml")

obj <- read_cosmx_seurat(cfg$paths$input_seurat_rds)

# Optional sample metadata. Use a de-identified CSV with at least sample_id.
if (file.exists(cfg$paths$sample_metadata_csv)) {
  sample_md <- readr::read_csv(cfg$paths$sample_metadata_csv, show_col_types = FALSE)
  obj <- add_sample_metadata(
    obj,
    sample_metadata = sample_md,
    object_sample_col = cfg$seurat$sample_id_col,
    metadata_sample_col = "sample_id"
  )
}

obj <- ensure_celltype_column(
  obj,
  source_col = cfg$seurat$celltype_source_col,
  target_col = cfg$seurat$celltype_publication_col
)

obj <- prepare_nanostring_assay(
  obj,
  assay = cfg$seurat$assay,
  join_layers = cfg$seurat$join_layers,
  normalize = cfg$seurat$normalize,
  normalization_method = cfg$seurat$normalization_method,
  scale_factor = cfg$seurat$scale_factor
)

print(summarize_metadata_mapping(obj, cols = c("HIV_status", "plaque_type")))

save_cosmx_object(obj, cfg$paths$prepared_seurat_rds)
write_session_info("outputs/sessionInfo.txt")
