remotes::install_github("ropensci/stats19")
library(stats19)
library(dplyr)


london_zones = zb_zone(london_cent, n_circles = 7, city = "London")

crashes_all = get_stats19(2018, "accidents", output_format = "sf")
casualties_all = get_stats19(2018, "casualties")
crashes_joined = dplyr::inner_join(crashes_all, casualties_all)


crashes_bicycle = crashes_joined %>% 
  filter(casualty_type == "Cyclist") %>% 
  mutate(x=1) %>% 
  select(x)



london_bikes = aggregate(crashes_bicycle, london_zones, FUN = sum)


tmap_mode("view")

zb_view(london_zones) +
  tm_shape(london_bikes) + 
#  tm_borders() + 
  tm_bubbles("x")

tm_shape(london_zones) +
tm_polygons("circle_id", palette = "YlOrBr", alpha = .6, legend.show = FALSE) + 
  tm_shape(london_bikes, point.per = "feature") + 
  tm_bubbles("x", border.col = "black")

tmap_mode("plot")

tm_shape(london_zones) +
  tm_polygons("circle_id", palette = "YlOrBr", alpha = .6, legend.show = FALSE) + 
  tm_shape(london_bikes, point.per = "feature") + 
  tm_bubbles("x", border.col = "black")


##########################################################
#### Perc bike/pedestrians for UK cities
##########################################################

crashes_joined2 = crashes_joined %>% 
  mutate(cycl_ped=as.numeric(casualty_type %in% c("Cyclist", "Pedestrian")),
         other=1 - cycl_ped) %>% 
  select(cycl_ped, other)


london_perc_walk_bike = aggregate(crashes_joined2, london_zones, FUN = sum) %>% 
  mutate(tot = cycl_ped + other,
         perc_cycl_ped = cycl_ped/tot,
         city = london_zones$city[1])

uk_cities = tmaptools::geocode_OSM(c("Birmingham", "Manchester", "Leeds", "Liverpool"), as.sf = TRUE) %>% 
  sf::st_transform(27700)

uk_zones = lapply(1:nrow(uk_cities), function(i) {
  zb_zone(x = uk_cities[i,], n_circles = 5, city = uk_cities$query[i])
})


uk_perc_walk_bike = c(list(london_perc_walk_bike), lapply(uk_zones, function(z) {
  aggregate(crashes_joined2, z, FUN = sum) %>% 
    mutate(tot = cycl_ped + other,
           perc_cycl_ped = cycl_ped/tot,
           city = z$city[1])
}))


uk = do.call(rbind, uk_perc_walk_bike)


tm_shape(uk) +
  tm_polygons("perc_cycl_ped") +
tm_facets(by = "city")

tm_shape(uk %>% filter(city !="London")) +
  tm_polygons("tot", convert2density = TRUE) +
  tm_facets(by = "city")




##### Barcelona

# https://opendata-ajuntament.barcelona.cat/data/en/dataset/accidents-persones-gu-bcn
b = readr::read_csv("data-raw/2018_accidents_persones_gu_bcn_.csv")

barc_acc = b %>% 
  st_as_sf(coords = c("Longitud", "Latitud"), crs = 4326) %>% 
  mutate(x=as.numeric(Desc_Tipus_vehicle_implicat %in% c("Bicicleta", "Turisme")),
         y=1-x) %>% 
  select(x,y)

Desc_Tipus_vehicle_implicat

barc_cent = tmaptools::geocode_OSM("Barcelona", as.sf = TRUE)

barc_zones = zb_zone(barc_cent, n_circles = 7)
barc_perc_walk_bike = aggregate(barc_acc, barc_zones, FUN = sum) %>% 
  mutate(z = x/(x+y))


tm1 = qtm(london_perc_walk_bike, fill = "z")
tm2 = qtm(barc_perc_walk_bike, fill = "z")
tmap_arrange(tm1, tm2)




