# Code availability statement template

All code used to process, visualize, and analyze CosMx spatial transcriptomics data is available at: [insert GitHub URL]. The repository includes R scripts for Seurat object preparation, metadata harmonization, spatial visualization, k-nearest-neighbor neighborhood/niche analysis, and differential-expression plotting. Large raw data files, intermediate Seurat objects, and protected clinical metadata are not stored in the GitHub repository. Instructions for obtaining approved de-identified data or processed objects are provided in the repository README and associated data-availability statement.

# Reproducibility checklist

Before public release:

- [ ] Remove or replace all local file paths.
- [ ] Confirm no protected health information or non-public sample identifiers are included.
- [ ] Confirm metadata fields are de-identified and approved for release.
- [ ] Add final GitHub URL and Zenodo DOI, if applicable.
- [ ] Run the workflow from a clean R session using `config/config.yml`.
- [ ] Save `sessionInfo()` or add an `renv.lock` file.
- [ ] Confirm all figures/tables can be regenerated from documented inputs.
