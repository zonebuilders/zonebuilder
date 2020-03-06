remotes::install_github("ropensci/stats19")
library(stats19)
library(dplyr)
library(tmap)
library(tmaptools)
library(sf)

devtools::load_all()

################################################################################
#### STATS19
################################################################################

## downloadsSTATS19 data
years = 2010:2018
crashes_all = get_stats19(years, "accidents", output_format = "sf")
casualties_all = get_stats19(years, "casualties")
crashes_joined = dplyr::inner_join(crashes_all, casualties_all)

## sf object of killed and seriously injured (ksi) cyclists
ksi_cycl = crashes_joined %>% 
  mutate(hour = as.numeric(substr(time, 1, 2)) + as.numeric(substr(time, 4, 5)) / 60) %>% 
  filter(casualty_type == "Cyclist",
         !(day_of_week %in% c("Saturday", "Sunday")),
         (hour >= 7 & hour <= 9) | (hour >= 16.5 & hour <= 18.5),
         accident_severity %in% c("Fatal", "Serious")) %>%
  mutate(count=1) %>% # dummy variable needed for aggregate
  select(count)


################################################################################
#### ClockBoard zones of 8 UK cities
################################################################################

# Find the major UK cities using geocode OSM
uk_cities = tmaptools::geocode_OSM(c("London", "Birmingham", "Manchester", "Leeds", "Liverpool", "Newcastle", "Sheffield", "Bristol"), as.sf = TRUE) %>% 
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
           km_cycled_per_working_day = segment_length_km * bicycle)
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
  mutate(ksi_yr = count / length(years),
         bkm_yr = (km_cycled_per_working_day / 1e9) * (2*200),
         ksi_bkm = ksi_yr / bkm_yr)

saveRDS(df, file = "data-raw/ksi_bkm_zone.rds")

################################################################################
#### Aux data (needed for plot)
################################################################################

uk = rnaturalearth::ne_countries(scale = 10, country = "United Kingdom", returnclass = "sf")
thames = rnaturalearth::ne_download(scale = 10, type = "rivers_lake_centerlines", returnclass = "sf", category = "physical") %>% 
  filter(name == "Thames")

saveRDS(uk, file = "data-raw/uk.rds")
saveRDS(thames, file = "data-raw/thames.rds")
