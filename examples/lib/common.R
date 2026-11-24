new_gallery_context <- function(repo, out, formats = "png", ppi = 300) {
  formats <- normalise_figure_formats(formats)
  e <- new.env(parent = globalenv())
  e$repo <- repo; e$out <- out; e$formats <- formats; e$ppi <- ppi; e$items <- list(); e$plots <- list()
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  e$csv <- function(d, name) {
    write.csv(d, file.path(out, paste0(name, ".csv")), row.names = FALSE, na = "NA")
  }
  e$save <- function(p, id, title, caption, width = 5.7, height = 4.6, seed = NA_integer_) {
    export_publication_figure(p, file.path(out, id), width, height, formats, ppi)
    e$items[[id]] <- list(id = id, title = title, caption = caption, seed = seed,
                          width_in = width, height_in = height,
                          formats = as.list(formats), png_ppi = if ("png" %in% formats) ppi else NULL,
                          files = as.list(paste0(id, ".", formats)))
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
