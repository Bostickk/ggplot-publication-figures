# 科研分组图配色库

核对日期：2026-11-24。用于离散分组的柱体、箱体及其他分组填充。散点保持黑边白心圆形。推荐默认 `npg_soft`：保留清晰色感，适中饱和度，避免过度灰化；用户明确选色时使用所选方案。

## 选择与复现

- `npg_soft` 为本地调整版：NPG 原色按 sRGB 各通道混入 20% 白色，四舍五入，顺序调整为蓝、红、绿、深蓝等。色值固定，不使用透明度稀释颜色。原版另存为 `npg`。
- `npg`、`nejm`、`lancet`、`aaas` 是 ggsci 的期刊图形启发配色，名称表示灵感来源。Set2 来自 ColorBrewer，Bright 和 Light 来自 Paul Tol。原始色值和顺序保存在 `palette-bank.json`。
- 优先推荐 `npg_soft`；需要更柔和的多色填充可选 `set2` 或 `tol_light`；需要更深对比可选 `nejm`。具体判断仍以实际输出为准。
- 将颜色按组名固定，先检查数据中的组名与颜色映射完全对应，同一项目保持一致。用户指定组色优先。
- 配色数量超过库存时另选方案或分面。定性分组保留独立色值；连续量、热图和正负效应使用相应连续或发散色标。
- 色觉差异优先考虑原版 `tol_bright`，并检查所用颜色、黑白打印和实际图形；调整后的颜色应重新检查。组别同时通过位置和标签表达。

```r
source("<skill-root>/scripts/publication_palettes.R")
group_order <- c("Control", "Model", "Treatment A", "Treatment B")
group_colours <- setNames(get_publication_palette("npg_soft", length(group_order)), group_order)
# Add to a plot whose fill maps to the same group names:
# scale_fill_manual(values = group_colours)
```

## 已存方案与来源

### `npg_soft` — NPG soft (adapted)

推荐的清亮柔和默认值，适合 Prism 风格柱体和箱体。

`#71C9DD #EB6F5D #33B39F #6376A0 #F5AF99 #9DA7C3 #A7DACE #E33333 #98816D #C0B09D`

来源：[NPG soft (adapted)](https://nanx.me/ggsci/reference/pal_npg.html)。提取：`Derived from stored NPG original`。

调整记录：Rounding half up in sRGB: new = 0.80 * original + 0.20 * white. Original one-based order: 2,1,3,4,5,6,7,8,9,10. Opaque HEX; alpha stays 1.

### `npg` — NPG original

颜色区分清楚，适合分组测量图。

`#E64B35 #4DBBD5 #00A087 #3C5488 #F39B7F #8491B4 #91D1C2 #DC0000 #7E6148 #B09C85`

来源：[NPG original](https://nanx.me/ggsci/reference/pal_npg.html)。提取：`ggsci::pal_npg("nrc")(10)`。

### `nejm` — NEJM

蓝、红、橙、绿均衡，适合临床与基础研究分组。

`#BC3C29 #0072B5 #E18727 #20854E #7876B1 #6F99AD #FFDC91 #EE4C97`

来源：[NEJM](https://nanx.me/ggsci/reference/pal_nejm.html)。提取：`ggsci::pal_nejm("default")(8)`。

### `lancet` — Lancet

对比强，红色较醒目；适合需要较强组间区分时。

`#00468B #ED0000 #42B540 #0099B4 #925E9F #FDAF91 #AD002A #ADB6B6 #1B1919`

来源：[Lancet](https://nanx.me/ggsci/reference/pal_lancet.html)。提取：`ggsci::pal_lancet("lanonc")(9)`。

### `aaas` — AAAS

整体较深，红色突出，作为高对比备选。

`#3B4992 #EE0000 #008B45 #631879 #008280 #BB0021 #5F559B #A20056 #808180 #1B1919`

来源：[AAAS](https://nanx.me/ggsci/reference/pal_aaas.html)。提取：`ggsci::pal_aaas("default")(10)`。

### `set2` — ColorBrewer Set2

柔和且有色感，适合柱体与箱体填充。

`#66C2A5 #FC8D62 #8DA0CB #E78AC3 #A6D854 #FFD92F #E5C494 #B3B3B3`

来源：[ColorBrewer Set2](https://colorbrewer2.org/#type=qualitative&scheme=Set2&n=8)。提取：`RColorBrewer::brewer.pal(8, "Set2")`。

### `tol_bright` — Paul Tol Bright

需要优先考虑色觉差异时的备选，仍须核对实际用色组合。

`#4477AA #EE6677 #228833 #CCBB44 #66CCEE #AA3377 #BBBBBB`

来源：[Paul Tol Bright](https://sronpersonalpages.nl/~pault/)。提取：`Paul Tol Figure 1; original order`。

### `tol_light` — Paul Tol Light

清浅、明亮，适合有黑色轮廓的填充区域；细线优先用更深的颜色。

`#77AADD #EE8866 #EEDD88 #FFAABB #99DDFF #44BB99 #BBCC33 #AAAA00 #DDDDDD`

来源：[Paul Tol Light](https://sronpersonalpages.nl/~pault/)。提取：`Paul Tol Figure 8; original order`。

