library(tidyverse)
library(sf)

cities = rnaturalearth::ne_download("large", type = "populated_places", returnclass = "sf")
bristol_midpoint = cities %>% filter(NAME == "Bristol") %>% 
  filter(POP_MAX == max(POP_MAX)) 
mapview::mapview(bristol_midpoint)
bristol_midpoint_aeq = bristol_midpoint %>% 
  st_transform(stplanr::geo_select_aeq(.))
mapview::mapview(bristol_midpoint_aeq)
z = zb_zone(point = bristol_midpoint_aeq, n_circles = 20)
library(tmap)
tmap_mode("view")
qtm(z)
