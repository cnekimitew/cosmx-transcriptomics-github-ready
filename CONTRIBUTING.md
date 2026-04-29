# Contributing

This repository provides a reproducible analysis workflow for CosMx/NanoString spatial transcriptomics data stored as a Seurat object.

## Repository organization

- Put reusable functions in `R/`.
- Put runnable workflow scripts in `analysis/`.
- Put optional R Markdown workflows in `notebooks/`.
- Put manuscript-related language in `manuscript/`.
- Put generated figures and tables in `outputs/`.

## Coding style

- Use clear object names, for example `cosmx_obj` rather than `seu.obj3`.
- Keep reusable code in functions rather than repeating long code blocks.
- Use `config/config.yml` for local paths and user-specific parameters.
- Do not hard-code local paths in scripts or notebooks.
- Keep example paths in `config/config_template.yml`.
- Add brief comments for analysis steps that may not be obvious to new users.
- Run code from a clean R session before submitting changes.

## Data and privacy

Do not commit protected health information, restricted clinical metadata, raw CosMx output folders, processed Seurat objects, `.Rds`, `.RData`, `.rda`, `.qs`, local configuration files, or generated outputs.

The file `config/config_template.yml` should contain example paths only. The local file `config/config.yml` should be used for real paths and should remain ignored by git.

## Before committing

Before committing changes, confirm that:

- No local paths are present, such as `/Users/`, `Desktop`, or `Dropbox`.
- No raw or processed data files are included.
- No protected health information or restricted clinical metadata are included.
- `config/config.yml` is not staged for commit.
- Generated outputs are not staged for commit.
- The workflow runs from a clean R session.
