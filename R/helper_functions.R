get_angles = function(n_segments = 4, starting_angle = 0, angles_mid = TRUE) {
  a = seq(starting_angle, starting_angle + 360, length.out = n_segments + 1)
  if (angles_mid) a = a - (360 / n_segments) / 2
  a / 180 * pi
}

doughnut_areas = function(n_circles, distance) {
  csdistance = c(0, cumsum(distance))
  sapply(2:(n_circles+1), function(i) {
    (pi * ((csdistance[i]) ^ 2)) - (pi * ((csdistance[i-1]) ^ 2))
  })
}

# n_circles = 10
# x = zb_region
# point = zb_region_midpoint
find_distance_equal_dohnut = function(x, n_circles, point) {
  if(is.null(point)) point = sf::st_centroid(x)
  boundary_points = sf::st_cast(x, "POINT")
  distances_to_points = sf::st_distance(boundary_points, point)
  max_distance = as.numeric(max(distances_to_points)) / 1000
  # / cos(pi / 180 * 45) # add multiplier to account for hypotenuse issue
  max_distance / (n_circles)
}

# distance = 10
# x = zb_region
# number_of_circles(x, distance)
number_of_circles = function(x, distance, point) {
  if(is.null(point)) point = sf::st_centroid(x)
  boundary_points = sf::st_cast(x, "POINT")
  distances_to_points = sf::st_distance(boundary_points, point)
  max_distance = as.numeric(max(distances_to_points)) / 1000
  which(cumsum(100) * distance > max_distance)[1]
  # / cos(pi / 180 * 45) # add multiplier to account for hypotenuse issue
}

numbers_of_segments = function(n_circles = 10, distance = rep(1, n_circles)) {
  areas = doughnut_areas(n_circles = n_circles, distance = distance)
  areas / areas[1]
}
