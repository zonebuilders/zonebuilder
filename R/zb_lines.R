#' Create lines radiating at equal angles from a point
#'
#' @param point Center point
#' @param n Number of lines
#' @param starting_angle Starting angle
#' @param distance Distance
#'
#' @return Objects of class `sfc` containing linestring geometries
#' @export
#'
#' @examples
#' point = sf::st_centroid(london_a())
#' n = 4
#' l = zb_lines(point, n)
#' plot(l)
zb_lines = function(point, n, starting_angle = 45, distance = 100000) {
  fr_matrix = matrix(sf::st_coordinates(point), ncol = 2)
  angles_deg = seq(0, to = 360, by = 360 / n) + starting_angle
  angles_rad = angles_deg / 180 * pi
  x_coord_to = distance * cos(angles_rad) + fr_matrix[, 1]
  y_coord_to = distance * sin(angles_rad) + fr_matrix[, 2]
  to_matrix = cbind(x_coord_to, y_coord_to)
  line_matrix_list = lapply(1:n, function(x) rbind(fr_matrix, to_matrix[x, ]))
  sf::st_sfc(lapply(line_matrix_list, sf::st_linestring), crs = sf::st_crs(point))
}

# test: break up our doughnut

