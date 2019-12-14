#' Title
#'
#' @param n_segments Number of segments
#' @param starting_angle Starting angle
#' @param distance Distance in metres
#' @inheritParams sz_zone
#'
#' @return An sf object with polygons representing segments dividing up geographic space
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
sz_segment = function(x, n_segments = 4, starting_angle = 0, distance = 100000) {
  fr_matrix = matrix(sf::st_coordinates(x), ncol = 2)
  #angles_deg = seq(0, to = 360, by = 360 / n_segments) + starting_angle
  #angles_rad = angles_deg / 180 * pi
  
  angles_rad <- get_angles(n_segments = n_segments, starting_angle = starting_angle)
  
  x_coord_to = distance * cos(angles_rad) + fr_matrix[, 1]
  y_coord_to = distance * sin(angles_rad) + fr_matrix[, 2]
  to_matrix = cbind(x_coord_to, y_coord_to)
  to_matrix_next = to_matrix[c(2:nrow(to_matrix), 1), ]
  coord_matrix_list = lapply(1:n_segments, function(x)
    rbind(fr_matrix, to_matrix[x, ], to_matrix_next[x, ], fr_matrix))
  poly_list = lapply(coord_matrix_list, function(x) sf::st_polygon(list(x)))
  sf::st_sfc(poly_list, crs = sf::st_crs(x))
}

get_angles <- function(n_segments = 4, starting_angle = 0, angles_mid = TRUE) {
  a = seq(starting_angle, starting_angle + 360, length.out = n_segments + 1)
  if (angles_mid) a = a - (360 / n_segments) / 2
  a / 180 * pi
}

doughnut_areas <- function(n_circles = 10, distance = 1) {
  sapply(1:n_circles, function(i) {
    (pi * ((distance * i) ^ 2)) - (pi * ((distance * (i-1)) ^ 2))
  })
}

numbers_of_segments <- function(n_circles = 10, distance = 1, min_area = 1, max_different_numbers = 3, multiple_of = 4) {
  areas <- doughnut_areas()
  max_segments <- ((areas / min_area) %/% multiple_of) * multiple_of
  max_segments
}


