# 基础实验与分组测量图

适用于柱状、箱线、配对、时间曲线、分层散点和剂量–反应图。

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

### 分组数据图默认接近 GraphPad Prism

柱状图加散点、箱线图加散点采用 **GraphPad Prism 风格**：白底，黑色左轴和下轴，向外的短刻度，无网格、无顶部和右侧外框；使用 Arial 或可用的相近无衬线字体，轴标题适度加粗，刻度文字清楚。误差线采用黑色细线和短端帽，显著性括号紧凑并置于数据上方。柱宽、组间距、散点大小和线宽随最终画布调整，优先保证缩小后可读。柱状图数值轴默认包含零点；箱线图按完整数据范围设置。配色和散点按第 13 节执行。

优先使用 `ggprism::theme_prism()`，该包专门提供接近 Prism 的 ggplot2 主题；其默认配色和字重仍需按本规范覆盖。若环境中尚无该包，使用下面的纯 ggplot2 后备主题，并记录实际使用的主题。仅有样式更新时无需安装额外软件。官方主题说明：https://csdaw.github.io/ggprism/articles/themes.html 。

```r
theme_prism_publication <- function(base_size = 11, base_family = "sans") {
  base <- if (requireNamespace("ggprism", quietly = TRUE)) {
    ggprism::theme_prism(base_size = base_size, base_family = base_family,
                        base_fontface = "plain", base_line_size = 0.6,
                        base_rect_size = 0.5, border = FALSE)
  } else {
    theme_classic(base_size = base_size, base_family = base_family)
  }
  base + theme(
    panel.grid = element_blank(), panel.border = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    plot.background = element_rect(fill = "white", colour = NA),
    axis.line = element_line(colour = "black", linewidth = 0.6),
    axis.ticks = element_line(colour = "black", linewidth = 0.6),
    axis.ticks.length = grid::unit(3, "pt"),
    axis.title = element_text(face = "bold", colour = "black"),
    axis.text = element_text(colour = "black"),
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_blank(), plot.caption = element_blank(),
    legend.position = "bottom", legend.direction = "horizontal",
    legend.title = element_blank(), legend.key = element_blank(),
    plot.margin = margin(5.5, 5.5, 5.5, 5.5)
  )
}
```

Prism 风格只调整视觉样式。误差量、统计检验、配对关系、须的定义和显著性结果均依据研究设计及实际数据确定。

### 分组连续测量数据的默认图形与样式

有个体观测值的分组连续测量数据，默认使用**带散点的柱状图或带散点的箱线图**。需要展示均值及预先明确的误差量时使用柱状图；需要展示中位数、四分位数及分布时使用箱线图。用户明确指定图形或样式时按当次要求执行。小提琴图在用户要求或分布展示确有需要时使用，并沿用以下散点样式。

- **散点：圆形、黑色描边、白色填充。** 使用 `shape = 21, colour = "black", fill = "white", alpha = 1`，推荐 `size = 2.2, stroke = 0.5`。这些固定样式写在 `aes()` 外，散点不映射组别颜色、填充或形状。通过横轴位置、分面和标签区分组别。
- **柱体和箱体：黑色描边、清亮且适中饱和度的填色。** 使用 `colour = "black"`，推荐 `linewidth = 0.5`。默认使用配色库中的 `npg_soft`，避免荧光色和过度灰化；其前四色为 `c("#71C9DD", "#EB6F5D", "#33B39F", "#6376A0")`。选择或更换配色时读取 [配色指南](palette-guide.md)，原始色值与调整记录见 [palette-bank.json](palette-bank.json)，R 色值与取色函数见 `../scripts/publication_palettes.R`。按组名建立具名颜色映射，同一项目保持一致。分组较多时补充直接标签或分面。
- 散点放在柱体或箱体上层，展示全部可用的独立生物学观测。只在水平方向抖动，固定 `seed`，保持纵轴测量值原样；分组柱或分组箱线图的散点须与对应组的横向位置对齐。
- 箱线图叠加全部散点时设置 `outlier.shape = NA`，由散点层完整展示离群观测，避免同一个样本绘制两次。
- 柱状图的误差线注明 SD、SEM、CI 或其他量；箱线图注明箱体与须的定义。统计学标记按需预留空间。技术孔、视野或切片先按实验单位汇总；配对或重复测量保留对应的个体关系和统计设计。

以下示例假定 `plot_df` 每行对应一个独立生物学观测，含因子 `group` 和数值 `value`；`group_colours` 是按组名建立的上述柔和色值映射。

```r
# 箱线图 + 全部观测点（须为 1.5 × IQR；离群值由散点层显示）
p_box <- ggplot(plot_df, aes(group, value, fill = group)) +
  geom_boxplot(width = 0.55, outlier.shape = NA,
               colour = "black", linewidth = 0.5) +
  geom_point(position = position_jitter(width = 0.12, height = 0, seed = 42),
             shape = 21, colour = "black", fill = "white",
             alpha = 1, size = 2.2, stroke = 0.5, show.legend = FALSE) +
  scale_fill_manual(values = group_colours) +
  theme_prism_publication()

# 柱状图 + 全部观测点；本例明确展示均值 ± SD
summary_df <- plot_df |>
  dplyr::group_by(group) |>
  dplyr::summarise(mean = mean(value, na.rm = TRUE),
                   sd = sd(value, na.rm = TRUE), .groups = "drop")
p_bar <- ggplot(summary_df, aes(group, mean, fill = group)) +
  geom_col(width = 0.6, colour = "black", linewidth = 0.5) +
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd),
                width = 0.15, colour = "black", linewidth = 0.5) +
  geom_point(data = plot_df, aes(x = group, y = value), inherit.aes = FALSE,
             position = position_jitter(width = 0.12, height = 0, seed = 42),
             shape = 21, colour = "black", fill = "white",
             alpha = 1, size = 2.2, stroke = 0.5, show.legend = FALSE) +
  scale_fill_manual(values = group_colours) +
  theme_prism_publication()
```

示例中的缺失值处理须与实际数据核对，并报告各组有效样本量；误差量须按研究问题选择。只有汇总均值、比例或计数时，柱体仍使用黑色描边和柔和填色，同时说明缺少个体数据。散点只依据真实观测生成。这套默认样式用于分组测量数据，火山图、PCA、富集条形图等保留各自的数据语义和颜色规则。


## 配对变化图

同一个体的两次测量用细灰线连接；个体观测使用黑边白心圆形。需要横向位移时，同一个体在两个位置使用相同位移。按提供的个体对应关系连接；同一次测量中的两个不同样本各自保留。摘要量按已确定的方法绘制，图注说明使用的摘要和区间。

示例：[03 配对图](../examples/biomedical_gallery.md#03-paired-change)。

## 多时间点曲线

个体轨迹使用轻线，组汇总使用更清晰的线；图例明确实线/虚线和组名。时间按真实数值间隔排列，数据缺口在个体曲线上保留为空段。散点仍为黑边白心圆形；颜色和线型用于组曲线。SD、SEM、置信区间依既定分析方法区分，绘图图注与实际带宽一致。模型估计区间从提供的结果读取。

示例：[04 时间曲线](../examples/biomedical_gallery.md#04-longitudinal)。

## 分层散点 / SuperPlot

可以通过分面和点大小同时展示视野/细胞观测与动物/独立实验的摘要。保留黑边白心圆形的个人风格；用小圆点表示底层观测，大圆点表示各独立单位均值，并在图注解释。按提供的实验结构计算摘要和误差量。示例不执行假设检验。

示例：[05 分层图](../examples/biomedical_gallery.md#05-nested-observations)。

## 剂量–反应

正剂量可以使用明确标注的对数横轴；零剂量单独处理或保留在线性轴。显示实际观测与提供的拟合曲线，拟合区间保持在观测剂量范围内。注明拟合模型、区间是均值置信区间还是预测区间，以及参数单位。实际研究中读取已确认的拟合结果；示例用明确分开的分析代码演示四参数 logistic 拟合与近似均值 95% CI。

示例：[06 剂量曲线](../examples/biomedical_gallery.md#06-dose-response)。

样式实现：`../scripts/biomedical_styles.R` 的 `theme_biomedical("prism")`。配色选择读取 [palette-guide.md](palette-guide.md)。

参考：[ggplot2 连线语义](https://ggplot2.tidyverse.org/reference/geom_path.html)、[箱线图定义](https://ggplot2.tidyverse.org/reference/geom_boxplot.html)、[R nls](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/nls.html)、[Lord 2020, J Cell Biol](https://doi.org/10.1083/jcb.202001064)。
