get_angles = function(n_segments = 4, starting_angle = -45, angles_mid = FALSE) {
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
# x = london_area
# point = london_area_midpoint
find_distance_equal_dohnut = function(x, n_circles, point) {
  if(is.null(point)) point = sf::st_centroid(x)
  boundary_points = sf::st_cast(x, "POINT")
  distances_to_points = sf::st_distance(boundary_points, point)
  max_distance = as.numeric(max(distances_to_points)) / 1000
  # / cos(pi / 180 * 45) # add multiplier to account for hypotenuse issue
  max_distance / (n_circles)
}

# get_distances(1, 1, 10)
# get_distances(2, 1, 10)
# get_distances(1, 2, 10)
# get_distances(.1, .1, 10)
get_distances = function(distance, distance_growth, n_circles) {
  distance + (0:(n_circles-1)) * distance_growth
}

# x = london_area
# number_of_circles(x, 1, 1, sf::st_centroid(x))
# number_of_circles(x, 0.1, 0.1, sf::st_centroid(x))
number_of_circles = function(area, distance, distance_growth, x) {
  boundary_points = suppressWarnings(sf::st_cast(area, "POINT"))
  distances_to_points = sf::st_distance(boundary_points, x)
  max_distance = as.numeric(max(distances_to_points)) / 1000
  csdistances = cumsum(get_distances(distance, distance_growth, 100))
  
  which(
    zonebuilder::zb_100_triangular_numbers * distance > max_distance
    )[1] + 1
  # / cos(pi / 180 * 45) # add multiplier to account for hypotenuse issue
}

# distances = function(distance, distance_growth) {
#   
# }

number_of_segments = function(n_circles = 10, distance = rep(1, n_circles)) {
  areas = doughnut_areas(n_circles = n_circles, distance = distance)
  areas / areas[1]
}
