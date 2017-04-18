#####################################################
# Source code for GIS in Action Conference April 2011
# R - Fundamentals for Spatial Data
# Marc Weber
#####################################################

#######################
# SpatialData in R - sp
#######################

# Download data
download.file("https://github.com/mhweber/gis_in_action_r_spatial/blob/gh-pages/files/WorkshopData.zip?raw=true",
              "WorkshopData3.zip",
              method="auto",
              mode="wb")
download.file("https://github.com/mhweber/gis_in_action_r_spatial/blob/gh-pages/files/HUCs.RData?raw=true",
              "HUCs.RData",
              method="auto",
              mode="wb")
unzip("WorkshopData3.zip", exdir = "/home/marc") 

getwd()
dir()
setwd("/home/marc/GitProjects")
class(iris)
str(iris)

# Exercise 1

library(sp)
getClass("Spatial")
getClass("SpatialPolygons")

library(rgdal)
data(nor2k)
plot(nor2k,axes=TRUE)

# Exercise 2

cities <- c('Ashland','Corvallis','Bend','Portland','Newport')
longitude <- c(-122.699, -123.275, -121.313, -122.670, -124.054)
latitude <- c(42.189, 44.57, 44.061, 45.523, 44.652)
population <- c(20062,50297,61362,537557,9603)
locs <- cbind(longitude, latitude) 
plot(locs, cex=sqrt(population*.0002), pch=20, col='red', 
     main='Population', xlim = c(-124,-120.5), ylim = c(42, 46))
text(locs, cities, pos=4)

breaks <- c(20000, 50000, 60000, 100000)
options(scipen=3)
legend("topright", legend=breaks, pch=20, pt.cex=1+breaks/20000, 
       col='red', bg='gray')

lon <- c(-123.5, -123.5, -122.5, -122.670, -123)
lat <- c(43, 45.5, 44, 43, 43)
x <- cbind(lon, lat)
polygon(x, border='blue')
lines(x, lwd=3, col='red')
points(x, cex=2, pch=20)

library(maps)
map()

map.text('county','oregon')
map.axes()
title(main="Oregon State")

p <- map('county','oregon')
str(p)
p$names[1:10]
p$x[1:50]

L1 <-Line(cbind(p$x[1:8],p$y[1:8]))
Ls1 <- Lines(list(L1), ID="Baker")
SL1 <- SpatialLines(list(Ls1))
str(SL1)
plot(SL1) 

library(maptools)
counties <- map('county','oregon', plot=F, col='transparent',fill=TRUE)
counties$names
#strip out just the county names from items in the names vector of counties
IDs <- sapply(strsplit(counties$names, ","), function(x) x[2])
counties_sp <- map2SpatialPolygons(counties, IDs=IDs,
                                   proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
summary(counties_sp)
plot(counties_sp, col="grey", axes=TRUE)

# Exercise 3

StreamGages <- read.csv('StreamGages.csv')
class(StreamGages)
head(StreamGages)

coordinates(StreamGages) <- ~LON_SITE + LAT_SITE
llCRS <- CRS("+proj=longlat +datum=NAD83")
proj4string(StreamGages) <- llCRS
summary(StreamGages)

bbox(StreamGages)
proj4string(StreamGages)

projInfo(type='datum')
projInfo(type='ellps')
projInfo(type='proj')

proj4string(StreamGages)

plot(StreamGages, axes=TRUE, col='blue')

map('state',regions=c('oregon','washington','idaho'),fill=FALSE, add=T)

plot(StreamGages[StreamGages$STATE=='OR',],add=TRUE,col="Yellow") #plot just the Oregon sites in blue on top of other sites
plot(StreamGages[StreamGages$STATE=='WA',],add=TRUE,col="Red")
plot(StreamGages[StreamGages$STATE=='ID',],add=TRUE,col="Green")

load("/home/marc/GitProjects/gis_in_action_r_spatial/files/HUCs.RData")
class(HUCs)
getClass("SpatialPolygonsDataFrame")
summary(HUCs)
slotNames(HUCs) #get slots using method
str(HUCs, 2)
head(HUCS@data) #the data frame slot 
HUCs@bbox #call on slot to get bbox

HUCs@polygons[[1]]
slotNames(HUCs@polygons[[1]])
HUCs@polygons[[1]]@labpt
HUCs@polygons[[1]]@Polygons[[1]]@area

# How would we code a way to extract the HUCs polygon with the smallest area? 
# Look at the min_area function that is included in the HUCs.RData file
min_area
min_area(HUCs)
# We use sapply from the apply family of functions on the area slot of the Polygons slot

StreamGages <- spTransform(StreamGages, CRS(proj4string(HUCs)))
gage_HUC <- over(StreamGages,HUCs, df=TRUE)
StreamGages$HUC <- gage_HUC$HUC_8[match(row.names(StreamGages),row.names(gage_HUC))]
head(StreamGages@data)

library(rgeos)
HUCs <- spTransform(HUCs,CRS("+init=epsg:2991"))
gArea(HUCs)

#######################
# SpatialData in R - sf
#######################

library(devtools)
# install_github("edzer/sfr")
library(sf)

methods(class = "sf")

library(sf)
counties_zip <- 'http://oe.oregonexplorer.info/ExternalContent/SpatialDataforDownload/orcnty2015.zip'
download.file(counties_zip, '/home/marc/OR_counties.zip')
unzip('/home/marc/OR_counties.zip')
counties <- st_read('orcntypoly.shp')

class(counties)

attr(counties, "sf_column")

head(counties)

plot(counties[1], main='Oregon Counties', graticule = st_crs(counties), axes=TRUE)

cities_zip <- 'http://navigator.state.or.us/sdl/data/shapefile/m2/cities.zip'
download.file(cities_zip, '/home/marc/OR_cities.zip')
unzip('/home/marc/OR_cities.zip')
cities <- st_read("cities.shp")

plot(cities[1], main='Oregon Cities', axes=TRUE, pch=3)

city_buffers <- st_buffer(cities, 10000)
plot(city_buffers, add=TRUE)
library(sp)
data(quakes)
head(quakes)

class(quakes)

quakes_sf = st_as_sf(quakes, coords = c("long", "lat"), crs = 4326,agr = "constant")

str(quakes_sf)
st_bbox(quakes_sf) 
head(st_coordinates(quakes_sf))

plot(quakes_sf[,3],cex=log(quakes_sf$depth/100), pch=21, bg=24, lwd=.4, axes=T, 
     main="Depths of Earthquakes off of Fiji") 


###########################
# SpatialData in R - Raster
###########################

library(raster)
r <- raster(ncol=10, nrow = 10, xmx=-116,xmn=-126,ymn=42,ymx=46)
str(r)
r
r[] <- runif(n=ncell(r))
r
plot(r)


r[5]
r[1,5]

r2 <- r * 50
r3 <- sqrt(r * 5)
s <- stack(r, r2, r3)
s
plot(s)

b <- brick(x=c(r, r * 50, sqrt(r * 5)))
b
plot(b)


# Exercise 1

US <- getData("GADM",country="USA",level=2)
states    <- c('California', 'Nevada', 'Utah','Montana', 'Idaho', 'Oregon', 'Washington')
PNW <- US[US$NAME_1 %in% states,]
plot(PNW, axes=TRUE)

library(ggplot2)
ggplot(PNW) + geom_polygon(data=PNW, aes(x=long,y=lat,group=group),
                           fill="cadetblue", color="grey") + coord_equal()

srtm <- getData('SRTM', lon=-116, lat=42)
plot(srtm)
plot(PNW, add=TRUE)

OR <- PNW[PNW$NAME_1 == 'Oregon',]
srtm2 <- getData('SRTM', lon=-121, lat=42)
srtm3 <- getData('SRTM', lon=-116, lat=47)
srtm4 <- getData('SRTM', lon=-121, lat=47)

srtm_all <- mosaic(srtm, srtm2, srtm3, srtm4,fun=mean)

plot(srtm_all)
plot(OR, add=TRUE)

srtm_crop_OR <- crop(srtm_all, OR)
plot(srtm_crop_OR, main="Elevation (m) in Oregon")
plot(OR, add=TRUE)

srtm_mask_OR <- crop(srtm_crop_OR, OR)

Benton <- OR[OR$NAME_2=='Benton',]
srtm_crop_Benton <- crop(srtm_crop_OR, Benton)
srtm_mask_Benton <- mask(srtm_crop_Benton, Benton)
plot(srtm_mask_Benton, main="Elevation (m) in Benton County")
plot(Benton, add=TRUE)

typeof(values(srtm_crop_OR))
values(srtm_crop_OR) <- as.numeric(values(srtm_crop_OR))
typeof(values(srtm_crop_OR))

cellStats(srtm_crop_OR, stat=mean)
cellStats(srtm_crop_OR, stat=min)
cellStats(srtm_crop_OR, stat=max)
cellStats(srtm_crop_OR, stat=median)
cellStats(srtm_crop_OR, stat=range)

values(srtm_crop_OR) <- values(srtm_crop_OR) * 3.28084

library(rasterVis)
histogram(srtm_crop_OR, main="Elevation In Oregon")
densityplot(srtm_crop_OR, main="Elevation In Oregon")

p <- levelplot(srtm_crop_OR, layers=1, margin = list(FUN = median))
p + layer(sp.lines(OR, lwd=0.8, col='darkgray'))

Benton_terrain <- terrain(srtm_mask_Benton, opt = c("slope","aspect","tpi","roughness","flowdir"))
plot(Benton_terrain)

Benton_hillshade <- hillShade(Benton_terrain[['slope']],Benton_terrain[['aspect']])
plot(Benton_hillshade, main="Hillshade Map for Benton County")

# Exercise 2

library(landsat)
data(july1,july2,july3,july4,july5,july61,july62,july7)
july1 <- raster(july1)
july2 <- raster(july2)
july3 <- raster(july3)
july4 <- raster(july4)
july5 <- raster(july5)
july61 <- raster(july61)
july62 <- raster(july62)
july7 <- raster(july7)
july <- stack(july1,july2,july3,july4,july5,july61,july62,july7)
july
plot(july)

ndvi <- (july[[4]] - july[[3]]) / (july[[4]] + july[[3]])
# OR
ndviCalc <- function(x) {
  ndvi <- (x[[4]] - x[[3]]) / (x[[4]] + x[[3]])
  return(ndvi)
}
ndvi <- calc(x=july, fun=ndviCalc)
plot(ndvi)

savi <- ((july[[4]] - july[[3]]) / (july[[4]] + july[[3]]) + 0.5)*1.5
# OR 
saviCalc <- function(x) {
  savi <- ((x[[4]] - x[[3]]) / (x[[4]] + x[[3]]) + 0.5)*1.5
  return(savi)
}
ndvi <- calc(x=july, fun=saviCalc)
plot(savi)

ndmi <- (july[[4]] - july[[5]]) / (july[[4]] + july[[5]])
# OR 
ndmiCalc <- function(x) {
  ndmi <- (x[[4]] - x[[5]]) / (x[[4]] + x[[5]])
  return(ndmi)
}
ndmi <- calc(x=july, fun=ndmiCalc)
plot(ndmi)

# Exercise 3

download.file("https://github.com/mhweber/gis_in_action_r_spatial/blob/gh-pages/files/NLCD2011.Rdata?raw=true",
              "NLCD2011.Rdata",
              method="auto",
              mode="wb")
load('NLCD2011.Rdata')



ThreeCounties <- OR[OR$NAME_2 %in% c('Washington','Multnomah','Hood River'),]
NLCD2011 <- crop(OR_NLCD, ThreeCounties)
srtm_mask_Benton <- mask(srtm_crop_Benton, Benton)
plot(srtm_mask_Benton, main="Elevation (m) in Benton County")
plot(Benton, add=TRUE)

srtm_crop_3counties <- crop(srtm_crop_OR, ThreeCounties)
plot(srtm_crop_3counties, main = "Elevation (m) for Washington, \n Multnomah and Hood River Counties")
plot(ThreeCounties, add=T)
county_av_el <- extract(srtm_crop_3counties , ThreeCounties, fun=mean, na.rm = T, small = T, df = T)

download.file("https://github.com/mhweber/gis_in_action_r_spatial/blob/gh-pages/files/NLCD2011.Rdata?raw=true",
              "NLCD2011.Rdata",
              method="auto",
              mode="wb")
load("/home/marc/NLCD2011.Rdata")

# Here we pull out the raster attribute table to a data frame to use later - when we manipule the raster in the raster package,
# we lose the extra categories we'll want later
rat <- as.data.frame(levels(NLCD2011[[1]]))

projection(NLCD2011)
proj4string(ThreeCounties)
ThreeCounties <- spTransform(ThreeCounties, CRS(projection(NLCD2011)))

# Aggregate so extract doesn't take quite so long - but this will take a few minutes as well...
NLCD2011 <- aggregate(NLCD2011, 3, fun=modal, na.rm = T)
plot(NLCD2011)
e <- extract(NLCD2011, ThreeCounties, method = 'simple')
class(e)
length(e) 
# This next section gets into fairly advance approaces in R using apply family of functions as well as melting (turning data to long form)
# and casting (putting back into wide form)
et = lapply(e,table)
library(reshape)
t <- melt(et)
t.cast <- cast(t, L1 ~ Var.1, sum)
head(t.cast)

names(t.cast)[1] <- 'ID'
nlcd <- data.frame(t.cast)
head(nlcd)
nlcd$Total <- rowSums(nlcd[,2:ncol(nlcd)])
head(nlcd)
# There are simpler cleaner ways to do but this loop applys a percent value to each category
for (i in 2:17)
{
  nlcd[,i] = 100.0 * nlcd[,i]/nlcd[,18] 
}
rat
# We'll use the raster attrubite table we pulled out earlier to reapply the full land cover category names
newNames <- as.character(rat$LAND_COVER) # LAND_COVER is a factor, we need to convert to character - understanding factors very important in R...
names(nlcd)[2:17] <- newNames[2:17]
nlcd <- nlcd[c(1:17)] # We don't need the total column anymore
nlcd

# Last, let's pull the county names back in
CountyNames <- ThreeCounties$NAME_2
nlcd$County <- CountyNames
nlcd
# Reorder the data frame
nlcd <- nlcd[c(18,2:17)]
nlcd

# Whew, that's it - is it a fair bit of code?  Sure.  But is it easily, quickly repeatable and reproducible now?  You bet.