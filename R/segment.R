#' Make segments
#' 
#' @inheritParams zb_zone
#' 
#' @return An `sf` data frame
#'
#' @export
#' @examples
#' zb_plot(zb_segment(london_c(), london_a()))
zb_segment = function(x = NULL,
                      area = NULL,
                      n_segments = 12,
                      distance = NA) {
  if (is.na(distance)) distance = ifelse(is.null(area), 15, 100) # 15 is the same as default ClockBoard with 5 rings, 100 is chosen to be large enough to cover arae
  zb_zone(x = x, area = area, n_circles = 1, distance = distance, n_segments = n_segments, segment_center = TRUE)
  
}

create_segments = function(x, n_segments = 4, starting_angle = -45, distance = 100000) {
  if (n_segments == 1) return(NULL)
  fr_matrix = matrix(sf::st_coordinates(x), ncol = 2)
  #angles_deg = seq(0, to = 360, by = 360 / n_segments) + starting_angle
  #angles_rad = angles_deg / 180 * pi
  
  angles_rad = get_angles(n_segments = n_segments, starting_angle = starting_angle)
  
  x_coord_to = distance * cos(angles_rad - 0.5 * pi) + fr_matrix[, 1]
  y_coord_to = distance * -sin(angles_rad - 0.5 * pi) + fr_matrix[, 2]
  to_matrix = cbind(x_coord_to, y_coord_to)
  to_matrix_next = to_matrix[c(2:nrow(to_matrix), 1), ]
  coord_matrix_list = lapply(1:n_segments, function(x)
    rbind(fr_matrix, to_matrix[x, ], to_matrix_next[x, ], fr_matrix))
  poly_list = lapply(coord_matrix_list, function(x) sf::st_polygon(list(x)))
  sf::st_sfc(poly_list, crs = sf::st_crs(x))
}



