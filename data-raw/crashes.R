remotes::install_github("ropensci/stats19")
library(stats19)
library(tidyverse)
library(tmap)
library(tmaptools)
library(sf)
library(zonebuilder)

devtools::load_all()

################################################################################
#### STATS19
################################################################################

## downloadsSTATS19 data
years = 2010:2020
# crashes_all = get_stats19(years, "accidents", output_format = "sf") # old way
# crashes_all = purrr::map_dfr(years, get_stats19, type = "accid") # fails as there's no 2010 data
# casualties_all = get_stats19(years, "casualties")
crashes_all = get_stats19(year = 1979, type = "accident")
casualties_all = get_stats19(year = 1979, type = "casualty")
summary(crashes_all$accident_year)
crashes_all_2010 = crashes_all %>% filter(accident_year > 2009)
casualties_all_2010 = casualties_all %>% filter(accident_year > 2009)
crashes_joined = dplyr::inner_join(crashes_all_2010, casualties_all_2010)
# crashes_joined_sf = stats19::format_sf(crashes_joined) # fails
crashes_coords = crashes_joined %>% select(matches("location"))

crashes_joined_sf = crashes_joined %>% 
  mutate(across(location_easting_osgr:location_northing_osgr, .fns = as.numeric)) %>% 
  filter(!is.na(location_easting_osgr)) %>% 
  filter(!is.na(location_northing_osgr)) %>% 
  sf::st_as_sf(coords = c("location_easting_osgr", "location_northing_osgr"), crs = 27700)

## sf object of killed and seriously injured (ksi) cyclists
ksi_cycl = crashes_joined_sf %>% 
  mutate(hour = as.numeric(substr(time, 1, 2)) + as.numeric(substr(time, 4, 5)) / 60) %>% 
  filter(casualty_type == "Cyclist",
         !(day_of_week %in% c("Saturday", "Sunday")),
         (hour >= 7 & hour <= 9) | (hour >= 16.5 & hour <= 18.5),
         accident_severity %in% c("Fatal", "Serious")) %>%
  mutate(count=1) %>% # dummy variable needed for aggregate
  select(count)
saveRDS(ksi_cycl, "ksi_cycl.Rds")

################################################################################
#### ClockBoard zones of 8 UK cities
################################################################################

# Find the major UK cities using geocode OSM
city_names = c("London", "Birmingham", "Manchester", "Leeds", "Liverpool", "Newcastle", "Sheffield", "Bristol")
uk_cities = tmaptools::geocode_OSM(city_names, as.sf = TRUE) %>% 
  sf::st_transform(27700)

# replace London coordinates by london_cent
uk_cities$geometry[[1]] = zonebuilder::london_cent[[1]]

# create zones of 5 circles
uk_zones = lapply(1:nrow(uk_cities), function(i) {
  zb_zone(x = uk_cities[i,], n_circles = 5, city = uk_cities$query[i])
})
names(uk_zones) = uk_cities$query


################################################################################
#### ClockBoard zones of 8 UK cities
################################################################################


#### Process cycling distances
regions = pct::pct_regions$region_name
#> [1] "london"                "greater-manchester"    "liverpool-city-region"
#> [4] "south-yorkshire"       "north-east"            "west-midlands"

uk_cities$region = c("london", "west-midlands", "greater-manchester", "west-yorkshire", "liverpool-city-region", "north-east", "south-yorkshire", "avon")

rnets = lapply(uk_cities$region, function(region) {
  pct::get_pct_rnet(region = region) %>% st_transform(27700) %>% 
    mutate(segment_length_km = as.numeric(sf::st_length(.) / 1e3),
           km_cycled_per_working_day = segment_length_km * bicycle) %>% 
    sf::st_centroid()
})

################################################################################
#### Aggregate ksi and cyling meters to zones 
################################################################################

# Aggregate ksi to zones
ksi_cycl_per_zone = do.call(rbind, lapply(uk_zones, function(z) {
  aggregate(ksi_cycl, z, FUN = sum) %>% 
    mutate(city = z$city,
           circle_id = z$circle_id,
           segment_id = z$segment_id) %>% 
    tidyr::replace_na(list(count = 0))
}))

# Aggregate cycling 
km_per_zone = do.call(rbind, mapply(FUN = function(rnet, z) {
  aggregate(rnet["km_cycled_per_working_day"], z, FUN = sum) %>% 
    mutate(city = z$city,
           circle_id = z$circle_id,
           segment_id = z$segment_id)
}, rnets, uk_zones, SIMPLIFY = FALSE))

# Join and filter
df = ksi_cycl_per_zone %>% 
  left_join(km_per_zone %>% st_drop_geometry(), by = c("city", "circle_id", "segment_id")) %>% 
  mutate(ksi_yr = count / 11,
         bkm_yr = (km_cycled_per_working_day / 1e9) * (2*200),
         ksi_bkm = ksi_yr / bkm_yr)

saveRDS(df, file = "data-raw/ksi_bkm_zone.rds")
plot(df[1:9, ])

# create admin boundary summary

mapview::mapview(uk_zones[[1]])
# recreate this... map of london
pct_zones_df %>% filter(str_detect(lad_name, "Newc")) %>% pull(lad_name) %>% unique()
pct_zones_df %>% filter(str_detect(lad_name, "Brist")) %>% pull(lad_name) %>% unique()
pct_zones_list = lapply(uk_cities$region, function(region) {
  pct::get_pct_zones(region = region, geography = "msoa") %>% st_transform(27700) %>% 
    mutate(
      segment_length_km = as.numeric(sf::st_length(.) / 1e3),
      km_cycled_per_working_day = segment_length_km * bicycle,
      lad_name = str_replace_all(lad_name, pattern = " upon Tyne", replacement = ""),
      lad_name = str_replace_all(lad_name, pattern = ", City of", replacement = "")
      ) 
})
mapview::mapview(pct_zones_list[[1]])
pct_zones_df = do.call(rbind, pct_zones_list)
lad_names = unique(pct_zones_df$lad_name)
setdiff(uk_cities$query, lad_names)
# [1] "London"    "Newcastle" "Bristol"  
intersect(uk_cities$query, lad_names)
uk_cities$query
pct_zones_list[[1]]$lad_name = "London"
# pct_zones_list[[6]]$lad_name = "Newcastle"
# pct_zones_list[[8]]$lad_name = "Bristol"

# Aggregate ksi to zones
ksi_cycl_per_zone = do.call(rbind, lapply(pct_zones_list, function(z) {
  aggregate(ksi_cycl, z, FUN = sum) %>% 
    mutate(city = z$lad_name,
           circle_id = z$circle_id,
           segment_id = z$segment_id) %>% 
    tidyr::replace_na(list(count = 0))
}))

# Aggregate cycling 
km_per_zone = do.call(rbind, mapply(FUN = function(rnet, z) {
  aggregate(rnet["km_cycled_per_working_day"], z, FUN = sum) %>% 
    mutate(city = z$city,
           circle_id = z$circle_id,
           segment_id = z$segment_id)
}, rnets, pct_zones_list, SIMPLIFY = FALSE))

plot(km_per_zone[1:9, ])
plot(ksi_cycl_per_zone[1:9, ])
nrow(km_per_zone)
nrow(ksi_cycl_per_zone)
# Join and filter

ksi_km = cbind(ksi_cycl_per_zone, sf::st_drop_geometry(km_per_zone))
ksi_cycl_per_admin_zone = ksi_km %>% 
  mutate(ksi_yr = count / 11,
         bkm_yr = (km_cycled_per_working_day / 1e9) * (2*200),
         ksi_bkm = ksi_yr / bkm_yr)
table(ksi_cycl_per_admin_zone$city)
ksi_cycl_per_admin_zone = ksi_cycl_per_admin_zone %>% 
  filter(city %in% uk_cities$query)
table(ksi_cycl_per_admin_zone$city)
plot(ksi_cycl_per_admin_zone %>% filter(city == "Leeds")) # looks good!

# # add city name data
# uk_cities_name_only = uk_cities %>% 
#   rename(city = query)
# ksi_cycl_per_admin_zone_joined = sf::st_join(
#   ksi_cycl_per_admin_zone,
#   uk_cities_name_only,
#   join = sf::st_nearest_feature
# )


saveRDS(ksi_cycl_per_admin_zone, "ksi_cycl_per_admin_zone.Rds")
piggyback::pb_upload("ksi_cycl_per_admin_zone.Rds")
piggyback::pb_download_url("ksi_cycl_per_admin_zone.Rds")

################################################################################
#### Aux data (needed for plot)
################################################################################

remotes::install_github("ropensci/rnaturalearthhires")
uk = rnaturalearth::ne_countries(scale = 10, country = "United Kingdom", returnclass = "sf")
thames = rnaturalearth::ne_download(scale = 10, type = "rivers_lake_centerlines", returnclass = "sf", category = "physical") %>% 
  filter(name == "Thames")

saveRDS(uk, file = "data-raw/uk.rds")
saveRDS(thames, file = "data-raw/thames.rds")

