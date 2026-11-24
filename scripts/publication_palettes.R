# Reusable categorical fills. Sources and adaptation details: references/palette-bank.json.
# Default npg_soft: NPG mixed with 20% white in sRGB, reordered blue/red/green/navy.
publication_palettes <- list(
  npg_soft = c("#71C9DD", "#EB6F5D", "#33B39F", "#6376A0", "#F5AF99", "#9DA7C3", "#A7DACE", "#E33333", "#98816D", "#C0B09D"),
  npg = c("#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F", "#8491B4", "#91D1C2", "#DC0000", "#7E6148", "#B09C85"),
  nejm = c("#BC3C29", "#0072B5", "#E18727", "#20854E", "#7876B1", "#6F99AD", "#FFDC91", "#EE4C97"),
  lancet = c("#00468B", "#ED0000", "#42B540", "#0099B4", "#925E9F", "#FDAF91", "#AD002A", "#ADB6B6", "#1B1919"),
  aaas = c("#3B4992", "#EE0000", "#008B45", "#631879", "#008280", "#BB0021", "#5F559B", "#A20056", "#808180", "#1B1919"),
  set2 = c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#FFD92F", "#E5C494", "#B3B3B3"),
  tol_bright = c("#4477AA", "#EE6677", "#228833", "#CCBB44", "#66CCEE", "#AA3377", "#BBBBBB"),
  tol_light = c("#77AADD", "#EE8866", "#EEDD88", "#FFAABB", "#99DDFF", "#44BB99", "#BBCC33", "#AAAA00", "#DDDDDD")
)

get_publication_palette <- function(name = "npg_soft", n = 4L) {
  if (!is.character(name) || length(name) != 1L || is.na(name) ||
      !name %in% names(publication_palettes)) stop("Unknown palette name.")
  colours <- publication_palettes[[name]]
  if (!is.numeric(n) || length(n) != 1L || !is.finite(n) ||
      n < 1 || n != floor(n) || n > length(colours)) {
    stop("n must be an integer from 1 to the number of stored colours; use another palette or facets for more groups.")
  }
  unname(colours[seq_len(n)])
}
