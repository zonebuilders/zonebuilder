#' Make doughnuts
#' 
#' @inheritParams zb_zone
#'
#' @return An sf object containing concentric donuts
#' @examples
#' x = zb_region
#' plot(zb_doughnut(x, n_circles = 4))
#' plot(zb_doughnut(x, d = 4))
#' x_point = sf::st_centroid(zb_region)
#' zb_doughnut(point = x_point, n = 4)
#' doughnuts = zb_doughnut(point = zb_region_cent, n_circles = 3, distance = 1, distance_growth = 1)
#' plot(doughnuts)
zb_doughnut = function(x, point, n_circles, distance, distance_growth) {
  # doughnut-specific checks
  if(is.null(n_circles)) {
    if (is.null(x)) stop("Please specify either x or n (or both)")
    n_circles = number_of_circles(x, distance)
  }
  
  if (length(distance) != n_circles) {
    distance = distance + distance * (0:(n_circles-1)) * distance_growth
  }
  create_rings(sf::st_geometry(point), n_circles, distance)
}

zb_segment = function(n_circles = 1, ...) {
}

create_rings = function(point, n_circles, distance) {
  csdistance = cumsum(distance)
  circles = lapply(csdistance * 1000, function(d) {
    doughnut_i = sf::st_buffer(point, d)
  })
  
  doughnuts_non_center = mapply(function(x, y) sf::st_sf(geometry = sf::st_difference(x, y)),
                                 circles[-1], 
                                 circles[-n_circles], 
                                 SIMPLIFY = FALSE)
  
  doughnuts = do.call(rbind, 
                       c(list(sf::st_sf(geometry = circles[[1]])), 
                         doughnuts_non_center))

  doughnuts  
}
