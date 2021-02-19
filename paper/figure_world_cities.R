library(tmap)
library(dplyr)

data(metro)

ttm()
qtm(metro, symbols.size = "pop2020")

x = c("Tokio", "Moscow", "London", "Amsterdam", "Sydney", "Cairo", "Nairobi", "Rio de Janeiro", "Buenos Aires", "Bogota", "Boston", "New York City", "Mexico City", "Istanbul", "Beijing", "Paris", "Rome", "Berlin")

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
  tm = tmaptools::read_osm(z, zoom = 9, type = 'stamen-watercolor', ext = 1.05)
})
names(bms_wc) = x



qtm_border = function(shp, width = 2, col = "black") {
  tm_shape(shp) + 
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


qtm(zns[[1]]) + qtm(mex, fill = NA)

tmap_mode("plot")


qtm(bms_wc[[13]]) + 
  tm_shape(zns[[13]]) + 
    #tm_polygons("circle_id", palette = "magma", alpha = 0.3, legend.show = FALSE) + 
    tm_borders(lwd = 2, col = "blue") +
  tm_shape(mex) + tm_borders(lwd = 2, col = "black")


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

qtm(bms_wc$London) + 
  qtm_border(london_a(), col = "purple", width = 3) +
  qtm_border(zns$London %>% filter(circle_id < 9))


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
