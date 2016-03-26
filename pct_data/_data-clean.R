require(dplyr)


#' from source data:
#' - data points: halfmile 2016 KML
#' - Elevation: #' geocontext.org
#'   http://www.geocontext.org/publ/2010/04/profiler/en/?import=kmz#

FILES <- list.files("pct_data")
for (file in FILES){
  temp <- read.csv(file = paste("pct_data/scr-data/", file, sep = "/"), header = T) %>%
    tbl_df()
  names(temp) <- c("distance_m","elevation_m")
  
  if (file != FILES[1]){
    if(abs(temp$elevation_m[1] - temp.old$elevation_m[nrow(temp.old)]) > 3){
      print("Error, trail mismatch")
      print(file)
    }
  }
  
  file <- gsub(".CSV","",file)
  file <- gsub(".csv","",file)
  write.csv(temp,
            paste("pct_data/", file, ".csv", sep = ""),
            row.names = F
  )
  
  temp.old <- temp
  
}

#only errors have to do with sort issues
rm(temp, temp.old, file, FILES)
