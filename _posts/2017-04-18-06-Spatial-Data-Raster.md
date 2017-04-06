---
title: "06 - Spatial Data in R - Raster"
author: Marc Weber
layout: post_page
---


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

