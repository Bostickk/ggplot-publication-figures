run_clinical_examples <- function(ctx) {
  # 07: an illustrative, supplied-results table, with no model fitting.
  forest <- data.frame(term=c("Predictor A","Predictor B","Predictor C","Predictor D","Predictor E","Predictor F"),
                        estimate=c(1.25,1.6,.78,1.15,.60,1.02),
                        lower=c(1.05,1.1,.61,.85,.39,.91),upper=c(1.49,2.33,1.00,1.56,.92,1.14))
  forest$term <- factor(forest$term,levels=rev(forest$term))
  forest$label <- sprintf("%.2f [%.2f, %.2f]",forest$estimate,forest$lower,forest$upper)
  ctx$csv(forest,"forest_supplied_synthetic_results")
  p<-ggplot(forest,aes(estimate,term))+
    geom_vline(xintercept=1,linetype="22",colour="#888888",linewidth=.5)+
    geom_segment(aes(x=lower,xend=upper,yend=term),linewidth=.7)+
    observation_layer()+
    geom_text(aes(x=4.2,label=label),hjust=1,size=3.5)+
    scale_x_log10(breaks=c(.4,.6,1,1.5,2.5,4.2),labels=c("0.4","0.6","1","1.5","2.5",""))+
    labs(x="Adjusted risk ratio (95% CI)",y=NULL)+theme_biomedical("clinical")+
    theme(axis.line.y=element_blank(),axis.ticks.y=element_blank())
  ctx$save(p,"07_forest","Forest plot","Directly supplied synthetic adjusted risk ratios and 95% confidence limits; no regression fitted. Ratio axis is logarithmic, null reference = 1. Row labels and numeric intervals correspond to the saved result table.",width=7,height=4.5)

  # 08: single-event, right-censored survival with a known common time origin.
  set.seed(108)
  kmraw<-data.frame(id=1:120,group=rep(c("Control","Intervention"),each=60))
  latent<-rexp(120,rate=ifelse(kmraw$group=="Control",.075,.045))
  censor<-runif(120,8,16);kmraw$time<-pmin(latent,censor,12)
  kmraw$status<-as.integer(latent<=censor & latent<=12)
  ctx$csv(kmraw,"km_observations")
  kc<-setNames(get_publication_palette("npg_soft",2),c("Control","Intervention"))
  curves<-list();censors<-list()
  for(g in names(kc)) {
    d<-kmraw[kmraw$group==g,]
    fit<-survival::survfit(survival::Surv(time,status)~1,data=d,conf.type="log-log")
    curves[[g]]<-data.frame(time=c(0,fit$time),estimate=c(1,fit$surv),
                              lower=c(1,fit$lower),upper=c(1,fit$upper),group=g)
    censors[[g]]<-data.frame(time=fit$time[fit$n.censor>0],estimate=fit$surv[fit$n.censor>0],group=g)
    stopifnot(all(diff(fit$surv)<=1e-12),all(fit$surv>=0 & fit$surv<=1))
  }
  km<-do.call(rbind,curves);cens<-do.call(rbind,censors)
  kband<-do.call(rbind,lapply(curves,step_band));risk<-make_risk_table(kmraw)
  ctx$csv(km,"km_estimates");ctx$csv(risk,"km_risk_table")
  p<-ggplot()+geom_ribbon(data=kband,aes(time,ymin=lower,ymax=upper,fill=group),alpha=.15)+
    geom_step(data=km,aes(time,estimate,colour=group,linetype=group),linewidth=.8)+
    geom_point(data=cens,aes(time,estimate,colour=group),shape=3,size=1.8,stroke=.5)+
    scale_colour_manual(values=kc)+scale_fill_manual(values=kc)+
    scale_linetype_manual(values=c(Control="solid",Intervention="22"))+
    scale_x_continuous(breaks=seq(0,12,3),limits=c(0,12),expand=expansion(add=.4))+
    scale_y_continuous(breaks=seq(0,1,.25),labels=function(x)paste0(100*x,"%"),limits=c(0,1),expand=expansion(mult=c(0,.02)))+
    labs(x=NULL,y="Survival probability")+theme_biomedical("clinical")
  p<-attach_risk_table(p,risk,kc)
  ctx$save(p,"08_km","Kaplan-Meier curve","Synthetic right-censored single-event data, 60 individuals/group, common time zero; maximum follow-up 12 months. Curves: Kaplan-Meier; bands: log-log 95% CI; + marks: censoring. Risk table: time >= each displayed time. No group-comparison test.",width=6.4,height=5.5,seed=108)

  # 09: absorbing competing events, estimated with Aalen-Johansen.
  set.seed(109)
  cr<-data.frame(id=1:160,group=rep(c("Control","Intervention"),each=80))
  ti<-rexp(160,ifelse(cr$group=="Control",.06,.035));td<-rexp(160,.025);tc<-runif(160,9,16)
  cr$time<-pmin(ti,td,tc,12)
  cr$event<-factor(ifelse(ti<=td & ti<=tc & ti<=12,"Outcome",
                          ifelse(td<ti & td<=tc & td<=12,"Death","Censor")),levels=c("Censor","Outcome","Death"))
  ctx$csv(cr,"cif_observations")
  cf<-list()
  for(g in names(kc)) {
    d<-cr[cr$group==g,]
    fit<-survival::survfit(survival::Surv(time,event)~1,data=d,id=id,conf.type="plain")
    j<-match("Outcome",fit$states);stopifnot(!is.na(j),max(abs(rowSums(fit$pstate)-1))<1e-8)
    cf[[g]]<-data.frame(time=c(0,fit$time),estimate=c(0,fit$pstate[,j]),
                        lower=c(0,fit$lower[,j]),upper=c(0,fit$upper[,j]),group=g)
    stopifnot(all(diff(cf[[g]]$estimate)>=-1e-12))
  }
  cif<-do.call(rbind,cf);cband<-do.call(rbind,lapply(cf,step_band));risk<-make_risk_table(cr)
  ctx$csv(cif,"cif_aj_estimates");ctx$csv(risk,"cif_risk_table")
  p<-ggplot()+geom_ribbon(data=cband,aes(time,ymin=lower,ymax=upper,fill=group),alpha=.15)+
    geom_step(data=cif,aes(time,estimate,colour=group,linetype=group),linewidth=.8)+
    scale_colour_manual(values=kc)+scale_fill_manual(values=kc)+
    scale_linetype_manual(values=c(Control="solid",Intervention="22"))+
    scale_x_continuous(breaks=seq(0,12,3),limits=c(0,12),expand=expansion(add=.4))+
    scale_y_continuous(breaks=seq(0,1,.2),labels=function(x)paste0(100*x,"%"),
                       limits=c(0,min(1,ceiling(max(cif$upper,na.rm=TRUE)*5)/5)),expand=expansion(mult=c(0,.02)))+
    labs(x=NULL,y="Cumulative incidence of outcome")+theme_biomedical("clinical")
  p<-attach_risk_table(p,risk,kc)
  ctx$save(p,"09_cif","Competing-risk cumulative incidence","Synthetic data: 80 individuals/group; target outcome and competing death are absorbing first events, with right censoring and a common time zero. Curves: Aalen-Johansen target-event probability; bands: pointwise plain 95% CI (bounded to [0,1] by survival). Risk table counts those free of both events and uncensored immediately before each displayed time. No test or regression.",width=6.4,height=5.5,seed=109)
}

make_risk_table <- function(d) {
  ans<-expand.grid(time=seq(0,12,3),group=c("Control","Intervention"))
  ans$n<-mapply(function(t,g)sum(d$group==g & d$time>=t),ans$time,ans$group)
  ans$group<-factor(ans$group,levels=c("Intervention","Control"))
  ans
}

attach_risk_table <- function(p,risk,cols) {
  r<-ggplot(risk,aes(time,group,label=n,colour=group))+
    geom_text(size=3.5,show.legend=FALSE)+scale_colour_manual(values=cols)+
    scale_x_continuous(breaks=seq(0,12,3),limits=c(0,12),expand=expansion(add=.4))+
    labs(x="Follow-up (months)",y=NULL,title="Number at risk")+theme_biomedical("clinical")+
    theme(axis.line=element_blank(),axis.ticks=element_blank(),
          axis.text.y=element_text(size=10),plot.title=element_text(size=10,hjust=0),plot.margin=margin(0,12,8,8))
  ((p+theme(legend.position="bottom")) / r + patchwork::plot_layout(heights=c(4,1.2),guides="collect")) &
    theme(legend.position="bottom")
}
