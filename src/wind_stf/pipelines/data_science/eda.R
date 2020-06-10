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

# ===========================================
# Defining constants
# ===========================================

# Uber Color Schemes
# colorscheme_uber <- data.table(
#  terrain = c("waters","land","highway","roads","parks","airport"),
#   dark = c("#12232f", "#09101d", "#304a5c", "#223949", "#041922", "#131926"),
#   light = c("#dbe2e6", "#ebf0f0", "#f5fafa", "#f0 f5f5", "#e6eae9", "#d9dede"),
# )
# rownames(colorscheme_uber) <- colorscheme_uber$terrain

golden_ratio <- (1+sqrt(5))/2


# ===========================================
# Loading data
# ===========================================
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

geodata_de <- geodata[which(geodata$CNTR_CODE == 'DE'), ]
geodata_eu <- geodata[geodata$CNTR_CODE %in% c("DK", "PL", "CZ", "SK", "CH", "AT", "FR", "BE", "LU", "NL"), ]  # DE neighboring countries

# Load metadata: wind turbines spatial data frame
turbines.metadata <- st_as_sf(
  read.csv("metadata/wind_turbine_data_comma-separated.csv"),
  coords = c("lon", "lat"),
  crs=st_crs(geodata_de))
turbines.metadata$dt <- as.Date.character(turbines.metadata$dt, tryFormats = c("%d.%M.%Y"))  # commissioning date column to standtard datetime format
turbines.metadata <- turbines.metadata[which(turbines.metadata$dt < "2015-12-31"),]          # only consider turbines commissioned before 2015-12-31
turbines.metadata$NUTS_ID <- trimws(turbines.metadata$NUTS_ID)

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

# ===========================================
# Preprocessing
# ===========================================
# TODO: why districts in power.generated not all in geodata_de districts with power.installed>0? Hypotheses: (1) geodata_de, power.generated with different NUTS3 definition
colnames(power.generated) %in% geodata_de[which(geodata_de$power.installed>0),]$NUTS_ID

get_new_commisionings <- function(nuts_id, turbines.metadata=turbines.metadata){
  new.commissionings <- data.table(turbines.metadata) %>%
    .[which(turbines.metadata$NUTS_ID==nuts_id), c("NUTS_ID", "dt", "power")] %>%
    arrange(., dt)
  new.commissionings <- select(new.commissionings, -NUTS_ID)
  return(new.commissionings)
}

aggregate_sameday_commissionings <- function(nuts_id, metadata=turbines.metadata){
  new.commissionings.aggregated <- aggregate(power~dt, data=get_new_commisionings(nuts_id, metadata), sum)
  return(new.commissionings.aggregated)
}

get_installed_power <- function(nuts_id, metadata=turbines.metadata){
  capacity.installed <- aggregate_sameday_commissionings(nuts_id, metadata)
  capacity.installed$power <- cumsum(capacity.installed$power)
  capacity.installed.xts <- xts(capacity.installed, order.by=ymd(capacity.installed$dt)) %>%
    .$power

  storage.mode(capacity.installed.xts) <- "double"
  index(capacity.installed.xts) <- index(capacity.installed.xts) # consider commissioning times as always being at 00:00:00
  colnames(capacity.installed.xts) <- nuts_id

  # unit test get_installed_power
  # assertive.base::are_identical(sum(new.commissionings$power), max(capacity.installed$power))
  # assertive.properties::is_monotonic_increasing(capacity.installed$power)
  return(capacity.installed.xts)
}

get_capacity_factor <- function(nuts_id, metadata=turbines.metadata, data=power.generated.xts){
  capacity.installed.xts <- get_installed_power(nuts_id, metadata)

  blank.xts <- xts(x=NULL,
                   seq(from=start(capacity.installed.xts)+hours(1),
                       to=as.Date(end(data))+hours(23),
                       by="hour"))

  capacity.installed.xts <- merge.xts(blank.xts,
                                      capacity.installed.xts,
                                      fill=na.locf)
  capacity.installed.xts <- capacity.installed.xts["20150101/20151231"]

  cf <- data[, nuts_id]/capacity.installed.xts
  # cf <- power.generated.xts[, "DEF0C"]/capacity.installed.xts
  return(cf)
}

# TODO: calculate all CFs and put them into single data.table / xts
get_all_capacity_factors <- function(){
  # cf.all <- apply(power.generated.xts, MARGIN=2, FUN=get_capacity_factor(, turbines.metadata, power.generated.xts))
  cf.all <- vapply(power.generated.xts, function(col) get_capacity_factor(col, turbines.metadata, power.generated.xts), FUN.VALUE = numeric(nrow(power.generated.xts)))
  return(cf.all)
}

get_capacity_factor("DEF0C")
beepr::beep(sound=4)

