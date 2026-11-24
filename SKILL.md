---
name: ggplot-publication-figures
description: Create, revise, and audit biomedical manuscript figures with R and ggplot2. Use for Prism-style experimental plots, forest plots, survival and competing-risk curves, omics figures, publication export, and report figure delivery.
license: MIT
---

# ggplot Publication Figures

## Ask about output formats on every invocation

At the start of every invocation of this plotting skill, ask the user which of PNG, PDF and SVG to produce. Present **PNG only at 300 ppi** as the default selection; allow any combination. Ask again for each new invocation, including when an earlier invocation established preferences. If the current request already names formats, ask a brief confirmation of that selection. Example: “本次需要哪些输出格式？默认仅 300 ppi PNG，也可选 PDF、SVG 或任意组合。”

Wait for the user's answer before final export. A preselected default or elapsed time is not confirmation. While waiting, inspect supplied materials or prepare the plot as useful. Produce only the confirmed formats; PNG uses 300 ppi unless the user explicitly requests another resolution. Record formats and PNG ppi in the delivery manifest. For a review-only invocation, this same opening question can establish whether any new files are wanted.

## Route the task

Use the author's supplied data and confirmed analyses to create reproducible figures. Read [core principles](references/core.md), then only the applicable module below. Beyond the required format question above, reuse existing context and ask only about missing information that directly affects the requested figure.

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
- Export each independent plot from one object to only the confirmed formats; default selection is 300 ppi PNG. Compose only when requested or when a risk table belongs to its time-to-event plot. Inspect full and reduced renderings and verify report paths before delivery.

## Examples and validation

Read [the synthetic gallery](examples/biomedical_gallery.md) for 12 runnable examples, their captions and limitations. Run `Rscript examples/biomedical_gallery.R` from the repository to regenerate them. These examples illustrate styles and implementations; choose analyses from the actual study design.

For figure embeds or PDF links, run `pwsh -File scripts/validate_figure_delivery.ps1 -ReportPath <report.md> -VaultRoot <vault-or-project-root>`. The validator defaults to PNG only; pass `-ExpectedFormats` matching this invocation's confirmed formats when different. This checks file delivery and complements visual inspection.
