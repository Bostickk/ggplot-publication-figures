---
name: ggplot-publication-figures
description: Create, revise, audit, and deliver publication-ready scientific figures with R and ggplot2. Use when making manuscript figures, standardizing bioinformatics plots, fixing clipping or label problems, exporting PNG/PDF/SVG, or embedding figures in Obsidian/Markdown reports. Enforces deterministic selections, data-preserving display rules, visual QC, and delivery-path validation.
---

# ggplot Publication Figures

Use this skill for figures intended for manuscripts, supplements, formal reports, or later multi-panel assembly. Do not use presentation polish as permission to alter source data, statistical results, thresholds, or biological interpretation.

## Required reference

Read [references/ggplot2 科研绘图规范.md](references/ggplot2%20科研绘图规范.md) completely before creating, revising, or auditing a figure. Apply the figure-specific rules and the delivery checklist, not just the theme defaults.

## Workflow

1. Establish the scientific object: comparison, statistical method, thresholds, units, sample size, and intended figure role.
2. Separate analysis variables from display variables. Preserve original values for statistics and ranking; record any wrapping, capping, squishing, or label displacement used only for display.
3. Build one independent plot per output file unless the user explicitly requests a composite. Use deterministic sorting and a fixed random seed for label placement.
4. Export the same plot object to PNG, PDF, and SVG. Use a new descriptive filename when the design or selection rule materially changes.
5. Run automated file/path checks and visually inspect both the full-size plot and an approximately 50% rendering. Inspect the densest or most extreme plot, not only an easy representative.

## Non-negotiable checks

- Never use axis limits to silently hide observations, labels, error bars, or annotations.
- Never manually cherry-pick labelled genes without declaring a prespecified biological annotation layer.
- Never call a GO analysis complete without stating whether BP, CC, and MF were tested.
- Never describe ORA as GSEA or GSEA as ORA.
- Never shrink essential text below readable manuscript-panel size to solve crowding.
- Never treat “files generated” as “delivered” until report embeds resolve to the exact current files.
- When an extreme value is capped for display, keep the original value for analysis, mark the boundary point distinctly, label the boundary tick, and explain the display-only transformation outside the plot.

## Grouped continuous-data plot defaults

For grouped continuous measurements with individual observations, default to a bar plot with overlaid points or a boxplot with overlaid points. Choose the summary to match the scientific question: bars for an explicitly intended mean and defined error measure, boxes for the median and distribution. Apply these defaults unless the user explicitly requests a different style:

- Use a GraphPad Prism-inspired appearance for these plots: white background, black left/bottom axes and outward ticks, no grid or enclosing panel border, readable sans-serif text, capped error bars, and compact significance brackets. Prefer `ggprism::theme_prism()` when available, with the clear, moderately saturated fills and point styling below; otherwise use the ggplot2 fallback in reference section 4. Do not use the generic theme unchanged for these grouped plots.
- Every overlaid observation is a circular, black-outlined, white-filled point: `shape = 21`, `colour = "black"`, `fill = "white"`, `alpha = 1`. Set these outside `aes()` so group scales do not override them.
- Bars and boxes have black outlines and clear, moderately saturated fills; avoid fluorescent colours and overly grey fills. Default to `npg_soft` from the reusable [palette guide](references/palette-guide.md). Read that guide when selecting or changing grouped-plot colours; exact HEX values and provenance are in [palette-bank.json](references/palette-bank.json), with reusable R vectors in `scripts/publication_palettes.R`. Preserve project group-to-colour mappings and explicit user choices.
- Jitter horizontally only with a fixed seed; retain exact measured y-values. Show all available independent biological observations. When overlaying all points on a boxplot, use `outlier.shape = NA` to avoid drawing outliers twice.
- If only aggregate summaries or counts are supplied, style the bars consistently and state that individual observations are unavailable; do not invent points. These defaults apply to grouped measurement plots, not to unrelated plot types such as volcano plots or PCA.

## Delivery validation

For Obsidian or Markdown reports, run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate_figure_delivery.ps1 `
  -ReportPath "D:\path\report.md" `
  -VaultRoot "D:\path\vault"
```

The validator checks embedded file resolution, PNG/PDF/SVG sibling files, and minimum file size. A passing automated check does not replace visual inspection.

