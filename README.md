# ggplot-publication-figures

A reusable Codex skill for creating, revising, auditing, and delivering publication-ready scientific figures with R and ggplot2.

The skill focuses on scientific integrity as well as appearance. It prevents silent axis clipping, requires deterministic label selection, distinguishes display-only transformations from analysis values, and verifies that figure files are actually embedded in Obsidian or Markdown reports.

## Contents

- `SKILL.md` — Codex skill entry point and required workflow.
- `references/ggplot2 科研绘图规范.md` — complete Chinese publication-figure specification.
- `scripts/validate_figure_delivery.ps1` — checks report embeds and matching PNG/PDF/SVG files.

## Install

Clone the repository into the Codex skills directory:

```powershell
git clone https://github.com/Bostickk/ggplot-publication-figures.git `
  "$env:USERPROFILE\.codex\skills\ggplot-publication-figures"
```

Restart or refresh Codex so the new skill is discovered. The skill can then be invoked explicitly as `$ggplot-publication-figures`, and it may also be selected automatically for manuscript-quality ggplot2 work.

## Delivery validation

```powershell
powershell -ExecutionPolicy Bypass `
  -File scripts/validate_figure_delivery.ps1 `
  -ReportPath "D:\path\report.md" `
  -VaultRoot "D:\path\vault"
```

The validator distinguishes Obsidian Wikilinks from standard Markdown image paths and verifies that each embedded figure has matching PNG, PDF, and SVG files.

## Core rules

- Preserve original values for statistics and ranking; keep display variables separate.
- Never use coordinate limits to silently hide observations or labels.
- Use deterministic and declared gene/pathway selection rules.
- State whether GO-BP, GO-CC, and GO-MF were tested.
- Distinguish ORA from GSEA in filenames, titles, and interpretation.
- Inspect the full-size figure and an approximately 50% rendering.
- Treat figure generation, multi-format export, report embedding, and path validation as one delivery workflow.

This repository is private and currently has no open-source license.
