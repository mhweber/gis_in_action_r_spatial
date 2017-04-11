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

The `raster` package uses three types of objects to represent raster data - `RasterLayer`, `RasterStack`, and `RasterBrick`.

Let's create an empty raster

{% highlight r %}
library(raster)
r <- raster(ncol=10, nrow = 10, xmx=-116,xmn=-126,ymn=42,ymx=46)
str(r)
r
r[] <- runif(n=ncell(r))
r
plot(r)
{% endhighlight %}

A raster stack is a raster with multiple raster layers

{% highlight r %}
r2 <- r * 50
r3 <- sqrt(r * 5)
s <- stack(r, r2, r3)
s
plot(s)
{% endhighlight %}

{% highlight r %}
library(raster)
library(rgdal)

alt <- getData('alt', country = "AT")
gadm <- getData('GADM', country = "AT", level = 2)
gadm_sub <- gadm[1:3, ]

plot(alt)
plot(gadm_sub, add=T)

asp <- terrain(alt, opt = "aspect", unit = "degrees", df = F)
slo <- terrain(alt, opt = "slope", unit = "degrees", df = F)

extract(slo, gadm_sub, fun = mean, na.rm = T, small = T, df = T)
extract(asp, gadm_sub, fun = mean, na.rm = T, small = T, df = T)
{% endhighlight %}

