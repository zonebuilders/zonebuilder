# Aim: generate figures comparing ClockBoard zoning system with borough zones

##### London PM10

tmpdir = "data-raw"
tmpfile = file.path(tmpdir, "LAEI_2016_Emissions_Summary_GIS.zip")

download.file("https://data.london.gov.uk/download/london-atmospheric-emissions-inventory--laei--2016/0210804b-4945-44ad-ab02-fa087dd4e504/LAEI_2016_Emissions_Summary_GIS.zip", destfile = tmpfile)

unzip(tmpfile, exdir = tmpdir)

library(sf)
library(stars)
library(dplyr)
library(tmap)
library(zonebuilder)

x1 = st_read("data-raw/2. GIS/SHP/Industrial and Comercial/IC_PM10.shp")
x2 = st_read("data-raw/2. GIS/SHP/Domestic and Miscellaneous/DM_PM10.shp")
x3 = st_read("data-raw/2. GIS/SHP/Other Transport/OtherT_PM10.shp")

x1 = x1 %>% 
  mutate(pm10 = ICCDDust16+ICCook16+  ICGasCom16+ICGasLk16+ICLandf16+ ICNRMMC16+ ICNRMMI16+ ICPart116+ ICPart2B16+ICSSWB16+  ICSLFC16+  ICSTW16+   ICWTS16)

x2 = x2 %>% 
  mutate(pm10 = MAcFires16 + MAgric16 + MForest16 + DGasComb16 + DHHGard16 + DFuelCom16 + DWBurn16)

x3 = x3 %>% 
  mutate(pm10 = OTAviat16 + OTCoShip16 + OTFrRail16 + OTPaShip16 + OTPaRail16 + OTSmPrV16)


plot(x1[,"pm10"])
plot(x2[,"pm10"])
plot(x3[,"pm10"])

x = x1 %>% 
  mutate(total_pm10 = pm10 + x2$pm10 + x3$pm10) %>% 
  select(total_pm10)

london_zones_zb = zb_zone(london_c(), n_circles = 8)
london_zones = zb_zone(london_c(), n_circles = 8, area = london_a())
london = st_interpolate_aw(x, london_zones, extensive = FALSE)
london_zb = st_interpolate_aw(x, london_zones_zb, extensive = FALSE)

london_boroughs = st_interpolate_aw(x, sf::st_transform(spData::lnd, crs = sf::st_crs(x)), extensive = FALSE)
brks_pm10 = c(0, 1, 2, 4, 8, 16)
m0 = tm_shape(x) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + 
  tm_layout(title = "A", frame = FALSE)
m0l = tm_shape(x) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", title = expression("PM10 (ug/" * m^3 * ")")) + tm_borders(col = "white", lwd = 0.2) + tm_layout(legend.only = TRUE)
m1 = tm_shape(london_boroughs) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + tm_borders(col = "white", lwd = 0.2) +  
  tm_layout(title = "B", frame = FALSE)
m2 = tm_shape(london_zb) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + tm_borders(col = "white", lwd = 0.2) +  
  tm_layout(title = "C", frame = FALSE)
m3 = tm_shape(london) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + tm_borders(col = "white", lwd = 0.2) +  
  tm_layout(title = "D", frame = FALSE)
tm1 = tmap_arrange(m0l, m0, m1, m2, m3, nrow = 1)
tm1
tmap_save(tm1, filename = "cityscale.png", width = 7, height = 2)
magick::image_read("cityscale.png")
piggyback::pb_upload("cityscale.png")
piggyback::pb_download_url("cityscale.png")
# [1] "https://github.com/zonebuilders/zonebuilder/releases/download/v0.0.2.9000/cityscale.png"

saveRDS(tm1, "tm1.Rds")
piggyback::pb_upload("tm1.Rds")
piggyback::pb_download_url("tm1.Rds")

# Todo: create a grid to show how the concept works for different datasets, e.g. road casualties
lnd_border = sf::st_union(zonebuilder::london_a())
n0 = tm_shape(lnd_border) + tm_borders() + tm_graticules() + tm_layout(title = "Raw data/grid")
# generate borough names
london_boroughs
n1 = tm_shape(london_boroughs) + tm_borders() + tm_layout(title = "Raw data/grid")
n0 = tm_shape(lnd_border) + tm_borders() + tm_graticules() + tm_layout(title = "Raw data/grid")
n0 = tm_shape(lnd_border) + tm_borders() + tm_graticules() + tm_layout(title = "Raw data/grid")

# Bike crashes data:
file.edit("data-raw/crashes.R")

library(stats19)

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

nrow(ksi_cycl)
ksi_cycl_wgs = sf::st_transform(ksi_cycl, 4326)

ksi_boroughs = aggregate(ksi_cycl, london_boroughs, FUN = sum)
ksi_zb = aggregate(ksi_cycl, london_zb, FUN = sum)
ksi_zb_lnd = aggregate(ksi_cycl, london, FUN = sum)

m0 = tm_shape(x) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + 
  tm_layout(title = "A", frame = FALSE)
m0l = tm_shape(x) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", title = "Average PM10\nμg/m^3") + tm_borders(col = "white", lwd = 0.2) + tm_layout(legend.only = TRUE)

m1 = tm_shape(london_boroughs) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + tm_borders(col = "white", lwd = 0.2) +  
  tm_layout(title = "B", frame = FALSE)
m2 = tm_shape(london_zb) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + tm_borders(col = "white", lwd = 0.2) +  
  tm_layout(title = "C", frame = FALSE)
m3 = tm_shape(london) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + tm_borders(col = "white", lwd = 0.2) +  
  tm_layout(title = "D", frame = FALSE)
tm1 = tmap_arrange(m0l, m0, m1, m2, m3, nrow = 1)
tm1


#### London OSM data (e.g. bus stops) - todo...

