# install.packages("XML")
library(XML)
library(dplyr)
library(RCurl)

# Loading Spot Data -------------
# Save the URL of the xml file in a variable
xml.url <- "https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/0Yqto1SBp1MrHmtmldF3mTYWBRej4cKNC/message.xml"
xData <- getURL(xml.url)

# Use the xmlTreePares-function to parse xml file directly from the web
xmlfile <- xmlParse(xData,asText=T)


# To extract the XML-values from the document, use xmlSApply:

SpotTracker <- xmlfile['//feedMessageResponse//messages//message ']

SpotTracker <- xmlSApply(SpotTracker, function(x) xmlSApply(x, xmlValue))

SpotTracker <- lapply(SpotTracker, FUN = function(node) node %>% as.data.frame() %>% t() %>% as.data.frame() %>%tbl_df()) %>%
  bind_rows()

  
SpotTracker <- SpotTracker %>%
  mutate(
    dateTime = as.Date(dateTime)
  ) %>%
  arrange(dateTime)

# Working with SPOT Data -------------

# Elevation Data
SpotData <- read.csv("pct_data/empirical_SPOT/sample_SpotTracker.csv")

googEl <- function(locs)  {
  require(RJSONIO)
  locstring <- paste(do.call(paste, list(locs[, 2], locs[, 1], sep=',')),
                     collapse='|')
  u <- sprintf('http://maps.googleapis.com/maps/api/elevation/json?locations=%s&sensor=false',
               locstring)
  res <- fromJSON(u)
  out <- t(sapply(res[[1]], function(x) {
    c(x[['location']]['lat'], x[['location']]['lng'], 
      x['elevation'], x['resolution']) 
  }))    
  rownames(out) <- rownames(locs)
  return(out)
}

locs <- matrix(c(146.9442, 146.4622, -36.0736, -36.0491), nc=2)

googEl(m)