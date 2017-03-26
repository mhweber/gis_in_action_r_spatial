---
title: "02 - Install spatial libraries"
author: "Marc Weber and Ben Weinstein"
layout: post_page
---
  
First we need to install several R libraries.  R operates on user-contributed libraries, and we'll be jumping into use of several of these spatial libraries in this workshop.  Several libraries we'll be making use of are `sp`, `rgdal`, `rgeos`, `raster`, and the new `sf` simple features library by Edzer Pebesma.  You should be able to use the packages tab in RStudio (see below) to install binaries in a straightforward way.  Mac and Linux users may have certain pre-requisites to fill, we'll assume you can navigate these on your own or can assist as needed (one of us is using a Linux system).

![RStudio Console](/gis_in_action_r_spatial/figure/packages.png)

Install all of the following packages in R:
{% highlight r %}
install.packages("rgdal")
install.packages("rgeos")
install.packages("raster")
install.packages("sf")
{% endhighlight %}

Installing `rgdal` will install the foundation spatial package, `sp`, as a dependency.  

For Linux users, you need GDAL >= 2.0.0, GEOS >= 3.3.0, and Proj.4 >=  4.8.0.  Edzer Pebesma's Simple Features ffor R GitHub repo has a good explanation:

[Simple Features for R](https://github.com/edzer/sfr)

You basically want to add [ubuntugis-unstable](http://ppa.launchpad.net/ubuntugis/ubuntugis-unstable/ubuntu/) to the package repositories and then get those three dependencies:

```
sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable
sudo apt-get install libgdal-dev libgeos-dev libproj-dev
```

`sf` package also needs udunits and udunits2 which may need coercing in linux:

[Units Issues in sf GitHub repo](https://github.com/edzer/units/issues/1)

The following should resolve:

```
sudo apt-get install libudunits2-dev
```


