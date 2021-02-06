
devtools::load_all()

data(london_area)
data(london_cent)

sf::st_crs(zonebuilder::london_area)

crs1 = sf::st_crs(zonebuilder::london_area)
sf::st_crs(london_area) = 4326
crs2 = sf::st_crs(london_area)

identical(crs1, crs2)
waldo::compare(crs1, crs2)
usethis::use_data(london_area, overwrite = TRUE)

sf::st_crs(london_cent) = 4326
usethis::use_data(london_cent, overwrite = TRUE)

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
  

plot(x1[, "total_pm10"])



london = st_interpolate_aw(x, london_zones, extensive = FALSE)


qtm(london, fill = "total_pm10")


#### London OSM data (e.g. bus stops)

library(tmap)
# load_all("../tmaptools")
# load_all("../tmap")

library(sf)
library(stars)
library(tidyverse)

library(geofabrik)
View(geofabrik_zones) 
get_geofabrik("england", download_directory = "~/local/data")
get_geofabrik("Greater London", download_directory = "~/local/data")

bus_stops = get_geofabrik("Greater London", layer = "points", key = "highway", value = "bus_stop") %>% 
  st_transform(27700) %>% 
  mutate(x=1) %>% 
  select(x)

london = aggregate(bus_stops, london_zones, FUN = sum)


qtm(london, fill = "x")


tm_shape(london) +
  tm_polygons("x", convert2density = TRUE)


## same for Paris
get_geofabrik("Ile-de-France", download_directory = "~/local/data")

paris_bbox = geocode_OSM("Paris", as.sf = TRUE, geometry = "bbox")
paris_cent = st_set_geometry(paris_bbox, "point") %>% st_set_crs(4326)


paris_zones = zb_zone(paris_bbox, point = paris_cent, intersection = FALSE)

paris_bus_stops = get_geofabrik("Ile-de-France", layer = "points", key = "highway", value = "bus_stop") %>% 
  #st_transform(27700) %>% 
  mutate(x=1) %>% 
  select(x)

paris = aggregate(paris_bus_stops, paris_zones, FUN = sum)

tm_shape(paris) +
  tm_polygons("x", convert2density = TRUE)


tmap_arrange(tm_shape(london) + tm_polygons("x", convert2density = TRUE),
             tm_shape(paris) + tm_polygons("x", convert2density = TRUE))


download.file("https://opendata.paris.fr/explore/dataset/arrondissements/download?format=geojson&timezone=Europe/Berlin&use_labels_for_header=true", destfile = "data-raw/france.json")


paris_poly = st_read("data-raw/france.json") %>% 
  st_transform(4326)
# 
# ile_de_france = get_geofabrik("Ile-de-France", layer = "multipolygons", key = "waterway", value = "riverbank")
# 
# 
# table(st_geometry_type(ile_de_france))
# 
# 
# paris_rivers = get_geofabrik("Ile-de-France", layer = "multipolygons", key = "waterway", value = "*", attributes = "waterway") %>% 
#   #st_transform(27700) %>% 
#   mutate(x=1) %>% 
#   select(x) %>% 
#   st_make_valid()
# 
# paris_rivers = get_geofabrik("Ile-de-France", layer = "multipolygons", key = "natural", value = "water", attributes = "natural") %>% 
#   #st_transform(27700) %>% 
#   mutate(x=1) %>% 
#   select(x) %>% 
#   st_make_valid()
# 
# 
# paris_rivers = get_geofabrik("Ile-de-France", layer = "multipolygons", key = "natural", value = "water") %>% 
#   mutate(x=1) %>% 
#   select(x) %>% 
#   st_make_valid()
# 
# 	
# library(osmdata)
# 
# paris_rivers <- opq ("paris") %>%
#   add_osm_feature (key="waterway", value="river") %>%
#   osmdata_sf ()
# 
# 
# library(rnaturalearth)
# 
# rivers = rnaturalearth::ne_download(scale = 10, type = "rivers_lake_centerlines", category = "physical", returnclass = "sf") %>% 
#   st_transform(4326)
# 
# paris_rivers = st_intersection(rivers, paris_poly)


# DOWNLOADED from https://mapcruzin.com/download-shapefile/france-natural-shape.zip
france_rivers = st_read("data-raw/natural.shp") %>% 
  mutate(is_valid = st_is_valid(.)) %>% 
  filter(is_valid, type == "riverbank") %>% 
  st_combine() %>% 
  st_make_valid() %>% 
  st_set_crs(4326)

paris = st_difference(paris_poly, france_rivers)


paris_zones = zb_zone(x = paris, point = paris_cent)


zb_view(paris_zones)
