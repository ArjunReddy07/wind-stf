library(beepr)
library(usethis)

library(data.table)

library(sf)
library(raster)
library(dplyr)
# library(spData)
# library(spDataLarge)
library(tidyr)
library(eurostat)
library(tmap)    # for static and interactive maps
# library(leaflet) # for interactive maps
# library(mapview) # for interactive maps
library(ggplot2) # tidyverse data visualization package
#library(shiny)   # for web applications
library(tmaptools)

library(TSstudio)
library(lubridate)
library(xts)

# ===========================================
# Defining constants
# ===========================================
setwd("./data/01_raw")

# Uber Color Schemes
colorscheme_uber <- data.table(
  terrain = c("waters","land","highway","roads","parks","airport"),
  dark = c("#12232f", "#09101d", "#304a5c", "#223949", "#041922", "#131926"),
  light = c("#dbe2e6", "#ebf0f0", "#f5fafa", "#f0 f5f5", "#e6eae9", "#d9dede"),
)
rownames(colorscheme_uber) <- colorscheme_uber$terrain

golden_ratio <- (1+sqrt(5))/2


# ===========================================
# Loading data
# ===========================================
# Download geospatial data from GISCO
geodata <- get_eurostat_geospatial(
  output_class = "sf",
  resolution = "1",
  nuts_level = 3,
  year = 2013)

geodata_de <- geodata[which(geodata$CNTR_CODE == 'DE'), ]
geodata_eu <- geodata[geodata$CNTR_CODE %in% c("DK", "PL", "CZ", "SK", "CH", "AT", "FR", "BE", "LU", "NL"), ]  # DE neighboring countries

# Load wind turbines spatial data frame
turbines.metadata <- st_as_sf(
  read.csv("metadata/wind_turbine_data_comma-separated.csv"),
  coords = c("lon", "lat"),
  crs=st_crs(geodata_de))
turbines.metadata$dt <- as.Date.character(turbines.metadata$dt, tryFormats = c("%d.%M.%Y"))  # commissioning date column to standtard datetime format
turbines.metadata <- turbines.metadata[which(turbines.metadata$dt < "2015-12-31"),]          # only consider turbines commissioned before 2015-12-31

# ===========================================
# Plotting
# ===========================================

# NUTS3
nuts3map <-  tm_shape(geodata_de, xlim=c(10.458-5,10.458+5)) + tm_fill(col="#223949") + tm_borders(col="#304A5C") +
  tm_shape(geodata_eu, xlim=c(10.458-6,10.458+6)) + tm_fill(col="#09101D") +
  tm_layout(bg.color = "#12232f", inner.margins = c(0, .02, .02, .02))
tmap_save(nuts3map, filename="../08_reporting/districts-map.png", dpi=600, outer.margins = c(0,0,0,0))

# Turbine locations: map
turbines.locations <- tm_shape(geodata_de, xlim=c(10.458-5,10.458+5)) + tm_fill(col="#223949") + tm_borders(col="#223949") +
  tm_shape(geodata_eu, xlim=c(10.458-5,10.458+5)) + tm_fill(col="#09101D") + tm_borders(col="#09101D") +
  tm_shape(turbines.metadata) + tm_dots(col="#dbe2e6") +
  tm_layout(bg.color = "#12232f", inner.margins = c(0, .02, .02, .02))
  # tm_scale_bar(breaks = c(0, 50, 100), text.size = 0.7, position = c("left", "bottom"))
tmap_save(turbines.locations, filename="../08_reporting/turbines-locations-map.png", dpi=600, outer.margins = c(0,0,0,0))

# Turbine counts: NUTS3 aggregation map
turbines.nuts3aggregation <- st_contains(geodata_de, turbines.metadata)
geodata_de$turbine.counts <- unlist(lapply(turbines.nuts3aggregation, length))
geodata_de$turbines.ids <- lapply(turbines.nuts3aggregation, unlist)

turbine.counts.map <-  tm_shape(geodata_de, xlim=c(10.458-5,10.458+5)) + tm_borders(col="#223949") + tm_fill(col="turbine.counts", breaks=c(0, 1, 10, 30, 100, 300, 762) , palette = get_brewer_pal("Blues", n = 6, contrast = c(0, 1))) +
  tm_shape(geodata_eu, xlim=c(10.458-6,10.458+6)) + tm_fill(col="#09101D") +
  tm_layout(bg.color = "#12232f", inner.margins = c(0, .02, .02, .02), legend.text.color = "#f5fafa", legend.title.color="#f5fafa", legend.position = c("left", "top"))
turbine.counts.map
tmap_save(turbine.counts.map, filename="../08_reporting/turbine-counts-map.png", dpi=600, outer.margins = c(0,0,0,0))

# Turbine counts: density
turbine.counts.density <- ggplot(geodata_de) + geom_density(aes(x=turbine.counts)) + scale_x_log10()
ggsave(turbine.counts.density, filename="../08_reporting/turbine-counts-density-plot.png", dpi=200)

# Rated Power: NUTS 3 aggregation @DEC 2015
get_installed_power <- function(turbines.ids){
  power.rated <- turbines.metadata[turbines.metadata$id %in% unlist(turbines.ids), ]$power
  return(sum(power.rated))
}

geodata_de$power.installed <- unlist(lapply(geodata_de$turbines.ids, get_installed_power))

# map
power.installed.map <- tm_shape(geodata_de, xlim=c(10.458-5,10.458+5)) + tm_borders(col="#223949") + tm_fill(col="power.installed", breaks=c(0, 0, 1e+03, 3e+03, 1e+04, 3e+04, 1e+05, 3e+05, 1.1e+06), legend.format = c(scientific=TRUE), palette = get_brewer_pal("Blues", contrast = c(0, 1))) +
  tm_shape(geodata_eu, xlim=c(10.458-6,10.458+6)) + tm_fill(col="#09101D") +
  tm_layout(bg.color = "#12232f", inner.margins = c(0, .02, .02, .02), legend.text.color = "#f5fafa", legend.title.color="#f5fafa", legend.position = c("left", "top"))
power.installed.map
tmap_save(power.installed.map, filename="../08_reporting/power-installed-map.png", dpi=600, outer.margins = c(0,0,0,0))

# density
power.installed.density <- ggplot(geodata_de) + geom_density(aes(x=power.installed)) + scale_x_log10()
ggsave(power.installed.density, filename="../08_reporting/power-installed-density-plot.png", dpi=200)

# Turbine ages: map
turbines.ages.map <- tm_shape(geodata_de, xlim=c(10.458-5,10.458+5)) + tm_fill(col="#223949") +
  tm_shape(geodata_eu, xlim=c(10.458-6,10.458+6)) + tm_fill(col="#09101D") +
  tm_shape(turbines.metadata) + tm_dots(col="dt", title="Commisioning Date", style="quantile", palette = viridisLite::inferno(6)) +
  tm_layout(bg.color = "#12232f", inner.margins = c(0, .02, .02, .02), legend.text.color = "#f5fafa", legend.title.color="#f5fafa",) + tmap_options(max.categories = 6)
tmap_save(turbines.ages.map, filename="../08_reporting/turbine-ages-map.png", dpi=600, outer.margins = c(0,0,0,0))

# Turbine ages: density
turbines.ages.density <- ggplot(turbines.metadata) + geom_density(aes(x=dt)) + geom_vline(xintercept=as.Date("2010-09-28"), col="red")
turbines.ages.density
ggsave(turbines.ages.density, filename="../08_reporting/turbine-ages-density-plot.png", dpi=200)


# Turbine ages: cumulative count
turbines.count.cumsum <- ggplot(turbines.metadata, aes(x=dt)) + stat_bin(aes(y=cumsum(..count..), geom="step")) + geom_vline(xintercept=as.Date("2010-09-28"), col="red")
ggsave(turbines.count.cumsum, filename="../08_reporting/turbine-cumulative-count-germany.png", dpi=200)
# ggplot(turbines.metadata, aes(x=dt)) + stat_bin(data=subset(turbines.metadata, NUTS_ID==" DE141"), aes(y=cumsum(..count..), geom="step"))

# Turbine ages: NUTS3 aggregated
turbines.nuts3aggregation <- aggregate(turbines.metadata, by=list(turbines.metadata$NUTS_ID), list)
rownames(turbines.nuts3aggregation) <- turbines.nuts3aggregation$Group.1

turbines.nuts3.count.cumsum.plot <- ggplot(turbines.nuts3aggregation, aes(x=dt)) + stat_bin(aes(y=cumsum(..count..), geom="step")) + geom_vline(xintercept=as.Date("2010-09-28"), col="red")
ggsave(turbines.nuts3.count.cumsum.plot, filename="../08_reporting/turbine-cumulative-count-nuts3.png", dpi=200)

turbines.nuts3aggregation$age.median <- lapply(turbines.nuts3aggregation$dt, median)


# map
ages.nuts3.map <- tm_shape(geodata_de, xlim=c(10.458-5,10.458+5)) + tm_borders(col="#223949") + tm_fill(col="dt", palette = viridisLite::inferno(6)) +
  tm_shape(geodata_eu, xlim=c(10.458-6,10.458+6)) + tm_fill(col="#09101D") +
  tm_layout(bg.color = "#12232f", inner.margins = c(0, .02, .02, .02), legend.text.color = "#f5fafa", legend.title.color="#f5fafa", legend.position = c("left", "top"))
ages.nuts3.map
tmap_save(ages.nuts3.map, filename="../08_reporting/ages-nuts3-map.png", dpi=600, outer.margins = c(0,0,0,0))

# Power generation: district DE141  # TODO: drop observations after 2015
file.names <- dir("./power-generation/")
file.paths <- paste("./power-generation/", file.names, sep="")
power.generated <- do.call(rbind, lapply(file.paths,read.csv))

power.generated <- read.csv("./power-generation/wpinfeed_inkW_nuts3_2015_utc.csv")  # TODO: drop district which not in geodata_de$NUTS_ID
power.generated$X <- ymd_hms(power.generated$X)
rownames(power.generated) <- power.generated$X
power.generated.ts <- xts(power.generated, order.by = power.generated$X)

power.generated <- select(power.generated, -X)


plot.ts(power.generated.ts[, c("DE145", "DE141", "DEF07")])
ts_seasonal(power.generated.ts[,"DE145"], type="normal")
ggplot(power.generated.selection, aes(x=X, y=DE80N, group = 1)) + geom_line() + xlab("")
plot(window(power.generated.ts, start=c(2015,3), end=c(2015,4)),  +  ylab="", col="blue", lwd=2  +     main="Monthly closing price of SBUX")
# Power generation: all districts superposed

# Power generation: spatial cross-correlation plot
corr.power <- cor(power.generated, method = "spearman")
# st_distance(head(geodata_de, 5))
geodata.districts.producing <- geodata_de[which(geodata_de$NUTS_ID %in% colnames(power.generated)),]
distances.nuts3 <- st_distance(geodata.districts.producing)
rownames(distances.nuts3) <- geodata.districts.producing$NUTS_ID
colnames(distances.nuts3) <- geodata.districts.producing$NUTS_ID

geodata.districts.producing.centroids <- st_centroid(geodata.districts.producing)
distances.nuts3.centroids <- st_distance(geodata.districts.producing.centroids)
rownames(distances.nuts3.centroids) <- geodata.districts.producing$NUTS_ID
colnames(distances.nuts3.centroids) <- geodata.districts.producing$NUTS_ID

# upper.tri(x, diag = FALSE)

# Empirical CDF for the different regional power outputs @2015
ecdf()

beep(sound=4)


