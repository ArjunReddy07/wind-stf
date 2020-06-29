library(ggplot2) # tidyverse data visualization package
library(plotly)
library(xts)
library(TSstudio)
library(data.table)
library(lubridate)
library(dplyr)
library(gridExtra)

setwd("./data/08_reporting")
golden_ratio <- (1+sqrt(5))/2

load("../02_intermediate/eda.vars.RData")

### What is a typical value for yearly WPG-kW? What districts present approx this value?
# A: median = 79243199 [kW]; DEB22 79549998 [kW]
# p.wpg.yearly <- ggplot(data.frame(val=power.generated.yearly), aes(x=val)) +
#  geom_density() +
#  geom_rug(alpha=0.5) +
#  geom_vline(xintercept = median(power.generated.yearly), colour="green", linetype = "dashed") +
#  geom_text(aes(x=median(power.generated.yearly), label="median\n", y=0.05), colour="black", alpha=0.7, angle=90, text=element_text(size=11)) +
#  xlab("2015 Average yearly power generation by district [kW]") +
#  ylab("Estimated Density [-]") +
#  scale_x_log10()
#p.wpg.yearly
#
#is.numeric(power.generated.xts$DEB22)

### How does a typical WPG-kW time series look like?
PlotTypicalWPGkw <- function(){
power.generated.daily.dt <- data.table(power.generated.xts) %>%
  mutate(day = as.Date(index(power.generated.xts), format = "%Y-%m-%d")) %>%
  aggregate(. ~ day, data = ., FUN = sum) %>%
  data.table(.)

power.capacity.daily.dt <- data.table(power.installed.xts) %>%
  mutate(day = as.Date(index(power.installed.xts), format = "%Y-%m-%d")) %>%
  aggregate(. ~ day, data = ., FUN = sum) %>%
  data.table(.)

setkey(power.generated.daily.dt, day)
setkey(power.capacity.daily.dt, day)
merged.deb22.dt <- power.generated.daily.dt[power.capacity.daily.dt, nomatch=0]

p.wpg.daily.kwh.xts <- ggplot(power.generated.daily.dt, aes(x = day)) +
  geom_line(aes(y=merged.deb22.dt$i.DEB22, color = 'capacity'), size = 0.4, alpha = 1.0) +
  geom_line(aes(y=merged.deb22.dt$DEB22, color = 'generation'), size = 0.4, alpha = 1.0) +
  scale_color_manual(name = NULL,
                   values = c('capacity' = '#737373', 'generation' = '#F98C0AFF')) +
  xlab("Date") +
  ylab("Daily Generation [kWh]") +
  scale_y_log10() +
  theme(axis.title.x = element_text(size = rel(0.75)),
        axis.title.y = element_text(size = rel(0.75)),
        legend.position = c(0.90, 0.25),
        legend.background = element_rect(fill=alpha('white', 1.0), color='transparent', size = 0.75),
        legend.key = element_rect(fill = 'transparent', colour = 'transparent'))

p.wpg.daily.kwh.density <- ggplot(power.generated.daily.dt, aes(y = DEB22)) +
  geom_density() +
  geom_rug(alpha = 0.3) +
  geom_hline(yintercept = median(power.generated.daily.dt$DEB22), color = "#dc724f", linetype = "dashed") +
  geom_text(aes(y = median(power.generated.daily.dt$DEB22), label = "median\n", x = 0.2), color = "#dc724f", alpha = 0.7, angle = 0, text = element_text(size = 11)) +
  scale_y_log10() +
  xlab("Estimated Density") +
  theme(legend.position = "none",
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_text(size = rel(0.75))
  )
# p.wpg.daily.kwh.density
p.wpg.daily.kw <- grid.arrange(p.wpg.daily.kwh.xts, p.wpg.daily.kwh.density, ncol=2, nrow=1, widths=c(5, 1))

ggsave(
  filename = paste0('../08_reporting/wpg-daily-typical-ts_',
                    format(Sys.time(), "%Y%m%d_%H%M%S"),
                    '.png'),
  plot = p.wpg.daily.kw,
  scale = golden_ratio,
  width = 210/golden_ratio,
  height = (210/golden_ratio)/(3*golden_ratio),
  units = 'mm',
  dpi = 300,
  limitsize = TRUE,
)
}

p.wpg.daily.kwh.xts <- ggplot(power.generated.daily.dt, aes(x = day)) +
  geom_line(aes(y=merged.deb22.dt$i.DEB22, color = 'capacity'), size = 0.4, alpha = 1.0) +
  geom_line(aes(y=merged.deb22.dt$DEB22, color = 'generation'), size = 0.4, alpha = 1.0) +
  scale_color_manual(name = NULL,
                   values = c('capacity' = '#737373', 'generation' = '#F98C0AFF')) +
  xlab("Date") +
  ylab("Daily Generation [kWh]") +
  scale_y_log10() +
  theme(axis.title.x = element_text(size = rel(0.75)),
        axis.title.y = element_text(size = rel(0.75)),
        legend.position = c(0.90, 0.25),
        legend.background = element_rect(fill=alpha('white', 0.0), color='transparent', size = 0.75),
        legend.key = element_rect(fill = 'transparent', colour = 'transparent'))
p.wpg.daily.kwh.xts

p.wpg.daily.kwh.density <- ggplot(power.generated.daily.dt, aes(y = DEB22)) +
  geom_density() +
  geom_rug(alpha = 0.3) +
  geom_hline(yintercept = median(power.generated.daily.dt$DEB22), color = "#dc724f", linetype = "dashed") +
  geom_text(aes(y = median(power.generated.daily.dt$DEB22), label = "median\n", x = 0.2), color = "#dc724f", alpha = 0.7, angle = 0, text = element_text(size = 11)) +
  scale_y_log10() +
  xlab("Estimated Density") +
  theme(legend.position = "none",
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_text(size = rel(0.75))
  )
# p.wpg.daily.kwh.density
p.wpg.daily.kw <- grid.arrange(p.wpg.daily.kwh.xts, p.wpg.daily.kwh.density, ncol=2, nrow=1, widths=c(5, 1))

ggsave(
  filename = paste0('../08_reporting/wpg-daily-typical-ts_',
                    format(Sys.time(), "%Y%m%d_%H%M%S"),
                    '.png'),
  plot = p.wpg.daily.kw,
  scale = golden_ratio,
  width = 210/golden_ratio,
  height = (210/golden_ratio)/(3*golden_ratio),
  units = 'mm',
  dpi = 300,
  limitsize = TRUE,
)
#### How does a typical WPG-CF time series look like?
#p.wpg.cf.xts <- ggplot(data = capacity.factors, aes(x = index(capacity.factors), y = capacity.factors[,'DEA56'])) +
#                geom_line(color = "#FC4E07", size = 0.5, alpha=0.3)





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

#### How does a typical WPG-CF time series look like?
#p.wpg.cf.xts <- ggplot(data = capacity.factors, aes(x = index(capacity.factors), y = capacity.factors[,'DEA56'])) +
#                geom_line(color = "#FC4E07", size = 0.5, alpha=0.3)





#plot_ly(x=ts.pairs$distances,
#        y=ts.pairs$spearman.corr,
#        color=ts.pairs$min.avg.cf,
#        type = 'scatter',
#        text = ts.pairs$pairs.id,
#        alpha=0.2,)

### What is a typical time series

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

