#' Generate zones covering a study region
#' 
#' This function first divides geographic space into [annuli](https://en.wikipedia.org/wiki/Annulus_(mathematics)) 
#' (concentric 2d rings or 'dohnuts') and then subdivides each annulus
#' into a number of segments.
#' 
#' @param x
#' @param point Optional midpoint of the region 
#' @param n_circles Number of rings including the central circle
#' @param n_segments Optional sequence of numbers
#' @param intersection Not implemented yet
#'
#' @return
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
sz_zone = function(x, point = NULL, n_circles,
                    n_segments = c(1, (1:(n_circles - 1)) * 4), # to  update
                    intersection = TRUE) {
  dohnuts = sz_dohnut(x = x, point = point, n = n_circles)
  if (missing(point)) point <- st_centroid(x)
  
  dohnut_segments = dohnuts[1, ]
  # i = 2 # for testing
  for(i in 2:nrow(dohnuts)) {
    segments = sz_segment(x = point, n = n_segments[i])
    dohnut_intersections = sf::st_intersection(dohnuts[i, ], segments)
    dohnut_segments = rbind(dohnut_segments, dohnut_intersections)
  }
  dohnut_segments
}