# Data directory

Do not commit raw CosMx files, Seurat objects, RData files, protected health information, or large intermediate objects to GitHub.

Recommended layout:

```text
data/
├── raw/                 # local only; ignored by git
├── processed/           # local only; ignored by git
└── sample_metadata_template.csv
```

Use `sample_metadata_template.csv` as a model for de-identified sample metadata. Replace placeholder rows with study-specific sample IDs only if they are approved for public release.
