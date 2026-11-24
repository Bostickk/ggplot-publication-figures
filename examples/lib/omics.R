run_omics_examples <- function(ctx) {
  # 10: synthetic differential-expression result table, then deterministic display.
  set.seed(110)
  v<-data.frame(gene=sprintf("Gene%03d",1:600),log2fc=c(rnorm(480,0,.5),rnorm(60,2,.6),rnorm(60,-2,.6)))
  v$pvalue<-2*pnorm(-abs(v$log2fc)/runif(600,.25,.6))
  v$padj<-p.adjust(v$pvalue,method="BH")
  v$direction<-factor(ifelse(v$padj<.05 & v$log2fc>1,"Up",ifelse(v$padj<.05 & v$log2fc< -1,"Down","NS")),levels=c("Down","NS","Up"))
  v$neglog10padj<- -log10(v$padj)
  selected<-character()
  for(dir in c("Down","Up")) {
    d<-v[v$direction==dir,]
    selected<-union(selected,head(d$gene[order(d$padj,-abs(d$log2fc),d$gene)],4))
    selected<-union(selected,head(d$gene[order(-abs(d$log2fc),d$padj,d$gene)],4))
  }
  labels<-v[v$gene%in%selected,]
  stopifnot(!anyDuplicated(labels$gene),all(labels$padj<.05),all(abs(labels$log2fc)>1))
  ctx$csv(v,"volcano_synthetic_results");ctx$csv(labels,"volcano_selected_labels")
  label_display<-v;label_display$display_label<-ifelse(v$gene%in%selected,v$gene,"")
  p<-ggplot(v,aes(log2fc,neglog10padj))+
    geom_hline(yintercept=-log10(.05),linetype="22",colour="#999999",linewidth=.4)+
    geom_vline(xintercept=c(-1,1),linetype="22",colour="#999999",linewidth=.4)+
    geom_point(aes(colour=direction),size=1.5,alpha=.85)+
    ggrepel::geom_text_repel(data=label_display,aes(label=display_label),seed=110,size=3.1,max.overlaps=Inf,
                             min.segment.length=0,segment.colour="#999999",segment.size=.3,box.padding=.35)+
    scale_colour_manual(values=c(Down="#4DBBD5",NS="#B8B8B8",Up="#E64B35"))+
    labs(x=expression(log[2]~fold~change),y=expression(-log[10]~BH~adjusted~P))+
    theme_biomedical("omics")
  ctx$save(p,"10_volcano","Volcano plot","Synthetic 600-gene result table; constructed two-sided P values are BH-adjusted within the example. DEG display: adjusted P < 0.05 and |log2FC| > 1. Labels: union of top 4 per direction by adjusted P and absolute log2FC, ties by stable keys. No display capping or label cherry-picking.",width=6.8,height=5.5,seed=110)

  # 11: row-standardized matrix with explicit sample groups and row clustering.
  set.seed(111)
  m<-matrix(rnorm(20*12,0,.6),20,12,dimnames=list(sprintf("Gene%02d",1:20),sprintf("S%02d",1:12)))
  m[1:7,5:8]<-m[1:7,5:8]+1.7;m[8:14,9:12]<-m[8:14,9:12]+1.7
  z<-t(scale(t(m)));stopifnot(max(abs(rowMeans(z)))<1e-10)
  row_order<-rownames(z)[hclust(dist(z),method="complete")$order]
  h<-expand.grid(gene=rownames(z),sample=colnames(z));h$z<-as.vector(z)
  h$gene<-factor(h$gene,levels=rev(row_order));h$sample<-factor(h$sample,levels=colnames(z))
  h$group<-factor(rep(rep(c("Control","Model","Treatment"),each=4),each=20),levels=c("Control","Model","Treatment"))
  ctx$csv(data.frame(gene=rownames(m),m,check.names=FALSE),"heatmap_synthetic_matrix")
  ctx$csv(h,"heatmap_row_zscores")
  ctx$csv(data.frame(sample=colnames(z),group=rep(c("Control","Model","Treatment"),each=4)),"heatmap_sample_groups")
  lim<-max(abs(z))
  p<-ggplot(h,aes(sample,gene,fill=z))+geom_tile()+
    facet_grid(~group,scales="free_x",space="free_x")+
    scale_fill_gradient2(low="#3C5488",mid="white",high="#E64B35",midpoint=0,limits=c(-lim,lim),name="Row Z-score")+
    scale_x_discrete(expand=c(0,0))+scale_y_discrete(expand=c(0,0))+
    labs(x=NULL,y=NULL)+theme_biomedical("omics")+
    theme(axis.line=element_blank(),axis.text.x=element_text(angle=45,hjust=1,size=9.5),
          axis.text.y=element_text(size=9.5),legend.title=element_text(size=10),legend.position="right",panel.spacing=grid::unit(2,"mm"))
  ctx$save(p,"11_heatmap","Annotated row-Z heatmap","Synthetic transformed measurement matrix: 20 genes x 12 samples, 4/group. Values standardized within each row (sample SD); gene rows clustered by Euclidean distance and complete linkage. Samples retain group order. Symmetric colour limits cover all values; Z-scores encode within-gene variation, not between-gene abundance.",width=6.3,height=5.9,seed=111)

  # 12: supplied illustrative ORA result table, without performing enrichment.
  terms<-c("Inflammatory response","Response to oxidative stress","Leukocyte migration",
           "Regulation of cytokine production","Extracellular matrix organization",
           "Cell adhesion","Response to hypoxia","Lipid metabolic process","Apoptotic signaling pathway")
  e<-data.frame(term=terms,count=c(24,19,17,21,14,18,12,15,10),
                padj=c(.0002,.0006,.0012,.002,.004,.006,.01,.02,.035),list_size=120L)
  e$ratio<-e$count/e$list_size;e$term<-factor(e$term,levels=rev(e$term))
  ctx$csv(e,"ora_supplied_synthetic_results")
  p<-ggplot(e,aes(ratio,term,size=count,colour=-log10(padj)))+geom_point()+
    scale_colour_viridis_c(option="D",begin=.15,end=.85,name=expression(-log[10]~adjusted~P))+
    scale_size_continuous(range=c(3,7),name="Gene count")+
    labs(x="Gene ratio",y=NULL)+theme_biomedical("omics")+
    theme(axis.line.y=element_blank(),legend.title=element_text(size=10))
  ctx$save(p,"12_enrichment","ORA dot plot","Illustrative synthetic GO biological-process-style ORA result table; no enrichment test is run and no GO identifiers are assigned. All 9 illustrative terms are shown in adjusted-P order. Ratio = count / 120 submitted genes. BP only; CC/MF and GSEA were not simulated. Values describe no biological discovery.",width=8,height=5.3)
}
