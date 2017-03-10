## ----spatialObj,eval=FALSE-----------------------------------------------
## library(sp)
## getClass("Spatial")

## ----spatialObj_gc,echo=FALSE,eval=TRUE----------------------------------
getClass("Spatial")

## ----get_sp_data, eval=FALSE---------------------------------------------
## download.file("http://jwhollister.com/iale_open_science/files/SpatialData.zip",
##                "SpatialData.zip",
##                method="auto",
##                mode="wb")
## unzip("SpatialData.zip",exdir="iale_workshop")

## ----locationData, echo=TRUE, eval=FALSE---------------------------------
## #Our current location (from GoogleEarth) is:
## Loc<-data.frame(lon=-122.68014,lat=45.517564,name='PDXhilton',ID=1)
## 
## #The Coordinate reference system for GoogleEarth is WGS84 Decimal Degrees
## WGS84<-CRS("+proj=longlat +datum=WGS84")  #ESRI GCS_WGS_1984
## 
## #From this we create `sp` object (Spatial Points Data Frame)
## #A SpatialPoints object has the geographic information but no attributes
## LocPt<-SpatialPoints(coordinates(Loc[,-3]),proj4string=WGS84)
## 
## #Let's also create a random polygon around our location
## #coordinates for the polygon
## Poly<-data.frame(Lon=c(-122.683461544862,-122.687996482959,-122.685670328434,
##                        -122.682541408927,-122.678202313853,-122.674828807098,
##                        -122.674485521254,-122.672769412589,-122.675904138992,
##                        -122.674481812434,-122.676631816156,-122.680281068949,
##                        -122.683461544862),
##                  Lat=c(45.5230187040173,45.5195152981109,45.5143352152495,
##                        45.5154464797329,45.512619192088,45.5138738461287,
##                        45.5167150399938,45.5190852959663,45.5192876717319,
##                        45.5216119799917,45.5235316111073,45.5213931392957,
##                        45.5230187040173))
## 
## #create SpatialPolygons Object
## #convert coords to polygon
## p<-Polygon(Poly)
## 
## #add id variable
## p1<- Polygons(list(p), ID=1)
## 
## #create SpatialPolygons object
## LocPoly<- SpatialPolygons(list(p1),proj4string=WGS84)
## 
## #A SpatialPointsDataFrame object has the geographic information plus attributes
## LocPtDF<-SpatialPointsDataFrame(coordinates(Loc[,-3]),Loc,proj4string=WGS84)
## 
## #create SpatialPolygonsDataFrame Object
## #adds field "Info" as an attribute to the polygon.
## LocPolyDF<- SpatialPolygonsDataFrame(LocPoly,
##                                      data.frame(ID=1,
##                                                 Info='PolygonAroundPDXhilton'))
## 
## #write the spatial dataframe objects to shapefiles
## writeOGR(LocPtDF,'iale_workshop','LocPt',
##          driver="ESRI Shapefile",overwrite_layer=TRUE)
## writeOGR(LocPolyDF,'iale_workshop','LocPoly',
##          driver="ESRI Shapefile",overwrite_layer=TRUE)
## 
## #create KML file of locations with the maptools package
## #point
## kmlPoints(LocPtDF,
##           kmlfile='iale_workshop/LocPt.kml',
##           name="Hilton",
##           description=paste("Our Current Location"),
##           icon="http://maps.google.com/mapfiles/kml/paddle/ltblu-stars.png",
##           kmlname="PDXhilton",
##           kmldescription="We R Here")
## 
## #polygon
## kmlPolygon(LocPolyDF,
##           kmlfile='iale_workshop/LocPoly.kml',
##           name="HiltonPoly",
##           description=paste("Random Polygon"),
##           lwd=5,border=2,
##           kmlname="HiltonPoly",
##           kmldescription="We R Here")

## ----readSpatialData-----------------------------------------------------
# Using rgdal command - readOGR - we now read in the shapefiles for our current 
# location in Portland.

#point location
Pt<-readOGR('iale_workshop',"LocPt") 
#Polygon location
Poly<-readOGR('iale_workshop',"LocPoly")

## ----dataView------------------------------------------------------------
#class info for object
class(Pt) 

#storage type
typeof(Pt)

# data structure for object
str(Pt) 

#summary info for object
summary(Pt) 

class(Poly) #class info for object

coordinates(Pt) #coordinates of the point

coordinates(Poly) #coordinates of polygon centroid

#to see the vertices of the Polygon we need to explore the "slots"
slotNames(Poly) #get a list of the "slot" names for the object

Poly@polygons  #will give info on each polygon
      
Poly@bbox #bounding box of object; same as bbox(Poly)
    
Poly@proj4string #coordinate reference system for the object; same as proj4string(Poly)
    
Poly@data #not much here but this is the attribute table

## ----plot_base-----------------------------------------------------------
  plot(Poly)
  plot(Pt,add=TRUE,pch=16,col='orange',cex=3)

## ----plot_ggplot, message=FALSE------------------------------------------
  ggplot(Poly,aes(x=long, y=lat)) + geom_path() + geom_point(data=Pt@data, aes(x=lon, y=lat),shape=16,color='orange',size=8)

## ----plot_ggmap, message=FALSE-------------------------------------------
    #get the image
      map<-ggmap(get_googlemap(center=c(lon=Pt@data$lon,lat=Pt@data$lat),
            zoom=15, #large numbers = larger scale (i.e zoomed in)
            maptype='satellite', #also hybrid/terrain/roadmap
            scale = 2), #resolution scaling, 1 (low) or 2 (high)
            size = c(600, 600), #size of the image to grab
            extent='device', #can also be "normal" etc
            darken = 0) #you can dim the map when plotting on top
    #plot location on the image
      map+geom_point(data=Pt@data, aes(x=lon, y=lat),shape=16,color='orange',size=8)+
        geom_path(data=Poly,aes(x=long, y=lat),size=2,colour='green')

## ----leaflet1, message=FALSE---------------------------------------------
#build the map without "pipes"
  m<-leaflet() #setup map
  m<-addTiles(m) #add open street map data
  m

## ----leaflet2, message=FALSE---------------------------------------------
  m<-addMarkers(m,lng=Pt@data$lon, lat=Pt@data$lat, popup="We R Here")  #add point location
  m

## ----leaflet3, message=FALSE---------------------------------------------
  m<-addPolygons(m,data=Poly, weight=2) #add polygon  
  m

## ----leafletPipe, message=FALSE, eval=TRUE-------------------------------
#or build the map with "pipes"
m <- leaflet() %>% addTiles(group = "OpenStreetMap") %>% 
  addProviderTiles("Stamen.Watercolor",group = "Watercolor") %>% 
  addMarkers(lng=Pt@data$lon, lat=Pt@data$lat, popup="We R Here",group='Pt') %>% 
  addPolygons(data=Poly, weight=2,group='Poly') %>% 
  addLayersControl(baseGroups = c("OpenStreetMap","Watercolor"), 
                 overlayGroups = c("Pt","Poly"))
m

## ----ge, eval=FALSE, message=FALSE---------------------------------------
## shell.exec('LocPt.kml')  #Start GE and add Pt location
## shell.exec('LocPoly.kml') #Now add the Polygon

## ----cropNLCD, message=FALSE, echo=TRUE, eval=FALSE----------------------
## # get the NLCD grid data-to repeat this is time cosuming;
## # the final raster is available on github
## NLCD<-raster('C:/Bryan/EPA/Data/nlcd_2011_landcover_2011_edition_2014_10_10/nlcd_2011_landcover_2011_edition_2014_10_10.img')  #change location to match your directory structure
## 
## #NLCD includes all lower 48 states.  Reduce to bbox(Pt) + 10km
## #reproject Pt to match NLCD
## PtAlb<-spTransform(Pt,CRSobj = CRS(proj4string(NLCD)))
## 
## #define extent based on bbox(PtAlb)+100km
## B<-bbox(PtAlb)
## Add<-10000
## Extent<-c(B[1,1]-Add,B[1,2]+Add,B[2,1]-Add,B[2,2]+Add)
## 
## #Crop NLCD
## NLCDpdx<-crop(NLCD,Extent)
## 
## #add colortable
## #get gex colors from Jeff's miscPackage
## ct <- system.file("extdata/nlcd_lookup.csv", package = "miscPackage")
## ct <- read.csv(ct, stringsAsFactors = FALSE)
## 
## #add colors 1:256
## ctbl <- rep("#000000", 256)
## 
## #update non-NULL colors
## ctbl[ct$code + 1] <- ct$hex
## NLCDpdx@legend@values <- ct$code
## NLCD@legend@colortable <- ctbl
## NLCD@legend@names <- ct$label
## 
## #export cropped NLCD as geotiff
## writeRaster(NLCDpdx, filename="NLCDpdx.tif", format="GTiff", overwrite=TRUE)

## ----dataViewRaster------------------------------------------------------
NLCD<-raster("iale_workshop/NLCDpdx.tif")  #simple read a raster image with the raster package.

slotNames(raster) #get a list of the "slot" names for the object

## ----dataViewRaster1-----------------------------------------------------
table(values(NLCD))

## ----dataViewRaster2-----------------------------------------------------
#Load the look up table
  ct <- "iale_workshop/nlcd_lookup.csv"
  ct <- read.csv(ct, stringsAsFactors = FALSE)
  ct  #view the table

#get the data from the raster
  codes<-data.frame(code=values(NLCD))
#merge with the lookup table
  Values<-merge(codes,ct,by='code',all.x=T)

#Now we can view the data
table(Values$label,useNA='ifany')

## ----plotNLCD1, message=FALSE--------------------------------------------
plot(NLCD)

## ----plotNLCD2, message=FALSE--------------------------------------------
plot(NLCD)
plot(Pt,add=T,pch=4,col='white',cex=1.5,lwd=2) 
plot(Poly,add=T,lwd=3,col=NA,border='black')

## ----proj4---------------------------------------------------------------
  #Coordinate reference system for the raster
    proj4string(NLCD)
#Coordinate reference system for point location
    proj4string(Pt)
#Coordinate reference system for polygon location
    proj4string(Poly)

## ----reproject-----------------------------------------------------------
  #reproject Pt to match NLCD
      PtAlb<-spTransform(Pt,CRSobj = CRS(proj4string(NLCD)))  
  #reproject Polyg to match NLCD
      PolyAlb<-spTransform(Poly,CRSobj = CRS(proj4string(NLCD)))  

## ----plotNLCD3, message=FALSE--------------------------------------------
plot(NLCD)
plot(PtAlb,add=T,pch=4,col='white',cex=1.5,lwd=2) 
plot(PolyAlb,add=T,lwd=3,col=NA,border='black')


## ----legend1, message=FALSE----------------------------------------------
    plot(NLCD)
    plot(PtAlb,add=T,pch=4,col='white',cex=1.5,lwd=2) 
    plot(PolyAlb,add=T,lwd=3,col=NA,border='black')
  #add legend
    legend('topright',ct$label,fill=ct$hex)

## ----analysis------------------------------------------------------------
# Now some simple GISy stuff.  Select, buffer, clip and save
  
#add a buffer around our current location
  bufWidth<-1000 #in meters
  PtBuffer<-gBuffer(PtAlb,width=bufWidth,id=PtAlb[["ID"]])
    #this is a SpatialPolygons object
      class(PtBuffer)
  
#If we want to add attributes later we will need to convert it to a SpatialPolygonsDataFrame.  We'll add the attributes from PtAlb
  PtBuffer<-SpatialPolygonsDataFrame(PtBuffer,PtAlb@data)

#Now we can add data if we want just like any other data frame
  PtBuffer@data$BufferWidthM[1]<-bufWidth

# we can use the crop command to clip the NLCD data to the buffer
  bufNLCD<-crop(NLCD,PtBuffer)

# when we plot the data we notice that the resulting raster is square rather than round as we expected. 
  plot(bufNLCD)

# to limit the NLCD data to the circular buffer we change use a mask to assign the values outside the buffer to NA (missing)
  bufNLCD<-mask(crop(NLCD,PtBuffer),PtBuffer)

# now the shape is correct but we lost the color table
  plot(bufNLCD)

# this will not affect the analysis but it doesn't look right so we can fix it
  bufNLCD@legend@colortable<-NLCD@legend@colortable

# success
  plot(bufNLCD)

#Now calcualte total proportion of each LULC and save to a data.frame
  lulc<-freq(bufNLCD)

#clean it up by removing the NA values
  lulc<-as.data.frame(lulc[!is.na(lulc[,1]),])

#calculate the proportions in each class
  lulc$proportion<-round(lulc$count/sum(lulc$count),3)

# calculate the total area of each class based on 30m x 30m grid cell size
  lulc$areaM2<-lulc$count*30*30

# finally, add the labels
    lulc<-merge(ct,lulc,by.x='code',by.y='value',all.y=TRUE)

# what a surprise, it is mostly developed land around the hotel
    lulc 


