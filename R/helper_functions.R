get_angles = function(n_segments = 4, starting_angle = 0, angles_mid = TRUE) {
  a = seq(starting_angle, starting_angle + 360, length.out = n_segments + 1)
  if (angles_mid) a = a - (360 / n_segments) / 2
  a / 180 * pi
}

doughnut_areas = function(n_circles = 10, distance = 1) {
  sapply(1:n_circles, function(i) {
    (pi * ((distance * i) ^ 2)) - (pi * ((distance * (i-1)) ^ 2))
  })
}



number_of_circles = function(x, distance) {
  b = sf::st_bbox(x)
  max_dimension = max(c(abs(b[1] - b[3]), abs(b[2] - b[4]))) 
  # / cos(pi / 180 * 45) # add multiplier to account for hypotenuse issue
  ceiling(as.numeric(max_dimension) / (1000 * 2 * distance))
}

numbers_of_segments = function(n_circles = 10, distance = 1, min_area = 1, max_different_numbers = 3, multiple_of = 4) {
  areas = doughnut_areas(n_circles = n_circles, distance = distance)
  max_segments = ((areas / min_area) %/% multiple_of) * multiple_of
  max_segments[1] = 1
  max_segments
}
