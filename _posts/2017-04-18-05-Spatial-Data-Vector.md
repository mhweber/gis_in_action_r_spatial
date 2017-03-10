---
title: "04 - Using Open Species Occurrence Data in R"
author: Scott A. Chamberlain
layout: post_page
---



Species occurrence data is available in increasingly large quantities, as open data, available on the web.
Accessing the data is not always straight-forward. Potential problems arise due to dependence on an internet
connection, data size (especially over slow internet connections), dirty data, species name conflicts, and more.

This lesson will go through some ways to collect open species occurrence data in R, and wrap up with
demos of how to get species occurrence data back into familiar data formats (e.g., Spatial R objects,
geojson, etc.).

## Lesson Goals

  - Intro to Open Data via APIs & other web services
  - Using `rgbif` and `spocc` to access species occurence data
  - Using `taxize` to access and parse taxonomic information
  - Coverting `spocc` output to `sp`

## Quick Links to Exercises and R code

  - [Exercise 1](#exercise-1): Search for species occurrence data, make a simple map
  - [Exercise 2](#exercise-2): Clean taxonomic names
  - [Exercise 3](#exercise-3): Convert occurrence data to other formats


## Open data on the web

* GUI interfaces (no scraping allowed/possible)
* HTML (scraping)
* CSV/TXT/TSV etc.
* FTP
* APIs (SOAP, RESTful)

GUI interfaces are great!  That's where (nearly) everyone starts in their data search process. However, when you need to do more than a few queries/search tasks/etc., GUIs become very cumbersome.

Some websites allow you to scrape their content. That is, every web page has html code that defines that page. This is a structured language that you can collect in a programming lanugage like R, then parse out the exact things that you want. This is quite fragile though - that is, websites can update often, breaking any code you've written to scrape the site. In addition, html isn't the best way to move data around.

> Tools for scraping: rvest, xml2

Sometimes websites will provide data dumps in csv/text format. This is much better than scraping html, as it's easier for humans to understand, and we we can easily read in and manipulate the data. Always look for this type of data download as a better alternative to html scraping.

> Tools for importing csv: base R functions read.table/etc., & readr, data.table::fread, readxl

Data providers sometimes provide data via FTP (File Transfer Protocol). This is simply a file system that you can access data from. This is easy to use without a programming language - you can just go tot the FTP site and download data. But, as above, when dealing with more than a few files, it's best to write some code to automate download, data manipulation, etc.

> Tools for working with ftp: RCurl, curl, httr

The best situation, in most cases, is that a data provider provides a RESTful API (Application Programming Interface). Think of APIs as a set of instructions for one computer to talk to another, or one script to talk to another. For example, when you log into a site using your Facebook credentials - that's using one of the Facebook APIs.

APIs lay out a series of routes that define what data is avaiable, parameters to use to construct queries, and so on. On top of APIs, any programming language can build a client to interact with the API. This is the bees knees.

Caveat: When you have very large data, APIs sometimes are not best. See FTP.

> Tools for working with APIs: RCurl, curl, httr, httsnap

## Installation

Some packages you'll need install directly from CRAN (you may need special instructions for `rgdal`)


{% highlight r %}
install.packages("rgdal")
install.packages(c("rgbif","taxize","geojsonio"))
{% endhighlight %}

For others we'll need `devtools`


{% highlight r %}
install.packages("spocc")
{% endhighlight %}


{% highlight r %}
install.packages(c("ggmap","grid","sp","rworldmap","RColorBrewer","httr","leafletR","gistr","maptools"))
devtools::install_github("ropensci/spoccutils")
{% endhighlight %}

Or install from binary

Download:

* Mac - https://github.com/ropensci/spoccutils/releases/download/v0.1.0/spoccutils_0.1.0.tgz
* Windows - https://github.com/ropensci/spoccutils/releases/download/v0.1.0/spoccutils_0.1.0.zip

Then install


{% highlight r %}
install.packages("spoccutils_0.1.0.tgz", repos = NULL)
# OR
install.packages("spoccutils_0.1.0.zip", repos = NULL)
{% endhighlight %}

## Occurrence data

GBIF has probably the biggest collection of species occurrence data available on the web, and so we'll cover the `rgbif` R client first.

### rgbif


{% highlight r %}
library("rgbif")
{% endhighlight %}


#### Intro workflow

##### Search for names

A number of ways to search for names:

* `name_backbone()`
* `name_suggest()`
* `name_lookup()`
* `name_usage()`


{% highlight r %}
name_suggest(q = "Helianthus", limit = 10)
{% endhighlight %}



{% highlight text %}
##        key                 canonicalName    rank
## 1  3119134                    Helianthus   GENUS
## 2  6711019               Helianthus hybr SPECIES
## 3  7338793    Helianthus grosse-serratus SPECIES
## 4  7338854            Helianthus apricus SPECIES
## 5  7338762            Helianthus nitidus SPECIES
## 6  7338726 Helianthus pseudoverbeinoides SPECIES
## 7  4249728            Helianthus virilis SPECIES
## 8  4249876          Helianthus truncatus SPECIES
## 9  4249970           Helianthus tenellus SPECIES
## 10 4250107           Helianthus striatus SPECIES
{% endhighlight %}

I often use `name_backbone()` to get to IDs that GBIF uses


{% highlight r %}
out <- name_backbone(name = "Oncorhynchus mykiss")
key <- out$usageKey
out[c('scientificName', 'usageKey')]
{% endhighlight %}



{% highlight text %}
## $scientificName
## [1] "Oncorhynchus mykiss (Walbaum, 1792)"
## 
## $usageKey
## [1] 5204019
{% endhighlight %}

After we've found keys for the species we want, we may want to search for specific datasets (or skip to searching for occurrences).

##### Search for datasets

There are many functions for searching datasets, including

* `dataset_suggest()`
* `dataset_search()`
* `dataset_metrics()`
* `datasets()`
* `installations()`
* `networks()`
* `nodes()`
* `organizations()`

Let's try `dataset_search()`


{% highlight r %}
res <- dataset_search(query = "Oregon State University")
dkey <- 'b8ed9b7c-5b73-4e6d-a6e1-b0911a09f947'
res$data
{% endhighlight %}



{% highlight text %}
##                                                                                                      datasetTitle
## 1 A geographic distribution database of Mononychellus mites (Acari: Tetranychidae) on cassava (Manihot esculenta)
## 2                                                               Oregon State University Herpetological Collection
## 3                                                                             Oregon State Ichthyology Collection
## 4                                                                                       Vascular Plant Collection
##                             datasetKey       type
## 1 785cf038-7b79-4c2f-9e9e-eb940fcd4c0c OCCURRENCE
## 2 02242d2f-b43f-44d1-8e53-4c51af461f5b OCCURRENCE
## 3 b8ed9b7c-5b73-4e6d-a6e1-b0911a09f947 OCCURRENCE
## 4 84aa5ee4-f762-11e1-a439-00145eb45e9a OCCURRENCE
##                                                                    hostingOrganization
## 1 Grupo Interinstitucional para el monitoreo de la biodiversidad en el Valle del Cauca
## 2                                                              Oregon State University
## 3                                                              Oregon State University
## 4                                                              Oregon State University
##                 hostingOrganizationKey
## 1 1ee0beb6-8a8c-4390-9f2b-f76259dd911a
## 2 ac5e8480-3714-11da-bc2e-b8a03c50a862
## 3 ac5e8480-3714-11da-bc2e-b8a03c50a862
## 4 ac5e8480-3714-11da-bc2e-b8a03c50a862
##                                publishingOrganization
## 1 Centro Internacional de Agricultura Tropical (CIAT)
## 2                             Oregon State University
## 3                             Oregon State University
## 4                             Oregon State University
##              publishingOrganizationKey publishingCountry
## 1 fee3882f-5360-4f01-a1ca-767c48fa629c                CO
## 2 ac5e8480-3714-11da-bc2e-b8a03c50a862                US
## 3 ac5e8480-3714-11da-bc2e-b8a03c50a862                US
## 4 ac5e8480-3714-11da-bc2e-b8a03c50a862                US
{% endhighlight %}

We can see OSU in there, with datasetKey's for various collections, which we can use to narrow our search down (you don't have to do this of course). We'll use the Oregon State Ichthyology Collection key.

##### Search for records

* `occ_search()`
* `occ_get()`

There are others, but we'll focus on `occ_seach()`


{% highlight r %}
dat <- occ_search(taxonKey = key, datasetKey = dkey)
{% endhighlight %}

The output object is a data.frame, but has a special print method to display (hopefully) helpful information on what was returned, and a brief data.frame output so that you can quickly inspect data.


### spocc


{% highlight r %}
library("spocc")
{% endhighlight %}

#### Get data

There are many other sources of species occurrence data of course. Working with many sources has overhead in terms of learning new interfaces to each dataset, caveats, data types, taxonomies, etc. Thus, we've been working on a client for working with many sources of species occurrence data - with a single interface to all of them. It's called `spocc`.

`spocc` unifies access to biodiversity data across sources. First, we'll get data from just one resource: `GBIF`.


{% highlight r %}
out <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 50)
out$gbif # GBIF data w/ metadata
{% endhighlight %}



{% highlight text %}
## Species [Accipiter striatus (50)] 
## First 10 rows of [Accipiter_striatus]
## 
##                  name  longitude latitude prov
## 1  Accipiter striatus    0.00000  0.00000 gbif
## 2  Accipiter striatus         NA       NA gbif
## 3  Accipiter striatus -104.88120 21.46585 gbif
## 4  Accipiter striatus  -71.19554 42.31845 gbif
## 5  Accipiter striatus  -78.15051 37.95521 gbif
## 6  Accipiter striatus  -97.80459 30.41678 gbif
## 7  Accipiter striatus  -75.17209 40.34000 gbif
## 8  Accipiter striatus -122.20175 37.88370 gbif
## 9  Accipiter striatus  -99.47894 27.44924 gbif
## 10 Accipiter striatus -135.32701 57.05420 gbif
## ..                ...        ...      ...  ...
## Variables not shown: issues (chr), key (int), datasetKey (chr),
##      publishingOrgKey (chr), publishingCountry (chr), protocol (chr),
##      lastCrawled (chr), lastParsed (chr), extensions (chr), basisOfRecord
##      (chr), sex (chr), establishmentMeans (chr), taxonKey (int),
##      kingdomKey (int), phylumKey (int), classKey (int), orderKey (int),
##      familyKey (int), genusKey (int), speciesKey (int), scientificName
##      (chr), kingdom (chr), phylum (chr), order (chr), family (chr), genus
##      (chr), species (chr), genericName (chr), specificEpithet (chr),
##      taxonRank (chr), continent (chr), stateProvince (chr), year (int),
##      month (int), day (int), eventDate (time), modified (chr),
##      lastInterpreted (chr), references (chr), identifiers (chr), facts
##      (chr), relations (chr), geodeticDatum (chr), class (chr), countryCode
##      (chr), country (chr), startDayOfYear (chr), verbatimEventDate (chr),
##      preparations (chr), institutionID (chr), verbatimLocality (chr),
##      nomenclaturalCode (chr), higherClassification (chr), rights (chr),
##      higherGeography (chr), occurrenceID (chr), type (chr), collectionCode
##      (chr), occurrenceRemarks (chr), gbifID (chr), accessRights (chr),
##      institutionCode (chr), endDayOfYear (chr), county (chr),
##      catalogNumber (chr), otherCatalogNumbers (chr), occurrenceStatus
##      (chr), locality (chr), language (chr), identifier (chr), disposition
##      (chr), dateIdentified (chr), informationWithheld (chr),
##      http...unknown.org.occurrenceDetails (chr), rightsHolder (chr),
##      taxonID (chr), datasetName (chr), recordedBy (chr), identificationID
##      (chr), eventTime (chr), georeferencedDate (chr), georeferenceSources
##      (chr), identifiedBy (chr), identificationVerificationStatus (chr),
##      samplingProtocol (chr), georeferenceVerificationStatus (chr),
##      individualID (chr), locationAccordingTo (chr),
##      verbatimCoordinateSystem (chr), previousIdentifications (chr),
##      georeferenceProtocol (chr), identificationQualifier (chr),
##      dynamicProperties (chr), georeferencedBy (chr), lifeStage (chr),
##      elevation (dbl), elevationAccuracy (dbl)
{% endhighlight %}



{% highlight r %}
out$ebird$data # empty
{% endhighlight %}



{% highlight text %}
## $Accipiter_striatus
## data frame with 0 columns and 0 rows
{% endhighlight %}



{% highlight r %}
out$gbif$meta #  metadata, your query parameters, time the call executed, etc.
{% endhighlight %}



{% highlight text %}
## $source
## [1] "gbif"
## 
## $time
## [1] "2015-07-05 12:19:01 PDT"
## 
## $found
## [1] 447905
## 
## $returned
## [1] 50
## 
## $type
## [1] "sci"
## 
## $opts
## $opts$scientificName
## [1] "Accipiter striatus"
## 
## $opts$limit
## [1] 50
## 
## $opts$fields
## [1] "all"
## 
## $opts$config
## list()
{% endhighlight %}

And you can search across many data sources easily by passing many values to the `from` parameter.


{% highlight r %}
out <- occ(query = 'Accipiter striatus', from = c('gbif', 'ebird'), limit = 50)
{% endhighlight %}

And easily squash together data


{% highlight r %}
df <- occ2df(out)
head(df); tail(df)
{% endhighlight %}



{% highlight text %}
##                 name  longitude latitude prov                date
## 1 Accipiter striatus    0.00000  0.00000 gbif 2014-12-31 23:00:00
## 2 Accipiter striatus         NA       NA gbif 2015-01-06 23:00:00
## 3 Accipiter striatus -104.88120 21.46585 gbif 2015-01-20 23:00:00
## 4 Accipiter striatus  -71.19554 42.31845 gbif 2015-01-22 17:48:59
## 5 Accipiter striatus  -78.15051 37.95521 gbif 2015-01-23 14:30:00
## 6 Accipiter striatus  -97.80459 30.41678 gbif 2015-01-25 16:57:47
##          key
## 1 1064538129
## 2 1065586305
## 3 1065595128
## 4 1065595652
## 5 1065595954
## 6 1065597283
{% endhighlight %}



{% highlight text %}
##                   name longitude latitude  prov                date
## 95  Accipiter striatus -122.2299 37.16132 ebird 2015-07-02 06:42:00
## 96  Accipiter striatus -120.4686 46.56399 ebird 2015-07-02 06:30:00
## 97  Accipiter striatus -122.9198 48.05832 ebird 2015-07-02 06:27:00
## 98  Accipiter striatus -108.9252 46.32603 ebird 2015-07-02 05:00:00
## 99  Accipiter striatus -115.0225 36.10069 ebird 2015-07-01 19:30:00
## 100 Accipiter striatus -122.3741 48.32464 ebird 2015-07-01 19:26:00
##          key
## 95  L2053470
## 96   L452865
## 97  L1406877
## 98  L3764188
## 99   L160294
## 100  L476174
{% endhighlight %}

There's a certain set of global parameters that work for all data resources, but other settings you can still pass separately to each resource. For example:


{% highlight r %}
gopts <- list(country = 'US')
eopts <- list(county = "Alameda county")
(dat <- occ(query = 'Accipiter striatus', from = c('gbif', 'ecoengine'),
    gbifopts = gopts, ecoengineopts = eopts, limit = 100))
{% endhighlight %}



{% highlight text %}
## Searched: gbif, ecoengine
## Occurrences - Found: 387,166, Returned: 122
## Search type: Scientific
##   gbif: Accipiter striatus (100)
##   ecoengine: Accipiter striatus (22)
{% endhighlight %}

#### Make a map

Static map using ggplot2


{% highlight r %}
library("spoccutils")
map_ggplot(dat)
{% endhighlight %}

![plot of chunk unnamed-chunk-15]({{ site.url }}/figure/../figure/unnamed-chunk-15-1.png) 

Static map using base R maps


{% highlight r %}
map_plot(dat)
{% endhighlight %}

![plot of chunk unnamed-chunk-16]({{ site.url }}/figure/../figure/unnamed-chunk-16-1.png) 

Interactive map using leaflet


{% highlight r %}
map_leaflet(dat)
{% endhighlight %}

![leaflet]({{ site.url }}/figure/../figure/leaflet_map.png)

## Exercise 1

Make a map!

1. Pick your favorite single species (or more than one), or favorite taxon group.
2. Search for occurrence data using `spocc` from at least __2__ data sources.
3. Make a map of the occurrence data.




## taxize

When dealing with spatial data, we're often dealing with biological specimens. Whenver that's the case, taxonomic names are a huge area of potential frustration.

`taxize` aims to solve your problems by giving you access to as many taxonomic name datasets as possible, all in one R package.


{% highlight r %}
library("taxize")
{% endhighlight %}


### Identifiers

Here, get Catalogue of Life identifier for the genus *Puma*


{% highlight r %}
(id <- get_colid("Puma", rows = 1))
{% endhighlight %}



{% highlight text %}
## 
## Retrieving data for taxon 'Puma'
{% endhighlight %}



{% highlight text %}
## [1] "abe977b1d27007a76dd12a5c93a637bf"
## attr(,"class")
## [1] "colid"
## attr(,"match")
## [1] "found"
## attr(,"uri")
## [1] "http://www.catalogueoflife.org/col/browse/tree/id/abe977b1d27007a76dd12a5c93a637bf"
{% endhighlight %}

Then we can pass those ids to other functions that act on those ids without any other input to do other cool things, like:

### Hierarchy of names


{% highlight r %}
classification(id)
{% endhighlight %}



{% highlight text %}
## $abe977b1d27007a76dd12a5c93a637bf
##        name    rank                               id
## 1  Animalia Kingdom 5ede24b0534ebd5e1f552d5b9f874a6a
## 2  Chordata  Phylum 4313bc7637e1fc1feb316a4dea2b668b
## 3  Mammalia   Class 7a4d4854a73e6a4048d013af6416c253
## 4 Carnivora   Order 29ff0553e8930d7e79b3ff4d1a753f62
## 5   Felidae  Family 0d57b790faceb41f2be7029302c5584e
## 6      Puma   Genus abe977b1d27007a76dd12a5c93a637bf
## 
## attr(,"class")
## [1] "classification"
## attr(,"db")
## [1] "col"
{% endhighlight %}

### Downstream names


{% highlight r %}
downstream(id, downto = "species")
{% endhighlight %}



{% highlight text %}
## 
{% endhighlight %}



{% highlight text %}
## $abe977b1d27007a76dd12a5c93a637bf
##                       childtaxa_id    childtaxa_name childtaxa_rank
## 1 0b4c73f8591ab777e49e32be159e3a18     Puma concolor        Species
## 2 755e49d6b2295783fe506662cd4e0516 Puma yagouaroundi        Species
## 
## attr(,"class")
## [1] "downstream"
## attr(,"db")
## [1] "col"
{% endhighlight %}

### Upstream names


{% highlight r %}
upstream(id, upto = "Family")
{% endhighlight %}



{% highlight text %}
## 
{% endhighlight %}



{% highlight text %}
## $Carnivora
##                        childtaxa_id childtaxa_name childtaxa_rank
## 1  2482ee002e750ac7e479ad483c29f724      Ailuridae         Family
## 2  0ab687cded396c710219d1cde6285b73        Canidae         Family
## 3  8d1e51bf59d91cf71210bb50d791f051     Eupleridae         Family
## 4  0d57b790faceb41f2be7029302c5584e        Felidae         Family
## 5  af918888f0c2689cd9c329367352f69e    Herpestidae         Family
## 6  76c296165acfb2fc7a5cd1a4ab2c1f45      Hyaenidae         Family
## 7  c4c0978893386ce3efcc3a3f40919760     Mephitidae         Family
## 8  11af881d91ba17872ac17ef1b21e3cb2     Mustelidae         Family
## 9  3ed4d567aa753266871c5ae89c786e8d    Nandiniidae         Family
## 10 c19e52f82ec72f2f172f7f374c20b026     Odobenidae         Family
## 11 859c36b0482060aad08ee7d45de4e773      Otariidae         Family
## 12 ad79012f4d50aa8396d3ffd46562000e       Phocidae         Family
## 13 7a076b0b0a10935f82a1799f5f6d5efd    Procyonidae         Family
## 14 6a840bb14ed245e5565e7d9f78a6f7d0        Ursidae         Family
## 15 7c35698b7c4859db5a3008e59d100f75     Viverridae         Family
## 
## attr(,"class")
## [1] "upstream"
## attr(,"db")
## [1] "col"
{% endhighlight %}

### Name synonyms


{% highlight r %}
synonyms("Poa annua", db = "tropicos", rows = 1)
{% endhighlight %}



{% highlight text %}
## 
## Retrieving data for taxon 'Poa annua'
{% endhighlight %}



{% highlight text %}
## $`Poa annua`
##       nameid              scientificname
## 1   25503923                 Aira pumila
## 8   25503925                 Aira pumila
## 9   25513515            Catabrosa pumila
## 16  25513642          Eragrostis infirma
## 20  25521823         Festuca tenuiculmis
## 21  25513728         Megastachya infirma
## 24  50231428              Ochlopoa annua
## 28  25512823              Poa aestivalis
## 39  25538791                  Poa algida
## 40  25512724                  Poa algida
## 48  25550983       Poa annua fo. reptans
## 53  25517736        Poa annua var. annua
## 56  25538823     Poa annua var. aquatica
## 60  50119145    Poa annua var. eriolepis
## 63  25512377      Poa annua var. reptans
## 68  25514155 Poa annua var. rigidiuscula
## 73  25555526            Poa bipollicaris
## 77  25515915            Poa crassinervis
## 79  25561445             Poa hohenackeri
## 81 100391965                 Poa humilis
## 82  25514158                 Poa infirma
## 87  25512725                 Poa meyenii
## 93  50200166                Poa puberula
## 94  25528166                Poa royleana
##                      scientificnamewithauthors  family
## 1                            Aira pumila Pursh Poaceae
## 8                   Aira pumila Vill. ex Trin. Poaceae
## 9     Catabrosa pumila (Pursh) Roem. & Schult. Poaceae
## 16           Eragrostis infirma (Kunth) Steud. Poaceae
## 20                   Festuca tenuiculmis Tovar Poaceae
## 21 Megastachya infirma (Kunth) Roem. & Schult. Poaceae
## 24               Ochlopoa annua (L.) H. Scholz Poaceae
## 28                     Poa aestivalis J. Presl Poaceae
## 39                     Poa algida (Sol.) Rupr. Poaceae
## 40                            Poa algida Trin. Poaceae
## 48  Poa annua fo. reptans (Hausskn.) T. Koyama Poaceae
## 53                       Poa annua var. annua  Poaceae
## 56               Poa annua var. aquatica Asch. Poaceae
## 60           Poa annua var. eriolepis E. Desv. Poaceae
## 63             Poa annua var. reptans Hausskn. Poaceae
## 68      Poa annua var. rigidiuscula L.H. Dewey Poaceae
## 73                    Poa bipollicaris Hochst. Poaceae
## 77                      Poa crassinervis Honda Poaceae
## 79                       Poa hohenackeri Trin. Poaceae
## 81                            Poa humilis Lej. Poaceae
## 82                           Poa infirma Kunth Poaceae
## 87                    Poa meyenii Nees & Meyen Poaceae
## 93                         Poa puberula Steud. Poaceae
## 94                 Poa royleana Nees ex Steud. Poaceae
{% endhighlight %}

### And lots more

We can do alot more with `taxize` - let's dig into an excercise to epxlore the package.

## Exercise 2

Take dirty names, clean them, then get additional taxonomic information, and output a table.

1. Get some taxonomic names - (hint: `names_list()`).
2. Get taxonomic identifiers for the names from a single data source (e.g., NCBI).
3. With the identifiers, get additional data on each taxon.



## Convert to spatial data formats

### sp & friends

`rgdal` has `writeOGR` and `readOGR`. These are your friends for reading and writing spatial data.

#### Convert data.frame to spatial classes

`data.frame` to `SpatialPointsDataFrame` class


{% highlight r %}
library("spocc")
library("sp")
out <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 50)
df <- occ2df(out)
df <- na.omit(df)
df2 <- df
coordinates(df2) <- ~latitude + longitude
df$latitude <- NULL
df$longitude <- NULL
spdf <- SpatialPointsDataFrame(df2, data = df)
head(spdf)
{% endhighlight %}



{% highlight text %}
##             coordinates               name prov                date
## 1                (0, 0) Accipiter striatus gbif 2014-12-31 23:00:00
## 3 (21.46585, -104.8812) Accipiter striatus gbif 2015-01-20 23:00:00
## 4 (42.31845, -71.19554) Accipiter striatus gbif 2015-01-22 17:48:59
## 5 (37.95521, -78.15051) Accipiter striatus gbif 2015-01-23 14:30:00
## 6 (30.41678, -97.80459) Accipiter striatus gbif 2015-01-25 16:57:47
## 7    (40.34, -75.17209) Accipiter striatus gbif 2015-01-11 20:50:25
##          key
## 1 1064538129
## 3 1065595128
## 4 1065595652
## 5 1065595954
## 6 1065597283
## 7 1065588599
{% endhighlight %}

Then you can go from there to lots of other things. For example, use the `SpatialPointsDataFrame` created above to save to a shape file.


{% highlight r %}
library("rgdal")
file <- tempfile()
dir.create("esrishape", showWarnings = FALSE)
writeOGR(spdf, "esrishape/out.shp", "", "ESRI Shapefile")
{% endhighlight %}

### GeoJSON/TopoJSON

`geojsonio` helps you convert R objects to GeoJSON and GeoJSON to nearly any of the `sp` spatial classes by parsing JSON then serializing into spatial classes, and back to GeoJSON (done right now via `rgdal`).

For example, convert a `data.frame` to GeoJSON...

...as an R list


{% highlight r %}
library("geojsonio")
(res <- geojson_list(us_cities[1:2,], lat = 'lat', lon = 'long'))
{% endhighlight %}



{% highlight text %}
## $type
## [1] "FeatureCollection"
## 
## $features
## $features[[1]]
## $features[[1]]$type
## [1] "Feature"
## 
## $features[[1]]$geometry
## $features[[1]]$geometry$type
## [1] "Point"
## 
## $features[[1]]$geometry$coordinates
## [1] -99.74  32.45
## 
## 
## $features[[1]]$properties
## $features[[1]]$properties$name
## [1] "Abilene TX"
## 
## $features[[1]]$properties$country.etc
## [1] "TX"
## 
## $features[[1]]$properties$pop
## [1] "113888"
## 
## $features[[1]]$properties$capital
## [1] "0"
## 
## 
## 
## $features[[2]]
## $features[[2]]$type
## [1] "Feature"
## 
## $features[[2]]$geometry
## $features[[2]]$geometry$type
## [1] "Point"
## 
## $features[[2]]$geometry$coordinates
## [1] -81.52  41.08
## 
## 
## $features[[2]]$properties
## $features[[2]]$properties$name
## [1] "Akron OH"
## 
## $features[[2]]$properties$country.etc
## [1] "OH"
## 
## $features[[2]]$properties$pop
## [1] "206634"
## 
## $features[[2]]$properties$capital
## [1] "0"
## 
## 
## 
## 
## attr(,"class")
## [1] "geo_list"
## attr(,"from")
## [1] "data.frame"
{% endhighlight %}

...as JSON


{% highlight r %}
as.json(res)
{% endhighlight %}



{% highlight text %}
## {"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[-99.74,32.45]},"properties":{"name":"Abilene TX","country.etc":"TX","pop":"113888","capital":"0"}},{"type":"Feature","geometry":{"type":"Point","coordinates":[-81.52,41.08]},"properties":{"name":"Akron OH","country.etc":"OH","pop":"206634","capital":"0"}}]}
{% endhighlight %}

Or directly to JSON


{% highlight r %}
geojson_json(us_cities[1:2,], lat = 'lat', lon = 'long')
{% endhighlight %}



{% highlight text %}
## {"type":"FeatureCollection","features":[{"type":"Feature","geometry":{"type":"Point","coordinates":[-99.74,32.45]},"properties":{"name":"Abilene TX","country.etc":"TX","pop":"113888","capital":"0"}},{"type":"Feature","geometry":{"type":"Point","coordinates":[-81.52,41.08]},"properties":{"name":"Akron OH","country.etc":"OH","pop":"206634","capital":"0"}}]}
{% endhighlight %}

GeoJSON in JSON format is very widely used on the web, so is useful to be familiar with.

## Exercise 3

Part A)

1. Get occurrence data via `rgbif` or `spocc`
2. Creat a single `data.frame` from all occurrence data
3. Create a shapefile with that data.

Part B)

1. Get GeoJSON from somewhere on the web.
2. Read it into R.
3. Convert it to a spatial class, and make a simple plot of the data

