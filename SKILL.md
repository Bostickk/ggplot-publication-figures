---
name: ggplot-publication-figures
description: Create, revise, and audit biomedical manuscript figures with R and ggplot2. Use for Prism-style experimental plots, forest plots, survival and competing-risk curves, omics figures, publication export, and report figure delivery.
---

# ggplot Publication Figures

Use the author's supplied data and confirmed analyses to create reproducible figures. Read [core principles](references/core.md), then only the applicable module below. Existing context is sufficient when it already establishes the task; ask only about missing information that directly affects the requested figure.

| Figure/task | Read |
| --- | --- |
| Bar/box with points, paired, longitudinal, nested, dose-response | [Experimental](references/experimental.md) |
| Forest, Kaplan–Meier, cumulative incidence and risk tables | [Clinical](references/clinical.md) |
| Volcano, heatmap, PCA, correlation, GO/KEGG, ORA/GSEA | [Omics](references/omics.md) |
| Image quantification, representative images, WB, scale bars | [Imaging](references/imaging.md) |
| Requested multi-panel figure or aligned plot/table | [Composition](references/composition.md) |
| Palette choice/change | [Palette guide](references/palette-guide.md) |
| Export, captions, report embeds and final review | [Delivery](references/delivery.md) |

## Defaults

- Grouped measurements: Prism-inspired white background, black axes and outlines, bars or boxes with observations. Observation points are circular, black-outlined and white-filled (`shape = 21, colour = "black", fill = "white", alpha = 1`), specified outside `aes()`. Boxplot outliers are shown once by the observation layer.
- Use clear moderately saturated fills, default `npg_soft`; preserve explicit user choices and project group mappings. Reusable palettes: `scripts/publication_palettes.R`; exact HEX/provenance: `references/palette-bank.json`.
- Apply figure-family semantics: effect axes and CI for forests; step curves, censor marks and risk tables for survival; continuous/diverging colour scales for omics. Use `scripts/biomedical_styles.R` for scoped theme profiles.
- Keep confirmed models, thresholds, exclusions and result values stable during visual edits. Store supplied analysis results separately from display variables. Compute new analyses only within the scope of the current request; clearly label simulated analyses in examples.
- Export each independent plot from one object to PNG/PDF/SVG. Compose only when requested or when a risk table belongs to its time-to-event plot. Inspect full and reduced renderings and verify report paths before delivery.

## Examples and validation

Read [the synthetic gallery](examples/biomedical_gallery.md) for 12 runnable examples, their captions and limitations. Run `Rscript examples/biomedical_gallery.R` from the repository to regenerate them. These examples illustrate styles and implementations; choose analyses from the actual study design.

For figure embeds, run `pwsh -File scripts/validate_figure_delivery.ps1 -ReportPath <report.md> -VaultRoot <vault-or-project-root>`. This checks file delivery and complements visual inspection.
