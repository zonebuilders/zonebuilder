#' Make doughnuts
#' 
#' @inheritParams zb_zone
#'
#' @return An sf object containing concentric donuts
#' @export
#' @examples
#' x = zb_region
#' plot(zb_doughnut(x, n_circles = 4), reset = FALSE)
#' plot(zb_region, add = TRUE)
#' plot(zb_doughnut(x, distance = 4), reset = FALSE)
#' plot(zb_region, add = TRUE)
#' x_point = sf::st_centroid(zb_region)
#' z = zb_doughnut(point = zb_region_cent, n_circles = 4, distance = 1)
#' z
#' plot(z)
zb_doughnut = function(x = NULL, point = NULL, n_circles = NULL, distance = NULL, distance_growth = 1) {
  
  # checks and class coercion    
  if (is.null(x) && is.null(point)) stop("Please specify either x or point")
  if (is(x, "sf")) x = sf::st_geometry(x)
  if (is.null(point)) {
    point = sf::st_centroid(x)
  } else {
    point = sf::st_geometry(point)
  }
  # doughnut-specific checks
  if(is.null(distance)) {
    distance = find_distance_equal_dohnut(x = x, n_circles = n_circles, point = point)
    distance_growth = 0
    message("Set distance to enable distance_growth")
  }
  if(is.null(n_circles)) {
    if (is.null(x)) stop("Please specify either x or n (or both)")
    n_circles = number_of_circles(x, distance, point)
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
