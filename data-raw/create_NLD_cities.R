library(sf)
library(tmap)
library(tmaptools)
library(dplyr)

data("NLD_muni")

library(geofabrik)
get_geofabrik("netherlands", download_directory = "~/local/data")
cities = get_geofabrik("netherlands", layer = "points", key = "place", value = "city")



# ALTERNATIVE
#
# library(osmdata)
# cities = opq ("netherlands") %>%
#   add_osm_feature(key = "place", value = "city") %>%
#   osmdata_sf()


NLD_cities = cities %>% 
  rename(geometry = '_ogr_geometry_') %>% 
  select(name) %>% 
  mutate(name = replace(name, name == "Den Haag", "'s-Gravenhage")) %>% 
  left_join(NLD_muni %>% st_drop_geometry() %>% select(population, name) %>% mutate(name = as.character(name)), by = c("name" = "name"))


saveRDS(NLD_cities, file = "NLD_cities.rds")

