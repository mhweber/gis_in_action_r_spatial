---
title: "10 - Placeholder"
author: Marc Weber and Ben Weinstein
layout: post_page
---

While I give brief introduction to the principles of tidy data, please install `tidyr` and `dplyr`.  If you run into problems with this, use the stickie pads and Scott, Jeff, or Bryan will be by to help.

**Principles of Tidy Data**

Nearly everything that I will cover in the section is stolen directly from some Hadley Wickham products.  In fact, if you just read the following paper, you should learn everything you need to know about data management (unless you are doing crazy database stuff- then you might need some intense instruction).


[Wickham, H. 2014. Tidy Data. Journal of Statistical Software 59.](http://vita.had.co.nz/papers/tidy-data.pdf)


> “Happy families are all alike; every unhappy family is unhappy in its own way”
> *Leo Tolstoy*

> “[T]idy datasets are all alike but every messy dataset is messy in its own way.”
> *Hadley Wickham*


It is estimated that 80% of data analysis time is spent cleaning and preparing data (Dasu T, Johnson T (2003). Exploratory Data Mining and Data Cleaning. John Wiley & Sons).  There will always be a need to devote some time to preparing data for specific analysis.  However, the ultimate goal is to reduce the time needed to deal with “messy data” issues.


Tidy data is a standard method of data storage for increased interpretability and integration.

*Why should you care about tidy data?*

  * Data analysis software is created based on a standardized data format
  * Data is super expensive and difficult to collect
  * Increase the ease and accuracy of data sharing
  * Because you are required to care

*The Principles of Tidy Data:*

1. Rows are observations
2. Variables are Columns
3. Observational Units are Tables


The rest of this section will be spent talking about (and playing with) two data manipulation packages: `tidyr` and `dplyr`.  To understand these packages (and other Wickham packages like `ggplot2`), it is first useful to make sure we have a basic understanding of pipes.  

If you need to execute several functions on an object, there are three ways to do this: use intermediate steps, nested functions, or pipes. With the intermediate steps, you essentially create a temporary data frame and use that as input to the next function. You can also nest functions (i.e. one function inside of another). This is handy, but can be difficult to read if too many functions are nested as the process from inside out. The last option, pipes, are a fairly recent addition to R.   Whenever you see %>%, read as “take… and then ….” 

Pipes allow us to:

1. Reduce the number of nested parenthesizes
2. Write code that reads left to right and more like actual pseudocode
3. Increase organization and more in-line with workflow


*Examples*


{% highlight r %}
library('magrittr')
str1<- "Facts are stubborn"
str2<-"but statistics are more pliable"

##Example of intermediate step
play<-paste(str1,str2)
toupper(play)
{% endhighlight %}



{% highlight text %}
## [1] "FACTS ARE STUBBORN BUT STATISTICS ARE MORE PLIABLE"
{% endhighlight %}



{% highlight r %}
##Example of nested functions 
toupper(paste(str1,str2))
{% endhighlight %}



{% highlight text %}
## [1] "FACTS ARE STUBBORN BUT STATISTICS ARE MORE PLIABLE"
{% endhighlight %}



{% highlight r %}
##Pipes
str1 %>% substr(1,5)
{% endhighlight %}



{% highlight text %}
## [1] "Facts"
{% endhighlight %}



{% highlight r %}
str1 %>% paste(str2) %>% toupper()
{% endhighlight %}



{% highlight text %}
## [1] "FACTS ARE STUBBORN BUT STATISTICS ARE MORE PLIABLE"
{% endhighlight %}


**Package: `tidyr`**

The `tidyr` package is intended to deal with a lot of the common messy data issues.  If you were using `reshape` or `reshape2` to clean your data, `tidyr` should be easier and faster.  However, it is specifically designed for data cleaning and not reshaping or aggregate (i.e. it might not replace `reshape2` in your workflow).  There are two main functions with which we will work: gather() and separate().

gather() takes multiple columns and collapses into key-value pairs, duplicating all other columns as needed.

*Example*

{% highlight r %}
library(tidyr)
messy<-data.frame(site=c("pawcatuck"," pettaquamscutt","pawtuxet"," pocasset","ponaganset"), a=c(56,76,43,25,21),b=c(123,234,187,198,23))

messy
{% endhighlight %}



{% highlight text %}
##              site  a   b
## 1       pawcatuck 56 123
## 2  pettaquamscutt 76 234
## 3        pawtuxet 43 187
## 4        pocasset 25 198
## 5      ponaganset 21  23
{% endhighlight %}



{% highlight r %}
messy %>%
  gather(treatment, count, a:b) %>% print()
{% endhighlight %}



{% highlight text %}
##               site treatment count
## 1        pawcatuck         a    56
## 2   pettaquamscutt         a    76
## 3         pawtuxet         a    43
## 4         pocasset         a    25
## 5       ponaganset         a    21
## 6        pawcatuck         b   123
## 7   pettaquamscutt         b   234
## 8         pawtuxet         b   187
## 9         pocasset         b   198
## 10      ponaganset         b    23
{% endhighlight %}


Given either regular expression or a vector of character positions, separate() turns a single character column into multiple columns.  

*Example*

{% highlight r %}
df <- data.frame(x = c("a.b", "a.d", "b.c"))%>% print()
{% endhighlight %}



{% highlight text %}
##     x
## 1 a.b
## 2 a.d
## 3 b.c
{% endhighlight %}



{% highlight r %}
df %>% separate(x, c("A", "B"))%>% print()
{% endhighlight %}



{% highlight text %}
##   A B
## 1 a b
## 2 a d
## 3 b c
{% endhighlight %}



{% highlight r %}
df <- data.frame(x = c("x: 123", "y: error: 7"))%>% print()
{% endhighlight %}



{% highlight text %}
##             x
## 1      x: 123
## 2 y: error: 7
{% endhighlight %}



{% highlight r %}
df %>% separate(x, c("key", "value"), ": ", extra = "merge") %>% print()
{% endhighlight %}



{% highlight text %}
##   key    value
## 1   x      123
## 2   y error: 7
{% endhighlight %}

**Package: `dplyr`**

The package `dplyr` is a fairly new (2014) package that tries to provide easy tools for the most common data manipulation tasks. It is built to work directly with data frames. The thinking behind it was largely inspired by the package `plyr` which has been in use for some time but suffered from being slow in some cases.

`dplyr` is built around 5 verbs. These verbs make up the majority of the data manipulation you tend to do. You might need to:

1. select () certain columns of data. Can in use it place of subset() but with some fancy additions like contains(), starts_with() and, ends_with()
2. filter() your data to select specific rows
3. arrange() the rows of your data into an order
4. mutate() your data frame to contain new columns
5. summarise() chunks of you data in some way


Also has glimpse(), which you can use it like str().


{% highlight r %}
library(dplyr)
glimpse(iris)
{% endhighlight %}



{% highlight text %}
## Observations: 150
## Variables:
## $ Sepal.Length (dbl) 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9,...
## $ Sepal.Width  (dbl) 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1,...
## $ Petal.Length (dbl) 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5,...
## $ Petal.Width  (dbl) 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1,...
## $ Species      (fctr) setosa, setosa, setosa, setosa, setosa, setosa, ...
{% endhighlight %}



{% highlight r %}
head(select(iris, contains("Petal"))) 
{% endhighlight %}



{% highlight text %}
##   Petal.Length Petal.Width
## 1          1.4         0.2
## 2          1.4         0.2
## 3          1.3         0.2
## 4          1.5         0.2
## 5          1.4         0.2
## 6          1.7         0.4
{% endhighlight %}



{% highlight r %}
iris%>%filter(Species=="setosa")%>%head()
{% endhighlight %}



{% highlight text %}
##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
## 1          5.1         3.5          1.4         0.2  setosa
## 2          4.9         3.0          1.4         0.2  setosa
## 3          4.7         3.2          1.3         0.2  setosa
## 4          4.6         3.1          1.5         0.2  setosa
## 5          5.0         3.6          1.4         0.2  setosa
## 6          5.4         3.9          1.7         0.4  setosa
{% endhighlight %}



{% highlight r %}
iris%>%arrange(Petal.Length)%>%head()
{% endhighlight %}



{% highlight text %}
##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
## 1          4.6         3.6          1.0         0.2  setosa
## 2          4.3         3.0          1.1         0.1  setosa
## 3          5.8         4.0          1.2         0.2  setosa
## 4          5.0         3.2          1.2         0.2  setosa
## 5          4.7         3.2          1.3         0.2  setosa
## 6          5.4         3.9          1.3         0.4  setosa
{% endhighlight %}



{% highlight r %}
iris%>%arrange(desc(Petal.Length))%>%head()
{% endhighlight %}



{% highlight text %}
##   Sepal.Length Sepal.Width Petal.Length Petal.Width   Species
## 1          7.7         2.6          6.9         2.3 virginica
## 2          7.7         3.8          6.7         2.2 virginica
## 3          7.7         2.8          6.7         2.0 virginica
## 4          7.6         3.0          6.6         2.1 virginica
## 5          7.9         3.8          6.4         2.0 virginica
## 6          7.3         2.9          6.3         1.8 virginica
{% endhighlight %}



{% highlight r %}
iris%>%mutate(Sepal.Length.mm=Sepal.Length*10)%>%head()
{% endhighlight %}



{% highlight text %}
##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
## 1          5.1         3.5          1.4         0.2  setosa
## 2          4.9         3.0          1.4         0.2  setosa
## 3          4.7         3.2          1.3         0.2  setosa
## 4          4.6         3.1          1.5         0.2  setosa
## 5          5.0         3.6          1.4         0.2  setosa
## 6          5.4         3.9          1.7         0.4  setosa
##   Sepal.Length.mm
## 1              51
## 2              49
## 3              47
## 4              46
## 5              50
## 6              54
{% endhighlight %}



{% highlight r %}
iris%>%summarize(sepalMean=mean(Sepal.Length,na.rm=TRUE))
{% endhighlight %}



{% highlight text %}
##   sepalMean
## 1  5.843333
{% endhighlight %}

And just one more cool `dplyr` function, group_by()


{% highlight r %}
group_by(iris,Species)%>%
  summarize(mean(Sepal.Length),
            mean(Sepal.Width),
            mean(Petal.Length),
            mean(Petal.Width))
{% endhighlight %}



{% highlight text %}
## Source: local data frame [3 x 5]
## 
##      Species mean(Sepal.Length) mean(Sepal.Width) mean(Petal.Length)
## 1     setosa              5.006             3.428              1.462
## 2 versicolor              5.936             2.770              4.260
## 3  virginica              6.588             2.974              5.552
## Variables not shown: mean(Petal.Width) (dbl)
{% endhighlight %}

As well as working with local in-memory data like data frames and data tables, `dplyr` also works with remote on-disk data stored in databases. Generally, if your data fits in memory there is no advantage to putting it in a database: it will only be slower and more hassle. The reason you’d want to use `dplyr` with a database is because either your data is already in a database (and you don’t want to work with static csv files that someone else has dumped out for you), or you have so much data that it does not fit in memory and you have to use a database. Currently `dplyr` supports the three most popular open source databases (SQLite, MySQL and PostgreSQL), and Google’s bigquery. [Link to `dplyr` database vignette](http://cran.r-project.org/web/packages/dplyr/vignettes/databases.html)


**Exercises**


{% highlight r %}
###Use for #1-3
set.seed(10)
messy <- data.frame(
  id = 1:4,
  trt = sample(rep(c('control', 'treatment'), each = 2)),
  work.T1 = runif(4),
  home.T1 = runif(4),
  work.T2 = runif(4),
  home.T2 = runif(4)
)
{% endhighlight %}

1. Use gather() to turn columns work.T1, home.T1, work.T2and home.T2 into a key-value pair of key and time. 

2. Use separate() to split the key into location and time.  Try piping #1 and #2 together into one command.

3. Using `dplyr`, find the max time for the treatment and control.

4. Using the mtcars data set, what is the average mpg for all vehicles in the mtcars data set?  What is the average mpg for each number of cylinders? Create a new column for the log of the weight.

