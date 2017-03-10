## ----eval=FALSE----------------------------------------------------------
## install.packages("rgdal")
## install.packages(c("rgbif","taxize","geojsonio"))

## ----eval=FALSE----------------------------------------------------------
## devtools::install_github("ropensci/spocc")

## ----eval=FALSE----------------------------------------------------------
## install.packages(c("ggmap","grid","sp","rworldmap","RColorBrewer","httr","leafletR","gistr","maptools"))
## devtools::install_github("ropensci/spoccutils")

## ----eval=FALSE----------------------------------------------------------
## install.packages("spoccutils_0.1.0.tgz", repos = NULL)
## # OR
## install.packages("spoccutils_0.1.0.zip", repos = NULL)

## ------------------------------------------------------------------------
library("rgbif")

## ------------------------------------------------------------------------
name_suggest(q = "Helianthus", limit = 10)

## ------------------------------------------------------------------------
out <- name_backbone(name = "Oncorhynchus mykiss")
key <- out$usageKey
out[c('scientificName', 'usageKey')]

## ------------------------------------------------------------------------
res <- dataset_search(query = "Oregon State University")
dkey <- 'b8ed9b7c-5b73-4e6d-a6e1-b0911a09f947'
res$data

## ------------------------------------------------------------------------
dat <- occ_search(taxonKey = key, datasetKey = dkey)

## ------------------------------------------------------------------------
library("spocc")

## ------------------------------------------------------------------------
out <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 50)
out$gbif # GBIF data w/ metadata
out$ebird$data # empty
out$gbif$meta #  metadata, your query parameters, time the call executed, etc.

## ------------------------------------------------------------------------
out <- occ(query = 'Accipiter striatus', from = c('gbif', 'ebird'), limit = 50)

## ------------------------------------------------------------------------
df <- occ2df(out)
head(df); tail(df)

## ------------------------------------------------------------------------
gopts <- list(country = 'US')
eopts <- list(county = "Alameda county")
(dat <- occ(query = 'Accipiter striatus', from = c('gbif', 'ecoengine'),
    gbifopts = gopts, ecoengineopts = eopts, limit = 100))

## ------------------------------------------------------------------------
library("spoccutils")
map_ggplot(dat)

## ------------------------------------------------------------------------
map_plot(dat)

## ----eval = FALSE--------------------------------------------------------
## map_leaflet(dat)

## ------------------------------------------------------------------------
library("taxize")

## ------------------------------------------------------------------------
(id <- get_colid("Puma", rows = 1))

## ------------------------------------------------------------------------
classification(id)

## ------------------------------------------------------------------------
downstream(id, downto = "species")

## ------------------------------------------------------------------------
upstream(id, upto = "Family")

## ------------------------------------------------------------------------
synonyms("Poa annua", db = "tropicos", rows = 1)

## ------------------------------------------------------------------------
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

## ------------------------------------------------------------------------
library("rgdal")
file <- tempfile()
dir.create("esrishape", showWarnings = FALSE)
writeOGR(spdf, "esrishape/out.shp", "", "ESRI Shapefile")

## ------------------------------------------------------------------------
library("geojsonio")
(res <- geojson_list(us_cities[1:2,], lat = 'lat', lon = 'long'))

## ------------------------------------------------------------------------
as.json(res)

## ------------------------------------------------------------------------
geojson_json(us_cities[1:2,], lat = 'lat', lon = 'long')

