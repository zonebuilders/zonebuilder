library(tmap)
library(dplyr)
library(terra)
library(stars)
library(maptiles)

data(metro)

ttm()
qtm(metro, symbols.size = "pop2020")

x = c(
"Moscow",
"Istanbul",
"London",
"Paris",
"Rome",
"Berlin",
"Madrid",
"Amsterdam",

"Toronto",
"Boston",
"New York",
"Chicago",
"Los Angeles",

"Mexico City",
"Rio de Janeiro",
"Buenos Aires",
"Bogota",

"Cairo",
"Nairobi",
"Johannesburg",

"Tokyo", 
"Beijing",
"Hong Kong",
"Bangkok",
"Singapore",
"Dubai",
"Delhi",
"Kuala Lumpur",
"Taipei",
"Seoul",

"Sydney")

metrosel = metro[match(x, metro$name), ]

for (iso in metrosel$iso_a3) {
  f = paste0("https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/", toupper(iso), "/", tolower(iso), "_ppp_2020.tif")
  g = paste0("~/local/data/worldpop/", basename(f))
  if (!file.exists(g)) curl::curl_download(url = f, destfile = g)
}

#https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/RUS/rus_ppp_2020.tif



geo = tmaptools::geocode_OSM(x, as.sf = TRUE)
# update cities
geo$point[geo$query == "London"] = st_transform(london_c(), crs = 4326)



## create zones
zns = lapply(seq_len(nrow(geo)), function(i) {
  zonebuilder::zb_zone(geo[i, ], n_circles = 9)
})
names(zns) = x

## download static basemaps
bms_wc = lapply(zns, function(z) {
  maptiles::get_tiles(z, "CartoDB.VoyagerNoLabels", zoom = 9)
#  tm = tmaptools::read_osm(z, zoom = 9, type = 'stamen-watercolor', ext = 1.05)
})




names(bms_wc) = x

tm_shape(bms_wc[[3]]) +
  tm_rgb()


qtm_border = function(shp, width = 2, col = "black", master = FALSE) {
  tm_shape(shp, is.master = master) + 
    tm_borders(lwd = (width * 2) + 1, col = "white") +
  tm_shape(shp) + 
    tm_borders(lwd = width, col = col) 
}


### City admin borders

# Mexico
# source: https://datacatalog.worldbank.org/dataset/mexico-municipalities-2012
mex = read_sf("sandbox/Muni_2012gw.shp")
mex = mex[mex$CVE_ENT == "09", ]
mex = st_union(mex)

m = terra::rast("sandbox/mex_ppp_2020.tif")
mc = crop(m, ext(as(zns$`Mexico City`, "SpatVector")))

tm_shape(mc) +
  tm_raster(style ="kmeans") + 
  qtm_border(mex, col = "purple", width = 3) +
  qtm_border(zns$`Mexico City` %>% filter(circle_id < 10), master = TRUE)



qtm(zns[[1]]) + qtm(mex, fill = NA)

tmap_mode("plot")


tm_shape(bms_wc$`Mexico City`) + tm_rgb() +
  qtm_border(mex, col = "purple", width = 3) +
  qtm_border(zns$`Mexico City` %>% filter(circle_id < 10), master = TRUE)


# Moscow
qtm(bms_wc$`Mexico City`) + 
  qtm_border(zns$`Mexico City`) +
  qtm_border(mex, width = 3, col = "purple")




# Tokyo
qtm(bms_wc[[1]]) + 
qtm_border(zns[[1]])
  
# Moscow
qtm(bms_wc[[2]]) + 
qtm_border(zns[[2]])
  


tmap_mode("view")
qtm(zns[[2]], fill.alpha = 0.2)


qtm(bms_wc$Amsterdam) + 
  qtm_border(zns$Amsterdam)


# London

tm_shape(bms_wc$London) + tm_rgb() +
  qtm_border(london_a(), col = "purple", width = 3) +
  qtm_border(zns$London %>% filter(circle_id < 9), master = TRUE)



a = terra::rast("sandbox/gbr_ppp_2020.tif")
ac = crop(a, ext(as(zns$London, "SpatVector")))

tm_shape(ac) +
  tm_raster(style ="kmeans") + 
qtm_border(london_a(), col = "purple", width = 3) +
  qtm_border(zns$London %>% filter(circle_id < 9), master = TRUE)


### New on CRAN Tweet on 2020-02-19

tmap_mode("view")
tm1 = tm_basemap("CartoDB.PositronNoLabels") +
  qtm_border(london_a(), col = "purple", width = 4) +
  qtm_border(zns$London %>% filter(circle_id < 9), width = 3) +
tm_shape(zns$London %>% filter(circle_id < 9, circle_id > 4)) +
  tm_text("label", size = 1.5) +
tm_shape(zns$London %>% filter(circle_id < 5, circle_id > 2)) +
  tm_text("label", size = 1.2) +
tm_scale_bar()

tm2 = tm_basemap("CartoDB.PositronNoLabels") +
  qtm_border(london_a(), col = "purple", width = 4) +
  qtm_border(zns$London %>% filter(circle_id < 9), width = 3) +
  tm_shape(zns$London %>% filter(circle_id < 9)) +
  tm_text("label", size = 1.5) +
tm_scale_bar()

tm1
tm2
