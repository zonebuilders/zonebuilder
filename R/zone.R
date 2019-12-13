#' Generate zones covering a study region
#' 
#' This function first divides geographic space into [annuli](https://en.wikipedia.org/wiki/Annulus_(mathematics)) 
#' (concentric 2d rings or 'dohnuts') and then subdivides each annulus
#' into a number of segments.
#' 
#' @param x
#' @param point Optional midpoint of the region 
#' @param n_circles Number of rings including the central circle
#'
#' @return
#' @export
#'
#' @examples
#' point = sf::st_centroid(sz_region)
#' n = 4
#' segments = sz_segment(point, n)
#' plot(segments, col = 1:n)
#' n = 16
#' segments = sz_segment(point, n)
#' plot(segments, col = 1:n) # logo?
sz_segment = function(x, ncol, nrow = NULL, intersection = TRUE) {
  fr_matrix = matrix(sf::st_coordinates(point), ncol = 2)
  angles_deg = seq(0, to = 360, by = 360 / n) + starting_angle
  angles_rad = angles_deg / 180 * pi
  x_coord_to = distance * cos(angles_rad) + fr_matrix[, 1]
  y_coord_to = distance * sin(angles_rad) + fr_matrix[, 2]
  to_matrix = cbind(x_coord_to, y_coord_to)
  to_matrix_next = to_matrix[c(2:nrow(to_matrix), 1), ]
  coord_matrix_list = lapply(1:n, function(x)
    rbind(fr_matrix, to_matrix[x, ], to_matrix_next[x, ], fr_matrix))
  poly_list = lapply(coord_matrix_list, function(x) sf::st_polygon(list(x)))
  sf::st_sfc(poly_list, crs = sf::st_crs(point))
}