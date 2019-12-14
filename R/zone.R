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
#' z = sz_zone(sz_region, n_circles = 4)
#' z
#' plot(z, col = 1:nrow(z))
#' z = sz_zone(sz_region, n_circles = 6)
#' plot(z, col = 1:nrow(z))
#' z = sz_zone(sz_region, n_circles = 6, n_segments = rep(12, 6))
#' plot(z, col = 1:nrow(z))
sz_zone = function(x = NULL,
                   point = NULL,
                   n_circles,
                   n_segments = c(1, (1:(n_circles - 1)) * 4), # to  update
                   distance = 1,
                   intersection = TRUE) {
  
  # if(sf::st_is_longlat(x)) # add lat lon checks
  # browser()
  doughnuts = sz_doughnut(x = x, point = point, n = n_circles, distance = distance, intersection = FALSE)
  
  
  doughnut_segments = doughnuts[1, ]
  # i = 2 # for testing
  for(i in 2:nrow(doughnuts)) {
    segments = sz_segment(x = point, n_segments = n_segments[i])
    doughnut_intersections = sf::st_intersection(doughnuts[i, ], segments)
    doughnut_segments = rbind(doughnut_segments, doughnut_intersections)
  }
  if(!is.null(x) && intersection) {
    doughnut_segments = sf::st_intersection(doughnut_segments, x)
  }
  doughnut_segments
}
