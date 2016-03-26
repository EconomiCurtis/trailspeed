
require(dplyr)


# Helper Functions -----

# Angle Calculator =====
anglclc <- function(op, adj){
  #' Angle Calculator
  #' TOA from SOHCAHTOA
  #' Where Opposite is elevation change
  #' and Adjacent is distance (as crow flies)
  #' returns the degree of that elevation change, from the previous point
  
  0.01 * {( atan(op/adj) * 180) / (pi)}  
}
# anglclc(100,100) # is .45


# Loop to Create Single Data Frame ------

FILES <- list.files("pct_data/scr-data/")
FILES <- grep("csv|CSV", FILES, value = TRUE)
pct_elev <- data.frame()

for (file in FILES){
  
  section = gsub(".csv|.CSV","",file)
  
  temp <- read.csv(file = paste("pct_data/scr-data/", file, sep = "/"), header = T) %>%
    tbl_df() %>%
    arrange(distance_m) %>%
    mutate(
      section  = section,
      dist_chg_m = distance_m - lag(distance_m)
    )
  
  if (file != FILES[1]){
    temp <- temp[-1,]
  }
  
  pct_elev <- bind_rows(
    pct_elev, temp
  )
   
  
}

# Clean Single File ------

pct_elev$dist_chg_m[1] = 0
pct_elev <- pct_elev %>%
  mutate(
    elv_chg_m  = elevation_m - lag(elevation_m),
    slope    = anglclc(elevation_m - lag(elevation_m), dist_chg_m)
    
  )

pct_elev$dist_m <- c(cumsum(pct_elev$dist_chg_m))

pct_elev <- pct_elev %>%
  select(
    dist_m, elevation_m, section, elv_chg_m, dist_chg_m, slope
  ) %>%
  mutate(
    section = as.factor(section)
  )


write.csv(pct_elev,
          "pct_data/pct_elev.csv",
          row.names = F)


# PCT Elevation Review -------


ggplot(
  pct_elev,
  aes(
    x = slope
  )
) +
  geom_histogram(binwidth = 0.005)

ggplot(
  pct_elev,
  aes(
    x = dist_m / 1609.34,
    y = elevation_m
  )
) +
  geom_line() +
  xlab("Miles")
 



