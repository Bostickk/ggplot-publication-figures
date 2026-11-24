new_gallery_context <- function(repo, out) {
  e <- new.env(parent = globalenv())
  e$repo <- repo; e$out <- out; e$items <- list(); e$plots <- list()
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  e$csv <- function(d, name) {
    write.csv(d, file.path(out, paste0(name, ".csv")), row.names = FALSE, na = "NA")
  }
  e$save <- function(p, id, title, caption, width = 5.7, height = 4.6, seed = NA_integer_) {
    for (ext in c("png", "pdf", "svg")) {
      args <- list(filename = file.path(out, paste0(id, ".", ext)), plot = p,
                   width = width, height = height, units = "in", bg = "white")
      if (ext == "png") args$dpi <- 400
      if (ext == "pdf") args$device <- grDevices::cairo_pdf
      if (ext == "svg") args$device <- grDevices::svg
      do.call(ggplot2::ggsave, args)
    }
    e$items[[id]] <- list(id = id, title = title, caption = caption, seed = seed,
                          width_in = width, height_in = height,
                          files = paste0(id, c(".png", ".pdf", ".svg")))
    e$plots[[id]] <- p
  }
  e
}

observation_layer <- function(...) {
  ggplot2::geom_point(..., shape = 21, colour = "black", fill = "white",
                      alpha = 1, size = 2.3, stroke = 0.5, show.legend = FALSE)
}

# Expand tabular estimates into exactly horizontal-then-vertical steps for CI bands.
step_band <- function(d) {
  n <- nrow(d)
  if (n < 2L) return(d)
  idx <- rep(seq_len(n), each = 2L)[- (2L * n)]
  ans <- d[idx, , drop = FALSE]
  ans$time <- rep(d$time, each = 2L)[-1L]
  ans
}
