# 生信与高维结果图

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


## 连续色标与分析结果

热图的行 Z-score 等相对变换采用以 0 为中心的发散色标，色标范围覆盖实际数据。表达量、GeneRatio、校正后 P 值等按变量含义选择顺序色标。分组色板用于离散组别；火山图 Up/Down/NS 各自固定语义。图注标明输入矩阵、上游分析方法、变换和排序规则。结果表的阈值与图形筛选保持一致。

本批可运行示例为 10 火山图、11 行 Z-score 热图、12 ORA 点图。ORA 示例使用清楚标记的模拟结果表，未经真实富集检验；GSEA 的 NES 与 running enrichment score 使用专门的分析结果，保留其方法名称。

样式实现：`../scripts/biomedical_styles.R` 的 `theme_biomedical("omics")`。见 [生信示例](../examples/biomedical_gallery.md#10-volcano)。
