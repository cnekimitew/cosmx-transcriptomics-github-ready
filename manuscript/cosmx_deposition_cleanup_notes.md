# CosMx code deposition cleanup notes

## Main issues fixed or flagged

1. Removed repeated `library()` calls and consolidated package loading.
2. Replaced hard-coded Desktop/Dropbox paths with editable variables.
3. Renamed `seu.obj3` to `cosmx_obj` for readability.
4. Moved sample annotation into a dedicated metadata section.
5. Flagged participant/sample identifiers that should be de-identified or externalized before GitHub deposition.
6. Replaced repeated `ImageDimPlot()` calls with reusable helper functions.
7. Consolidated repeated niche-analysis code into one function.
8. Disabled optional Giotto and differential-expression sections by default.
9. Added output directory creation and `sessionInfo()` for reproducibility.
10. Added notes recommending pseudobulk/sample-aware models for manuscript-level differential expression.

## Files not to upload publicly

Do not upload raw or processed data files unless the data are approved for public release:

- `.Rds`
- `.RData`
- `.qs`
- raw CosMx output folders
- files containing direct identifiers or sample IDs not approved for public release
- `config.yml` containing local paths

## Suggested repository structure

```text
cosmx-spatial-transcriptomics/
├── README.md
├── notebooks/
│   └── cosmx_transcriptomics_publication_clean.Rmd
├── R/
│   ├── spatial_helpers.R
│   ├── niche_helpers.R
│   └── plotting_helpers.R
├── data/
│   └── sample_metadata_template.csv
├── results/
│   └── .gitkeep
├── .gitignore
└── renv.lock
```

## Suggested code availability language

Analysis code used to process and visualize the CosMx spatial transcriptomics data is available at [GitHub repository link]. Raw and processed spatial transcriptomics data are available through [repository/dbGaP/GEO/Zenodo/institutional repository] under controlled access, in accordance with participant consent and institutional approvals.
