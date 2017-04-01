---
title: "05 - Spatial Data in R - simple features"
author: Marc Weber
layout: post_page
---

Before we get to the fun stuff, I want to make sure we are all on the same page on what we mean when we talk about open science and reproducible research.  No exercises for this section.  Just a few slides and definitions.  

##Lesson Goals
  - Know the definition of open science
  - Know what is meant by reproducible research
  
##What is Open Science?
Like a lot of things, there isn't a single, agreed upon definition of what open science is.  There are however many components that most agree are part of open science.  In short, those are: 

  - Access to code, publications, data, etc.
  - Work is repeatable and reproducible
  - Built for a web enabled world
  - Continuous, not binary (i.e 50 Shades of Open)
  
Instead of repeating work here, I will point you to some other definitions I have used in the past:

  - [Slide deck on open science](http://jwhollister.com/open_science_neers/#(2))
  - [Storify on definition of open science](https://storify.com/jhollist/what-is-the-definition-of-open-science)

For this workshop we are going to focus on the technology of open science.  In particular open data and open source tools that help facilitate reproducibility.  So then ...

##What is Reproducible Research
Reproducible research has its roots in [Literate Programming](http://www.literateprogramming.com/) which advocated for clear documentation of code.  Since then reproducible research has taken this definition and applied it to scientific research.  The result is a definition that advocates for the combining of all the code, data, text, and figures that make up a given piece of scientific research.  Recently, full computational reproducibility has been proposed that includes details on the computational resources (e.g. through virtual machines or,recently, Linux containers) used to conduct an analysis.  

Much of this is going to be beyond the scope of this workshop. Thus, our use of the term is  focus on the tools, in particular R and markdown, needed to write reproducible documents (and presentations) so that others can reproduce our analyses.  We will also talk a bit out tools in R that facilitate working with data, using spatial data, and finding open species occurrence data.



