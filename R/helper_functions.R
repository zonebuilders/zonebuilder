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



number_of_circles = function(x, distance) {
  b = sf::st_bbox(x)
  max_dimension = max(c(abs(b[1] - b[3]), abs(b[2] - b[4]))) 
  # / cos(pi / 180 * 45) # add multiplier to account for hypotenuse issue
  ceiling(as.numeric(max_dimension) / (1000 * 2 * distance))
}

numbers_of_segments = function(n_circles = 10, distance = rep(1, n_circles)) {
  areas = doughnut_areas(n_circles = n_circles, distance = distance)
  areas / areas[1]
}
