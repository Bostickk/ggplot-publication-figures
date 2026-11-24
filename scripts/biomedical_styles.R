# Scoped styles for ggplot2 biomedical figures; no global theme changes.
theme_biomedical <- function(profile = c("prism", "clinical", "omics"), base_size = 11,
                             base_family = "sans") {
  profile <- match.arg(profile)
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Install ggplot2 to use these themes.")
  base <- if (profile == "prism" && requireNamespace("ggprism", quietly = TRUE)) {
    ggprism::theme_prism(base_size = base_size, base_family = base_family,
                        base_fontface = "plain", base_line_size = 0.55,
                        base_rect_size = 0.5, border = FALSE)
  } else ggplot2::theme_classic(base_size = base_size, base_family = base_family)
  out <- base + ggplot2::theme(
    panel.grid = ggplot2::element_blank(), panel.border = ggplot2::element_blank(),
    axis.line = ggplot2::element_line(colour = "black", linewidth = 0.55),
    axis.ticks = ggplot2::element_line(colour = "black", linewidth = 0.55),
    axis.ticks.length = grid::unit(3, "pt"),
    axis.title = ggplot2::element_text(face = "bold"),
    axis.text = ggplot2::element_text(colour = "black"),
    plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
    plot.subtitle = ggplot2::element_blank(), plot.caption = ggplot2::element_blank(),
    legend.position = "bottom", legend.title = ggplot2::element_blank(),
    strip.background = ggplot2::element_blank(),
    strip.text = ggplot2::element_text(face = "bold"),
    plot.background = ggplot2::element_rect(fill = "white", colour = NA),
    plot.margin = ggplot2::margin(8, 12, 8, 8)
  )
  if (profile == "omics") out <- out + ggplot2::theme(axis.ticks = ggplot2::element_blank())
  out
}
