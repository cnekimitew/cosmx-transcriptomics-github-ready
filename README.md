CosMX - HIV analysis


This repository contains reproducible R code for analysis and visualization of CosMx/NanoString spatial transcriptomics data stored as a Seurat object. The workflow includes object preparation, metadata harmonization, spatial visualization, spatial neighborhood/niche analysis, marker visualization, and differential-expression plotting.

## Repository structure

```text
.
├── R/                         # Reusable functions
├── analysis/                  # Runnable analysis scripts
├── config/                    # Configuration templates
├── data/                      # Metadata templates only; large data are not tracked
├── notebooks/                 # Optional R Markdown workflows
├── manuscript/                # Code/data availability language
└── outputs/                   # Generated outputs; ignored by git
