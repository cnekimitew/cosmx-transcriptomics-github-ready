# Differential expression and volcano plots ---------------------------------

run_pairwise_de <- function(
  obj,
  group_col,
  ident_1,
  ident_2,
  assay = NULL,
  test_use = "wilcox",
  logfc_threshold = 0,
  min_pct = 0.1
) {
  if (!group_col %in% colnames(obj@meta.data)) {
    stop("Group column '", group_col, "' not found.", call. = FALSE)
  }

  Seurat::Idents(obj) <- group_col

  Seurat::FindMarkers(
    obj,
    ident.1 = ident_1,
    ident.2 = ident_2,
    assay = assay,
    test.use = test_use,
    logfc.threshold = logfc_threshold,
    min.pct = min_pct
  ) |>
    tibble::rownames_to_column("gene") |>
    dplyr::mutate(p_val_adj = p.adjust(.data$p_val, method = "BH"))
}

plot_volcano <- function(
  de_results,
  genes_to_label = NULL,
  p_adj_cutoff = 0.05,
  logfc_cutoff = log2(1.5),
  title = "Differential expression"
) {
  required <- c("gene", "avg_log2FC", "p_val_adj")
  missing <- setdiff(required, colnames(de_results))
  if (length(missing) > 0) {
    stop("DE results missing columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }

  plot_df <- de_results |>
    dplyr::mutate(
      neg_log10_padj = -log10(pmax(.data$p_val_adj, .Machine$double.xmin)),
      significant = .data$p_val_adj < p_adj_cutoff & abs(.data$avg_log2FC) >= logfc_cutoff,
      label = ifelse(.data$gene %in% genes_to_label, .data$gene, NA_character_)
    )

  ggplot2::ggplot(plot_df, ggplot2::aes(x = avg_log2FC, y = neg_log10_padj)) +
    ggplot2::geom_point(ggplot2::aes(alpha = significant), size = 1.5) +
    ggrepel::geom_text_repel(
      data = subset(plot_df, !is.na(label)),
      ggplot2::aes(label = label),
      max.overlaps = Inf
    ) +
    ggplot2::geom_hline(yintercept = -log10(p_adj_cutoff), linetype = "dashed") +
    ggplot2::geom_vline(xintercept = c(-logfc_cutoff, logfc_cutoff), linetype = "dashed") +
    ggplot2::theme_classic(base_size = 12) +
    ggplot2::labs(
      title = title,
      x = "Average log2 fold change",
      y = "-log10 adjusted p-value"
    ) +
    ggplot2::guides(alpha = "none")
}
