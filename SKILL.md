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

## Delivery validation

For Obsidian or Markdown reports, run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/validate_figure_delivery.ps1 `
  -ReportPath "D:\path\report.md" `
  -VaultRoot "D:\path\vault"
```

The validator checks embedded file resolution, PNG/PDF/SVG sibling files, and minimum file size. A passing automated check does not replace visual inspection.

