library(ggplot2) # tidyverse data visualization package
library(plotly)
library(xts)
library(TSstudio)
library(data.table)
library(lubridate)
library(dplyr)
library(gridExtra)

# Ensure current working dir is data/08_reporting
if(!dir.exists("./metadata")){
  setwd("./data/08_reporting")
}

golden_ratio <- (1+sqrt(5))/2

load("../02_intermediate/eda.vars.RData")

### What is a typical value for yearly WPG-kW? What districts present approx this value?
# A: median = 79243199 [kW]; DEB22 79549998 [kW]
#PlotYearlyWPGkWh <- function(){
#   p.wpg.yearly <- ggplot(data.frame(val=power.generated.yearly), aes(x=val)) +
#    geom_density() +
#    geom_rug(alpha=0.5) +
#    geom_vline(xintercept = median(power.generated.yearly), colour="green", linetype = "dashed") +
#    geom_text(aes(x=median(power.generated.yearly), label="median\n", y=0.05), colour="black", alpha=0.7, angle=90, text=element_text(size=11)) +
#    xlab("2015 Average yearly power generation by district [kW]") +
#    ylab("Estimated Density [-]") +
#    scale_x_log10()
#  p.wpg.yearly
#}
#PlotYearlyWPGkWh()

### How does a typical WPG-kWh time series look like?
PlotTypicalWPGkwh <- function() {
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
  merged.deb22.dt <- power.generated.daily.dt[power.capacity.daily.dt, nomatch = 0]

  p.wpg.daily.kwh.xts <- ggplot(power.generated.daily.dt, aes(x = day)) +
    geom_line(aes(y = merged.deb22.dt$i.DEB22, color = 'capacity'), size = 0.4, alpha = 1.0) +
    geom_line(aes(y = merged.deb22.dt$DEB22, color = 'generation'), size = 0.4, alpha = 1.0) +
    scale_color_manual(name = NULL,
                       values = c('capacity' = '#737373', 'generation' = '#F98C0AFF')) +
    xlab("Date") +
    ylab("Daily Generation [kWh]") +
    scale_y_log10() +
    theme(axis.title.x = element_text(size = rel(0.75)),
          axis.title.y = element_text(size = rel(0.75)),
          legend.position = c(0.90, 0.25),
          legend.background = element_rect(fill = alpha('white', 0.0), color = 'transparent', size = 0.75),
          legend.key = element_rect(fill = 'transparent', colour = 'transparent', size=0.5))

  p.wpg.daily.kwh.density <- ggplot(power.generated.daily.dt, aes(y = DEB22)) +
    geom_density(aes(x =  ..scaled..)) +
    geom_rug(alpha = 0.3) +
    geom_hline(yintercept = median(power.generated.daily.dt$DEB22), color = "#F98C0AFF", alpha = 0.6) +
    geom_text(aes(y = median(power.generated.daily.dt$DEB22), label = "median\n", x = 0.4), color = "#F98C0AFF", alpha = 0.7, angle = 0, text = element_text(size = rel(0.75))) +
    scale_y_log10() +
    xlab("Estimated Density") +
    scale_x_continuous(breaks=c(0.0, 0.5, 1.0)) +
    theme(legend.position = "none",
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.title.y = element_blank(),
          axis.title.x = element_text(size = rel(0.75))
    )
  # p.wpg.daily.kwh.density
  p.wpg.daily.kw <- grid.arrange(p.wpg.daily.kwh.xts, p.wpg.daily.kwh.density, ncol = 2, nrow = 1, widths = c(5, 1))

  ggsave(
    filename = paste0('../08_reporting/wpg-daily-typical-ts_',
                      format(Sys.time(), "%Y%m%d_%H%M%S"),
                      '.png'),
    plot = p.wpg.daily.kw,
    scale = golden_ratio,
    width = 210 / golden_ratio,
    height = (210 / golden_ratio) / (3 * golden_ratio),
    units = 'mm',
    dpi = 300,
    limitsize = TRUE,
  )
}
# PlotTypicalWPGkwh()

### How does a typical WPG-CF time series look like?
PlotTypicalWPGcf <- function() {
    capacity.factors.dt <- data.table(capacity.factors) %>%
    mutate(day = as.Date(index(capacity.factors), format = "%Y-%m-%d")) %>%
    aggregate(. ~ day, data = ., FUN = mean) %>%
    data.table(.)

  p.wpg.daily.cf <- ggplot(capacity.factors.dt, aes(x = day)) +
    geom_line(aes(y = capacity.factors.dt$DEB22), size = 0.4, color = '#F98C0AFF', alpha = 1.0) +
    ylim(0.00, 1.00) +
    xlab("Date") +
    ylab("Daily Capacity Factor [-]") +
    theme(axis.title.x = element_text(size = rel(0.75)),
          axis.title.y = element_text(size = rel(0.75)),)

   p.wpg.daily.cf.density <- ggplot(capacity.factors.dt, aes(y = DEB22)) +
    geom_density(aes(x =  ..scaled..)) +
    ylim(0.00, 1.00) +
    geom_rug(alpha = 0.3) +
    geom_hline(aes(yintercept = median(capacity.factors.dt$DEB22), color = "median"), alpha = 0.6) +
    # geom_text(aes(y = median(capacity.factors.dt$DEB22), label = "median\n", x = 0.2), color = "#F98C0AFF", alpha = 0.7, angle = 0, hjust = 0, text = element_text(size = 9)) +
    geom_hline(aes(yintercept = mean(capacity.factors.dt$DEB22), color = "mean"), alpha = 0.6) +
    # geom_text(aes(y = mean(capacity.factors.dt$DEB22), label = "mean\n", x = 0.2), color = "#BB3754FF", alpha = 0.7, angle = 0, hjust = 0, text = element_text(size = 9)) +
    scale_color_manual(name = NULL, values = c(median = "#F98C0AFF", mean = "#BB3754FF")) +
    xlab("Estimated Density") +
    scale_x_continuous(breaks=c(0.0, 0.5, 1.0)) +
    theme(axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.title.y = element_blank(),
          axis.title.x = element_text(size = rel(0.75)),
          legend.position = c(0.6, 0.8),
          legend.background = element_rect(fill = alpha('white', 0.0), color = 'transparent', size = 0.75),
          legend.key = element_rect(fill = 'transparent', colour = 'transparent'))
  p.wpg.daily.cf <- grid.arrange(p.wpg.daily.cf, p.wpg.daily.cf.density, ncol = 2, nrow = 1, widths = c(5, 1))

  ggsave(
    filename = paste0('../08_reporting/wpg-cf-daily-typical-ts_',
                      format(Sys.time(), "%Y%m%d_%H%M%S"),
                      '.png'),
    plot = p.wpg.daily.cf,
    scale = golden_ratio,
    width = 210 / golden_ratio,
    height = (210 / golden_ratio) / (3 * golden_ratio),
    units = 'mm',
    dpi = 300,
    limitsize = TRUE,
  )
}
# PlotTypicalWPGcf()

### How are hourly, distrital time series temporarily correlated?
# We use a pearson cross-correlation function to assess the temporal correlation between the hourly time series.
# This requires the choice of a maximum lag.
# Assuming a nearly critical condition in which an air mass travels in a straight line between the producing districts
# most distant from one another (max(ts.pairs$distances)=800km) with an average streamline velocity the minimum
# found across the land, assumed to be 7 km/h. We then use this modeled critical wind trajectory to
# determine a reasonable upper bound for the maximum lag considered for evaluating the cross-correlation function: 800/7 ~= 114h.
# Figure \ref{fig:single-pair-ccf} shows the cross-correlation for the most distant pair of producing districts.
# Correlations tend to fall below ??? as the lag surpasses ??? hours.

# Furthermore, in order to attain an informative overview of cross-correlations between districts time series,
# we restrict ourselves to those pairs presenting no more than 400 km of Euclidean distance,
# which tend to present spearman correlations of at least 0.5 (fig. \ref{fig:spatial-analysis).
# This results in about 75% of all producing district pairs remaining for the temporal analysis.
# When assessing the correlation coefficients at different lags, we define as a positive lag the condition
# where the northernmost district in the pair is lagged in relation to the southernmost one in the pair.
# This follows the consideration that, in Germany, wind flows from SSW (240°) tend to predominate both in
# frequency and speed and, in consequence, also in power \cite{windatlas}.
FilterOutDistantPairs <- function(ts.pairs){
  ts.pairs.near <- ts.pairs[distances < 400E+3, ]
  print(paste0(100*dim(ts.pairs.near)[1]/dim(ts.pairs)[1], '% of original pair entries remain.'))
  return(ts.pairs.near)
}

OrderPairByLatitude <- function(ts.pairs, turbines.centroids){
  ts.pairs.out <- ts.pairs
  count = 0
  if (turbines.centroids[ts.pairs$id1, lat] > turbines.centroids[ts.pairs$id2, lat]){
    ts.pairs.out$id1 <- ts.pairs$id2
    ts.pairs.out$id2 <- ts.pairs$id1
    count <- count + 1
  }
  print(paste0(100*count/dim(ts.pairs)[1], '% of original pair entries remain.'))
  return(ts.pairs.near)
}

ts.pairs.near <- FilterOutDistantPairs(ts.pairs)
ts.pairs.near.orderedSN <- OrderPairByLatitude(ts.pairs.near, turbines.centroids)

GetCCF <- function(id1, id2){
  ccf.object <- ccf(rank(as.ts(capacity.factors[, id1])),
                    rank(as.ts(capacity.factors[, id2])),
                    lax.max = 120,
                    plot = FALSE)
  return(ccf.object$acf)
}


#a <- GetCCF('DEA1B', 'DEA44')
#b <- GetCCF('DED43', 'DED43')
#
#ccf.object <- ccf(rank(as.ts(capacity.factors[, 'DED43'])),
#                  rank(as.ts(capacity.factors[, 'DED53'])),
#                  lag = 6,
#                  plot = TRUE)
#
#plot(x=seq(-6,6), y=ccf.object$acf)
#
#ts.pairs$ccf =  mapply(ccf, capacity.factors, MoreArgs = list(lag.max = 72))
#  ccf(rank(as.ts(capacity.factors[,'DEA56'])), rank(as.ts(capacity.factors[,'DEA59'])), lag.max = 72)

### How dependent are the TS from different districs: TS correlation vs centroid distance
#plot_ly(x=ts.pairs$distances,
#        y=ts.pairs$spearman.corr,
#        color=ts.pairs$min.avg.cf,
#        type = 'scatter',
#        text = ts.pairs$pairs.id,
#        alpha=0.2,)
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


