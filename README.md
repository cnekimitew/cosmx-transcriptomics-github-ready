# CosMx Spatial Transcriptomics Analysis

This repository contains reproducible R code for analysis and visualization of CosMx/NanoString spatial transcriptomics data stored as a Seurat object. The workflow includes object preparation, metadata harmonization, spatial visualization, neighborhood/niche analysis, marker visualization, and differential-expression plotting.

## Repository structure

```text
.
├── R/                         # Reusable functions
│   ├── 00_packages.R
│   ├── cosmx_io.R
│   ├── cosmx_metadata.R
│   ├── cosmx_plotting.R
│   ├── cosmx_niches.R
│   └── cosmx_de.R
├── analysis/                  # Runnable analysis scripts
│   ├── 01_prepare_object.R
│   ├── 02_spatial_visualization.R
│   ├── 03_spatial_niches.R
│   └── 04_differential_expression.R
├── config/                    # User-editable paths and parameters
│   └── config_template.yml
├── data/                      # Placeholder only; large data are not tracked
│   ├── README.md
│   └── sample_metadata_template.csv
├── outputs/                   # Generated figures/tables; ignored by git
├── manuscript/                # Code/data availability language
└── notebooks/                 # Optional R Markdown workflow
```

## Quick start

1. Clone the repository.
2. Copy `config/config_template.yml` to `config/config.yml`.
3. Edit `config/config.yml` so paths point to your local Seurat object and metadata file.
4. Install required packages:

```r
install.packages(c(
  "Seurat", "SeuratObject", "dplyr", "ggplot2", "ggrepel", "patchwork",
  "pheatmap", "yaml", "readr", "tibble", "FNN", "Matrix", "viridis"
))
```

5. Run the workflow from the project root:

```r
source("analysis/01_prepare_object.R")
source("analysis/02_spatial_visualization.R")
source("analysis/03_spatial_niches.R")
source("analysis/04_differential_expression.R")
```

## Data availability

Large Seurat objects, raw CosMx outputs, processed data objects, and protected clinical metadata are not included in this GitHub repository. Publicly shareable data will be available through GEO accession GSE324056. If applicable, reviewer access tokens will be provided during peer review and public access will be enabled upon publication.

## Main workflow

### 1. Prepare object

`analysis/01_prepare_object.R` reads a Seurat object, harmonizes sample metadata, optionally joins Seurat v5 assay layers, normalizes expression, and saves a publication-ready Seurat object.

### 2. Spatial visualization

`analysis/02_spatial_visualization.R` generates slide-level spatial plots, FOV-level zooms, molecule overlays, UMAP plots, and dot plots for marker panels.

### 3. Spatial niches

`analysis/03_spatial_niches.R` computes local neighborhoods using k-nearest neighbors over spatial coordinates, summarizes neighboring cell-type composition, clusters neighborhoods into spatial niches, and plots niche locations.

### 4. Differential expression

`analysis/04_differential_expression.R` provides a simple Seurat `FindMarkers()` wrapper and publication-style volcano plots.

## Reproducibility notes

- All file paths are controlled from `config/config.yml`.
- Random steps use explicit seeds.
- Generated outputs are written to `outputs/` and are ignored by git.
- Package versions should be recorded using `sessionInfo()` or `renv::snapshot()` before release.

## Recommended citation language

See `manuscript/code_availability.md`.

## License

The analysis code in this repository is made available under the MIT License. See the `LICENSE` file for details.

This license applies only to the code in this repository. Raw data, processed Seurat objects, clinical metadata, images, and other restricted study materials are not included and may be subject to separate data-use restrictions.
