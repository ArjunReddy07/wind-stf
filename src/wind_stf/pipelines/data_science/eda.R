library(beepr)

library(hdf5r)    # for handling hdf5 files
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
library(plotly)
#library(shiny)   # for web applications
library(tmaptools)

library(TSstudio)
library(lubridate)
library(xts)

# Defining constants ===========================================
# Uber Color Schemes
# colorscheme_uber <- data.table(
#  terrain = c("waters","land","highway","roads","parks","airport"),
#   dark = c("#12232f", "#09101d", "#304a5c", "#223949", "#041922", "#131926"),
#   light = c("#dbe2e6", "#ebf0f0", "#f5fafa", "#f0 f5f5", "#e6eae9", "#d9dede"),
# )
# rownames(colorscheme_uber) <- colorscheme_uber$terrain

golden_ratio <- (1+sqrt(5))/2


# Loading data ===========================================
# Ensure current working dir is data/01_raw
if(!dir.exists("./metadata")){
  setwd("./data/01_raw")
}

# Get geospatial data: first try from local files, then download from GISCO if necessary
tryCatch(
  {
    # attempt to read file locally
    # use assign so you can access the variable outside of the function
    assign("geodata", st_read("./geospatial/geodata.shp"), envir = .GlobalEnv)
    print("Loaded geodata from local storage.")
  },
  error = function( err ){
    print("Could not read data from current directory, attempting download...")
    tryCatch(
      {
        assign("geodata",
               get_eurostat_geospatial(
                 output_class = "sf",
                 resolution = "1",
                 nuts_level = 3,
                 year = 2013),
               envir = .GlobalEnv)
        st_write(geodata, "./geospatial/geodata.shp")
        print("Loaded geodata from GISCO server. Saved it locally.")
      },
      error = function( err ){
        print("Could not download geodata from GISCO. Aborting execution.")
      }
    )
  }
)

geodata.de <- geodata[which(geodata$CNTR_CODE == 'DE'), ]
geodata.eu <- geodata[geodata$CNTR_CODE %in% c("DK", "PL", "CZ", "SK", "CH", "AT", "FR", "BE", "LU", "NL"), ]  # DE neighboring countries

# Load metadata: wind turbines spatial data frame
turbines.metadata <- st_as_sf(
  read.csv("metadata/wind_turbine_data.csv", sep=";"),
  coords = c("lon", "lat"),
  crs=st_crs(geodata.de))
turbines.metadata$dt <- as.Date.character(turbines.metadata$dt, tryFormats = c("%d.%M.%Y"))  # commissioning date column to standtard datetime format
turbines.metadata <- turbines.metadata[which(turbines.metadata$dt < "2015-12-31"),]          # only consider turbines commissioned before 2015-12-31
turbines.metadata$NUTS_ID <- trimws(turbines.metadata$NUTS_ID)

# TODO: DE146 should be in turbines.metadata$NUTS_ID

# Load power generation data
# TODO: drop observations after 2015
# file.names <- dir("./power-generation/")
# file.paths <- paste("./power-generation/", file.names, sep="")
# power.generated <- do.call(rbind, lapply(file.paths,read.csv))

power.generated <- read.csv("./power-generation/wpinfeed_inkW_nuts3_2015_utc.csv")  # TODO: drop districts not in geodata_de$NUTS_ID
power.generated$X <- ymd_hms(power.generated$X, tz="UTC")
rownames(power.generated) <- power.generated$X
power.generated <- select(power.generated, -X)

power.generated.xts <- xts(power.generated, order.by = ymd_hms(rownames(power.generated)))

# Preprocessing  ===========================================
# TODO: why districts in power.generated not all in geodata_de districts with power.installed>0? Hypotheses: (1) geodata_de, power.generated with different NUTS3 definition
colnames(power.generated) %in% geodata_de[which(geodata_de$power.installed>0),]$NUTS_ID

GetPowerInstalled <- function(metadata=turbines.metadata){
  power.installed.deltas <- aggregate(power ~ dt + NUTS_ID, data=metadata, sum)  # installed power aggregated for sameday, same district commissionings

  power.installed <- power.installed.deltas %>%
    arrange(NUTS_ID, dt) %>%
    group_by(NUTS_ID) %>%
    mutate(power.tot = cumsum(power))

  return(power.installed)
}

GetPowerInstalledTimeSeries <- function(.power.installed=power.installed){
  blank.xts <- xts(x=NULL,
                   seq(from=min(.power.installed$dt) + hours(1),
                       to=as.Date("2015-12-31") + hours(23),
                       by="hour"))

  .power.installed <- select(.power.installed, -power)
  power.installed.xts <- read.zoo(.power.installed, split="NUTS_ID")

  power.installed.xts2 <- merge.xts(blank.xts,
                                   power.installed.xts,
                                   fill=na.locf) %>%
    .["20150101/20151231"]

  colnames(blank.xts) <- unique(.power.installed$NUTS_ID)

  power.installed <- aggregate_sameday_commissionings(metadata)
  power.installed$power <- cumsum(power.installed$power)
  power.installed.xts <- xts(power.installed, order.by=ymd(capacity.installed$dt)) %>%
    .$power

  storage.mode(power.installed.xts) <- "double"
  index(power.installed.xts) <- index(power.installed.xts) # consider commissioning times as always being at 00:00:00
  colnames(power.installed.xts) <- nuts_id

  # unit test get_installed_power
  # assertive.base::are_identical(sum(new.commissionings$power), max(capacity.installed$power))
  # assertive.properties::is_monotonic_increasing(capacity.installed$power)
  return(power.installed.xts)
}

GetCapacityFactor <- function(nuts_id, metadata=turbines.metadata, data=power.generated.xts){
  capacity.installed.xts <- get_installed_power(nuts_id, metadata)

  blank.xts <- xts(x=NULL,
                   seq(from=start(capacity.installed.xts)+hours(1),
                       to=as.Date(end(data))+hours(23),
                       by="hour"))

  capacity.installed.xts <- merge.xts(blank.xts,
                                      capacity.installed.xts,
                                      fill=na.locf)
  capacity.installed.xts <- capacity.installed.xts["20150101/20151231"]

  cf <- power.generated.xts/capacity.installed.xts
  return(cf)
}

# TODO: calculate all CFs and put them into single data.table / xts
GetAllCapacityFactors <- function(){
  # v0
  # cf.all <- vapply(power.generated.xts, function(col) dummy_function(names(col)), FUN.VALUE = numeric(nrow(power.generated.xts)))

  # v1
  # power.generated.all <- power.generated.xts
  # power.installed.all <- vapply(power.generated.xts, function(col) get_installed_power(col), FUN.VALUE = numeric(nrow(power.generated.xts)))
  # cf.all <- power.generated.all / power.installed.all
  # crbind(cf.all, cf)

  # v2
  cf.all <- xts()
  for ( nuts_id in names(power.generated.xts) ){
    cf <- get_capacity_factor(nuts_id)
    print(nuts_id)
  }
  return(cf)
}

# cfs <- get_all_capacity_factors()
beepr::beep(sound=4)

# debugging hypothesis: differnt from the examples
# xz <- xts(replicate(6, sample(c(1:100), 1000, rep = T)),
#           order.by = Sys.Date() + 1:1000)
# names(xz) <- c("a", "b", "c", "d", "e", "f")
#
# xz_a <- vapply(xz, function(col) col + 100, FUN.VALUE = numeric(nrow(xz)))
# xz_b <- xz/xz_a

# TODO: not all colnames in power.generated.xts can be found in turbines.metadata$NUTS_ID
