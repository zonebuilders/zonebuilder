## code to prepare the datasets used in this package

library(sf)
library(tidyverse)

zb_region = spData::lnd %>% 
  st_transform(27700) %>% 
  st_union()

# identical(zb_region, zb_region2)

usethis::use_data(zb_region)

zb_region_cent = tmaptools::geocode_OSM("london uk", as.sf = TRUE) %>% 
  st_transform(27700)

zb_region_centroid = st_centroid(zb_region)
plot(zb_region)
plot(zb_region_cent$geometry, add = TRUE)
plot(zb_region_centroid, add = TRUE, col = "red")

usethis::use_data(zb_region_cent)


# Triangular number sequence ----------------------------------------------

n = 100
zb_100_triangular_numbers = cumsum(1:100)
usethis::use_data(zb_100_triangular_numbers)
