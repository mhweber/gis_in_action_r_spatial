---
title: "08 - Install spatial libraries"
author: "Scott Chamberlain and Jeff Hollister"
layout: post_page
---
  
Installing `rgdal` and `rgeos` can be a bit problematic, especially from Mac and Linux.  Using the instructions below should ease that on the Mac side.  Linux users, we will assume you can track down the issues on your own.  Windows users you get the benefits of the binaries for all these being built and available by default.

__rgdal__

Install from source from CRAN, and pass to `configure.args` the path to your GDAL library. 

{% highlight r %}
install.packages("rgdal", type = "source", configure.args = "--with-gdal-config=/Library/Frameworks/GDAL.framework/Versions/1.11/unix/bin/gdal-config --with-proj-include=/Library/Frameworks/PROJ.framework/unix/include --with-proj-lib=/Library/Frameworks/PROJ.framework/unix/lib")
{% endhighlight %}

__rgeos__

May work without anything, 

{% highlight r %}
install.packages("rgeos", type = "source")
{% endhighlight %}
