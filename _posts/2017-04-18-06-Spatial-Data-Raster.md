---
title: "06 - Spatial Data in R - Raster"
author: Marc Weber
layout: post_page
---

While there is an `sp` `SpatialGridDataFrame` object to work with rasters in R, the prefered method far and away is to use the newer `raster` package by Robert J. Hijmans.  The raster package has made working with raster data (as well as vector spatial data for some things) much easier and more efficient.  The raster package allows you to:
- read and write almost any commonly used raster data format using rgdal
- create rasters, do typical raster processing operations such as resampling, projecting, filtering, raster math, etc.
- work with files on disk that are too big to read into memory in R
- run operations quite quickly since the package relies on back-end C code

The [home page](https://cran.r-project.org/web/packages/raster/) for the `raster` package has links to several well-written vignettes and documentation for the package.

The `raster` package uses three classes / types of objects to represent raster data - `RasterLayer`, `RasterStack`, and `RasterBrick` - these are all `S4` new style classes in R, just like `sp` classes.

## Lesson Goals
- Understand how to create, load, and analyze raster data in R
- Understand basic structure of rasters in R and how to manipulate
- Try some typical GIS-y operations on raster data in R like performing zonal statistics

## Quick Links to Exercises
- [Exercise 1](#exercise-1): Exploratory analysis on raster data
- [Exercise 2](#exercise-2): NDVI?
- [Exercise 3](#exercise-3): Zonal Statistics?

Let's create an empty `RasterLayer` object-

{% highlight r %}
library(raster)
r <- raster(ncol=10, nrow = 10, xmx=-116,xmn=-126,ymn=42,ymx=46)
str(r)
r
r[] <- runif(n=ncell(r))
r
plot(r)
{% endhighlight %}

When you look at summary information for the `RasterLayer`, by simply typing "r", you'll notice the main information defining a `RasterLayer` object described.  Minimal information needed to define a `RasterLayer` include the number of columns and rows, the bounding box or spatial extent of the raster, the the coordinate reference system.  What do you notice about the coordinate reference system of raster we just generated from scratch?

A  `RasterStack` is a raster object with multiple raster layers - essentially a multi-band raster.  `RasterStack` and `RasterBrick` are very similar and we won't delve into differences much here - basically, a `RasterStack` can virtually connect several `RasterLayer` objects in memory and allows pixel-based calculations on separate raster layers, while a `RasterBrick` has to refer to a single multi-layer file or multi-layer object.  Note that methods that operate on either a `RasterStack` or `RasterBrick` usually return a `RasterBrick`, and processing will be mor efficient on a `RasterBrick` object.  

It's easy to manipulate our `RasterLayer' to make a couple new layers, and then stack layers:

{% highlight r %}
r2 <- r * 50
r3 <- sqrt(r * 5)
s <- stack(r, r2, r3)
s
plot(s)
{% endhighlight %}

Same process for generating a raster brick (here I make layers and stack, or brick, in same step):

{% highlight r %}
b <- brick(x=c(r, r * 50, sqrt(r * 5)))
b
plot(b)
{% endhighlight %}


## Exercise 1
### Exploratory analysis on raster data

Let's play with some real datasets and perform some simple analyses on some raster data.  First let's grab some boundary spatial polygon data to use in conjuntion with raster data - we'll grab PNW states using the very handy getData function in `raster' (you can use help(getData) to learn more about the function). Here we use the global administrative boundaries, or GADM data, to load in US states and subset to the PNW - note how we subset the data and see if you follow how that works.


{% highlight r %}
US <- getData("GADM",country="USA",level=1)
states    <- c('California', 'Nevada', 'Utah','Montana', 'Idaho', 'Oregon', 'Washington')
PNW <- US[US$NAME_1 %in% states,]
plot(PNW, axes=TRUE)
{% endhighlight %}



- R `raster` Resources:

    - [The Visual Raster Cheat Sheet](https://cran.r-project.org/web/packages/raster/)
    OR you can install this as a package and run examples yourself in R:
    - [The Visual Raster Cheat Sheet](https://github.com/etiennebr/visualraster)
