---
title: "01 - Before The Workshop"
author: Marc Weber
layout: post_page
---

Prior to the start of the workshop everyone will need to have the software 
installed and tested.  You will need to have  R and RStudio.  Get the latest versions of each and install using the defaults.  

1. **R:** 
    - [General Info](http://cran.r-project.org/)
    - [Windows](http://cran.r-project.org/bin/windows/base/R-3.2.0-win.exe)
    - [Mac](http://cran.r-project.org/bin/macosx/R-3.3.2.pkg)
        - *Note:* Mac users will need to make sure they have XQuartz installed. You can check to see if you have it by looking in the directory `Applications/Utilities`.  If you need to install it, [follow this link](http://xquartz.macosforge.org/landing/).
        
2. **RStudio:** 
    - [General Info](http://www.rstudio.com/products/rstudio/download/)
    - [Windows](https://download1.rstudio.org/RStudio-1.0.136.exe)
    - [Mac](https://download1.rstudio.org/RStudio-1.0.136.dmg)
    - [Ubuntu (64 bit)](https://download1.rstudio.org/rstudio-1.0.136-amd64.deb)
  
Once everything is installed, follow the instructions below to test your installation.

## Open RStudio
Once installed, RStudio should be accessible from the start menu.  Start up RStudio.  Once running it should look something like:

![RStudio Window](/gis_in_action_r_spatial/figure/rstudio.png)

## Find "Console" window
By default the console window will be on the left side of RStudio.  Find that window.  It will looking something like:  

![RStudio Console](/gis_in_action_r_spatial/figure/rstudio_console.png)

## Copy and paste the code
Click in the window and paste in the code from below:


{% highlight r %}
version$version.string
{% endhighlight %}

## It should say...

{% highlight text %}
## [1] "R version 3.3.2 (2016-10-31)"
{% endhighlight %}

## Or...

{% highlight text %}
## [1] "R version 3.3.3 (2017-03-06)"
{% endhighlight %}


