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
- [Exercise 1](#exercise-1): Getting to Know of Spatial Objects
- [Exercise 2](#exercise-2): Building and Manipulating Spatial Data in R
- [Exercise 3](#exercise-3): Reading and writing data and projections 

Download and extract data for exercises to your computer
{% highlight r %}
zipFile<- "https://github.com/mhweber/gis_in_action_r_spatial/blob/gh-pages/files/WorskhopData.zip"
outDir<-"/home/Downloads" # set local directory you want to use
unzip(zipFile,exdir=outDir)
{% endhighlight %}


## A Little R Background
### Terminology: Working Directory

Working directory in R is the location on your computer R is working from.  To determine your working directory, in console type:

{% highlight r %}
getwd()
{% endhighlight %}

Which should return something like:

{% highlight text %}
## [1] "/home/marc/GitProjects/gis_in_action_r_spatial"
{% endhighlight %}

To see what is in the directory:
{% highlight r %}
dir()
{% endhighlight %}

To establish a different directory:
{% highlight r %}
setwd("/home/marc/GitProjects")
{% endhighlight %}

### Terminology: data structures
R is an interpreted language (access through a command-line interpreter) with a number of data structures (vectors, matrices, arrays, data frames, lists) and extensible objects (regression models, time-series, geospatial coordinates) and supports procedural programming with functions. 

To learn about objects, become friends with the built-in `class` and `str` functions. Let's explore the built-in iris data set to start:

{% highlight r %}
class(iris)
{% endhighlight %}

{% highlight text %}
## [1] "data.frame"
{% endhighlight %}

{% highlight r %}
str(iris)
{% endhighlight %}

{% highlight text %}
## 'data.frame':	150 obs. of  5 variables:
## $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
## $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
## $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
## $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
## $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
{% endhighlight %}

As we can see, `iris` is a data frame and is used extensively for beginning tutorials on learning R. Data frames consist of rows of observations  on columns of values for variables of interest - they are one of the fundamental and most important data structures in R.

### Overview of Classes and Methods

- Class: object types
    - `class()`: gives the class type 
    - `typeof()`: information on how the object is stored
    - `str()`: how the object is structured
- Method: generic functions
    - `print()`
    - `plot()`
    - `summary()`

## Exercise 1
### Getting to Know of Spatial Objects

Handling of spatial data in R has been standardized in recent years through the base package `sp` - uses 'new-style' classes in R that adhere to 'simple features' OGC specification.  

The best source to learn about `sp` and and fundamentals of spatial analysis in R is Roger Bivand's book [Applied Spatial Data Analysis in R](http://www.asdar-book.org/)

Although we'll look at the new simple features object specification this morning as well, numerous packages are currently built using sp object structure so need to learn to navigate current R spatial ecosystem.
 
 `sp` provides definitions for basic spatial classes (points, lines, polygons, pixels, and grids).
 
To start with, it's good to stop and ask yourself what it takes to define spatial objects.  What would we need to define vector (point, line, polygon) spatial objects?  

- A coordinate reference system
- A bounding box, or extent
- plot order
- data
- ?

`sp` objects inherit from the basic spatial class, which has two 'slots' in R new-style class lingo.  From the Bivand book above, here's what this looks like (Blue at top of each box is the class name, items in white are the slots, arrows show inheritance between classes):

![SpatialClassesFig1](/gis_in_action_r_spatial/figure/SpatialClassesFig1.png)
 
 
- Let's explore this in R.  We can use the `getClass()` command to view the subclasses of a spatial object:

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

Next we'll delve a bit deeper into the spatial objects inhereting from the base spatial class and try creating some simple objects.  Here's a schematic of how spatial points and lines inherit from the base spatial class - again, from the Bivand book:

![SpatialClassesFig2](/gis_in_action_r_spatial/figure/SpatialClassesFig2.png)

And to explore a bit in R:

{% highlight r %}
getClass("SpatialPolygons")
{% endhighlight %}

{% highlight text %}
## Class "SpatialPolygons" [package "sp"]
## 
## Slots:
##                               
## Name:     polygons   plotOrder        bbox proj4string
## Class:        list     integer      matrix         CRS
## 
## Extends: "Spatial" 
## 
## Known Subclasses: 
## Class "SpatialPolygonsDataFrame", directly, with explicit coerce
{% endhighlight %}

Take a few minutes to examine the spatial objects figures and think of ways to learn more about objects and slots in R using methods we've seen such as `class()`, `str()`, `typeof()` - you'll see some of these work with some objects, some don't - just explore a bit.
A hint - which we'll use more - to access slots in a new style (in R,and from here on, we'll refer to as S4) object, use the @ symbol.  You've seen it already when we used `str()` on objects.

Also, there are a number of spatial methods you can use with classes in `sp` - here are some usefule ones to familarize yourself with:

| Method / Class   | Description | 
|------------------|-------------| 
| bbox()           | Returns the bounding box coordinates | 
| proj4string()    | Sets or retrieves projection attributes using the CRS object | 
| CRS()            | Creates an object of class of coordinate reference system arguments | 
| spplot()         | Plots a separate map of all the attributes unless specified otherwise | 
| coordinates()    | Returns a matrix with the spatial coordinates. For spatial polygons it returns the centroids. | 
| over(x, y)       | Used for example to retrieve the polygon or grid indexes on a set of points | 
| spsample(x)      | Sampling of spatial points within the spatial extent of objects | 

## Exercise 2
### Building and Manipulating Spatial Data in R

Basic data structures in R can represent spatial data - all we need is some vectors with location and attribute information

{% highlight r %}
cities <- c('Ashland','Corvallis','Bend','Portland','Newport')
longitude <- c(-122.699, -123.275, -121.313, -122.670, -124.054)
latitude <- c(42.189, 44.57, 44.061, 45.523, 44.652)
population <- c(20062,50297,61362,537557,9603)
locs <- cbind(longitude, latitude) 
plot(locs, cex=sqrt(population*.0002), pch=20, col='red', 
  main='Population', xlim = c(-124,-120.5), ylim = c(42, 46))
text(locs, cities, pos=4)
{% endhighlight %}

Add a legend
{% highlight r %}
breaks <- c(20000, 50000, 60000, 100000)
options(scipen=3)
legend("topright", legend=breaks, pch=20, pt.cex=1+breaks/20000, 
  col='red', bg='gray')
{% endhighlight %}

![BasicMap](/gis_in_action_r_spatial/figure/BasicMap.png)

Add a polygon to our map...
{% highlight r %}
lon <- c(-123.5, -123.5, -122.5, -122.670, -123)
lat <- c(43, 45.5, 44, 43, 43)
x <- cbind(lon, lat)
polygon(x, border='blue')
lines(x, lwd=3, col='red')
points(x, cex=2, pch=20)
{% endhighlight %}

![BasicMap2](/gis_in_action_r_spatial/figure/BasicMap2.png)

So, is this sufficient for working with spatial data in R and doing spatial analysis?  What are we missing?

Packages early on in R came at handling spatial data in their own way. The `maps` package is great example - a database of locational information that is quite handy. The `maps` package format was developed in S (R is implementation of S) - lines represented as a sequence of points separated by 'NA' values - think of as drawing with a pen, raising at NA, then lowering at a value.  Bad for associating with data since objects are only distinguished by separation with NA values. Try the following code-

{% highlight r %}
library(maps)
map()
{% endhighlight %}

![globalmap](/gis_in_action_r_spatial/figure/globalmap.png)

{% highlight r %}
map.text('county','oregon')
map.axes()
title(main="Oregon State")
{% endhighlight %}

![OregonCounties](/gis_in_action_r_spatial/figure/OregonCounties.png)

`maps` package draws on a binary database - see Becker references in help(map) for more details. Creates a list of 4 vectors when you create a `maps` object in R.

Explore the structure of map object a bit....
{% highlight r %}
p <- map('county','oregon')
str(p)
p$names[1:10]
p$x[1:50]
{% endhighlight %}

Spatial classes provided in `sp` package have mostly standardized spatial data in R and provide a solid way to represent and work with spatial data in R. 

Let's create a basic `sp` SpatialLines object from coordinates we were looking at in `maps` package..

{% highlight r %}
L1 <-Line(cbind(p$x[1:8],p$y[1:8]))
Ls1 <- Lines(list(L1), ID="Baker")
SL1 <- SpatialLines(list(Ls1))
str(SL1)
plot(SL1) 
{% endhighlight %}

Bottom line segment of Baker county...compare with earlier map and see if you understand why...

The `maptools` package provides convenience function for making spatial objects from  map objects.  Try the following code and see if you can follow each step...

{% highlight r %}
library(maptools)
counties <- map('county','oregon', plot=F, col='transparent',fill=TRUE)
counties$names
#strip out just the county names from items in the names vector of counties
IDs <- sapply(strsplit(counties$names, ","), function(x) x[2])
counties_sp <- map2SpatialPolygons(counties, IDs=IDs,
    proj4string=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))
summary(counties_sp)
plot(counties_sp, col="grey", axes=TRUE)
{% endhighlight %}

![OregonCounties2](/gis_in_action_r_spatial/figure/OregonCounties2.png)

## Exercise 3
### Reading and writing data and projections

Now let's look at how to construct a spatial object in R from a data frame with coordinate information.

{% highlight r %}
StreamGages <- read.csv('StreamGages.csv')
class(StreamGages)
head(StreamGages)
{% endhighlight %}

A very common task you might do in R in taking a spreadsheet of data with coordinate information and turning it into a spatial object to do further GIS operations on.  Here, we've read a speadsheet in an R data frame. Data frames, as we saw earlier, consist of rows of observations  on columns of values for variables of interest

As with anything in R, there are several ways to go about this, but the basics are we need to pull the coordinate columns of the data frame into a matrix which becomes the coordinates sloot of a spatial object, and then give the `SpatialPointsDataFrame` we create a coordinate reference system.

{% highlight r %}
coordinates(StreamGages) <- ~LON_SITE + LAT_SITE
llCRS <- CRS("+proj=longlat +datum=NAD83")
{% endhighlight %}
 
See how it looks
{% highlight r %}
summary(StreamGages)
{% endhighlight %}

{% highlight r %}
## Object of class SpatialPointsDataFrame
## Coordinates:
##                 min        max
## LON_SITE -124.66912 -110.44111
## LAT_SITE   41.42768   49.00075
## Is projected: NA 
## proj4string : [NA]
## Number of points: 2771
## Data attributes:
##   SOURCE_FEA              EVENTTYPE                                           STATION_NM  
##  Min.   :  10361700   StreamGage:2771   ABERDEEN-SPRINGFIELD CANAL NR SPRINGFIELD ID:   1 ##  
##  1st Qu.:  12331050                     ABERDEEN WASTE NR ABERDEEN ID               :   1 ##  
##  Median :  13069000                     ABERNATHY CREEK NEAR LONGVIEW, WA           :   1 ##  
##  Mean   :  14573679                     AENEAS LAKE NEAR TONASKET, WA               :   1 ##  
##  3rd Qu.:  13349362                     AGENCY CREEK NEAR JOCKO, MT                 :   1 ##  
##  Max.   :1315377299                     Agency Creek near Jocko MT (2)              :   1 ##  
##                                         (Other)                                     :2765 ##  
##      STATE     
##  WA     :1054  
##  ID     : 800  
##  OR     : 622  
##  MT     : 220  
##  WY     :  52  
##  NV     :  19  
##  (Other):   4  
{% endhighlight %}

Summary method gives a description of the spatial object in R. Summary works on pretty much all objects in R - for spatial data, gives us basic information about the projection, coordinates, and data for an sp object if it's a spatial data frame object.

We can use the generic plot function in R to produce a quick plot add axes as well-axes option puts box around region
{% highlight r %}
plot(StreamGages, axes=TRUE, col='blue') 
{% endhighlight %}

![StreamGageMap](/gis_in_action_r_spatial/figure/StreamGageMap.png)

And we can combine and use state borders from maps package in our map
{% highlight r %}
map('state',regions=c('oregon','washington','idaho'),fill=FALSE, add=T)
{% endhighlight %}

![StreamGageMap2](/gis_in_action_r_spatial/figure/StreamGageMap2.png)


- Good Intro to R Spatial Resources:

    - [Bivand, R. S., Pebesma, E. J., & Gómez-Rubio, V. (2008). Applied spatial data analysis with R. New York: Springer.](http://www.asdar-book.org/)

    - [R spatial objects cheat sheet](https://www.dropbox.com/s/vv1ndtjrze0g8f2/RSpatialObjectsCheatSheet.ppt?dl=0)










