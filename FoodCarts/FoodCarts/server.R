library(shiny)
library(maptools)
library(dplyr)
library(htmltools)

server <- function(input, output, session) {
  
  #Read in data
  d<-read.csv("FoodCarts.csv",row.names=1)
  
  #Base map
  
  m <- leaflet(d) %>% addTiles() %>% fitBounds(~min(x),~min(y),~max(x),~max(y)) %>% addMarkers(~x,~y,popup=~Name)
  output$mymap <- renderLeaflet(m)
}
