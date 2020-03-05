remotes::install_github("ropensci/stats19")
library(stats19)
library(dplyr)
library(tmap)
library(tmaptools)

years = 2010:2018
crashes_all = get_stats19(years, "accidents", output_format = "sf")
casualties_all = get_stats19(years, "casualties")
crashes_joined = dplyr::inner_join(crashes_all, casualties_all)

##########################################################
#### Perc bike/pedestrians for UK cities
##########################################################

crashes_joined2 = crashes_joined %>% 
  mutate(hour = as.numeric(substr(time, 1, 2)) + as.numeric(substr(time, 4, 5)) / 60) %>% 
  filter(!(day_of_week %in% c("Saturday", "Sunday")),
         (hour >= 7 & hour <= 9) | (hour >= 16.5 & hour <= 18.5),
         accident_severity %in% c("Fatal", "Serious")) %>% 
  mutate(cycl=as.numeric(casualty_type == c("Cyclist")),
         other=1 - cycl) %>% 
  select(cycl, other) #, date, time


## zones: 

# Find the other cities using geocode OSM
uk_cities = tmaptools::geocode_OSM(c("London", "Birmingham", "Manchester", "Leeds", "Liverpool", "Newcastle", "Sheffield", "Bristol"), as.sf = TRUE) %>% 
  sf::st_transform(27700)

# replace London coordinates by london_cent
uk_cities$geometry[[1]] = london_cent[[1]]

# create zones of 5 circles
uk_zones = lapply(1:nrow(uk_cities), function(i) {
  zb_zone(x = uk_cities[i,], n_circles = 5, city = uk_cities$query[i])
})
names(uk_zones) = uk_cities$query

uk_perc_bike = lapply(uk_zones, function(z) {
  aggregate(crashes_joined2, z, FUN = sum) %>% 
    mutate(tot = cycl + other,
           perc_cycl = cycl/tot,
           city = z$city[1],
           circle_id = z$circle_id,
           segment_id = z$segment_id)
})
uk = do.call(rbind, uk_perc_bike)


tm_shape(uk) +
  tm_polygons("cycl", style = "kmeans") +
  tm_facets(by = "city")

tm_shape(uk) +
  tm_polygons("perc_cycl", style = "kmeans") +
tm_facets(by = "city")

#### Process cycling distances
regions = pct::pct_regions$region_name
#> [1] "london"                "greater-manchester"    "liverpool-city-region"
#> [4] "south-yorkshire"       "north-east"            "west-midlands"

uk_cities$region = c("london", "west-midlands", "greater-manchester", "west-yorkshire", "liverpool-city-region", "north-east", "south-yorkshire", "avon")

rnets = lapply(uk_cities$region, function(region) {
  pct::get_pct_rnet(region = region) %>% st_transform(27700)
})

rnets = lapply(rnets, function(rnet) {
  rnet$segment_length = as.numeric(sf::st_length(rnet))
  rnet$m_cycled_per_working_day = rnet$segment_length * rnet$bicycle
  rnet
})


cycled_m_per_zone = mapply(FUN = function(rnet, z) {
  aggregate(rnet["m_cycled_per_working_day"], z, FUN = sum) %>% 
    mutate(km = m_cycled_per_working_day / 1e3,
           city = z$city,
           circle_id = z$circle_id,
           segment_id = z$segment_id)
}, rnets, uk_zones, SIMPLIFY = FALSE)
cycle_dist = do.call(rbind, cycled_m_per_zone)


df = uk %>% 
  left_join(cycle_dist %>% st_drop_geometry(), by = c("city", "circle_id", "segment_id")) %>% 
  mutate(ksi_yr = cycl / length(years),
         bkm_yr = (km / 1e9) * (2*200),
         ksi_bkm_yr = ksi_yr / bkm_yr,
         ksi_bkm_yr = ifelse(bkm_yr < 1e-05, NA, ksi_bkm_yr)) # at least 10,000 km per yer



tmap_mode("plot")
tm_shape(df) +
  tm_polygons("ksi_bkm_yr", breaks = c(0, 1000, 2500, 5000, 7500, 12500), textNA = "Too little cycling") +
  tm_facets(by = "city")

tmap_mode("view")
tm_shape(df) +
  tm_polygons("ksi_bkm_yr", breaks = c(0, 1000, 2500, 5000, 7500, 12500), textNA = "Too little cycling", popup.vars = TRUE)
