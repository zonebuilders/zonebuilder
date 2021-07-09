# Error in build process:
# https://github.com/zonebuilders/zonebuilder/runs/3009599916#step:9:233

remotes::install_github("mtennekes/tmap")

library(zonebuilder)
library(tmap)
library(sf)
z = zb_zone(london_c(), london_a())
summary(sf::st_is_valid(z))
plot(z)
mapview::mapview(z) # works
qtm(z) # works
tmap_mode("view")
qtm(z)
qtm(sf::st_make_valid(z))
tmap_options(check.and.fix = TRUE)
qtm(z)

zb_view(z)


lnd_a = zonebuilder::london_a()
sf::st_is_valid(lnd_a)
sf::st_is_valid(london_c())


library(zonebuilder)
library(tmap)
library(sf)
z = zb_zone(london_c(), london_a())
summary(sf::st_is_valid(z))
# plot(z)
# mapview::mapview(z) # works
# qtm(z) # works
tmap_mode("view")e
sf::sf_use_s2(use_s2 = FALSE)
qtm(z)

current_s2 = sf::sf_use_s2()
if(current_s2) {
  message("Temporarily setting sf::sf_use_s2(FALSE)")
  sf::sf_use_s2(FALSE)
  # run the operation
  sf::sf_use_s2(TRUE)
}


london_a()

london_area_lonlat = sf::st_transform(sf::st_set_crs(london_area, 27700), 4326)
london_cent_lonlat = sf::st_transform(sf::st_set_crs(london_cent, 27700), 4326)
usethis::use_data(london_area_lonlat)
usethis::use_data(london_cent_lonlat)

# Update the data docs...
file.edit("R/data.R")
