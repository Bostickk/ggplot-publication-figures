# ggplot2 科研绘图与 Figure 交付规范

本规范用于使用 **R + ggplot2** 生成、修改、审计和交付科研图片。默认目标是期刊投稿 Figure、补充材料或正式科研报告，而不是 PPT 风格展示。规范不仅约束“图看起来怎么样”，也约束数据是否被忠实呈现、标签如何选择、文件如何版本化，以及图片是否真正嵌入最终文档。

## 1. 优先级与完成标准

科研绘图的优先级依次为：**数据与统计结果真实 > 图形语义准确 > 缩小后的可读性 > 信息密度 > 风格统一与美观**。任何美化都不能改变原始数值、统计检验、显著性阈值、候选对象排序或结论方向。

一张图只有同时满足以下条件才算完成：绘图规则明确且可复现；输出文件存在；PNG、PDF、SVG 内容一致；图中文字在缩小至约 50% 后仍可读；没有被坐标范围悄悄隐藏的数据；最终报告嵌入的是本次生成的准确路径；图注或正文说明了必要的阈值、选择规则和仅用于展示的变换。

## 2. 数据分析与视觉呈现必须分离

原始数据、统计分析变量和展示变量应分开保存。建议至少保留 `value_raw`、`value_plot` 和 `display_status` 三类字段：`value_raw` 用于统计检验和排序，`value_plot` 仅用于绘图，`display_status` 记录是否发生封顶、截断或其他展示变换。

禁止为了“图更好看”而直接修改原始表格、删除极端样本、改变显著性、重新定义分组，或只保留支持假说的基因和通路。若确实需要排除样本或重新计算统计量，必须回到分析流程，给出预设规则、理由和敏感性分析，不能在绘图代码中暗中完成。

所有非显然的展示变换都应在图注或报告方法说明中披露，包括坐标封顶、标签位移、名称缩写、长标签换行、只展示 Top N、对数变换和伪计数。图内默认不使用 subtitle 或长 caption 承载这些说明。

## 3. 代码与复现

默认使用 `ggplot2`。数据整理、统计计算、标签选择、绘图和导出应分开书写，避免在一个 `ggplot()` 调用中混杂不可审计的筛选逻辑。最终图对象保存为有意义的名称，如 `p_volcano`、`p_go_bp`，而不是反复覆盖无法追踪的临时对象。

绘图脚本至少应明确记录：输入文件或上游对象；比较组及方向；统计方法；显著性阈值；标签选择规则；颜色和分组顺序；画布尺寸；输出路径；软件和关键包版本。涉及 `ggrepel` 或其他随机布局时必须固定 `seed`，确保相同输入产生相同标签布局。

推荐结构：加载包 → 读取并检查数据 → 定义因子顺序、颜色和显示名称 → 计算统计或读取冻结结果 → 构造展示变量 → 构建图对象 → 三格式导出 → 自动检查 → 视觉检查。

## 4. 默认主题

默认使用白色背景和简洁期刊风格，可从 `theme_classic(base_size = 11)` 或经过精简的 `theme_minimal(base_size = 11)` 开始。不要使用 ggplot2 默认灰底，也不要添加装饰性边框、阴影、渐变背景或 PPT 式文本框。

```r
theme_publication <- function(base_size = 11) {
  theme_classic(base_size = base_size) +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_blank(),
      plot.caption = element_blank(),
      axis.title = element_text(size = 12),
      axis.text = element_text(size = 10.5, colour = "black"),
      legend.title = element_text(size = 11),
      legend.text = element_text(size = 10),
      legend.position = "bottom",
      legend.box = "horizontal",
      strip.background = element_blank(),
      strip.text = element_text(size = 11, face = "bold"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      plot.margin = margin(5.5, 5.5, 5.5, 5.5)
    )
}
```

主题是起点而不是固定模板。若某类图需要浅色主网格帮助读取连续数值，可以保留少量水平网格线，但线条应轻、数量应少，并有明确阅读价值。

## 5. 标题、图内文字与命名

正式 Figure 默认可以不保留主标题；若保留，只使用一个简短主标题并水平居中。默认不添加 subtitle、长 caption、方法说明或结论性句子。比较组、统计方法和阈值若已能从坐标轴与图注理解，不应在标题中重复。

组名必须能让论文读者独立理解。内部文件可以使用短名，但图中首次出现时更推荐“疾病状态 + 干预 + 剂量/单位”，例如 `SAP + Sesamol (25 mg/kg)`，而不是脱离上下文的 `SAP-25`。所有缩写应在图注首次定义，并在同一项目中保持完全一致。

GO 结果必须标明本体范围。若只分析 biological process，不得笼统写成 `GO enrichment`；应写成 `GO biological process` 或 `GO-BP`。如果同时分析 biological process、cellular component 和 molecular function，应分别标记 BP、CC、MF，且报告未显著的本体，不得让读者误以为只存在 BP。

## 6. 单图、分面与组合图

默认每个分析图独立生成和保存，不自行使用 `patchwork`、`cowplot` 或 `gridExtra` 拼接。一个 comparison、一个统计问题或一个可独立引用的分析对象通常对应一个文件，便于后续统一排版和替换。

只有在同一图内直接比较确有科学意义时才使用 facet。例如同一 comparison 的 UP 与 DOWN 富集结果可以上下排列为两个板块，但不应把多个无关 comparison 挤入一个大图。facet strip 使用白底或无背景，标题简短；若分面导致主绘图区明显变窄、标签难读或空面板过多，应拆分为单图。

## 7. 画布、字体与无效留白

画布由数据决定，不让数据去填预设的大画布。常规横向单图通常为 5.5–7 inch 宽，纵向单图通常为 4.5–6 inch 宽，高度根据分类、标签、图例和显著性标记动态调整。分类较多时优先增加高度，而不是同时扩大宽度。

默认 `base_size` 不低于 11。主标题约 13–15 pt，坐标轴标题 11–13 pt，刻度和分类标签 10–12 pt，图例标题 10–12 pt，图例文字 9.5–11 pt，统计标记 10–12 pt。禁止把关键文字缩到 8 pt 以下来解决拥挤；应优先重排布局、换行标签、移动图例或调整画布比例。

连续坐标可合理使用 `expand = expansion(mult = c(0.01, 0.03))`，但在设置范围之前必须统计是否有点、误差线、标签或显著性标记位于范围外。减少留白不能成为裁掉数据的理由。

## 8. 坐标范围、极端值与裁剪

**禁止使用 `xlim()`、`ylim()`、`scale_*_continuous(limits = ...)` 或 `coord_cartesian()` 悄悄隐藏数据。** 在设定任何固定范围前，必须计算范围外观测数量、方向、原始最小值和最大值，并确认范围不会隐藏被标记对象。

极端值较少且扩展坐标后仍能保持主体可读时，优先完整展示所有数据。若极端值使绝大多数数据压缩到无法阅读，可以只对展示坐标进行封顶或挤压，但必须遵守四项规则：统计和排序仍使用原始值；边界点使用不同形状或明确标记；边界刻度写成 `≤−L`、`≥L` 等含义明确的形式；图注或报告明确说明这是展示封顶及其阈值。

```r
display_limit <- 8

plot_df <- result_df |>
  dplyr::mutate(
    log2fc_raw = log2FoldChange,
    log2fc_plot = pmax(pmin(log2fc_raw, display_limit), -display_limit),
    display_status = dplyr::case_when(
      log2fc_raw >  display_limit ~ "capped_high",
      log2fc_raw < -display_limit ~ "capped_low",
      TRUE ~ "within_range"
    )
  )
```

展示封顶点应作为单独图层绘制，并设置 `show.legend = FALSE`，除非其形状含义已在图例中准确解释。不能让辅助图层意外改变主图图例的点形状。使用 `coord_cartesian(clip = "off")` 时要检查是否出现穿出面板的长引线、越界标签或被导出边界切掉的元素。

## 9. 标签选择与引线

所有自动标签必须有确定、可复现的规则。规则应先在数据表中生成标签名单，再交给绘图层；禁止依赖图形当前范围或肉眼临时选择。若加入少量预设机制基因，应将它们作为单独的“生物学关注基因”层，并在图注说明，不能与统计 Top 基因混成一个不透明名单。

`ggrepel` 使用固定 `seed`。引线应细、浅、尽可能短；标签应靠近对应数据点，并为图周围留出合理边距。若出现跨越大半个面板的引线，首先检查数据点是否被坐标裁掉、展示坐标与标签坐标是否不一致，随后再调整 `box.padding`、`point.padding`、`max.overlaps` 和画布。禁止通过缩小标签字体来掩盖布局问题。

最终至少检查标签最密集、极端值最多的那张图，而不是只检查最简单的代表图。应同时查看原尺寸和约 50% 缩放版本，确认基因名、引线和阈值线仍可辨认。

## 10. 图例、颜色与图层语义

图例默认放在底部并横向排列，标题应短，多个图例应尽量合并或紧凑排列。若右侧图例明显压缩绘图区，应移动到底部；能够直接标注且不会造成拥挤时，可删除无必要图例。

颜色应期刊友好、色盲可辨，并在同一项目中保持相同含义。颜色不能是唯一编码；在关键比较中可结合形状、线型或直接标签。阈值线、参考线和背景辅助层应低调，不得比数据更突出。

每一个额外图层都要检查是否影响图例。用于封顶点、背景区间、辅助边界或标签定位的图层通常应设置 `inherit.aes = FALSE` 或 `show.legend = FALSE`。只有读者需要解释该图层时，才让它进入图例。

## 11. 火山图

火山图的横轴通常为 `log2 fold change`，纵轴优先使用 `−log10(adjusted P value)`。正式 DEG 阈值必须预先明确，例如 `padj < alpha` 且 `|log2FC| > cutoff`；不能在不同图之间悄悄改变阈值，也不能把 raw P value 与 adjusted P value 混用。

默认标签规则为：在正式 DEG 中，上调和下调分别选择 adjusted P value 最小的 Top 4，以及 `|log2FC|` 最大的 Top 4；两组名单取并集，重复基因只标一次。若信息量或期刊版面需要改变 Top N，应在代码参数和图注中同时修改，不能手工删减。排序要明确处理缺失值和并列值，并使用稳定的次级排序键。

```r
select_volcano_labels <- function(df, n_each = 4) {
  deg <- df |>
    dplyr::filter(!is.na(padj), padj < alpha, abs(log2FoldChange) > lfc_cutoff) |>
    dplyr::mutate(direction = ifelse(log2FoldChange > 0, "Up", "Down"))

  by_padj <- deg |>
    dplyr::group_by(direction) |>
    dplyr::arrange(padj, dplyr::desc(abs(log2FoldChange)), gene, .by_group = TRUE) |>
    dplyr::slice_head(n = n_each)

  by_lfc <- deg |>
    dplyr::group_by(direction) |>
    dplyr::arrange(dplyr::desc(abs(log2FoldChange)), padj, gene, .by_group = TRUE) |>
    dplyr::slice_head(n = n_each)

  dplyr::bind_rows(by_padj, by_lfc) |>
    dplyr::distinct(gene, .keep_all = TRUE)
}
```

极端 log2FC 常见于低计数基因。若上游分析允许，可将 LFC shrinkage 用于排序或补充展示，但必须说明估计方法；不能在冻结结果之后无说明地把原始 log2FC 替换成收缩值。无论是否收缩，低表达风险应结合平均表达量和原始计数复核，不能只凭极端倍数变化确定机制基因。

## 12. GO、KEGG、ORA 与 GSEA

GO/KEGG/ORA/GSEA 默认每个 comparison、每种数据库或本体独立输出。标题简短居中或省略，term 长标签使用 `stringr::str_wrap()`，通常每行 30–45 个字符。分类数量增加时增加高度，不用超宽画布或小字体解决。

必须区分过度富集分析（over-representation analysis, ORA）与基因集富集分析（gene set enrichment analysis, GSEA）。ORA 的输入通常是阈值筛选后的基因列表，GSEA 使用完整排序基因列表；两者的统计量、背景和解释不能互换。图题、文件名和报告文字都应明确写出方法。

GO 应明确 BP、CC、MF 是否均进行了检验。若只做 BP，必须在图名、文件名和正文中明确。UP/DOWN 可以上下两个板块呈现，但应保持共同的颜色和大小语义；若某方向没有通过预设多重校正阈值的 term，应在相应位置显示简洁的 `No term passed BH q < 0.05`，而不是留下不解释的空白板块或悄悄删除该方向。

只显示 Top N 时，排序规则必须在代码中固定，例如先按 `padj`，再按 GeneRatio 或 NES。项目关注通路可以另做机制导向图，但不得把人工筛选的通路称为“无偏 Top N”。图注应说明总显著通路数、显示数量及筛选方式。

## 13. 热图、PCA、相关性及分组分布图

热图应使用与分析一致的表达矩阵和变换。基因选择、标准化方式、聚类距离、聚类方法、样本注释和色标中心必须明确。行 Z-score 只表示同一基因跨样本的相对变化，不得被解释为基因间绝对表达量。Top 上调与 Top 下调基因的选择应确定化、去重，并在图注写明阈值与排序依据。

PCA 应说明输入变换、纳入基因和方差解释率。样本点标签或异常样本标记不能被坐标范围遮挡；若添加置信椭圆，应确认样本量与分布足以支持其解释。相关性热图应说明相关系数、表达变换和是否对角聚类，颜色范围应以有意义的中心对称或按数据范围设置。

箱线图、小提琴图和柱状图不得用柱形均值掩盖原始生物学重复。样本量允许时应叠加独立数据点。误差线必须说明表示 SD、SEM、CI 还是其他量；统计学标记要预留空间，但不能造成大面积上方空白。技术孔、视野或切片不能被画成独立生物学重复。

## 14. 负结果与空结果

没有显著结果也是结果。若某 comparison、方向或数据库没有通过预设阈值的条目，应保留一个紧凑、明确的空结果面板或单图说明，而不是用未校正结果填充、改变阈值或直接省略。空结果图不应占用与复杂富集图相同的大画布。

当直接比较为 0 DEG 时，不应生成看似有大量信号的 Top DEG 热图；可以改为展示效应量分布、候选基因估计及置信区间，或明确标注无正式 DEG。图形设计不能制造不存在的“剂量差异”。

## 15. 文件导出、命名与版本

最终图同时导出 PDF、SVG 和 300 ppi 以上 PNG。三种格式必须来自同一个图对象、相同尺寸和相同数据，不能分别修改。含大量点或透明度时，应检查 PDF/SVG 文件大小和渲染是否异常。

```r
export_figure <- function(p, stem, width, height, dpi = 600) {
  ggsave(paste0(stem, ".png"), p, width = width, height = height,
         units = "in", dpi = dpi, bg = "white")
  ggsave(paste0(stem, ".pdf"), p, width = width, height = height,
         units = "in", device = cairo_pdf, bg = "white")
  ggsave(paste0(stem, ".svg"), p, width = width, height = height,
         units = "in", bg = "white")
}
```

文件名应包含足以识别的分析对象、comparison、方法和必要版本信息，避免 `final.png`、`new2.png`。当标签规则、坐标策略或整体设计发生实质变化时，应使用新的描述性文件名，不要只覆盖原文件名。旧文件可保留用于追溯，但最终报告只能嵌入当前版本。新的唯一文件名也能减少 Obsidian、浏览器或图片预览器缓存旧图的问题。

## 16. Obsidian 与 Markdown 报告交付

生成图片文件不等于完成交付。每次修改后必须确认最终报告中嵌入的是新文件，而不是旧路径或旧文件名；图注、方法说明和显示规则也要同步更新。

Obsidian 的 `![[...]]` 通常按 vault 根目录解析。应先找到实际 `.obsidian` 所在目录并将其作为 vault root，再验证每一个嵌入路径。不能用“相对当前 note 的路径能够拼接成功”代替 Obsidian 的实际解析规则。标准 Markdown 图片 `![alt](path)` 通常按文档所在目录解析，应与 Wikilink 区分检查。

推荐维护一份图形清单，至少包含：figure ID、分析对象、比较组、PNG/PDF/SVG 路径、生成脚本、生成时间、标签规则、展示变换、报告嵌入位置和当前/废弃状态。图形清单与报告嵌入应一一对应。

## 17. 自动检查与视觉检查

自动检查至少包括：预期图形数量；PNG/PDF/SVG 是否齐全；文件是否非空且大小合理；同一 stem 的三种格式是否存在；报告中的每个嵌入路径是否按真实规则解析；是否仍引用旧文件名；标签名单有无重复；坐标范围外观测数量；封顶点数量与方向；显著性阈值和选择规则是否一致。

自动通过不能替代视觉检查。视觉检查至少包括：标题是否居中且未被裁切；字体在 50% 缩放后是否清楚；数据区域是否占主体；图例是否正确且紧凑；长标签是否合理换行；极端点是否可见；标签引线是否过长或穿出面板；显著性标记、误差线和边界点是否被裁切；不同格式渲染是否一致。

检查对象不能只选“代表图”。至少查看一张常规图、一张标签最密集的图、一张极端值最多的图，以及一张空结果或负结果图。若这些图属于同一批量模板，任何一张暴露出模板问题，都应回到代码修复整批图。

## 18. 输出前清单

1. 数据和统计结果是否保持原样，展示变量是否单独保存？
2. 比较方向、单位、阈值、样本量和分析方法是否明确？
3. 是否存在被坐标范围隐藏的点、标签、误差线或统计标记？
4. 极端值若被封顶，是否保留原值、标记边界并在图注说明？
5. 标签选择是否确定、可复现、去重且使用 adjusted P value？
6. `ggrepel` 是否固定 seed，标签引线是否短而清楚？
7. GO 是否说明 BP、CC、MF 范围，ORA 与 GSEA 是否正确区分？
8. 负结果是否诚实、紧凑地展示，而不是被省略或换阈值？
9. 图形是否白底、简洁、无 subtitle，必要主标题是否居中？
10. 长标签、图例、画布和边距是否针对数据调整，而不是缩小字体？
11. 缩小到约 50% 后，坐标轴、分类名称、图例和标记是否仍可读？
12. 是否分别导出了内容一致的 PNG、PDF、SVG？
13. 实质修改是否使用新文件名，最终文档是否不再嵌入旧版本？
14. Obsidian Wikilink 是否按真实 vault root 验证，Markdown 图片是否按文档目录验证？
15. 自动检查和最困难图形的视觉检查是否均已通过？

若任一项答案是否定，应先修复，再把图片标记为可交付版本。

