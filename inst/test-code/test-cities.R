# Aim: test zonebuilder in different cities

library(sf)
library(magrittr)
library(zonebuilder)


# Accra -------------------------------------------------------------------

# devtools::install_github("nowosad/spDataLarge")
region = read_sf("https://github.com/ATFutures/who-data/releases/download/v0.0.5/accra.geojson") %>% 
  st_transform(crs = stplanr::geo_select_aeq(.))

z = zonebuilder::zb_zone(region)
plot(z) 

centrepoint_new = tmaptools::geocode_OSM(q = "Accra", as.sf = TRUE)
centrepoint_aeq = centrepoint_new %>% 
  sf::st_transform(sf::st_crs(region))

plot(region$geometry, reset = FALSE)
plot(centrepoint_aeq, add = TRUE)

za = zb_zone(region, point = centrepoint_aeq)
names(za)
plot(za$geometry)

# Bristol -----------------------------------------------------------------

region = spDataLarge::bristol_zones %>%
  sf::st_transform(stplanr::geo_select_aeq(.)) %>%
  sf::st_union() %>%  # with another dataset
  sf::st_buffer(200)
centrepoint_new = tmaptools::geocode_OSM(q = "Bristol", as.sf = TRUE)
centrepoint_aeq = centrepoint_new %>% 
  sf::st_transform(sf::st_crs(region))

za = zb_zone(bristol2, point = centrepoint_aeq)
names(za)
plot(za$geometry)
