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


library(raster)


US <- getData("GADM",country="USA",level=2)
states    <- c('California', 'Nevada', 'Utah','Montana', 'Idaho', 'Oregon', 'Washington')
PNW <- US[US$NAME_1 %in% states,]
plot(PNW, axes=TRUE)

srtm <- getData('SRTM', lon=-116, lat=42)
plot(srtm)
plot(PNW, add=TRUE)

OR <- PNW[PNW$NAME_1 == 'Oregon',]

plot(srtm)
plot(OR, add=TRUE)
srtm2 <- getData('SRTM', lon=-121, lat=42)
srtm3 <- getData('SRTM', lon=-116, lat=47)
srtm4 <- getData('SRTM', lon=-121, lat=47)

srtm_all <- mosaic(srtm, srtm2, srtm3, srtm4,fun=mean)

plot(srtm_all)
plot(OR, add=TRUE)

srtm_crop_OR <- crop(srtm_all, OR)
plot(srtm_crop_OR, main="Elevation (m) in Oregon")
plot(OR, add=TRUE)

Benton <- OR[OR$NAME_2=='Benton',]
srtm_crop_Benton <- crop(srtm_crop_OR, Benton)
srtm_mask_Benton <- mask(srtm_crop_Benton, Benton)
plot(srtm_mask_Benton, main="Elevation (m) in Benton County")
plot(Benton, add=TRUE)

values(srtm_crop_OR) <- as.numeric(values(srtm_crop_OR))
cellStats(srtm_crop_OR, stat=mean)


library(rasterVis)
histogram(srtm_crop_OR, main="Elevation In Oregon")
densityplot(srtm_crop_OR, main="Elevation In Oregon")

p <- levelplot(srtm_crop_OR, layers=1, margin = list(FUN = median))
p + layer(sp.lines(OR, lwd=0.8, col='darkgray'))

Benton_terrain <- terrain(srtm_mask_Benton, opt = c("slope","aspect","tpi","roughness","flowdir"))
plot(Benton_terrain)

Benton_hillshade <- hillShade(Benton_terrain[['slope']],Benton_terrain[['aspect']])
plot(Benton_hillshade, main="Hillshade Map for Benton County")
library(ggplot2)

ggplot(PNW) + geom_polygon(data=PNW, aes(x=long,y=lat,group=group),
  fill="cadetblue", color="grey") + coord_equal()

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




library(sp)
data(quakes)
head(quakes)
# Data frames consist of rows of observations on columns of values for variables of interest. Create the coordinate reference system to use
llCRS <- CRS("+proj=longlat +datum=NAD83")
# now stitch together the data frame coordinate fields and the  
# projection string to createa SpatialPoints object
quakes_sp <- SpatialPoints(quakes[, c('long', 'lat')], proj4string = llCRS)
# Summary method gives a description of the spatial object in R. Summary works on pretty much all objects in R - for spatial data, gives us basic information about the projection, coordinates, and data for an sp object if it's a spatial data frame object.
summary(quakes_sp)
quakes_coords <- cbind(quakes$long, quakes$lat)
quakes_sp_df <- SpatialPointsDataFrame(quakes_coords, quakes, proj4string=llCRS, match.ID=TRUE)
summary(quakes_sp_df) # attributes folded back in
quakes_sf <- st_as_sf(quakes_sp_df)
plot(quakes_sp_df[,3],cex=log(quakes_sf$depth/100), pch=21, bg=24, lwd=.4, axes=T) 
str(quakes_sf)
