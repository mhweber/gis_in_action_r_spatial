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
- [Exercise 2](#exercise-2): Visualizing spatial data in R
- [Exercise 3](#exercise-3): Working with rasters 


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
 
 
- Let's explore this in R.  We can use the "getClass()" command to view the subclasses of a spatial object:

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

Next we'll delve a bit deeper into the spatial objects inhereting from the base spatial class and try creating some simple objects.  Here's a schematic of how spatial points and lines inherit from the base spatial class - again, from the Bivand book, :

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

- Good Intro to R Spatial Resources:

    - [Bivand, R. S., Pebesma, E. J., & Gómez-Rubio, V. (2008). Applied spatial data analysis with R. New York: Springer.](http://www.asdar-book.org/)

    - [R spatial objects cheat sheet](https://www.dropbox.com/s/vv1ndtjrze0g8f2/RSpatialObjectsCheatSheet.ppt?dl=0)










