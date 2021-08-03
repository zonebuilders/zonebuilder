# Aim: generate figures comparing ClockBoard zoning system with borough zones

##### London PM10

tmpdir = "data-raw"
tmpfile = file.path(tmpdir, "LAEI_2016_Emissions_Summary_GIS.zip")

download.file("https://data.london.gov.uk/download/london-atmospheric-emissions-inventory--laei--2016/0210804b-4945-44ad-ab02-fa087dd4e504/LAEI_2016_Emissions_Summary_GIS.zip", destfile = tmpfile)

unzip(tmpfile, exdir = tmpdir)

library(sf)
library(stars)
library(dplyr)

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
london = st_interpolate_aw(x, london_zones, extensive = FALSE)
london_zb = st_interpolate_aw(x, london_zones_zb, extensive = FALSE)


london_boroughs = st_interpolate_aw(x, sf::st_transform(spData::lnd, crs = sf::st_crs(x)), extensive = FALSE)
brks_pm10 = c(0, 1, 2, 4, 8, 16)
m0 = tm_shape(x) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + tm_borders()
m1 = tm_shape(london) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", title = "Average PM10") + tm_borders()
m2 = tm_shape(london_zb) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + tm_borders()
m3 = tm_shape(london_boroughs) + tm_fill("total_pm10", breaks = brks_pm10, palette = "viridis", legend.show = FALSE) + tm_borders()
tm1 = tmap_arrange(m0, m3, m2, m1)
saveRDS(tm1, "tm1.Rds")
piggyback::pb_upload("tm1.Rds")
piggyback::pb_download_url("tm1.Rds")

#### London OSM data (e.g. bus stops)

