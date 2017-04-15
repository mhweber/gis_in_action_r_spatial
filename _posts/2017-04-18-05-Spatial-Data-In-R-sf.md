---
title: "05 - Spatial Data in R - simple features"
author: Marc Weber
layout: post_page
---

The `sf` Simple Features for R package by Edzer Pebesma is a new, very nice package that represents a changes of gears from the `sp` S4 or new style class representation of spatial data in R, and instead provides [simple features access](https://en.wikipedia.org/wiki/Simple_Features) for R. This will be familiar to folks who use [PostGIS](https://en.wikipedia.org/wiki/PostGIS), [MySQL Spatial Extensions](https://en.wikipedia.org/wiki/MySQL), [Oracle Spatial](https://en.wikipedia.org/wiki/Oracle_Spatial_and_Graph), the [OGR component of the GDAL library](https://en.wikipedia.org/wiki/GDAL) and [GeoPandas](http://geopandas.org/) in Python.

The big difference is the use of S3 classes in R rather than the S4, or new style classes of `sp` with the use of slots.  Simple features are simply `data.frame` objects that have a geometry list-column.  `sf` interfaces with [GEOS](https://trac.osgeo.org/geos) for topolgoical operations, uses [GDAL](https://en.wikipedia.org/wiki/GDAL) for data creation as well as very speedy I/O along with [GEOS](https://trac.osgeo.org/geos), and also which is quite nice can directly read and write to spatial databases such as [PostGIS](https://en.wikipedia.org/wiki/PostGIS).  

Edzar Pebesma has extensive documentation, blog posts and vignettes available for `sf` here:
[Simple Features for R](https://github.com/edzer/sfr)

## Lesson Goals
  - Learn about new simple features package

Firs, if not already installed, install `sf`

```r
library(devtools)
# install_github("edzer/sfr")
library(sf)
```

```
## Linking to GEOS 3.5.0, GDAL 2.1.1, proj.4 4.9.3
```

The `sf` package has numerous topological methods for performing spatial operations.

```r
methods(class = "sf")
```

```
##  [1] [                 aggregate         cbind            
##  [4] coerce            initialize        plot             
##  [7] print             rbind             show             
## [10] slotsFromS3       st_agr            st_agr<-         
## [13] st_as_sf          st_bbox           st_boundary      
## [16] st_buffer         st_cast           st_centroid      
## [19] st_convex_hull    st_crs            st_crs<-         
## [22] st_difference     st_drop_zm        st_geometry      
## [25] st_geometry<-     st_intersection   st_is            
## [28] st_linemerge      st_polygonize     st_precision     
## [31] st_segmentize     st_simplify       st_sym_difference
## [34] st_transform      st_triangulate    st_union         
## see '?methods' for accessing help and source code
```

To begin exploring, let's read in some spatial data. Download Oregon counties from the [Oregon Spatial Data Library](http://spatialdata.oregonexplorer.info/geoportal/catalog/main/home.page) and load into simple features object - first we get the url for zip file, download and unzip, and then read into a simple features object in R.

```r
library(sf)
counties_zip <- 'http://oe.oregonexplorer.info/ExternalContent/SpatialDataforDownload/orcnty2015.zip'
download.file(counties_zip, '/home/marc/OR_counties.zip')
unzip('/home/marc/OR_counties.zip')
counties <- st_read('orcntypoly.shp')
```

```
## Reading layer `orcntypoly' from data source `J:\GitProjects\R-Spatial-Tutorials\orcntypoly.shp' using driver `ESRI Shapefile'
## Simple feature collection with 36 features and 12 fields
## geometry type:  POLYGON
## dimension:      XY
## bbox:           xmin: -124.7038 ymin: 41.99208 xmax: -116.4632 ymax: 46.29239
## epsg (SRID):    4269
## proj4string:    +proj=longlat +datum=NAD83 +no_defs
```

```r
class(counties)
```

```
## [1] "sf"         "data.frame"
```

```r
attr(counties, "sf_column")
```

```
## [1] "geometry"
```

```r
head(counties)
```

```
## Simple feature collection with 6 features and 5 fields
## geometry type:  POLYGON
## dimension:      XY
## bbox:           xmin: -124.7038 ymin: 41.99253 xmax: -119.3594 ymax: 43.61744
## epsg (SRID):    4269
## proj4string:    +proj=longlat +datum=NAD83 +no_defs
##   OBJECTID SHAPE_Leng SHAPE_Area     unitID         instName
## 1        1          0          0 1155133033 Josephine County
## 2        1          0          0 1155129015     Curry County
## 3        1          0          0 1135853029   Jackson County
## 4        1          0          0 1135848011      Coos County
## 5        1          0          0 1155134035   Klamath County
## 6        1          0          0 1135854037      Lake County
##                         geometry
## 1 POLYGON((-123.229619367 42....
## 2 POLYGON((-123.811553228 42....
## 3 POLYGON((-122.282727755 42....
## 4 POLYGON((-123.811553228 42....
## 5 POLYGON((-121.332969065 43....
## 6 POLYGON((-119.896580665 43....
```

Simple plotting just as with `sp` spatial objects...
```r
plot(counties[1], main='Oregon Counties', axes=TRUE)
```

![ORExplorerCounties](/gis_in_action_r_spatial/figure/GIS Explorer OR Counties.png)


Let's download Oregon cities as well from Oregon Explorer and load into simple features object

```r
cities_zip <- 'http://navigator.state.or.us/sdl/data/shapefile/m2/cities.zip'
download.file(cities_zip, 'C:/users/mweber/temp/OR_cities.zip')
unzip('C:/users/mweber/temp/OR_cities.zip')
cities <- st_read("cities.shp")
```

```
## Reading layer `cities' from data source `J:\GitProjects\R-Spatial-Tutorials\cities.shp' using driver `ESRI Shapefile'
## Simple feature collection with 898 features and 6 fields
## geometry type:  POINT
## dimension:      XY
## bbox:           xmin: 238691 ymin: 92141.21 xmax: 2255551 ymax: 1641591
## epsg (SRID):    NA
## proj4string:    +proj=lcc +lat_1=43 +lat_2=45.5 +lat_0=41.75 +lon_0=-120.5 +x_0=399999.9999984001 +y_0=0 +datum=NAD83 +units=ft +no_defs
```

```r
plot(cities[1])
```

![GIS Explorer OR Cities](/gis_in_action_r_spatial/figure/GIS Explorer OR Cities.png)

Let's construct an `sf`  spatial object in R from a data frame with coordinate information - we'll use the built-in dataset 'quakes' with information on earthquakes off the coast of Fiji.  Construct spatial points sp, spatial points data frame, and then promote it to a simple features object.

```r
library(sp)
data(quakes)
head(quakes)
```

```
##      lat   long depth mag stations
## 1 -20.42 181.62   562 4.8       41
## 2 -20.62 181.03   650 4.2       15
## 3 -26.00 184.10    42 5.4       43
## 4 -17.97 181.66   626 4.1       19
## 5 -20.42 181.96   649 4.0       11
## 6 -19.68 184.31   195 4.0       12
```

```r
class(quakes)
```

```
## [1] "data.frame"
```

```r
# Data frames consist of rows of observations on columns of values for variables of interest. Create the coordinate reference system to use
llCRS <- CRS("+proj=longlat +datum=NAD83")
# now stitch together the data frame coordinate fields and the  
# projection string to createa SpatialPoints object
quakes_sp <- SpatialPoints(quakes[, c('long', 'lat')], proj4string = llCRS)
# Summary method gives a description of the spatial object in R. Summary works on pretty much all objects in R - for spatial data, gives us basic information about the projection, coordinates, and data for an sp object if it's a spatial data frame object.
summary(quakes_sp)
```

```
## Object of class SpatialPoints
## Coordinates:
##         min    max
## long 165.67 188.13
## lat  -38.59 -10.72
## Is projected: FALSE 
## proj4string :
## [+proj=longlat +datum=NAD83 +ellps=GRS80 +towgs84=0,0,0]
## Number of points: 1000
```

```r
# we can use methods in sp library to extract certain information from objects
bbox(quakes_sp)
```

```
##         min    max
## long 165.67 188.13
## lat  -38.59 -10.72
```

```r
proj4string(quakes_sp)
```

```
## [1] "+proj=longlat +datum=NAD83 +ellps=GRS80 +towgs84=0,0,0"
```

```r
# now promote the SpatialPoints to a SpatialPointsDataFrame
quakes_coords <- cbind(quakes$long, quakes$lat)
quakes_sp_df <- SpatialPointsDataFrame(quakes_coords, quakes, proj4string=llCRS, match.ID=TRUE)
summary(quakes_sp_df) # attributes folded back in
```

```
## Object of class SpatialPointsDataFrame
## Coordinates:
##              min    max
## coords.x1 165.67 188.13
## coords.x2 -38.59 -10.72
## Is projected: FALSE 
## proj4string :
## [+proj=longlat +datum=NAD83 +ellps=GRS80 +towgs84=0,0,0]
## Number of points: 1000
## Data attributes:
##       lat              long           depth            mag      
##  Min.   :-38.59   Min.   :165.7   Min.   : 40.0   Min.   :4.00  
##  1st Qu.:-23.47   1st Qu.:179.6   1st Qu.: 99.0   1st Qu.:4.30  
##  Median :-20.30   Median :181.4   Median :247.0   Median :4.60  
##  Mean   :-20.64   Mean   :179.5   Mean   :311.4   Mean   :4.62  
##  3rd Qu.:-17.64   3rd Qu.:183.2   3rd Qu.:543.0   3rd Qu.:4.90  
##  Max.   :-10.72   Max.   :188.1   Max.   :680.0   Max.   :6.40  
##     stations     
##  Min.   : 10.00  
##  1st Qu.: 18.00  
##  Median : 27.00  
##  Mean   : 33.42  
##  3rd Qu.: 42.00  
##  Max.   :132.00
```

```r
str(quakes_sp_df, max.level=2)
```

```
## Formal class 'SpatialPointsDataFrame' [package "sp"] with 5 slots
##   ..@ data       :'data.frame':	1000 obs. of  5 variables:
##   ..@ coords.nrs : num(0) 
##   ..@ coords     : num [1:1000, 1:2] 182 181 184 182 182 ...
##   .. ..- attr(*, "dimnames")=List of 2
##   ..@ bbox       : num [1:2, 1:2] 165.7 -38.6 188.1 -10.7
##   .. ..- attr(*, "dimnames")=List of 2
##   ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
```

```r
# Convert to simple features
quakes_sf <- st_as_sf(quakes_sp_df)
str(quakes_sf)
plot(quakes_sp_df[,3],cex=log(quakes_sf$depth/100), pch=21, bg=24, lwd=.4, axes=T) 
```

![Quakes](/gis_in_action_r_spatial/figure/Quakes.png)
- R `sf` Resources:

    - [GitHub Simple Features Repo](https://github.com/edzer/sfr)
    
    - [First Impressions From SF](https://geographicdatascience.com/2017/01/06/first-impressions-from-sf-the-simple-features-r-package/)
    


