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

library(units)

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

LoadGeodata <- function(){
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

  return(list('de' = geodata[which(geodata$CNTR_CODE == 'DE'), ],
              'eu' = geodata[geodata$CNTR_CODE %in% c("DK", "PL", "CZ", "SK", "CH", "AT", "FR", "BE", "LU", "NL"), ]))  # DE neighboring countries ))
}
geodata <- LoadGeodata()

# Load metadata: wind turbines spatial data frame
turbines.metadata <- st_as_sf(
  read.csv("metadata/wind_turbine_data.csv", sep=";"),
  coords = c("lon", "lat"),
  crs=st_crs(geodata$de))

turbines.metadata$dt <- as.Date.character(turbines.metadata$dt, tryFormats = c("%d.%m.%Y"))  # commissioning date column to standard datetime format

turbines.metadata.st <- read.csv("metadata/wind_turbine_data.csv", sep=";")

GetPowerGeneratedTS <- function(){
  power.generated <- read.csv("./power-generation/wpinfeed_inkW_nuts3_2015_utc.csv")  # TODO: drop districts not in geodata$de$NUTS_ID
  power.generated$X <- ymd_hms(power.generated$X, tz="UTC")
  rownames(power.generated) <- power.generated$X
  power.generated <- select(power.generated, -X)

  power.generated.xts <- xts(power.generated, order.by = ymd_hms(rownames(power.generated)))
  return(power.generated.xts)
}

# Preprocessing  ===========================================
districts.blacklist <- c('DE409', 'DE40C', 'DE403')  # districts TS which represent outliers in correlogram
turbines.metadata <- turbines.metadata[ which( turbines.metadata$NUTS_ID != districts.blacklist), ]
turbines.metadata.st <- turbines.metadata.st[ which( turbines.metadata.st$NUTS_ID != districts.blacklist), ]

# Transform a matrix upper diagonal into a vector
TransformMatrixIntoVector <- function(A){
  bool.mask <- upper.tri(A, diag = FALSE)
  V <- A[bool.mask]
  return(V)
}


GetPowerInstalled <- function(metadata=turbines.metadata){
  power.installed.deltas <- aggregate(power ~ dt + NUTS_ID, data=metadata, sum)  # installed power aggregated for sameday, same district commissionings

  power.installed <- power.installed.deltas %>%
    arrange(NUTS_ID, dt) %>%
    group_by(NUTS_ID) %>%
    mutate(power.tot = cumsum(power))

  return(power.installed)
}

GetPowerInstalledTimeSeries <- function(.power.installed=power.installed, colnames){
  blank.xts <- xts(x=NULL,
                   seq(from=min(.power.installed$dt) + hours(1),
                       to=as.Date("2015-12-31") + hours(23),
                       by="hour"))

  .power.installed <- select(.power.installed, -power)
  power.installed.xts <- read.zoo(.power.installed, split="NUTS_ID") %>%
    merge.xts(blank.xts,
              .,
              fill=na.locf) %>%
    na.fill(., fill=0) %>%
    .["20150101/20151231"]

  power.installed.xts <- power.installed.xts[, colnames]  # order columns the same way of power.generated.xts

  # tests for GetPowerInstalledTimeSeries
  # assertive.base::are_identical(sum(new.commissionings$power), max(capacity.installed$power))
  # assertive.properties::is_monotonic_increasing(capacity.installed$power)
  # sum(is.na(power.installed.xts)) == 0
  # sum(names(power.installed.xts) == names(power.generated.xts))

  return(power.installed.xts)
}


GetAllCapacityFactorsTimeSeries <- function(power.generated.xts, power.installed.xts){
  cf <- power.generated.xts/power.installed.xts
  cf <- na.fill(cf, fill=0)  # handle NAs resulting from divisions by zero (no power.installed)

  # unit test for GetCapacityFactor
  # GetColumnsContainingNA(cf, view=TRUE)

  return(cf)
}

GetColumnsContainingNA <- function(df, view=FALSE){
  if(sum(is.na(cf)) != 0) {
    columns.with.na <- df[,which(sapply(df, function(x) sum(is.na(x))) > 0)]
    columns.with.na.names <- names(columns.with.na)
    if(view) View(columns.with.na)
    return(columns.with.na.names)
  }
  else return("No NA found")
}

# checking for data loss during transformation
sum(is.na(turbines.metadata))
"DE146" %in% unique(turbines.metadata$NUTS_ID)

turbines.metadata <- turbines.metadata[which(turbines.metadata$dt < "2015-12-31"),]          # only consider turbines commissioned before 2015-12-31
turbines.metadata$NUTS_ID <- trimws(turbines.metadata$NUTS_ID)

# Load power generation data
# TODO: drop observations after 2015
# file.names <- dir("./power-generation/")
# file.paths <- paste("./power-generation/", file.names, sep="")
# power.generated <- do.call(rbind, lapply(file.paths,read.csv))

GetTurbinesCentroids <- function(){
  turbines.metadata.st <- read.csv("metadata/wind_turbine_data.csv", sep=";")
  turbines.metadata.st[ , !(turbines.metadata.st$NUTS_ID %in% districts.blacklist)]

  turbines.metadata.st$dt <- as.Date.character(turbines.metadata.st$dt, tryFormats = c("%d.%m.%Y"))  # commissioning date column to standard datetime format
  turbines.metadata.st <- turbines.metadata.st[which(turbines.metadata.st$dt < "2015-12-31"),]
  turbines.centroids <- aggregate(. ~ NUTS_ID, data= turbines.metadata.st[,c("lat", "lon", "NUTS_ID")], mean)
  rownames(turbines.centroids) <- turbines.centroids$NUTS_ID
  turbines.centroids <- turbines.centroids[ names(capacity.factors), ] # order centroids table the same way as capacity.factors, and corr.cf tables
  turbines.centroids <- st_as_sf(turbines.centroids,
                                 coords = c("lon", "lat"),
                                 crs=st_crs(geodata$de))
  return(turbines.centroids)
}

GetTurbinesCentroidsDistances <- function(turbines.centroids){
  distances.centroids <- st_distance(turbines.centroids)
  rownames(distances.centroids) <- turbines.centroids$NUTS_ID
  colnames(distances.centroids) <- turbines.centroids$NUTS_ID
  return(distances.centroids)
}

# EDA  ===========================================
# TODO: why districts in power.generated not all in geodata$de districts with power.installed>0? Hypotheses: (1) geodata$de, power.generated with different NUTS3 definition
#colnames(power.generated) %in% geodata$de[which(geodata$de$power.installed>0),]$NUTS_ID
DropBlackMailedDistricts <- function(power.generated.xts){
  return ( power.generated.xts[ , !(names(power.generated.xts) %in% districts.blacklist)] )
}

power.generated.xts <- GetPowerGeneratedTS()
power.generated.xts <- DropBlackMailedDistricts(power.generated.xts)
power.installed.xts <- GetPowerInstalled(turbines.metadata) %>%
  GetPowerInstalledTimeSeries(., colnames=names(power.generated.xts))

capacity.factors <- GetAllCapacityFactorsTimeSeries(power.generated.xts, power.installed.xts)

# Get matrix: correlation matrix for generated power
corr.cf <- cor(capacity.factors, method = "spearman")
corr.cf.pearson <- cor(capacity.factors, method = "pearson")
# Get centroid of turbines locations by district
turbines.centroids <- GetTurbinesCentroids()

# Euclidean distances between pairs of centroids
distances.centroids <- GetTurbinesCentroidsDistances(turbines.centroids)

# TS pairs: a dataframe characterising pairs of time series
district.pairs <- combn( unique( turbines.metadata$NUTS_ID ), 2 )
district.pairs.id <- paste(district.pairs[1,], district.pairs[2,], sep="-")

GetDistrictPowerInstalled <- function(id){
  return( power.installed.xts[ end(power.installed.xts), id ] )
}

# some districts were not generating any wind power for most of the period. Better not to consider them.
GetAllDistrictAvgCf <- function(){
  cf.mean <- apply( capacity.factors, MARGIN=2, mean)
  return( cf.mean )
}

GetDistrictAvgCf <- function(id){
  return( cf.mean[ id ] )
}

# min.power.installed <- apply(district.pairs, MARGIN=c(1,2), FUN=GetDistrictPowerInstalled) %>%  # get power installed for every cell in district.pairs
#                        apply( . , MARGIN=2, FUN=min)                                            # get minimum power installed in district pair pair

cf.mean <- GetAllDistrictAvgCf()
min.avg.cf <- apply(district.pairs, MARGIN=c(1,2), FUN=GetDistrictAvgCf) %>%
              apply( . , MARGIN=2, FUN=min)

# starting.dates <- GetAllDistrictFirstCommissioning()
# latest.production.start <- apply(district.pairs, MARGIN=c(1,2), FUN=GetDistrictAvgCf) %>%
#                            apply( . , MARGIN=2, FUN=min)

ts.pairs <- data.table(pairs.id=district.pairs.id,
                       id1=district.pairs[1,],
                       id2=district.pairs[2,],
                       distances= as.double( TransformMatrixIntoVector(distances.centroids) ),
                       spearman.corr=TransformMatrixIntoVector(corr.cf),
                       pearson.corr = TransformMatrixIntoVector(corr.cf.pearson),
                       # least.power=min.power.installed,
                       min.avg.cf=min.avg.cf)

p <- ggplot(data=ts.pairs, aes(x=distances, y=spearman.corr)) +
  geom_point(alpha = 0.1) +
  xlab("Euclidean Distance [km]") +
  ylab("Spearman Correlation [-]")
p
ggsave( '../08_reporting/correlation-spearman-vs-distance.png',
  plot = p,
  scale = golden_ratio,
  width = 210/golden_ratio,
  height = (210/golden_ratio)/golden_ratio,
  units = 'mm',
  dpi = 300,
  limitsize = TRUE,
)

p <- ggplot(data=ts.pairs, aes(x=distances, y=pearson.corr)) +
  geom_point(alpha = 0.1) +
  xlab("Euclidean Distance [km]") +
  ylab("Pearson Correlation [-]")
p
ggsave( '../08_reporting/correlation-pearson-vs-distance.png',
  plot = p,
  scale = golden_ratio,
  width = 210/golden_ratio,
  height = (210/golden_ratio)/golden_ratio,
  units = 'mm',
  dpi = 300,
  limitsize = TRUE,
)

# ggplotly(p)

#plot_ly(x=ts.pairs$distances,
#        y=ts.pairs$spearman.corr,
#        color=ts.pairs$min.avg.cf,
#        type = 'scatter',
#        text = ts.pairs$pairs.id,
#        alpha=0.2,)

 # show time series
 #p <- ggplot(data = capacity.factors, aes(x = index(capacity.factors), y = capacity.factors[,'DEA56'])) +
 #      geom_line(color = "#FC4E07", size = 0.5, alpha=0.3)
 #ggplotly(p)
#
# # plot seasonal time series
# ts_seasonal(capacity.factors[,'DEA56'])
# capacity.factors.daily <- aggregate()
#
 # plot cross-correlogram

GetCCF <- function(id1, id2){
  ccf.object <- ccf(rank(as.ts(capacity.factors[, id1])),
                    rank(as.ts(capacity.factors[, id2])),
                    lax.max = 72,
                    plot = FALSE)
  return(ccf.object$acf)
}

a <- GetCCF('DEA1B', 'DEA44')
b <- GetCCF('DED43', 'DED43')

ccf.object <- ccf(rank(as.ts(capacity.factors[, 'DED43'])),
                  rank(as.ts(capacity.factors[, 'DED53'])),
                  lag = 6,
                  plot = TRUE)

plot(x=seq(-6,6), y=ccf.object$acf)

#ts.pairs$ccf =  mapply(ccf, capacity.factors, MoreArgs = list(lag.max = 72))
#  ccf(rank(as.ts(capacity.factors[,'DEA56'])), rank(as.ts(capacity.factors[,'DEA59'])), lag.max = 72)
