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
#' @param distance Distance between each doughnut ring in km
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
#' z = zb_zone(zb_region, n_circles = 6)
#' plot(z, col = 1:nrow(z))
#' z = zb_zone(zb_region, n_circles = 8)
#' plot(z, col = 1:nrow(z))
#' z = zb_zone(zb_region, n_circles = 8, distance_growth = 0, equal_area = TRUE) # bug with missing pies
#' plot(z, col = 1:nrow(z))
zb_zone = function(x = NULL,
                   point = NULL,
                   n_circles = NULL,
                   # n_segments = c(1, (1:(n_circles - 1)) * 4), # NA
                   n_segments = 12,
                   distance = 1,
                   distance_growth = 1,
                   equal_area = FALSE,
                   intersection = TRUE) {


  # checks    
  if (is.null(x) && is.null(point)) stop("Please specify either x or point")
  if (is.null(point)) {
    point = sf::st_centroid(x)
  } else {
    point = sf::st_geometry(point)
  }
  if (sf::st_is_longlat(point)) {
    point = stplanr::geo_select_aeq(point)
    if (!is.null(x)) x = stplanr::geo_select_aeq(x)
  }
  
  if(is.null(n_circles)) {
    if (is.null(x)) stop("Please specify either x or n (or both)")
    n_circles = number_of_circles(x, distance)
  }
  
  if (length(distance) != n_circles) {
    distance = distance + distance * (0:(n_circles-1)) * distance_growth
  }

  doughnuts = create_rings(point, n_circles, distance)
  
  if (equal_area) {
    n_segments = numbers_of_segments(n_circles = n_circles, distance = distance)
  }
  n_segments = rep(n_segments, length.out = n_circles)
  n_segments[1] <- 1
  
  segments = lapply(n_segments, create_segment, x = point)
  
  if(!is.null(x) && intersection) {
    doughnuts = sf::st_intersection(doughnuts, x)
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

zb_doughnut = function(n_segments = 1, ...) {
}

zb_segment = function(n_circles = 1, ...) {
}
