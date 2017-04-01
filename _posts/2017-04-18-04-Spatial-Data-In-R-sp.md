---
title: "04 - Spatial Data in R - sp"
author: Marc Weber
layout: post_page
---


So, to begin, what is R and why should we use R for spatial analysis?  Let's break that into two questions - first, what is R and why should we use it?

- A language and environment for statistical computing and graphics
- R is lightweight, free, open-source and cross-platform
- Works with contriburted packages - currently 10,365 -extensibility
- Automation and recording of workflow (reproducibility)
- Optimized work flow - data manipulation, analysis andvisualization all in one place
- R does not alter underlying data - manipulation and visualization in memory
- R is great for repetative graphics

Second, why use R for spatial, or GIS, workflows?

- Spatial and statistical analysis in one environment
- Leverage statistical power of R (i.e.  modeling spatial data, data visualization, statistical exploration)
- Can handle vector and raster data, as well as work with spatial databases and pretty much any data format spatial data comes in
- R's GIS capabilities growing rapidly right now - new packages added monthly - currently about 180 spatial packages

Some drawbacks for using R for GIS work

- R not as good for interactive use as desktop GIS applications like ArcGIS or QGIS (i.e.  editing features, panning,zooming)
- Steep learning curve
- Up to you to find packages to do what you need - help not always great


## Lesson Goals
- Understanding of spatial data in R and `sp` (spatial) objects in R
- Introduction to R packages for spatial analysis
- Learn to read vector spatial data into R
- Perform some simple exploratory spatial data analysis with vector data in R

## Quick Links to Exercises
- [Exercise 1](#exercise-1): Working in R and representing spatial data in R
- [Exercise 2](#exercise-2): Visualizing spatial data in R
- [Exercise 3](#exercise-3): Working with rasters 


## A Little R Background

### Overview of Classes and Methods

- Class: object types
    - `class()`: gives the class type 
    - `typeof()`: information on how the object is stored
    - `str()`: how the object is structured
- Method: generic functions
    - `print()`
    - `plot()`
    - `summary()`

###Subclasses of Spatial Objects

- This is a big topic that we will only touch upon.  For more information see Bivand, R. S., Pebesma, E. J., & Gómez-Rubio, V. (2008). Applied spatial data analysis with R. New York: Springer.
- We can use the "getClass()" command to view the subclasses of spatial objects.


{% highlight r %}
library(sp)
getClass("Spatial")
{% endhighlight %}


{% highlight text %}
## Class "Spatial" [package "sp"]
## 
## Slots:
##                               
## Name:         bbox proj4string
## Class:      matrix         CRS
## 
## Known Subclasses: 
## Class "SpatialPoints", directly
## Class "SpatialGrid", directly
## Class "SpatialLines", directly
## Class "SpatialPolygons", directly
## Class "SpatialPointsDataFrame", by class "SpatialPoints", distance 2
## Class "SpatialPixels", by class "SpatialPoints", distance 2
## Class "SpatialGridDataFrame", by class "SpatialGrid", distance 2
## Class "SpatialLinesDataFrame", by class "SpatialLines", distance 2
## Class "SpatialPixelsDataFrame", by class "SpatialPoints", distance 3
## Class "SpatialPolygonsDataFrame", by class "SpatialPolygons", distance 2
{% endhighlight %}

## Packages for Using R as a GIS

The standard packages that give GIS functionality to R are listed below with a bit of annotation on each.

1. `sp`: This is one of the foundational packages for dealing with spatial data in R.  It sets up the spatial data classes (e.g. `SpatialLines`, `SpatialPolygonsDataFrame`, etc.) that are used (or at least recognized) by all of the other packages. Some analysis also included in `sp`. 
2. `rgdal`: This is another of the foundational packages, that is built of the [Geospatial Data Abstraction Library](http://www.gdal.org/).  This provides most of the utilities you will need to read and write a variety of geospatial data formats.
3. `rgeos`: This package provides an R interface to [GEOS (Geometry Engine, Open Source)](http://trac.osgeo.org/geos/).  This gives you most of what you typically think of as "GISy" analysis.
4. `raster`: Allows processing and analysis of raster data and also provides capability to deal with large rasters by being able to read data from disk.

And, some other useful additional packages:

1. `gdistance`: Provides tools for doing a variety of cost surface based analyses
2. `geosphere`: Calculates Great Circle distances and provides a variety of tools for dealing with distances, bearings, etc.
3. `landsat`: Provides processing and correction tools multi-spectral imagery (and shout out to co-maintaner of r-sig-ecology, [Sarah Goslee](http://www.ars.usda.gov/pandp/people/people.htm?personid=31752)).
4. `maptools`: Another widely used package to faciliate reading and writing spatial data. This is especially useful for creating kml files for use in Google Earth
5. `SDMTools`: Provides species distribution modelling tools in R.  Biggest thing (at least for me) is the implementation of most of FRAGSTATS in and R package.  Those tools are a bit hidden here, but allows you to calculate most landscape metrics without having to rewrite those tools in R.

For data visualization these packages may be useful:

1. `ggplot2`: this package is used to produce elegant graphics and can handle most `sp` objects.
2. `ggmap`: allows you to add google map imagery to `ggplot2` graphics
3. `leaflet`: a new interactive map package built off of the leaflet javascript library.  Works great for unprojected spatial data.  This package is a great product that will certainly increase in functionality. 
4. `cartographer`:  Current functionality is similar to leaflet, but instead this package uses the D3 javascript library.  That has some really important advantages (we think) over leaflet.  Most notable D3 has projection support that could be used to support viz of projected data.

## Build the datasets for this exercise

Lets start by making a shapefiles for our current location and a polygon around our location. We won't have time to go into how to do this but the code is included so you can see how it was done. 

All of the files used in this lesson can be downloaded from: [http://jwhollister.com/iale_open_science/files/SpatialData.zip](http://jwhollister.com/iale_open_science/files/SpatialData.zip)

To download an upzip these with R:


{% highlight r %}
download.file("http://jwhollister.com/iale_open_science/files/SpatialData.zip",
               "SpatialData.zip",
               method="auto",
               mode="wb") 
unzip("SpatialData.zip",exdir="iale_workshop")
{% endhighlight %}



{% highlight r %}
#Our current location (from GoogleEarth) is:
Loc<-data.frame(lon=-122.68014,lat=45.517564,name='PDXhilton',ID=1)

#The Coordinate reference system for GoogleEarth is WGS84 Decimal Degrees
WGS84<-CRS("+proj=longlat +datum=WGS84")  #ESRI GCS_WGS_1984 

#From this we create `sp` object (Spatial Points Data Frame)
#A SpatialPoints object has the geographic information but no attributes
LocPt<-SpatialPoints(coordinates(Loc[,-3]),proj4string=WGS84)

#Let's also create a random polygon around our location
#coordinates for the polygon
Poly<-data.frame(Lon=c(-122.683461544862,-122.687996482959,-122.685670328434,
                       -122.682541408927,-122.678202313853,-122.674828807098,
                       -122.674485521254,-122.672769412589,-122.675904138992,
                       -122.674481812434,-122.676631816156,-122.680281068949,
                       -122.683461544862),
                 Lat=c(45.5230187040173,45.5195152981109,45.5143352152495,
                       45.5154464797329,45.512619192088,45.5138738461287,
                       45.5167150399938,45.5190852959663,45.5192876717319,
                       45.5216119799917,45.5235316111073,45.5213931392957,
                       45.5230187040173))  

#create SpatialPolygons Object
#convert coords to polygon
p<-Polygon(Poly) 

#add id variable
p1<- Polygons(list(p), ID=1) 

#create SpatialPolygons object
LocPoly<- SpatialPolygons(list(p1),proj4string=WGS84) 

#A SpatialPointsDataFrame object has the geographic information plus attributes
LocPtDF<-SpatialPointsDataFrame(coordinates(Loc[,-3]),Loc,proj4string=WGS84)

#create SpatialPolygonsDataFrame Object
#adds field "Info" as an attribute to the polygon.
LocPolyDF<- SpatialPolygonsDataFrame(LocPoly,
                                     data.frame(ID=1,
                                                Info='PolygonAroundPDXhilton'))

#write the spatial dataframe objects to shapefiles
writeOGR(LocPtDF,'iale_workshop','LocPt', 
         driver="ESRI Shapefile",overwrite_layer=TRUE)
writeOGR(LocPolyDF,'iale_workshop','LocPoly', 
         driver="ESRI Shapefile",overwrite_layer=TRUE)

#create KML file of locations with the maptools package 
#point
kmlPoints(LocPtDF, 
          kmlfile='iale_workshop/LocPt.kml', 
          name="Hilton", 
          description=paste("Our Current Location"),
          icon="http://maps.google.com/mapfiles/kml/paddle/ltblu-stars.png",
          kmlname="PDXhilton",
          kmldescription="We R Here")

#polygon
kmlPolygon(LocPolyDF, 
          kmlfile='iale_workshop/LocPoly.kml', 
          name="HiltonPoly", 
          description=paste("Random Polygon"),
          lwd=5,border=2,
          kmlname="HiltonPoly",
          kmldescription="We R Here")
{% endhighlight %}

### Reading the spatial Data

The `rgdal` package is good for reading of vector spatial data into R. For Grid data we will use the package `raster`.  All spatial data in these exercises will be converted into `sp` objects (SpatialPointsDataFrame; SpatialPolygonsDataFrame; and, SpatialGrid) 



{% highlight r %}
# Using rgdal command - readOGR - we now read in the shapefiles for our current 
# location in Portland.

#point location
Pt<-readOGR('iale_workshop',"LocPt") 
{% endhighlight %}



{% highlight text %}
## OGR data source with driver: ESRI Shapefile 
## Source: "iale_workshop", layer: "LocPt"
## with 1 features
## It has 4 fields
{% endhighlight %}



{% highlight r %}
#Polygon location
Poly<-readOGR('iale_workshop',"LocPoly")
{% endhighlight %}



{% highlight text %}
## OGR data source with driver: ESRI Shapefile 
## Source: "iale_workshop", layer: "LocPoly"
## with 1 features
## It has 2 fields
{% endhighlight %}

- Let us look at the data


{% highlight r %}
#class info for object
class(Pt) 
{% endhighlight %}



{% highlight text %}
## [1] "SpatialPointsDataFrame"
## attr(,"package")
## [1] "sp"
{% endhighlight %}



{% highlight r %}
#storage type
typeof(Pt)
{% endhighlight %}



{% highlight text %}
## [1] "S4"
{% endhighlight %}



{% highlight r %}
# data structure for object
str(Pt) 
{% endhighlight %}



{% highlight text %}
## Formal class 'SpatialPointsDataFrame' [package "sp"] with 5 slots
##   ..@ data       :'data.frame':	1 obs. of  4 variables:
##   .. ..$ lon : num -123
##   .. ..$ lat : num 45.5
##   .. ..$ name: Factor w/ 1 level "PDXhilton": 1
##   .. ..$ ID  : num 1
##   ..@ coords.nrs : num(0) 
##   ..@ coords     : num [1, 1:2] -122.7 45.5
##   .. ..- attr(*, "dimnames")=List of 2
##   .. .. ..$ : NULL
##   .. .. ..$ : chr [1:2] "coords.x1" "coords.x2"
##   ..@ bbox       : num [1:2, 1:2] -122.7 45.5 -122.7 45.5
##   .. ..- attr(*, "dimnames")=List of 2
##   .. .. ..$ : chr [1:2] "coords.x1" "coords.x2"
##   .. .. ..$ : chr [1:2] "min" "max"
##   ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
##   .. .. ..@ projargs: chr "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
{% endhighlight %}



{% highlight r %}
#summary info for object
summary(Pt) 
{% endhighlight %}



{% highlight text %}
## Object of class SpatialPointsDataFrame
## Coordinates:
##                  min        max
## coords.x1 -122.68014 -122.68014
## coords.x2   45.51756   45.51756
## Is projected: FALSE 
## proj4string :
## [+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0]
## Number of points: 1
## Data attributes:
##       lon              lat               name         ID   
##  Min.   :-122.7   Min.   :45.52   PDXhilton:1   Min.   :1  
##  1st Qu.:-122.7   1st Qu.:45.52                 1st Qu.:1  
##  Median :-122.7   Median :45.52                 Median :1  
##  Mean   :-122.7   Mean   :45.52                 Mean   :1  
##  3rd Qu.:-122.7   3rd Qu.:45.52                 3rd Qu.:1  
##  Max.   :-122.7   Max.   :45.52                 Max.   :1
{% endhighlight %}



{% highlight r %}
class(Poly) #class info for object
{% endhighlight %}



{% highlight text %}
## [1] "SpatialPolygonsDataFrame"
## attr(,"package")
## [1] "sp"
{% endhighlight %}



{% highlight r %}
coordinates(Pt) #coordinates of the point
{% endhighlight %}



{% highlight text %}
##      coords.x1 coords.x2
## [1,] -122.6801  45.51756
{% endhighlight %}



{% highlight r %}
coordinates(Poly) #coordinates of polygon centroid
{% endhighlight %}



{% highlight text %}
##        [,1]     [,2]
## 0 -122.6803 45.51817
{% endhighlight %}



{% highlight r %}
#to see the vertices of the Polygon we need to explore the "slots"
slotNames(Poly) #get a list of the "slot" names for the object
{% endhighlight %}



{% highlight text %}
## [1] "data"        "polygons"    "plotOrder"   "bbox"        "proj4string"
{% endhighlight %}



{% highlight r %}
Poly@polygons  #will give info on each polygon
{% endhighlight %}



{% highlight text %}
## [[1]]
## An object of class "Polygons"
## Slot "Polygons":
## [[1]]
## An object of class "Polygon"
## Slot "labpt":
## [1] -122.68028   45.51817
## 
## Slot "area":
## [1] 0.0001011193
## 
## Slot "hole":
## [1] FALSE
## 
## Slot "ringDir":
## [1] 1
## 
## Slot "coords":
##            [,1]     [,2]
##  [1,] -122.6835 45.52302
##  [2,] -122.6803 45.52139
##  [3,] -122.6766 45.52353
##  [4,] -122.6745 45.52161
##  [5,] -122.6759 45.51929
##  [6,] -122.6728 45.51909
##  [7,] -122.6745 45.51672
##  [8,] -122.6748 45.51387
##  [9,] -122.6782 45.51262
## [10,] -122.6825 45.51545
## [11,] -122.6857 45.51434
## [12,] -122.6880 45.51952
## [13,] -122.6835 45.52302
## 
## 
## 
## Slot "plotOrder":
## [1] 1
## 
## Slot "labpt":
## [1] -122.68028   45.51817
## 
## Slot "ID":
## [1] "0"
## 
## Slot "area":
## [1] 0.0001011193
{% endhighlight %}



{% highlight r %}
Poly@bbox #bounding box of object; same as bbox(Poly)
{% endhighlight %}



{% highlight text %}
##          min        max
## x -122.68800 -122.67277
## y   45.51262   45.52353
{% endhighlight %}



{% highlight r %}
Poly@proj4string #coordinate reference system for the object; same as proj4string(Poly)
{% endhighlight %}



{% highlight text %}
## CRS arguments:
##  +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0
{% endhighlight %}



{% highlight r %}
Poly@data #not much here but this is the attribute table
{% endhighlight %}



{% highlight text %}
##   ID                   Info
## 0  1 PolygonAroundPDXhilton
{% endhighlight %}

## Exercise 1

### Getting spatial data into R

1. Download the data for this and other excercises:  [SpatialData.zip](http://jwhollister.com/iale_open_science/files/SpatialData.zip)
2. Unzip the data to a convenient location of you computer.
3. Open R studio and start a new R script.
5. Load the packages: `rgdal`,`sp`,`raster` and,`rgeos`.  You'll need some of these now and some later. 
6. Use `readOGR` to load the shapefiles "LocPt.shp" and "LocPoly.shp"
7. Explore the `sp` objects with: `class`, `typeof`, and `summary`

### Visualizing Spatial Data

- Let's look at the data.
- The simplest method is to use base graphics.  


{% highlight r %}
  plot(Poly)
  plot(Pt,add=TRUE,pch=16,col='orange',cex=3)
{% endhighlight %}

![plot of chunk plot_base]({{ site.url }}/figure/plot_base-1.png) 

- You have more control over the plot with the `ggplot2` package.  But... it comes with a cost-very complicated.

- Here is the plot with ggplot2 


{% highlight r %}
  ggplot(Poly,aes(x=long, y=lat)) + geom_path() + geom_point(data=Pt@data, aes(x=lon, y=lat),shape=16,color='orange',size=8)
{% endhighlight %}

![plot of chunk plot_ggplot]({{ site.url }}/figure/plot_ggplot-1.png) 

- With `ggplot2` and the `ggmap` package we can add a satelite (or other) image from googlemaps.  


{% highlight r %}
    #get the image
      map<-ggmap(get_googlemap(center=c(lon=Pt@data$lon,lat=Pt@data$lat),
            zoom=15, #large numbers = larger scale (i.e zoomed in)
            maptype='satellite', #also hybrid/terrain/roadmap
            scale = 2), #resolution scaling, 1 (low) or 2 (high)
            size = c(600, 600), #size of the image to grab
            extent='device', #can also be "normal" etc
            darken = 0) #you can dim the map when plotting on top
    #plot location on the image
      map+geom_point(data=Pt@data, aes(x=lon, y=lat),shape=16,color='orange',size=8)+
        geom_path(data=Poly,aes(x=long, y=lat),size=2,colour='green')
{% endhighlight %}

![plot of chunk plot_ggmap]({{ site.url }}/figure/plot_ggmap-1.png) 


- Nice image but not interactive
- For interactive maps there are some new packages such as `leaflet` available (see https://rstudio.github.io/leaflet/).  Now available on CRAN.
- The first step is to setup the map and add a base map from "open street map"



{% highlight r %}
#build the map without "pipes"
  m<-leaflet() #setup map
  m<-addTiles(m) #add open street map data
  m
{% endhighlight %}

<!--html_preserve--><div id="htmlwidget-7455" style="width:504px;height:504px;" class="leaflet"></div>
<script type="application/json" data-for="htmlwidget-7455">{ "x": {
 "calls": [
 {
 "method": "addTiles",
"args": [
 "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
null,
null,
{
 "minZoom":                 0,
"maxZoom":                18,
"maxNativeZoom": null,
"tileSize":               256,
"subdomains": "abc",
"errorTileUrl": "",
"tms": false,
"continuousWorld": false,
"noWrap": false,
"zoomOffset":                 0,
"zoomReverse": false,
"opacity":                 1,
"zIndex": null,
"unloadInvisibleTiles": null,
"updateWhenIdle": null,
"detectRetina": false,
"reuseTiles": false,
"attribution": "&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>" 
} 
] 
} 
] 
},"evals": [  ] }</script><!--/html_preserve-->


- Now we can add a marker with our current location



{% highlight r %}
  m<-addMarkers(m,lng=Pt@data$lon, lat=Pt@data$lat, popup="We R Here")  #add point location
  m
{% endhighlight %}

<!--html_preserve--><div id="htmlwidget-1200" style="width:504px;height:504px;" class="leaflet"></div>
<script type="application/json" data-for="htmlwidget-1200">{ "x": {
 "calls": [
 {
 "method": "addTiles",
"args": [
 "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
null,
null,
{
 "minZoom":                 0,
"maxZoom":                18,
"maxNativeZoom": null,
"tileSize":               256,
"subdomains": "abc",
"errorTileUrl": "",
"tms": false,
"continuousWorld": false,
"noWrap": false,
"zoomOffset":                 0,
"zoomReverse": false,
"opacity":                 1,
"zIndex": null,
"unloadInvisibleTiles": null,
"updateWhenIdle": null,
"detectRetina": false,
"reuseTiles": false,
"attribution": "&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>" 
} 
] 
},
{
 "method": "addMarkers",
"args": [
         45.517564,
       -122.68014,
null,
null,
null,
{
 "clickable": true,
"draggable": false,
"keyboard": true,
"title": "",
"alt": "",
"zIndexOffset":                 0,
"opacity":                 1,
"riseOnHover": false,
"riseOffset":               250 
},
"We R Here" 
] 
} 
],
"limits": {
 "lat": [         45.517564,         45.517564 ],
"lng": [        -122.68014,        -122.68014 ] 
} 
},"evals": [  ] }</script><!--/html_preserve-->


- and finally we add the polygon around our location



{% highlight r %}
  m<-addPolygons(m,data=Poly, weight=2) #add polygon  
  m
{% endhighlight %}

<!--html_preserve--><div id="htmlwidget-8138" style="width:504px;height:504px;" class="leaflet"></div>
<script type="application/json" data-for="htmlwidget-8138">{ "x": {
 "calls": [
 {
 "method": "addTiles",
"args": [
 "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
null,
null,
{
 "minZoom":                 0,
"maxZoom":                18,
"maxNativeZoom": null,
"tileSize":               256,
"subdomains": "abc",
"errorTileUrl": "",
"tms": false,
"continuousWorld": false,
"noWrap": false,
"zoomOffset":                 0,
"zoomReverse": false,
"opacity":                 1,
"zIndex": null,
"unloadInvisibleTiles": null,
"updateWhenIdle": null,
"detectRetina": false,
"reuseTiles": false,
"attribution": "&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>" 
} 
] 
},
{
 "method": "addMarkers",
"args": [
         45.517564,
       -122.68014,
null,
null,
null,
{
 "clickable": true,
"draggable": false,
"keyboard": true,
"title": "",
"alt": "",
"zIndexOffset":                 0,
"opacity":                 1,
"riseOnHover": false,
"riseOffset":               250 
},
"We R Here" 
] 
},
{
 "method": "addPolygons",
"args": [
 [
 [
 {
 "lng": [ -122.683461544862, -122.680281068949, -122.676631816156, -122.674481812434, -122.675904138992, -122.672769412589, -122.674485521254, -122.674828807098, -122.678202313853, -122.682541408927, -122.685670328434, -122.687996482959, -122.683461544862 ],
"lat": [  45.5230187040173,  45.5213931392957,  45.5235316111073,  45.5216119799917,  45.5192876717319,  45.5190852959663,  45.5167150399938,  45.5138738461287,   45.512619192088,  45.5154464797329,  45.5143352152495,  45.5195152981109,  45.5230187040173 ] 
} 
] 
],
null,
null,
{
 "lineCap": null,
"lineJoin": null,
"clickable": true,
"pointerEvents": null,
"className": "",
"stroke": true,
"color": "#03F",
"weight":                 2,
"opacity":               0.5,
"fill": true,
"fillColor": "#03F",
"fillOpacity":               0.2,
"dashArray": null,
"smoothFactor":                 1,
"noClip": false 
},
null 
] 
} 
],
"limits": {
 "lat": [   45.512619192088,  45.5235316111073 ],
"lng": [ -122.687996482959, -122.672769412589 ] 
} 
},"evals": [  ] }</script><!--/html_preserve-->


- leaflet maps can also be built with "pipes" (see code below)



{% highlight r %}
#or build the map with "pipes"
m <- leaflet() %>% addTiles(group = "OpenStreetMap") %>% 
  addProviderTiles("Stamen.Watercolor",group = "Watercolor") %>% 
  addMarkers(lng=Pt@data$lon, lat=Pt@data$lat, popup="We R Here",group='Pt') %>% 
  addPolygons(data=Poly, weight=2,group='Poly') %>% 
  addLayersControl(baseGroups = c("OpenStreetMap","Watercolor"), 
                 overlayGroups = c("Pt","Poly"))
m
{% endhighlight %}

<!--html_preserve--><div id="htmlwidget-1297" style="width:504px;height:504px;" class="leaflet"></div>
<script type="application/json" data-for="htmlwidget-1297">{ "x": {
 "calls": [
 {
 "method": "addTiles",
"args": [
 "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
null,
"OpenStreetMap",
{
 "minZoom":                 0,
"maxZoom":                18,
"maxNativeZoom": null,
"tileSize":               256,
"subdomains": "abc",
"errorTileUrl": "",
"tms": false,
"continuousWorld": false,
"noWrap": false,
"zoomOffset":                 0,
"zoomReverse": false,
"opacity":                 1,
"zIndex": null,
"unloadInvisibleTiles": null,
"updateWhenIdle": null,
"detectRetina": false,
"reuseTiles": false,
"attribution": "&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>" 
} 
] 
},
{
 "method": "addProviderTiles",
"args": [
 "Stamen.Watercolor",
null,
"Watercolor",
{
 "errorTileUrl": "",
"noWrap": false,
"zIndex": null,
"unloadInvisibleTiles": null,
"updateWhenIdle": null,
"detectRetina": false,
"reuseTiles": false 
} 
] 
},
{
 "method": "addMarkers",
"args": [
         45.517564,
       -122.68014,
null,
null,
"Pt",
{
 "clickable": true,
"draggable": false,
"keyboard": true,
"title": "",
"alt": "",
"zIndexOffset":                 0,
"opacity":                 1,
"riseOnHover": false,
"riseOffset":               250 
},
"We R Here" 
] 
},
{
 "method": "addPolygons",
"args": [
 [
 [
 {
 "lng": [ -122.683461544862, -122.680281068949, -122.676631816156, -122.674481812434, -122.675904138992, -122.672769412589, -122.674485521254, -122.674828807098, -122.678202313853, -122.682541408927, -122.685670328434, -122.687996482959, -122.683461544862 ],
"lat": [  45.5230187040173,  45.5213931392957,  45.5235316111073,  45.5216119799917,  45.5192876717319,  45.5190852959663,  45.5167150399938,  45.5138738461287,   45.512619192088,  45.5154464797329,  45.5143352152495,  45.5195152981109,  45.5230187040173 ] 
} 
] 
],
null,
"Poly",
{
 "lineCap": null,
"lineJoin": null,
"clickable": true,
"pointerEvents": null,
"className": "",
"stroke": true,
"color": "#03F",
"weight":                 2,
"opacity":               0.5,
"fill": true,
"fillColor": "#03F",
"fillOpacity":               0.2,
"dashArray": null,
"smoothFactor":                 1,
"noClip": false 
},
null 
] 
},
{
 "method": "addLayersControl",
"args": [
 [ "OpenStreetMap", "Watercolor" ],
[ "Pt", "Poly" ],
{
 "collapsed": true,
"autoZIndex": true,
"position": "topright" 
} 
] 
} 
],
"limits": {
 "lat": [   45.512619192088,  45.5235316111073 ],
"lng": [ -122.687996482959, -122.672769412589 ] 
} 
},"evals": [  ] }</script><!--/html_preserve-->


- Leaflet is great but does not currently work easily with projected data
- Jeff Hollister is  developing an interactive map viewer that does work with projected data.  His package is called `quickmapr`.  It is not yet on CRAN, but availble from [GitHub](https://github.com/jhollist/quickmapr).  Jeff can demonstrate it later if there is time.
- We can also view the files in GoogleEarth (if loaded on your computer).  But again this approach will not work with projected data.



{% highlight r %}
shell.exec('LocPt.kml')  #Start GE and add Pt location
shell.exec('LocPoly.kml') #Now add the Polygon 
{% endhighlight %}

## Exercise 2

### Visualizing spatial data in R

1. Use the `plot` command to view "LocPt.shp" and "LocPoly.shp"
2. If you want more of a challenge try 'ggplot2' or 'leafletR'
3. For windows users with the Google Earth you can also load the kml files ("LocPt.kml" and "LocPoly.kml")

##Working with rasters

- Now let's add in some raster data.
- The 2011 NLCD Data were downloaded from http://gisdata.usgs.gov/TDDS/DownloadFile.php?TYPE=nlcd2011&FNAME=nlcd_2011_landcover_2011_edition_2014_10_10.zip.
- This file was too large to work with effectively so the image was cropped to a 10km x 10km area around our current location. 
- The cropped image was saved as "NLCDpdx.tif" and is include in http://jwhollister.com/iale_open_science/files/SpatialData.zip
- To repeat the process of getting the full scene is below.  This is time consuming so we won't run this, but the steps are included if you'd like to working on thi on your own.



{% highlight r %}
# get the NLCD grid data-to repeat this is time cosuming; 
# the final raster is available on github
NLCD<-raster('C:/Bryan/EPA/Data/nlcd_2011_landcover_2011_edition_2014_10_10/nlcd_2011_landcover_2011_edition_2014_10_10.img')  #change location to match your directory structure

#NLCD includes all lower 48 states.  Reduce to bbox(Pt) + 10km
#reproject Pt to match NLCD
PtAlb<-spTransform(Pt,CRSobj = CRS(proj4string(NLCD)))   

#define extent based on bbox(PtAlb)+100km
B<-bbox(PtAlb)
Add<-10000 
Extent<-c(B[1,1]-Add,B[1,2]+Add,B[2,1]-Add,B[2,2]+Add)

#Crop NLCD 
NLCDpdx<-crop(NLCD,Extent)

#add colortable
#get gex colors from Jeff's miscPackage
ct <- system.file("extdata/nlcd_lookup.csv", package = "miscPackage")
ct <- read.csv(ct, stringsAsFactors = FALSE)

#add colors 1:256
ctbl <- rep("#000000", 256)

#update non-NULL colors
ctbl[ct$code + 1] <- ct$hex
NLCDpdx@legend@values <- ct$code
NLCD@legend@colortable <- ctbl
NLCD@legend@names <- ct$label

#export cropped NLCD as geotiff
writeRaster(NLCDpdx, filename="NLCDpdx.tif", format="GTiff", overwrite=TRUE)
{% endhighlight %}


- Let's get the raster data and look at it



{% highlight r %}
NLCD<-raster("iale_workshop/NLCDpdx.tif")  #simple read a raster image with the raster package.

slotNames(raster) #get a list of the "slot" names for the object
{% endhighlight %}



{% highlight text %}
## [1] ".Data"      "generic"    "package"    "group"      "valueClass"
## [6] "signature"  "default"    "skeleton"
{% endhighlight %}


- We can use the `values` method to look at the raster data categories.



{% highlight r %}
table(values(NLCD))
{% endhighlight %}



{% highlight text %}
## 
##     11     21     22     23     24     31     41     42     43     52 
##  20355  36829 131456 125320  62889    926   7345  26794  22077   1573 
##     71     81     82     90     95 
##   2156   2805    453   1507   1737
{% endhighlight %}


- Need to interpret the codes
- Fortunately we can translate the codes into the NLCD Land Use / Land Cover Categories
- Jeff has a lookup table we'll use



{% highlight r %}
#Load the look up table
  ct <- "iale_workshop/nlcd_lookup.csv"
  ct <- read.csv(ct, stringsAsFactors = FALSE)
  ct  #view the table
{% endhighlight %}



{% highlight text %}
##    code     hex                        label
## 1    11 #5475A8                   Open Water
## 2    12 #FFFFFF           Perennial Ice/Snow
## 3    21 #E8D1D1        Developed, Open Space
## 4    22 #E29E8C     Developed, Low Intensity
## 5    23 #FF0000  Developed, Medium Intensity
## 6    24 #B50000    Developed, High Intensity
## 7    31 #D2CDC0 Barren Land (Rock/Sand/Clay)
## 8    41 #85C77E             Deciduous Forest
## 9    42 #38814E             Evergreen Forest
## 10   43 #38814E                 Mixed Forest
## 11   51 #AF963C                  Dwarf Scrub
## 12   52 #DCCA8F                  Scrub/Shrub
## 13   71 #FDE9AA         Grassland/Herbaceous
## 14   72 #D1D182            Sedge/Herbaceuous
## 15   73 #A3CC51                      Lichens
## 16   74 #82BA9E                         Moss
## 17   81 #FBF65D                  Pasture/Hay
## 18   82 #CA9146             Cultivated Crops
## 19   90 #C8E6F8               Woody Wetlands
## 20   95 #64B3D5 Emergent Herbaceous Wetlands
{% endhighlight %}



{% highlight r %}
#get the data from the raster
  codes<-data.frame(code=values(NLCD))
#merge with the lookup table
  Values<-merge(codes,ct,by='code',all.x=T)

#Now we can view the data
table(Values$label,useNA='ifany')
{% endhighlight %}



{% highlight text %}
## 
## Barren Land (Rock/Sand/Clay)             Cultivated Crops 
##                          926                          453 
##             Deciduous Forest    Developed, High Intensity 
##                         7345                        62889 
##     Developed, Low Intensity  Developed, Medium Intensity 
##                       131456                       125320 
##        Developed, Open Space Emergent Herbaceous Wetlands 
##                        36829                         1737 
##             Evergreen Forest         Grassland/Herbaceous 
##                        26794                         2156 
##                 Mixed Forest                   Open Water 
##                        22077                        20355 
##                  Pasture/Hay                  Scrub/Shrub 
##                         2805                         1573 
##               Woody Wetlands 
##                         1507
{% endhighlight %}

- We'll use base graphics to plot this raster image


{% highlight r %}
plot(NLCD)
{% endhighlight %}

![plot of chunk plotNLCD1]({{ site.url }}/figure/plotNLCD1-1.png) ![plot of chunk plotNLCD1]({{ site.url }}/figure/plotNLCD1-2.png) 

- add our location and surrounding polygon


{% highlight r %}
plot(NLCD)
{% endhighlight %}

![plot of chunk plotNLCD2]({{ site.url }}/figure/plotNLCD2-1.png) 

{% highlight r %}
plot(Pt,add=T,pch=4,col='white',cex=1.5,lwd=2) 
plot(Poly,add=T,lwd=3,col=NA,border='black')
{% endhighlight %}

![plot of chunk plotNLCD2]({{ site.url }}/figure/plotNLCD2-2.png) 

- nothing happens due to differences in projection
- view projection information


{% highlight r %}
  #Coordinate reference system for the raster
    proj4string(NLCD)
{% endhighlight %}



{% highlight text %}
## [1] "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
{% endhighlight %}



{% highlight r %}
#Coordinate reference system for point location
    proj4string(Pt)
{% endhighlight %}



{% highlight text %}
## [1] "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
{% endhighlight %}



{% highlight r %}
#Coordinate reference system for polygon location
    proj4string(Poly)
{% endhighlight %}



{% highlight text %}
## [1] "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
{% endhighlight %}

- We could change to the raster to WGS84 or 
- Change the locations to Albers
- Since we will want to keep albers for analysis convert the locations


{% highlight r %}
  #reproject Pt to match NLCD
      PtAlb<-spTransform(Pt,CRSobj = CRS(proj4string(NLCD)))  
  #reproject Polyg to match NLCD
      PolyAlb<-spTransform(Poly,CRSobj = CRS(proj4string(NLCD)))  
{% endhighlight %}

- now we can add PtAlb and PolyAlb to the NLCD plot


{% highlight r %}
plot(NLCD)
{% endhighlight %}

![plot of chunk plotNLCD3]({{ site.url }}/figure/plotNLCD3-1.png) 

{% highlight r %}
plot(PtAlb,add=T,pch=4,col='white',cex=1.5,lwd=2) 
plot(PolyAlb,add=T,lwd=3,col=NA,border='black')
{% endhighlight %}

![plot of chunk plotNLCD3]({{ site.url }}/figure/plotNLCD3-2.png) 

- add a legend (we'll use the same lookup table we used above) 


{% highlight r %}
    plot(NLCD)
{% endhighlight %}

![plot of chunk legend1]({{ site.url }}/figure/legend1-1.png) 

{% highlight r %}
    plot(PtAlb,add=T,pch=4,col='white',cex=1.5,lwd=2) 
    plot(PolyAlb,add=T,lwd=3,col=NA,border='black')
  #add legend
    legend('topright',ct$label,fill=ct$hex)
{% endhighlight %}

![plot of chunk legend1]({{ site.url }}/figure/legend1-2.png) 

- Now let's do some real GIS
- We have the spatial objects
    - NLCD: a 10x10km raster of the NLCD data for the area around our hotel
    - PtAlb: our current location as a SpatialPointsDataFrame 
    - PolyAlb: a random polygon around PtAlb
- We will do the equivalent of a buffer, clip, and calculate Land Use/Land Cover proportions within that buffer.


{% highlight r %}
# Now some simple GISy stuff.  Select, buffer, clip and save
  
#add a buffer around our current location
  bufWidth<-1000 #in meters
  PtBuffer<-gBuffer(PtAlb,width=bufWidth,id=PtAlb[["ID"]])
    #this is a SpatialPolygons object
      class(PtBuffer)
{% endhighlight %}



{% highlight text %}
## [1] "SpatialPolygons"
## attr(,"package")
## [1] "sp"
{% endhighlight %}



{% highlight r %}
#If we want to add attributes later we will need to convert it to a SpatialPolygonsDataFrame.  We'll add the attributes from PtAlb
  PtBuffer<-SpatialPolygonsDataFrame(PtBuffer,PtAlb@data)

#Now we can add data if we want just like any other data frame
  PtBuffer@data$BufferWidthM[1]<-bufWidth

# we can use the crop command to clip the NLCD data to the buffer
  bufNLCD<-crop(NLCD,PtBuffer)

# when we plot the data we notice that the resulting raster is square rather than round as we expected. 
  plot(bufNLCD)
{% endhighlight %}

![plot of chunk analysis]({{ site.url }}/figure/analysis-1.png) ![plot of chunk analysis]({{ site.url }}/figure/analysis-2.png) 

{% highlight r %}
# to limit the NLCD data to the circular buffer we change use a mask to assign the values outside the buffer to NA (missing)
  bufNLCD<-mask(crop(NLCD,PtBuffer),PtBuffer)

# now the shape is correct but we lost the color table
  plot(bufNLCD)
{% endhighlight %}

![plot of chunk analysis]({{ site.url }}/figure/analysis-3.png) 

{% highlight r %}
# this will not affect the analysis but it doesn't look right so we can fix it
  bufNLCD@legend@colortable<-NLCD@legend@colortable

# success
  plot(bufNLCD)
{% endhighlight %}

![plot of chunk analysis]({{ site.url }}/figure/analysis-4.png) ![plot of chunk analysis]({{ site.url }}/figure/analysis-5.png) 

{% highlight r %}
#Now calcualte total proportion of each LULC and save to a data.frame
  lulc<-freq(bufNLCD)

#clean it up by removing the NA values
  lulc<-as.data.frame(lulc[!is.na(lulc[,1]),])

#calculate the proportions in each class
  lulc$proportion<-round(lulc$count/sum(lulc$count),3)

# calculate the total area of each class based on 30m x 30m grid cell size
  lulc$areaM2<-lulc$count*30*30

# finally, add the labels
    lulc<-merge(ct,lulc,by.x='code',by.y='value',all.y=TRUE)

# what a surprise, it is mostly developed land around the hotel
    lulc 
{% endhighlight %}



{% highlight text %}
##   code     hex                       label count proportion  areaM2
## 1   11 #5475A8                  Open Water   279      0.081  251100
## 2   21 #E8D1D1       Developed, Open Space    16      0.005   14400
## 3   22 #E29E8C    Developed, Low Intensity   316      0.092  284400
## 4   23 #FF0000 Developed, Medium Intensity   903      0.263  812700
## 5   24 #B50000   Developed, High Intensity  1917      0.559 1725300
{% endhighlight %}

## Exercise 3

### Working with rasters

1. Use the command `raster` to load the NLCD data ("NLCDpdx.tif")
2. Plot the data
3. Add LocPt and LocPoly (you will need to reproject)
4. Use `values` and `freq` to the analyze the raster.
5. We are done.










