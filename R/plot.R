#' Generate a colour palette for zones
#' 
#' This function generates a colour palette for zones, using hcl colour space
#' 
#' @param z An `sf` object containing zones covering the region
#' @return A vector of colours
#' @export
#'
#' @examples
#' z = zb_zone(zb_region, point = zb_region_cent)
#' zb_palette(z)
#' plot(z, col = zb_palette(z))
zb_palette = function(z) {
  z$h = z$segment_id * 30
  z$l = pmin(20 + z$circle_id * 10, 100)
  z$c = 50 + ((100-z$l) / 80 * 50)
  z$c[z$segment_id == 0] = 0

  hcl(h = z$h, c = z$c, l = z$l)
}

#' View zones
#' 
#' This function opens an interactive map of the zones
#' 
#' @param z An `sf` object containing zones covering the region
#' @export
zb_view = function(z) {
  if (requireNamespace("tmap")) {
    suppressMessages(tmap_mode("view"))
    z$color = zb_palette(z)
    tm_shape(z) + 
      tm_fill("color", alpha = .6, id = "label", group = "Colours", popup.vars = c("circle_id", "segment_id", "label")) + 
    tm_shape(z, point.per = "unit") +
      tm_borders(group = "Borders") +
      tm_text("label", col = "black", size = "circle_id", group = "Labels")
  } else {
    stop("Please install tmap")
  }
}

#' Plot zones
#' 
#' This function opens a static map of the zones
#' 
#' @param z An `sf` object containing zones covering the region
#' @export
zb_plot = function(z) {
  z$color = zb_palette(z)
  if (requireNamespace("tmap")) {
    suppressMessages(tmap_mode("plot"))
    tm_shape(z, point.per = "unit") + 
      tm_polygons("color") + 
      tm_text("label", col = "black", size = "AREA", root = 10)
  } else {
    plot(sf::st_geometry(z), col = z$color)
    co = st_coordinates(st_centroid(z, of_largest_polygon = TRUE))
    text(co[, 1], co[, 2], cex = 0.8, labels = z$label)
  }
}
