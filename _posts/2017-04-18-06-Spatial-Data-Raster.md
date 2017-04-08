---
title: "06 - Spatial Data in R - Raster"
author: Marc Weber
layout: post_page
---

% highlight r %}
library(raster)
#create an empty raster
r <- raster(ncol=10, nrow = 10, xmx=-116,xmn=-126,ymn=42,ymx=46)
str(r)
r
r[] <- 1:ncell(r)
r
plot(r)
{% endhighlight %}

A raster stack is a raster with multiple raster layers
% highlight r %}
r2 <- r * 50
r3 <- sqrt(r * 5)
s <- stack(r, r2, r3)
s
plot(s)
{% endhighlight %}

{% highlight r %}
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

