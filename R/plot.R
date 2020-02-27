#' Generate colors for zones
#' 
#' This function generates colors for zones.
#' 
#' @param z An `sf` object containing zones covering the region
#' @param palette Palette type, one of \code{"hcl"} (a palette based on the HCL color space), \code{"rings"} (a palette which colors the rings using the YlOrBr color brewer palette), \code{"dartboard"} (a palette which resembles a dartboard)
#' @return A vector of colors
#' @export
#' @importFrom RColorBrewer brewer.pal 
#'
#' @examples
#' z = zb_zone(london_area, point = london_cent)
#' zb_color(z)
#' plot(z, col = zb_color(z))
zb_color = function(z, palette = c("rings", "hcl", "dartboard")) {
  palette = match.arg(palette)
  
  if (palette == "hcl") {
    z$h = z$segment_id * 30
    z$l = pmin(10 + z$circle_id * 15, 100)
    z$c = 70 + ((100-z$l) / 80 * 30)
    z$c[z$segment_id == 0] = 0
    
    hcl(h = z$h, c = z$c, l = z$l)
  } else if (palette == "rings") {
    RColorBrewer::brewer.pal(9, "YlOrBr")[pmin(9,z$circle_id+1)]
  } else if (palette == "dartboard") {
    
    z$blackred = ((z$segment_id %% 2) == 0)
    z$blackwhite = ((z$circle_id %% 2) == 0)
    
    ifelse(z$blackred, ifelse(z$blackwhite, "#181818", "#C62627"), ifelse(z$blackwhite, "#EAD0AE", "#0BA158"))

    
  }
}



#' View zones
#' 
#' This function opens an interactive map of the zones
#' 
#' @param z An `sf` object containing zones covering the region
#' @param alpha Alpha transparency, number between 0 (fully transparent) and 1 (not transparent)
#' @param palette Palette type, one of \code{"hcl"} (a palette based on the HCL color space), \code{"rings"} (a palette which colors the rings using the YlOrBr color brewer palette), \code{"dartboard"} (a palette which resembles a dartboard)
#' @export
#' @examples
#' z = zb_zone(london_area, point = london_cent)
#' zb_view(z, palette = "rings")
zb_view = function(z, alpha = 0.4, palette = c("rings", "hcl", "dartboard")) {
  palette = match.arg(palette)
  if (requireNamespace("tmap")) {
    suppressMessages(tmap::tmap_mode("view"))
    tmap::tmap_options(show.messages = FALSE)
    
    z$color = zb_color(z, palette)
    tmap::tm_basemap("OpenStreetMap") +
    tmap::tm_shape(z) + 
      tmap::tm_fill("color", alpha = alpha, id = "label", group = "colors", popup.vars = c("circle_id", "segment_id", "label")) + 
    tmap::tm_shape(z, point.per = "unit") +
      tmap::tm_borders(group = "Borders", col = "black", lwd = 1.5) +
      tmap::tm_text("label", col = "black", size = "circle_id", group = "Labels") +
      tmap::tm_scale_bar()
  } else {
    stop("Please install tmap")
  }
}

#' Plot zones
#' 
#' This function opens a static map of the zones
#' 
#' @param z An `sf` object containing zones covering the region
#' @param palette Palette type, one of \code{"hcl"} (a palette based on the HCL color space), \code{"rings"} (a palette which colors the rings using the YlOrBr color brewer palette), \code{"dartboard"} (a palette which resembles a dartboard)
#' @param text_size Vector of two numeric values that determine the relative text sizes. The first determines the smallest text size and the second one the largest text size. The largest text size is used for the outermost circle, and the smallest for the central circle in case there are 9 or more circles. If there are less circles, the relative text size is larger (see source code for exact method)
#' @param zone_label_thres This number determines in which zones labels are printed, namely each zone for which the relative area size is larger than `zone_label_thres`. 
#' @export
zb_plot = function(z, palette = c("rings", "hcl", "dartboard"), text_size = c(0.3, 1), zone_label_thres = 0.002) {
  palette = match.arg(palette)
  z$color = zb_color(z, palette)
  
  areas = as.numeric(sf::st_area(z))
  areas = areas / sum(areas)
  
  sel = areas > zone_label_thres
  
  cent = sf::st_set_crs(sf::st_set_geometry(z, "centroid"), sf::st_crs(z))

  par(mar=c(.2,.2,.2,.2))
  plot(sf::st_geometry(z), col = z$color, border = "grey40")
  co = st_coordinates(cent[sel,])
  mx = max(z$circle_id[sel])
  cex = seq(text_size[1], text_size[2], length.out = 9)[pmin(9, z$circle_id[sel] + (9-mx))]
  text(co[, 1], co[, 2], cex = cex, labels = z$label[sel])
}
