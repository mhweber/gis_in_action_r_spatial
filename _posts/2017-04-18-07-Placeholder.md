---
title: "07 - Placeholder"
author: Marc Weber and Ben Weinstein
layout: post_page
---



One of the goals for reproducible research is to provide your work in such a way that others can not only understand what was done, but can repeat it exactly on their own machines. To do this effectively we need to understand how to create reproducible reports.  This will be a very high level introduction to both concepts, but should hopefully give you a jumping off place for more learning.

##Quick Links to Exercises and R code
- [Exercise 1](#exercise-1): Create and render your own reproducible document


##Lesson Goals
- Gain familiarity with Markdown and `knitr`
- Create a simple, reproducible document and presentation

##Markdown
Markdown has become an important additional tool in the R ecosystem as it can be used to create package vignettes, can be used on [GitHub](http://github.com), and forms the basis for several reproducible research tools in RStudio (e.g. `rmarkdown`, `knitr`).  Markdown is a tool that allows you to write simply formatted text that is converted to HTML/XHTML.  The primary goal of markdown is readibility of the raw file.  Over the last couple of years, Markdown has emerged as a key way to write up reproducible documents, create websites (this whole website was written in Markdown), and make presentations.  For the basics of markdown and general information look at [Daring Fireball](http://daringfireball.net/projects/markdown/basics).  RStudio also has some [great material](https://support.rstudio.com/hc/en-us/articles/205368677-R-Markdown-Dynamic-Documents-for-R) with a more specific R Markdown flavor

*note: this text borrowed liberally from another class [SciComp2014](http://scicomp2014.edc.uri.edu) and another [workshop](http://usepa.github.io/introR/2015/01/15/08-Repeat-Reproduce/)*

To get you started, here is some of the most common markdown you will use: Text, Headers, Lists, Links, and Images.

### Text

So, for basic text... Just type it!

### Headers

In pure markdown, there are two ways to do headers but for most of what you need, you can use the following for headers:


    # Header 1
    ## Header 2
    ...
    ###### Header 6
  

### List

Lists can be done many ways in markdown. An unordered list is simply done with a `-`, `+`, or `*`.  For example

- this list
- is produced with
- the following 
- markdown.
    - nested

<pre>    
- this list
- is produced with
- the following 
- markdown
    - nested
</pre> 
    
Notice the space after the `-`.  

To create an ordered list, simply use numbers.  So to produce:

1. this list
2. is produced with
3. the following
4. markdown.
    - nested

<pre>
1. this list
2. is produced with
3. the following
4. markdown.
    - nested
</pre>

### Links and Images

Last type of formatting that you will likely want to accomplish with R markdown is including links and images.  While these two might seem dissimilar, I am including them together as their syntax is nearly identical.

So, to create a link you would use the following:

```
[Workshop Website](http://jwhollister.com/iale_open_science)
```

The text you want linked goes in the `[]` and the link itself goes in the `()`.  That's it! Now to show an image, you simply do this:

```
![R Logo](http://www.r-project.org/Rlogo.png)
```

The only difference is the use of the `!` at the beginning.  When parsed, the image itself will be included, and not just linked text.  As these will be on the web, the images need to also be available via the web.  You can link to local files, but will need to use a path relative to the root of the document you are working on.  Let's not worry about that. It's easy, but beyond the scope of this tutorial.

##Reproducible Documents and Presentations
By itself Markdown is pretty cool, but doesn't really provide any value added to the way most of us already work.  However, when you add in a few other things, it, in my opinion, changes things dramatically.  Three tools in particular that, along with Markdown, have moved reproducible research forward (especially as it relates to R) are, the `knitr` package, the `rmarkdown` package, and a tool called [pandoc](http://pandoc.org/).  We are not going to cover the details of these, but we will use them via RStudio.  

In short, these tools allow us to write up documents, embed code via "code chunks", run that code and render the final document with nicely formatted text, results, figures etc into a final format of our choosing.  We can create `.html`, `.docx`, `.pdf`, ...  The benefit of doing this is that all of our data and code are a part of the document.  I share my source document, then anyone can reproduce all of our calculations.  For instance, I can make a manuscript that looks like this:

![Rendered Manuscript](/iale_open_science/figure/rendered.jpg)


from a source markdown document that looks like:


![Raw RMarkdown](/iale_open_science/figure/source.jpg)


While we can't get to this level of detail with just the stock RStudio tools, we can still do some pretty cool stuff.  First, lets talk a bit about "code chunks."  

###Code Chunks
Since we are talking about markdown and R, our documents will all be R Markdown documents (i.e. .Rmd).  To include R Code in your .Rmd you would do something like:

    ```{r}
    x<-rnorm(100)
    x
    ```
    
This identifies what is known as a code chunk.  When written like it is above, it will echo the code to your final document, evalute the code with R and echo the results to the final document.  There are some cases where you might not want all of this to happen.  You may want just the code returned and not have it evalutated by R.  This is accomplished with:

    ```{r eval=FALSE}
    x<-rnorm(100)
    ```

Alternatively, you might just want the output returned, as would be the case when using R Markdown to produce a figure in a presentation or paper:


    ```{r echo=FALSE}
    x<-rnorm(100)
    y<-jitter(x,1000)
    plot(x,y)
    ```

Each of your code chunks can have a label.  That would be accomplished with something like:
 
    ```{r myFigure, echo=FALSE}
    x<-rnorm(100)
    y<-jitter(x,1000)
    plot(x,y)
    ```

We've seen `plot()` above, but you could also use `ggplot2`


    ```{r }
    x<-rnorm(100)
    y<-jitter(x,1000)
    ggplot(data.frame(x,y),aes(x=x,y=y)) +
       geom_point()
    ```

Lastly, tables in markdown can be done by hand, but better yet you can use some functions and packages to output these.  Below is an example using `knitr::kable()`.  There are other packages that also do this (e.g. `xtable` and `pander`) and have a lot of flexibility, but `kable()` is the easiest.  You can do this with:


    ```{r echo=FALSE,results="asis"}
    knitr::kable(head(iris),format="markdown")
    ```


Now, lets get started and actually create a reproducible document

###Create a Document
To create your document, go to File: New File : R Markdown.  You should get a window that looks something like:

![New RMarkdown](/iale_open_science/figure/newrmarkdown.jpg)

Add title and author, select "HTML" as the output and click "OK".  RStudio will open a new tab in the editor and in it will be your new document, with some very useful examples.

In this document we can see a couple of things.  First at the top we see:

    ---
    title: "My First Reproducible Document"
    author: "Jeff W. Hollister"
    date: "1/6/2015"
    output: pdf_document
    ---

This is the YAML(YAML Ain't Markup Language) header or front-matter.  It is metadata about the document that can be very useful.  For our purposes we don't need to know anything more about this.  Below that you see text, code chunks, and if it were included some markdown.  At its core this is all we need for a reproducible document.  We can now take this document, pass it through `knitr::knit()` and pandoc, through `rmarkdown::render()` or use RStudio to get our output. 

In RStudio, look near the top of the editor window you will see:

![knit it](/iale_open_science/figure/knit.jpg)

Click this and behold the magic!

It should be easy to see how this could be used to write the text describing an analysis, embed the analysis and figure creation directly in the document, and render a final document.  You share the source and rendered document and anyone has access to your full record of that research!

###Create a Presentation
Creating a presentation is not much different.  We just need a way to specify different slides.  So, repeat the steps from above, but this time instead of selecting "Document", select "Presentation".  Only thing we need to know is that a second level header (i.e. `##`) is what specifies the title of the next slide.  Any thing you put after that goes on that slide.    

I know you will probably wonder if you can change the look and feel of this presentation, and the answer is yes.  It does require a bit of work and how you do it depends on which output format you choose.  You can control some of the basics via the YAML but more custom work will require digging into CSS for the HTML formats and customizing the Beamer outputs requires knowledge of LaTeX.  

You can find out more on each format from the RStudio documentation.  

  - [ioSlides](http://rmarkdown.rstudio.com/ioslides_presentation_format.html) 
  - [Slidy](http://rmarkdown.rstudio.com/slidy_presentation_format.html)
  - [Beamer](http://rmarkdown.rstudio.com/beamer_presentation_format.html) 

##Exercise 1
The exercise for this lesson is described in more detail in the [next lesson](http://jwhollister.com/iale_open_science/2015/07/05/07-Build-Your-Own/).  That lesson is all hands on with developing a Markdown document.  
