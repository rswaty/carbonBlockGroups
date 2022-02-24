

### take data produced by Maddie Tango and Steven WIlmer, process it and make into leaflet map
### this processing by Randy Swaty
### took original data, simplified and removed uneeded attributes for size reduction.  Only saved simplified shapefiles to this directory.  ###Originials located on google drive at https://drive.google.com/drive/folders/1ghZ9M_cZ_uIequiaxTs1WVGFLrYjP2O_?usp=sharing

# add in second set of polygons
# try simplifying features for speed
# reduce weight of lines
# legend title
# add units to legend
# simple dash!


# packages
library(rgdal)
library(raster)
library(htmlwidgets)
library(leaflet)
library(tidyverse)
library(sf)
library(tmaptools)

# read in datasets, process, remove/rename columns for popup

blockgroups_reduced <- st_read("data/blockgroups_final.shp") %>%
                      select(5, 16:20, 26, 36:38) %>%
                      rename(PercentConifer = coniferPct,
                             PercentRiparian = ripariaPct,
                             PercentHardwood = hardwooPct,
                             PercentConiferHardwood = coniHarPct,
                             PercentDeveloped = devPct,
                             CarbonPerKM = sumCarPeKm,
                             PercentNonWhite = pct_nonWhi,
                             Category = categ) %>%
                             st_transform(CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

format(object.size(blockgroups_reduced), units = "Mb") #123mb



# simplify shapes


blockgroups_reduced_simple <- simplify_shape(blockgroups_reduced, fact = 0.05)

format(object.size(blockgroups_reduced_simple), units = "Mb")  # 22mb

st_write(blockgroups_reduced_simple, "data/blockgroups_reduced_simple.shp", driver="ESRI Shapefile")



forest50nonwhite70reduced <- st_read("data/forest50nonwhite70.shp") %>%
  select(5, 16:20, 26, 36:39) %>%
  rename(PercentConifer = coniferPct,
         PercentRiparian = ripariaPct,
         PercentHardwood = hardwooPct,
         PercentConiferHardwood = coniHarPct,
         PercentDeveloped = devPct,
         CarbonPerKM = sumCarPeKm,
         PercentNonWhite = pct_nonWhi,
         Category = categ,
         PercentForest = pctForest) %>%
  st_transform(CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))



format(object.size(forest50nonwhite70reduced), units = "Mb") 


## bins for carbon 
bins <- c(0, 20, 40, 60, 80, 100)
pal <- colorBin("Greens", domain = blockgroups_reduced_simple$CarbonPerKM, bins = bins)

popup <- paste(
  "Percent Non-white", forest50nonwhite70reduced$PercentNonWhite, "<br>",
  "Amount of carbon", forest50nonwhite70reduced$CarbonPerKM, "<br>",
  "Percent forested", forest50nonwhite70reduced$PercentForest)


mapForLiz <-
  leaflet(blockgroups_reduced_simple) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(-81.0260447, 33.983476, zoom = 7) %>%  
  addPolygons(
    data = blockgroups_reduced_simple,
    fillColor = ~pal(CarbonPerKM),
    fillOpacity = 1, 
    weight = 0.6,
    opacity = 0.8,
    color = "grey") %>%
  addPolygons(
    data = forest50nonwhite70reduced,
    fillOpacity = 0, 
    weight = 0.9,
    opacity = 1,
    color = "#a503fc", 
    popup = ~popup) %>%
  addLegend(
    pal = pal,
    values = ~CarbonPerKM,
    position = "bottomright",
    opacity = 1) 

mapForLiz

saveWidget(mapForLiz, 'map.html', selfcontained = TRUE)






