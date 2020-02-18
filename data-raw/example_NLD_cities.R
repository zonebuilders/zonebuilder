library(sf)
library(tmap)
library(tmaptools)
library(dplyr)

tmpdir = "~/local/data"
tmpfile = tempfile(tmpdir = tmpdir)

download.file("https://www.cbs.nl/-/media/cbs/dossiers/nederland%20regionaal/wijk-en-buurtstatistieken/wijkbuurtkaart_2018_v2.zip", destfile = tmpfile)


unzip(tmpfile, exdir = tmpdir)

brt = st_read(file.path(tmpdir, "buurt_2018_v2.shp"))

brtsel = brt %>%
  arrange(desc(OAD)) %>% 
  head(1000) %>% 
  st_centroid()


qtm(brtsel, dots.col = "OAD")


gm = st_read(file.path(tmpdir, "gemeente_2018_v2.shp")) %>% 
  filter(AANT_INW > 0)

# 
# library(rnaturalearth)
# 
# cities = rnaturalearth::ne_download(scale = "large", type = "populated_places", returnclass = "sf")
# 
# citiesNLD = cities %>% 
#   filter(SOV_A3 == "NLD")
# NLD_cities = tmaptools::geocode_OSM(as.character(gm$GM_NAAM), as.sf = TRUE)
# usethis::edit_r_environ() "GF_DOWNLOAD_DIRECTORY=~/local/data"

get_geofabrik("netherlands", download_directory = "~/local/data")

cities = get_geofabrik("netherlands", layer = "points", key = "place", value = "city")


cities2 = cities %>% 
  select(name) %>% 
  mutate(name = replace(name, name == "Den Haag", "'s-Gravenhage")) %>% 
  left_join(gm %>% st_drop_geometry() %>% select(AANT_INW, GM_NAAM) %>% mutate(GM_NAAM = as.character(GM_NAAM)), by = c("name" = "GM_NAAM"))



qtm(cities2, symbols.size = "AANT_INW")

zbs = do.call(rbind, lapply(1:nrow(cities2), function(i) {
  ci = cities2[i, ]
  
  # Amsterdam 5, Eindhoven-Rotterdam 4, Roermond-Zeeland 2, others 3 
  nrings = ifelse(ci$AANT_INW < 60000, 2,
           ifelse(ci$AANT_INW < 220000, 3,
           ifelse(ci$AANT_INW < 800000, 4, 5)))
  
  zb = zb_zone(point = ci, n_circles = nrings)
  zb$labelplus = paste(ci$name, zb$label, sep = "_")
  zb
}))

tm_shape(zbs) +
  tm_polygons(col = "circle_id", id = "labelplus") + 
  tm_scale_bar()

sum(cities2$AANT_INW) / sum(gm$AANT_INW)


