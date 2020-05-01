library(tmap)
library(sf)
library(tidyverse)

brt = st_read("~/local/data/buurt_2018_v2.shp")

brt = brt %>% 
  filter(WATER == "NEE") %>% 
  select(BEV_DICHTH) %>% 
  mutate(brt_id = 1L:n(),
         BEV_DICHTH = ifelse(BEV_DICHTH < 0, 0, BEV_DICHTH))

NLD_cities = readRDS(url("https://github.com/zonebuilders/zonebuilder/releases/download/0.0.1/NLD_cities.Rds")) %>% 
  arrange(desc(population))


zbs = do.call(rbind, lapply(1:nrow(NLD_cities), function(i) {
  ci = NLD_cities[i, ]
  
  # Amsterdam 5, Eindhoven-Rotterdam 4, Roermond-Zeeland 2, others 3 
  nrings = ifelse(ci$population < 60000, 2,
                  ifelse(ci$population < 220000, 3,
                         ifelse(ci$population < 800000, 4, 5)))
  
  zb = zb_zone(point = ci, n_circles = nrings) %>% 
    mutate(name = ci$name,
           labelplus = paste(ci$name, label, sep = "_"))
  
  zb
}))




cities = lapply(unique(zbs$name), function(city) {
  x = zbs %>% filter(name == city) %>% 
    mutate(zoneid = 1L:n()) %>% 
    st_transform(28992) %>% 
    sf::st_make_valid() %>% 
    st_cast("MULTIPOLYGON")
  
  x_brt = sf::st_intersection(brt, x) %>% 
    mutate(area = as.numeric(st_area(.)),
           pop = BEV_DICHTH * (area / 10^6))
  
 pop_totals = x_brt %>% 
    st_drop_geometry() %>% 
    group_by(zoneid) %>% 
    summarise(pop = sum(pop))
  
  x %>% left_join(pop_totals, by = "zoneid")
})
names(cities) = unique(zbs$name)

tmap_options(limits = c(facets.view = 10))

tms = lapply(cities[1:10], function(city) {
  tm_shape(city) +
    tm_polygons("pop", convert2density = TRUE, breaks = c(0, 2.5, 5, 7.5, 10, 15, 25)*1000, title = city$name[1])
})

tmap_arrange(tms)


citiesSF = do.call(rbind, cities)

citiesSF$name = factor(citiesSF$name, levels = unique(zbs$name))

tm = tm_shape(citiesSF) +
  tm_polygons("pop", convert2density = TRUE, breaks = c(0, 2.5, 5, 10, 15, 25)*1000, title = "Population per km2") +
  tm_facets(by = "name", ncol = 5)

tmap_save(tm, filename = "Dutch_city_population.png", width = 5, height = 8, scale = 0.75)



