library(tmap)
library(dplyr)
library(terra)
library(stars)
library(maptiles)
localdir = "~/local/data/worldpop/"


data(metro)
data(World)

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
"Seoul",

"Sydney")

df = metro[match(x, metro$name), ]
df$country_area = World$area[match(df$iso_a3, World$iso_a3)]
df$country_area[is.na(df$country_area)] = 0

df = df[order(df$country_area), c("name", "name_long", "iso_a3", "country_area")]

#################
## Download WorldPop data
#################


df = df %>% 
  mutate(f = paste0("https://data.worldpop.org/GIS/Population/Global_2000_2020_Constrained/2020/BSGM/", iso_a3, "/", tolower(iso_a3), "_ppp_2020_UNadj_constrained.tif"))

for (f in df$f) {
  g = paste0(localdir, basename(f))
  if (!file.exists(g)) {
    tryCatch({
      curl::curl_download(url = f, destfile = g)  
    }, error = function(e) {
      NULL
    })
  }
}

#https://data.worldpop.org/GIS/Population/Global_2000_2020/2020/RUS/rus_ppp_2020.tif
#https://data.worldpop.org/GIS/Population/Global_2000_2020_Constrained/2020/BSGM/GBR/gbr_ppp_2020_UNadj_constrained.tif


#################
## OSM centres
#################

geo = tmaptools::geocode_OSM(df$name, as.sf = TRUE)
# update cities
geo$point[geo$query == "London"] = st_transform(london_c(), crs = 4326)


## check which ones are better: OSM or metro dataset
geo$id = 1:nrow(geo)

qtm(geo, dots.col = "blue", text = "id", text.ymod = 1) + qtm(df, dots.col = "red")

blue_better = c(1, 3, 5, 6, 7, 8, 9, 10, 11, 12, 14,15, 16:30)

df$geometry[blue_better] = geo$point[blue_better]

#################
## Zones
#################

## create zones
zns = lapply(seq_len(nrow(df)), function(i) {
  zonebuilder::zb_zone(df[i, ], n_circles = 10)
})
names(zns) = x


#################
## Background tiles
#################

## download static basemaps
basemaps = lapply(zns, function(z) {
  maptiles::get_tiles(z, "CartoDB.VoyagerNoLabels", zoom = 9)
#  tm = tmaptools::read_osm(z, zoom = 9, type = 'stamen-watercolor', ext = 1.05)
})

#################
## Load worldpop data
#################

popdata = lapply(1:nrow(df), function(i) {
  #if (i==31) browser()
  bn = basename(df$f[i])
  g = file.path(localdir, bn)
  if (file.exists(g)) {
    a1 = terra::rast(g)
    e = ext(as(zns[[i]], "SpatVector"))
    a1 = crop(a1, e)
    
    a1 = expand(a1, e)
    a1[][is.na(a1[]) | is.nan(a1[])] = 0
    
  } else {
    a1 = NULL
  }
  a1
})
#df$has_pop_data = !sapply(popdata, is.null)


#################
## City admin borders
#################
admin = vector(mode = "list", length = nrow(df))
names(admin) = df$name

# Mexico
# source: https://datacatalog.worldbank.org/dataset/mexico-municipalities-2012
mex = read_sf("sandbox/Muni_2012gw.shp")
mex = mex[mex$CVE_ENT == "09", ]
mex = st_union(mex)
admin$`Mexico City` = mex

# London
admin$London = london_a()

# Amsterdam
data("NLD_muni")
ams = sf::st_transform(NLD_muni$geometry[which(NLD_muni$name == "Amsterdam")], crs = 4326)
admin$Amsterdam = ams

# Bangkok
#https://data.humdata.org/dataset/thailand-administrative-boundaries

bk = st_read("sandbox/bangkok/tha_admbnda_adm1_rtsd_20190221.shp") %>% 
  filter(ADM1_EN == "Bangkok")
admin$Bangkok = bk

#Berlin
#https://daten.gdz.bkg.bund.de/produkte/vg/vg250_ebenen_0101/aktuell/vg250_01-01.geo84.shape.ebenen.zip

bl = st_read("sandbox/berlin/vg250_01-01.geo84.shape.ebenen/vg250_ebenen_0101/VG250_GEM.shp")
bl = bl[which(bl$GEN == "Berlin"),]
admin$Berlin = bl

#Paris
# https://www.data.gouv.fr/en/datasets/arrondissements-1/
pr = st_union(st_read("sandbox/paris/arrondissements.shp"))
admin$Paris = pr


rm(mex, ams, bk, bl, pr)


#################
## Plots
#################

plotdir = "sandbox/plots/"

df$circles = c(5, 6, 5, 7, 9, 
               8, 5, 9, 8, 9, 
               6, 9, 7, 5, 8,
               7, 6, 5, 9, 9,
               9, 6, 9, 8, 6,
               9, 8, 9, 9, 9)

df$circles = 9


# Normalize popdata to people/km2
popdata_norm = lapply(popdata, function(p) {
  #km2 = as.numeric(st_area(tmaptools::bb_poly(st_bbox(p)))) / 1e6
  km2 = sum(area(p, sum = FALSE)[]) / 1e6
  km2_cell = km2 / ncell(p)
  p[] = p[] / km2_cell
  p[][is.na(p[])] = 0
  p
}) 


alldata = as.vector(unlist(lapply(popdata_norm, function(p) {
  p[]
})))

kmeans(alldata, centers = 10)


pquan = t(sapply(popdata_norm, function(p) {
  as.vector(quantile(na.omit(p[])))
}))
colSums(pquan) / 30


brks = c(0, 1000, 2500, 5000, 8000, Inf)
pal = c("#FFFFFF", pals::brewer.blues(4))
acol = pals::alphabet(26)[26]


qtm_border = function(shp, width = 2, col = "black", master = FALSE) {
  tm_shape(shp, is.master = master) + 
    tm_borders(lwd = (width * 2) + 1, col = "white") +
    tm_shape(shp) + 
    tm_borders(lwd = width, col = col) 
}


tml = lapply(match(nms, df$name), function(i) {
  if (df$has_pop_data[i]) {
    tm = tm_shape(popdata_norm[[i]]) + 
      tm_raster(breaks = brks, title = "pop/km2", palette = pal, legend.show = FALSE)
      #tm_raster(style = "kmeans", title = "pop/100m sq")
    
    if (!is.null(admin[[i]])) {
      tm = tm + qtm_border(admin[[i]], col = acol, width = 3)
    }
    
    tm = tm + qtm_border(zns[[i]] %>% filter(circle_id <= df$circles[i]), master = TRUE) + tm_layout(title = df$name[i], frame = FALSE, outer.margins = 0, scale = 0.5, legend.position = c("right", "bottom"))
  } else {
    tm = NULL
  }
  return(tm)
})

tma1 = tmap_arrange(tml[1:15], ncol = 3)
tmap_save(tma1, paste0(plotdir, "cities1_15.png"), width = 1800, height = 3000) 

tma2 = tmap_arrange(tml[16:30], ncol = 3)
tmap_save(tma2, paste0(plotdir, "cities16_30.png"), width = 1800, height = 3000) 


