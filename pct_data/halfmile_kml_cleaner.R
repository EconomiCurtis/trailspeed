require(XML)
library(httr)
library(dplyr)

#load halfmile's orginal KML dataset (not kmz... unzip the kmz)
data <- xmlParse("C:/Users/OKComputer/Documents/PCT Prep Maps and more/HalfmilePCT2016.kml")
xml_data <- xmlToList(data)

# Debugbing XML -----
# #Line maps of Cal
# names(xml_data[["Document"]][[46]][[3]][[3]][[3]])
# 
# for (i in 1:26){
#   print(i)
#   print((xml_data[["Document"]][[46]][[4]][[3]][[i]][1]))
# }
# xml_data[["Document"]][[46]][[4]][[2]][[5]][1]

 
# Set Up Section maps -------
CA_Sec_A <- xml_data[["Document"]][[46]][[3]][[2]][[3]]
CA_Sec_B <- xml_data[["Document"]][[46]][[3]][[3]][[2]]
CA_Sec_C <- xml_data[["Document"]][[46]][[3]][[4]][[2]]
CA_Sec_D <- xml_data[["Document"]][[46]][[3]][[5]][[2]]
CA_Sec_E <- xml_data[["Document"]][[46]][[3]][[6]][[2]]
CA_Sec_F <- xml_data[["Document"]][[46]][[3]][[7]][[2]]
CA_Sec_G <- xml_data[["Document"]][[46]][[3]][[8]][[2]]

CA_Sec_H <- xml_data[["Document"]][[46]][[4]][[2]][[2]]
CA_Sec_I_Yo <- xml_data[["Document"]][[46]][[4]][[3]][[3]]

PCT_Trip <- list(
  CA_Sec_A,CA_Sec_B,CA_Sec_C,CA_Sec_D,CA_Sec_E,CA_Sec_F,CA_Sec_G,CA_Sec_H,CA_Sec_I_Yo
)

# Create Single Table with all lat-long coordinates ----
PCT_Data <- data.frame()
for (i in PCT_Trip){
  temp <- i
  print(paste0(
    "On ",temp[[1]]
  ))
  
  tempSecDF <- data.frame()
  for (j in 1:length(temp[3]$MultiGeometry)){
    SecCoord <- (temp[3]$MultiGeometry[j]$LineString$coordinates)
    SecCoord <- gsub("\t|\n","",SecCoord)
    SecCoord <- strsplit(SecCoord," ")
    SecCoord <- SecCoord[[1]]
    SecCoord <- data.frame(
      do.call(rbind, strsplit(SecCoord, ",", fixed = T))
    )
    names(SecCoord) <- c("Long","Lat","Alt")
    SecCoord <- SecCoord %>%
      select(Lat, Long, everything()) %>%
      mutate(
        section = as.character(gsub(" ","_",temp[1])),
        Lat = (as.character(Lat)),
        Long = as.character(Long),
        Alt = as.numeric(Alt)
      )
    
    tempSecDF <- bind_rows(
      tempSecDF, 
      SecCoord
    )
  }
  
  PCT_Data <- bind_rows(
    PCT_Data,
    tempSecDF
  )
  
}

# Add distance ===========

# Calculate distance in kilometers between two points
earth.dist <- function (long1, lat1, long2, lat2)
{
  # assumes a spherical earth
  rad <- pi/180
  a1 <- lat1 * rad
  a2 <- long1 * rad
  b1 <- lat2 * rad
  b2 <- long2 * rad
  dlon <- b2 - a2
  dlat <- b1 - a1
  a <- (sin(dlat/2))^2 + cos(a1) * cos(b1) * (sin(dlon/2))^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  R <- 6378.145
  d <- R * c
  

  
  return(d)
}

earth.dist(
  as.numeric(PCT_Data$Long[1:3]),
  as.numeric(PCT_Data$Lat[1:3]),
  as.numeric(PCT_Data$Long[2:4]),
  as.numeric(PCT_Data$Lat[2:4]))

#in kilometers, 
# - times by 0.621371 to miles
# - mult by 3280.84 for feet

PCT_Data <- PCT_Data %>%
  mutate(
    dist_km = earth.dist(
      as.numeric(Long), 
      as.numeric(Lat), 
      as.numeric(lag(Long)), 
      as.numeric(lag(Lat))
      ),
    dist_km = ifelse(is.na(dist_km), 0, dist_km),
    dist_step_ft = dist_km * 3280.84,
    dist_km = cumsum(dist_km),
    dist_mil = dist_km * 0.621371,
    section = as.factor(section)
  )

# Get Elevation Data from GOOGLE ------------
googEl <- function(locs)  {
  # beware, you can only run about 120K of these quiries. 
  # - get key at http://maps.googleapis.com/maps/api/elevation/json
  # - but that is kinda buggy
  # - 2nd choice: run your max queries on a couple different IP addresses... as I did
  
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
# googEl(
#   locs = matrix(
#     c("146.9442", "146.4622", "-36.0736", "-36.0491"),
#     nc = 2
#   )
# )

# Elevation Capture, Testing Setup --------
# PCT_Data_El <- as.data.frame(
#   googEl( 
#     matrix(
#       c(PCT_Data$Long[1:50],
#         PCT_Data$Lat[1:50]),
#       nc = 2
#     )
#   )
# )
# 
# PCT_Data_El <- bind_rows(
#   PCT_Data_El,
#   as.data.frame(
#     googEl( 
#       matrix(
#         c(PCT_Data$Long[1:50],
#           PCT_Data$Lat[1:50]),
#         nc = 2
#       )
#     )
#   )
#   
# )


#PCT_Data_El <- data.frame()
TIME = proc.time()
for (i in seq(117551,nrow(PCT_Data),50)){
     #seq(1201,1400,50)){  
     # seq(1,nrow(PCT_Data),50)){
     # seq(1,150,50)){ 
     # seq(1,nrow(PCT_Data),50)){
  
  Sys.sleep(0.1)
  
  if (i == 158351){
    i_end = nrow(PCT_Data)
  } else (
    i_end = i+49
  )
  
  print(paste0(i, " to ", i_end, "  Time Elapsed: ", round(proc.time() - TIME)[3]))
  
  PCT_Data_El <- bind_rows(
    PCT_Data_El,
    as.data.frame(
      googEl(
        matrix(
          c(PCT_Data$Long[i:i_end],
            PCT_Data$Lat[i:i_end]),
          nc = 2
        )
      )
    )
  )
}
write.csv(
  PCT_Data_El, 
  file = "pct_data/pct_trail_dat.csv"
)


PCT_Data_El_df <- 
  data.frame(PCT_Data_El) %>%
  mutate(
    Lat = as.character(lat),
    Long = as.character(lng),
    elevation = as.numeric(elevation),
    resolution = as.numeric(resolution)
  ) %>%
  select(Lat, Long, elevation, resolution)


PCT_Data_ele <- left_join(
  PCT_Data, 
  PCT_Data_El_df,
  by = c("Lat","Long")
) %>%
  mutate(
    elevation_ft = elevation * 3.28084
  )

PCT_Data_ele <- PCT_Data_ele %>%
  select(
    
  )


write.csv(
  PCT_Data_ele, 
  file = "pct_data/pct_trail_dat.csv"
)

