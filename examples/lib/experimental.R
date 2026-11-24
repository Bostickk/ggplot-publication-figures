run_experimental_examples <- function(ctx) {
  # 01/02: same synthetic observations as the original public preview.
  groups <- c("Group A", "Group B", "Group C", "Group D")
  vals <- list(c(3.2,4.1,3.7,5.0,4.4,3.4,4.8,3.9,4.6,3.5),
               c(7.2,9.0,8.1,10.3,8.7,7.6,9.5,8.4,10.0,7.9),
               c(5.4,6.7,5.9,7.4,6.3,5.6,7.0,6.1,7.7,6.5),
               c(4.3,5.5,4.9,6.2,5.2,4.6,5.8,5.0,6.5,4.7))
  raw <- data.frame(group = factor(rep(groups, each = 10), levels = groups),
                    unit_id = sprintf("S%02d", 1:40), value = unlist(vals))
  summ <- data.frame(group = factor(groups, levels = groups), n = 10L,
                     mean = vapply(vals, mean, 0), sd = vapply(vals, sd, 0))
  cols <- setNames(get_publication_palette("npg_soft", 4), groups)
  ctx$csv(raw, "grouped_observations"); ctx$csv(summ, "grouped_summary")
  pts <- observation_layer(data = raw, aes(group, value), inherit.aes = FALSE,
                            position = position_jitter(width = .14, height = 0, seed = 42))
  bar <- ggplot(summ, aes(group, mean, fill = group)) +
    geom_col(width = .6, colour = "black", linewidth = .5) +
    geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), width = .15, linewidth = .5) +
    pts + scale_fill_manual(values = cols) +
    scale_y_continuous(expand = expansion(mult = c(0,.07))) +
    labs(x = NULL, y = "Measurement (a.u.)") + theme_biomedical("prism") + theme(legend.position = "none")
  box <- ggplot(raw, aes(group, value, fill = group)) +
    geom_boxplot(width = .55, colour = "black", linewidth = .5, outlier.shape = NA, staplewidth = .45) +
    pts + scale_fill_manual(values = cols) + labs(x = NULL, y = "Measurement (a.u.)") +
    theme_biomedical("prism") + theme(legend.position = "none")
  ctx$save(bar,"01_bar","Bar + observations","Synthetic data; n = 10 independent units per group. Bars: mean; error bars: sample SD; all 40 observations shown. Horizontal jitter only, seed 42.", seed=42)
  ctx$save(box,"02_box","Box + observations","Same synthetic data as 01. Boxes: median and hinges; whiskers: most extreme observations within 1.5 x IQR. All observations shown once by the point layer.",seed=42)

  # 03: paired raw observations, with the same x-offset at both visits.
  set.seed(103)
  baseline <- rnorm(12, 7.4, 1.0); followup <- baseline - rnorm(12, 1.5, .65)
  paired <- data.frame(id=rep(sprintf("P%02d",1:12),2), visit=rep(c("Before","After"),each=12),
                       value=c(baseline,followup), x=rep(1:2,each=12)+rep(seq(-.12,.12,length.out=12),2))
  ctx$csv(paired,"paired_observations")
  p <- ggplot(paired,aes(x,value,group=id)) + geom_line(colour="#969696",linewidth=.45) +
    observation_layer() + scale_x_continuous(breaks=1:2, labels=c("Before","After"),expand=expansion(add=.4)) +
    labs(x=NULL,y="Measurement (a.u.)") + theme_biomedical("prism")
  ctx$save(p,"03_paired","Paired change","Synthetic paired measurements for 12 individuals. Each grey line joins the same individual; fixed identical horizontal offsets preserve pairing. No hypothesis test.",width=4.8,seed=103)

  # 04: descriptive longitudinal display, with one explicitly missing visit.
  set.seed(104)
  long <- expand.grid(time=c(0,2,5,8), id=sprintf("L%02d",1:20))
  long$group <- ifelse(as.integer(sub("L","",long$id))<=10,"Control","Intervention")
  intercept <- rnorm(20,5,.6)
  long$value <- intercept[match(long$id,sprintf("L%02d",1:20))] +
    ifelse(long$group=="Control",.35,.13)*long$time+rnorm(nrow(long),0,.4)
  long$value[long$id=="L13" & long$time==5] <- NA_real_
  long <- long[order(long$id,long$time),]
  spl <- split(long,list(long$group,long$time),drop=TRUE)
  ls <- do.call(rbind,lapply(spl,function(d) data.frame(group=d$group[1],time=d$time[1],
                     n=sum(!is.na(d$value)),mean=mean(d$value,na.rm=TRUE),sd=sd(d$value,na.rm=TRUE))))
  ls <- ls[order(ls$group,ls$time),]; rownames(ls)<-NULL
  lc <- setNames(get_publication_palette("npg_soft",2),c("Control","Intervention"))
  ctx$csv(long,"longitudinal_observations");ctx$csv(ls,"longitudinal_summary")
  p <- ggplot() + geom_ribbon(data=ls,aes(time,ymin=mean-sd,ymax=mean+sd,fill=group),alpha=.13) +
    geom_line(data=long,aes(time,value,group=id,colour=group),alpha=.25,linewidth=.35) +
    observation_layer(data=long,aes(time,value),na.rm=TRUE) +
    geom_line(data=ls,aes(time,mean,colour=group,linetype=group),linewidth=.95) +
    scale_colour_manual(values=lc)+scale_fill_manual(values=lc)+
    scale_linetype_manual(values=c(Control="solid",Intervention="22"))+
    scale_x_continuous(breaks=c(0,2,5,8))+labs(x="Time (days)",y="Measurement (a.u.)")+
    theme_biomedical("prism")
  ctx$save(p,"04_longitudinal","Longitudinal trajectories","Synthetic data: 10 individuals/group, visits at 0, 2, 5 and 8 days. Thin lines: individuals; thick lines: group means; bands: descriptive mean +/- SD. L13 at day 5 is missing and its trajectory retains a gap. N by visit is in longitudinal_summary.csv.",width=6.4,seed=104)

  # 05: small field observations and larger animal means; no inferential test.
  set.seed(105)
  nested <- expand.grid(field=1:6, animal=1:4, group=c("Control","Model","Treatment"))
  nested$animal_id <- paste(nested$group,nested$animal,sep="_")
  mu <- setNames(c(4,8,5.6),c("Control","Model","Treatment"))
  shifts <- setNames(rnorm(12,0,.7),unique(nested$animal_id))
  nested$value <- mu[nested$group]+shifts[nested$animal_id]+rnorm(nrow(nested),0,.6)
  am <- aggregate(value~group+animal+animal_id,nested,mean)
  gm <- aggregate(value~group,am,mean)
  ctx$csv(nested,"nested_field_observations");ctx$csv(am,"nested_animal_means");ctx$csv(gm,"nested_group_means")
  p <- ggplot(nested,aes(factor(animal),value))+
    geom_hline(data=gm,aes(yintercept=value),linetype="22",colour="#999999",linewidth=.4)+
    geom_point(position=position_jitter(width=.10,height=0,seed=105),shape=21,fill="white",colour="black",size=1.7,stroke=.4)+
    geom_point(data=am,shape=21,fill="white",colour="black",size=3.6,stroke=.85)+
    facet_wrap(~group,nrow=1)+labs(x="Animal within group",y="Field measurement (a.u.)")+
    theme_biomedical("prism")
  stopifnot(nrow(am)==12,nrow(nested)==72)
  ctx$save(p,"05_nested","Nested observations","Synthetic data: 4 independent animals/group, 6 fields/animal. Small circles: fields; large circles: animal means; dashed line: mean of the four animal means in that group. Panels separate groups. No hypothesis test.",width=7.0,height=4.5,seed=105)

  # 06: analysis first, then display of a fitted 4-parameter logistic curve.
  set.seed(106)
  dose <- data.frame(dose=rep(c(.01,.03,.1,.3,1,3,10),each=6))
  dose$logdose <- log10(dose$dose)
  dose$response <- 10+80*plogis((dose$logdose+.35)/.45)+rnorm(nrow(dose),0,3)
  fit <- nls(response~bottom+(top-bottom)*plogis((logdose-mid)/slope),dose,
             start=list(bottom=10,top=90,mid=-.35,slope=.45))
  b <- coef(fit); grid <- data.frame(logdose=seq(min(dose$logdose),max(dose$logdose),length.out=200))
  q <- plogis((grid$logdose-b['mid'])/b['slope'])
  J <- cbind(1-q,q,-(b['top']-b['bottom'])*q*(1-q)/b['slope'],
              -(b['top']-b['bottom'])*q*(1-q)*(grid$logdose-b['mid'])/b['slope']^2)
  grid$estimate <- as.numeric(predict(fit,grid)); se<-sqrt(rowSums((J%*%vcov(fit))*J))
  crit<-qt(.975,df.residual(fit));grid$lower<-grid$estimate-crit*se;grid$upper<-grid$estimate+crit*se;grid$dose<-10^grid$logdose
  ctx$csv(dose,"dose_observations");ctx$csv(grid,"dose_fitted_curve")
  ctx$csv(data.frame(parameter=names(b),estimate=as.numeric(b)),"dose_model_parameters")
  stopifnot(all(grid$lower<=grid$estimate),all(grid$estimate<=grid$upper),b['slope']>0)
  p<-ggplot()+geom_ribbon(data=grid,aes(dose,ymin=lower,ymax=upper),fill="#71C9DD",alpha=.3)+
    geom_line(data=grid,aes(dose,estimate),colour="#3C5488",linewidth=.9)+
    observation_layer(data=dose,aes(dose,response))+
    scale_x_log10(breaks=c(.01,.1,1,10))+labs(x="Concentration (arbitrary units)",y="Response (a.u.)")+theme_biomedical("prism")
  ctx$save(p,"06_dose","Dose-response curve","Synthetic independent measurements: 6 per positive concentration. Curve: four-parameter logistic nls fit; band: approximate 95% CI for the mean using the delta method and residual t quantile. No prediction interval or extrapolation. Fitted parameters/curve saved separately.",width=6,seed=106)
}
