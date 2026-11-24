# Export only the formats selected for this invocation. PNG defaults to 300 ppi.
normalise_figure_formats <- function(formats = "png") {
  formats <- unique(sub("^\\.", "", tolower(trimws(unlist(strsplit(formats, ",", fixed = TRUE))))))
  if (!length(formats) || any(!formats %in% c("png", "pdf", "svg"))) {
    stop("Select one or more formats from png, pdf, svg.")
  }
  formats
}

parse_figure_export_args <- function(args = commandArgs(trailingOnly = TRUE), default_output) {
  result <- list(formats = "png", ppi = 300, output = default_output)
  seen <- character()
  for (arg in args) {
    if (!grepl("^--(formats|ppi|output)=", arg)) stop("Unknown argument: ", arg)
    key <- sub("^--([^=]+)=.*$", "\\1", arg)
    if (key %in% seen) stop("Repeated argument: ", key)
    seen <- c(seen, key)
    value <- sub("^--[^=]+=", "", arg)
    if (!nzchar(value)) stop("Empty argument: ", key)
    result[[key]] <- value
  }
  result$formats <- normalise_figure_formats(result$formats)
  result$ppi <- suppressWarnings(as.numeric(result$ppi))
  if (length(result$ppi) != 1L || !is.finite(result$ppi) || result$ppi <= 0 || result$ppi != floor(result$ppi)) {
    stop("ppi must be a positive integer.")
  }
  result
}

export_publication_figure <- function(p, stem, width, height, formats = "png", ppi = 300) {
  formats <- normalise_figure_formats(formats)
  if (!is.numeric(ppi) || length(ppi) != 1L || !is.finite(ppi) || ppi <= 0 || ppi != floor(ppi)) stop("ppi must be a positive integer.")
  for (ext in formats) {
    args <- list(filename = paste0(stem, ".", ext), plot = p, width = width,
                 height = height, units = "in", bg = "white")
    if (ext == "png") args$dpi <- ppi
    if (ext == "pdf") args$device <- grDevices::cairo_pdf
    if (ext == "svg") args$device <- grDevices::svg
    do.call(ggplot2::ggsave, args)
  }
  paste0(stem, ".", formats)
}

figure_report_link <- function(title, stem, formats = "png") {
  formats <- normalise_figure_formats(formats)
  ext <- if ("png" %in% formats) "png" else if ("svg" %in% formats) "svg" else "pdf"
  paste0(if (ext == "pdf") "[" else "![", title, "](", stem, ".", ext, ")")
}
