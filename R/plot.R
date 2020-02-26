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
    RColorBrewer::brewer.pal(9, "YlOrBr")[z$circle_id+1]
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
#' @export
zb_plot = function(z, palette = c("rings", "hcl", "dartboard")) {
  palette = match.arg(palette)
  z$color = zb_color(z, palette)
  if (requireNamespace("tmap")) {
    suppressMessages(tmap::tmap_mode("plot"))
    tmap::tm_shape(z, point.per = "unit") + 
      tmap::tm_polygons("color") + 
      tmap::tm_text("label", col = "black", size = "AREA", root = 10)
  } else {
    plot(sf::st_geometry(z), col = z$color)
    co = st_coordinates(st_centroid(z, of_largest_polygon = TRUE))
    text(co[, 1], co[, 2], cex = 0.8, labels = z$label)
  }
}
