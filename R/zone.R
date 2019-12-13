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
#'
#' @return
#' @export
#'
#' @examples
#' point = sf::st_centroid(sz_region)
#' n_circles = 4
#' segments = sz_segment(point, n)
#' plot(segments, col = 1:n)
#' n = 16
#' segments = sz_segment(point, n)
#' plot(segments, col = 1:n) # logo?
sz_zones = function(x, n_circles,
                    n_segments = c(1, (1:(n_circles - 1)) * 4), # to  update
                    nrow = NULL, intersection = TRUE) {
  dohnuts = sz_dohnut(x = x, n = n_circles)
  for(i in 2:nrow(dohnuts)) {
    segments = 
    dohnut_intersections = s
  }
}