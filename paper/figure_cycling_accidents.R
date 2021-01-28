library(dplyr)
library(tmap)

# download preprocessed data (processing script /data-raw/crashes.R)
df = readRDS(gzcon(url("https://github.com/zonebuilders/zonebuilder/releases/download/0.0.1/ksi_bkm_zone.rds")))
uk = readRDS(gzcon(url("https://github.com/zonebuilders/zonebuilder/releases/download/0.0.1/uk.rds")))
thames = readRDS(gzcon(url("https://github.com/zonebuilders/zonebuilder/releases/download/0.0.1/thames.rds")))

# filter: set zones with less than 10,000 km of cycling per yer to NA
df_filtered = df %>% 
  mutate(ksi_bkm = ifelse((bkm_yr * 1e09) < 2e04, NA, ksi_bkm))

tmap_mode("plot")
(tm = tm_shape(uk) +
  tm_fill(col = "white") +
  tm_shape(df_filtered, is.master = TRUE) +
  tm_polygons("ksi_bkm", breaks = c(0, 1000, 2500, 5000, 7500, 12500), textNA = "Too little cycling", title = "Killed and seriously injured\ncyclists per billion cycled\nkilometers") +
  tm_facets(by = "city", ncol=4) +
  tm_shape(uk) +
  tm_borders(lwd = 1, col = "black", lty = 3) +
  tm_shape(thames) +
  tm_lines(lwd = 1, col = "black", lty = 3) +
  tm_layout(bg.color = "lightblue", legend.outside.size = .23, outer.margins = 0, legend.text.size = .7, legend.title.size = 1, panel.label.size = 1.2))

tmap_save(tm, filename = "paper/figures/cycling_accidents.pdf", width = 5, height = 3, scale = .6)
