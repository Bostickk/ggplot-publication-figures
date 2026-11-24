# Style demonstration only: synthetic observations, no hypothesis tests.
library(ggplot2)

repo_root <- getOption("biomed.repo_root", NULL)
if (is.null(repo_root)) {
  script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  if (length(script_arg) != 1L) stop("Run this example with Rscript examples/prism_style_demo.R")
  script_path <- normalizePath(sub("^--file=", "", script_arg), mustWork = TRUE)
  repo_root <- dirname(dirname(script_path))
}
source(file.path(repo_root, "scripts", "figure_export.R"))
export_args <- parse_figure_export_args(default_output=file.path(repo_root, "examples", "output"))
output_dir <- export_args$output
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
groups <- c("Group A", "Group B", "Group C", "Group D")
values <- list(
  c(3.2, 4.1, 3.7, 5.0, 4.4, 3.4, 4.8, 3.9, 4.6, 3.5),
  c(7.2, 9.0, 8.1, 10.3, 8.7, 7.6, 9.5, 8.4, 10.0, 7.9),
  c(5.4, 6.7, 5.9, 7.4, 6.3, 5.6, 7.0, 6.1, 7.7, 6.5),
  c(4.3, 5.5, 4.9, 6.2, 5.2, 4.6, 5.8, 5.0, 6.5, 4.7)
)
dat <- data.frame(
  group = factor(rep(groups, each = 10), levels = groups),
  sample = rep(seq_len(10), 4), value = unlist(values),
  provenance = "Synthetic data for style demonstration"
)
write.csv(dat, file.path(output_dir, "prism_npgsoft_style_demo_synthetic_data.csv"), row.names = FALSE)
source(file.path(repo_root, "scripts", "publication_palettes.R"))
palette <- setNames(get_publication_palette("npg_soft", length(groups)), groups)
summary_df <- data.frame(group = factor(groups, levels = groups),
                         mean = vapply(values, mean, numeric(1)),
                         sd = vapply(values, sd, numeric(1)))

base_theme <- if (requireNamespace("ggprism", quietly = TRUE)) {
  ggprism::theme_prism(base_size = 12, base_family = "sans",
                       base_fontface = "plain", base_line_size = 0.6,
                       base_rect_size = 0.5, border = FALSE)
} else {
  theme_classic(base_size = 12, base_family = "sans")
}
prism_npgsoft_theme <- base_theme +
  theme(axis.title = element_text(face = "bold", size = 13),
        axis.text = element_text(size = 11, colour = "black"),
        axis.title.y = element_text(margin = margin(r = 10)),
        axis.text.x = element_text(margin = margin(t = 7)),
        axis.ticks.length = grid::unit(3, "pt"),
        panel.grid = element_blank(), panel.border = element_blank(),
        legend.position = "none", plot.margin = margin(12, 16, 12, 10))

points <- geom_point(
  data = dat, aes(x = group, y = value), inherit.aes = FALSE,
  position = position_jitter(width = 0.14, height = 0, seed = 42),
  shape = 21, colour = "black", fill = "white", alpha = 1,
  size = 2.5, stroke = 0.55, show.legend = FALSE
)

p_bar <- ggplot(summary_df, aes(group, mean, fill = group)) +
  geom_col(width = 0.60, colour = "black", linewidth = 0.55) +
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd),
                width = 0.17, colour = "black", linewidth = 0.55) +
  points + scale_fill_manual(values = palette) +
  scale_y_continuous(breaks = seq(0, 12, 2), expand = expansion(mult = c(0, 0.07))) +
  labs(x = NULL, y = "Measurement (a.u.)") + prism_npgsoft_theme

p_box <- ggplot(dat, aes(group, value, fill = group)) +
  geom_boxplot(width = 0.55, colour = "black", linewidth = 0.55,
               outlier.shape = NA, staplewidth = 0.45) +
  points + scale_fill_manual(values = palette) +
  scale_y_continuous(breaks = seq(0, 12, 2), expand = expansion(mult = c(0, 0.07))) +
  expand_limits(y = 0) + labs(x = NULL, y = "Measurement (a.u.)") + prism_npgsoft_theme

for (kind in c("bar", "box")) {
  p <- if (kind == "bar") p_bar else p_box
  stem <- file.path(output_dir, paste0("prism_npgsoft_", kind, "_scatter_demo"))
  export_publication_figure(p, stem, 5.2, 4.5, export_args$formats, export_args$ppi)
}
capture.output(sessionInfo(), file = file.path(output_dir, "session-info.txt"))
stopifnot(nrow(dat) == 40L, all(is.finite(dat$value)), min(dat$value) >= 0)
message("Exported two plots in selected formats: ", paste(export_args$formats,collapse=", "), "; PNG defaults to 300 ppi; synthetic data only.")

writeLines(c(
  "# Prism-style figure demonstration",
  "",
  "Synthetic data only; 10 observations per group; no hypothesis tests.",
  "",
  "Bar heights: mean; error bars: sample SD. All observations are shown.",
  "",
  figure_report_link("Bar plot", "prism_npgsoft_bar_scatter_demo", export_args$formats),
  "",
  "Boxes: median and interquartile range; whiskers: observations within 1.5 x IQR.",
  "All observations are shown by the point layer, including outliers.",
  "",
  figure_report_link("Boxplot", "prism_npgsoft_box_scatter_demo", export_args$formats)
), file.path(output_dir, "report.md"))
