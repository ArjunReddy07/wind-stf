library(ggplot2) # tidyverse data visualization package
library(plotly)
library(xts)
library(TSstudio)


setwd("./data/08_reporting")
golden_ratio <- (1+sqrt(5))/2

load("../02_intermediate/eda.vars.RData")

### What is a typical value for yearly WPG-kW? What districts present approx this value?
# A: median = 79243199 [kW]; DEB22 79549998 [kW]
p.wpg.yearly <- ggplot(data.frame(val=power.generated.yearly), aes(x=val)) +
  geom_density() +
  geom_rug(alpha=0.5) +
  geom_vline(xintercept = median(power.generated.yearly), colour="green", linetype = "dashed") +
  geom_text(aes(x=median(power.generated.yearly), label="median\n", y=0.05), colour="black", alpha=0.7, angle=90, text=element_text(size=11)) +
  xlab("2015 Average yearly power generation by district [kW]") +
  ylab("Estimated Density [-]") +
  scale_x_log10()
p.wpg.yearly

### How does a typical WPG-kW time series look like?
power.generated.daily.xts <- power.generated.xts %>%
  mutate(day = as.Date(index(power.generated.xts), format = "%Y-%m-%d")) %>%
  aggregate(~ day, , FUN = sum)

p.wpg.kw.xts <- ggplot(data = data.frame(power.generated.xts[,'DEB22']), aes(x = index(power.generated.xts), y = power.generated.xts[,'DEB22'])) +
                geom_line(color = "#FC4E07", size = 0.5, alpha=0.3)
p.wpg.kw.xts

### How does a typical WPG-CF time series look like?
p.wpg.cf.xts <- ggplot(data = capacity.factors, aes(x = index(capacity.factors), y = capacity.factors[,'DEA56'])) +
                geom_line(color = "#FC4E07", size = 0.5, alpha=0.3)





#plot_ly(x=ts.pairs$distances,
#        y=ts.pairs$spearman.corr,
#        color=ts.pairs$min.avg.cf,
#        type = 'scatter',
#        text = ts.pairs$pairs.id,
#        alpha=0.2,)

### What is a typical time series

### How dependent are the TS from different districs: TS correlation vs centroid distance
#p <- ggplot(data=ts.pairs, aes(x=distances, y=spearman.corr)) +
#  geom_point(alpha = 0.1) +
#  xlab("Euclidean Distance [km]") +
#  ylab("Spearman Correlation [-]")
#p
#ggsave( '../08_reporting/correlation-spearman-vs-distance.png',
#  plot = p,
#  scale = golden_ratio,
#  width = 210/golden_ratio,
#  height = (210/golden_ratio)/golden_ratio,
#  units = 'mm',
#  dpi = 300,
#  limitsize = TRUE,
#)
#
#p <- ggplot(data=ts.pairs, aes(x=distances, y=pearson.corr)) +
#  geom_point(alpha = 0.1) +
#  xlab("Euclidean Distance [km]") +
#  ylab("Pearson Correlation [-]")
#p
#ggsave( '../08_reporting/correlation-pearson-vs-distance.png',
#  plot = p,
#  scale = golden_ratio,
#  width = 210/golden_ratio,
#  height = (210/golden_ratio)/golden_ratio,
#  units = 'mm',
#  dpi = 300,
#  limitsize = TRUE,
#)

# ggplotly(p)

#plot_ly(x=ts.pairs$distances,
#        y=ts.pairs$spearman.corr,
#        color=ts.pairs$min.avg.cf,
#        type = 'scatter',
#        text = ts.pairs$pairs.id,
#        alpha=0.2,)


 # plot cross-correlogram




#GetCCF <- function(id1, id2){
#  ccf.object <- ccf(rank(as.ts(capacity.factors[, id1])),
#                    rank(as.ts(capacity.factors[, id2])),
#                    lax.max = 72,
#                    plot = FALSE)
#  return(ccf.object$acf)
#}
#
#a <- GetCCF('DEA1B', 'DEA44')
#b <- GetCCF('DED43', 'DED43')
#
#ccf.object <- ccf(rank(as.ts(capacity.factors[, 'DED43'])),
#                  rank(as.ts(capacity.factors[, 'DED53'])),
#                  lag = 6,
#                  plot = TRUE)
#
#plot(x=seq(-6,6), y=ccf.object$acf)

#ts.pairs$ccf =  mapply(ccf, capacity.factors, MoreArgs = list(lag.max = 72))
#  ccf(rank(as.ts(capacity.factors[,'DEA56'])), rank(as.ts(capacity.factors[,'DEA59'])), lag.max = 72)

### Saving plots
#ggsave( '../08_reporting/power-generated-yearly-distribution.png',
#  plot = p.wpg.yearly,
#  scale = golden_ratio,
#  width = 210/golden_ratio,
#  height = (210/golden_ratio)/golden_ratio,
#  units = 'mm',
#  dpi = 300,
#  limitsize = TRUE,
#)