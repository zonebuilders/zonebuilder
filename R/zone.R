#' Generate zones covering a region of interest
#' 
#' This function first divides geographic space into [annuli](https://en.wikipedia.org/wiki/Annulus_(mathematics)) 
#' (concentric 2d rings or 'doughnuts') and then subdivides each annulus
#' into a number of segments.
#' 
#' @param x Region of interest
#' @param point Optional midpoint of the region 
#' @param n_circles Number of rings including the central circle
#' @param n_segments Optional sequence of numbers
#' @param distance Distance  (km)
#' @param distance_growth The rate at which the doughnut ring widths grow (km)
#' @param intersection Not implemented yet
#'
#' @return An `sf` object containing zones covering the region
#' @export
#'
#' @examples
#' data(zb_region)
#' z = zb_zone(zb_region, n_circles = 4)
#' z
#' plot(z, col = 1:nrow(z))
#' z_from_cent = zb_zone(zb_region, point = zb_region_cent, n_circles = 8)
#' plot(z_from_cent, col = 1:nrow(z))
#' zb_region_sf = sf::st_sf(data.frame(n = 1), geometry = zb_region)
#' z = zb_zone(zb_region_sf, n_circles = 3, n_segments = c(1, 4, 8))
#' plot(z) # quadrant not respected 
#' plot(zb_zone(zb_region, n_circles = 6), col = 1:6)
#' plot(zb_zone(zb_region, n_circles = 8), col = 1:8)
#' plot(zb_zone(zb_region, n_circles = 8, distance = 0.1), col = 1:8)
zb_zone = function(x = NULL,
                   point = NULL,
                   n_circles = NULL,
                   # n_segments = c(1, (1:(n_circles - 1)) * 4), # NA
                   n_segments = 12,
                   distance = 1,
                   distance_growth = 1,
                   intersection = TRUE) {
  
  # checks and class coercion    
  # sorry this now appears twice #### ----
  if (is.null(x) && is.null(point)) stop("Please specify either x or point")
  if (is.null(point)) {
    x = sf::st_geometry(x)
    point = sf::st_centroid(x)
  } else {
    point = sf::st_geometry(point)
  }
  # sorry this now appears twice #### ----
  
  # to implement
  # if (sf::st_is_longlat(point)) {
  #   point = stplanr::geo_select_aeq(point)
  #   if (!is.null(x)) x = stplanr::geo_select_aeq(x)
  # }
  
  doughnuts = zb_doughnut(x, point, n_circles, distance, distance_growth)

  n_segments = rep(n_segments, length.out = n_circles)
  n_segments[1] <- 1
  
  segments = lapply(n_segments, zb_segment, x = point)
  
  if(!is.null(x) && intersection) {
    ids = sapply(sf::st_intersects(doughnuts, x), length) > 0
    doughnuts = sf::st_intersection(doughnuts, x)
    segments = segments[ids]
  }
  
  doughnut_segments = do.call(rbind, mapply(function(x, y) {
    if (is.null(y)) {
      x
    } else {
      sf::st_intersection(x, y)
    }
  }, split(doughnuts, 1:nrow(doughnuts)), segments, SIMPLIFY = FALSE))
  
  doughnut_segments
}

# Create zones of equal area (to be documented)
# z = zb_zone(zb_region, n_circles = 8, distance_growth = 0, equal_area = TRUE) # bug with missing pies
# suggestion: split out new new function, reduce n. arguments
# plot(z, col = 1:nrow(z))
zb_zone_equal_area = function(x = NULL,
                   point = NULL,
                   n_circles = NULL,
                   # n_segments = c(1, (1:(n_circles - 1)) * 4), # NA
                   n_segments = 12,
                   distance = 1,
                   distance_growth = 1,
                   intersection = TRUE) {
  # Functions to calculate distances
  n_segments = numbers_of_segments(n_circles = n_circles, distance = distance)
  zb_zone(x, point, n_circles, n_segments, distance, intersection = intersection)
  
}
  