# Code cleanup report

This repository was generated from an exploratory CosMx R Markdown notebook. The original notebook contained repeated package loading, hard-coded Desktop/Dropbox paths, exploratory inspection chunks, duplicated plots for each slide, interactive `locator()` zoom code, and study-specific metadata directly embedded in the analysis file.

## Major changes made

1. **Moved reusable logic into functions**
   - `R/cosmx_io.R`: object loading, assay joining, normalization, saving.
   - `R/cosmx_metadata.R`: cell-type and sample metadata harmonization.
   - `R/cosmx_plotting.R`: reusable spatial, molecule-overlay, UMAP/dot-plot helpers.
   - `R/cosmx_niches.R`: kNN spatial neighborhood/niche analysis.
   - `R/cosmx_de.R`: differential-expression and volcano plotting.

2. **Removed hard-coded local paths**
   - Paths now live in `config/config.yml`, created from `config/config_template.yml`.

3. **Separated exploratory code from publication workflow**
   - Main analysis scripts are in `analysis/`.
   - Optional R Markdown report is in `notebooks/`.

4. **Protected data release hygiene**
   - Large Seurat objects, RData files, raw CosMx output, and local processed data are ignored by git.
   - A template metadata file is provided instead of embedding potentially sensitive sample identifiers.

5. **Added reproducibility scaffolding**
   - Project file, README, DESCRIPTION, .gitignore, session-info output, and code-availability statement template.
