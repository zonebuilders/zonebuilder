## code to prepare the datasets used in this package

library(sf)
library(tidyverse)

london_area = spData::lnd %>% 
  st_transform(27700) %>% 
  st_union()

# identical(london_area, london_area2)
sf::st_crs(london_area) = NA

usethis::use_data(london_area, overwrite = TRUE)

# fix issue with ASCII strings
london_cent = tmaptools::geocode_OSM("london uk", as.sf = TRUE) %>% 
  st_transform(27700) %>% 
  st_geometry()

london_area_centroid = st_centroid(london_area)
plot(london_area)
plot(london_cent, add = TRUE)
plot(london_area_centroid, add = TRUE, col = "red")
sf::st_crs(london_cent) = NA

usethis::use_data(london_cent, overwrite = TRUE)


# Triangular number sequence ----------------------------------------------

n = 100
zb_100_triangular_numbers = cumsum(1:100)
usethis::use_data(zb_100_triangular_numbers)
