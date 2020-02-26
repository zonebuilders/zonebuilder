#' Make doughnuts
#' 
#' @inheritParams zb_zone
#'
#' @return An sf object containing concentric donuts
#' @export
#' @examples
#' x = london_area
#' plot(zb_doughnut(x, n_circles = 4), reset = FALSE)
#' plot(london_area, add = TRUE)
#' z = zb_doughnut(x, distance = 0.5)
#' plot(z, reset = FALSE)
#' plot(london_area, add = TRUE)
#' plot(z[5, ], add = TRUE, col = "red")
#' x_point = sf::st_centroid(london_area)
#' z = zb_doughnut(point = london_cent, n_circles = 4, distance = 4:1)
#' z
#' plot(z)
zb_doughnut = function(x = NULL, point = NULL, n_circles = NULL, distance = NULL, distance_growth = 1) {
  
  called_args = names(match.call(expand.dots = TRUE)[-1])
  
  # checks and class coercion    
  if (is.null(x) && is.null(point)) stop("Please specify either x or point")
  if (is.null(point)) {
    x = sf::st_geometry(x)
    point = sf::st_centroid(x)
  } else {
    if (is.null(x) && is.null(distance)) stop("Please specify x or distance")
    point = sf::st_geometry(point)
  }
  # doughnut-specific checks
  if(is.null(distance)) {
    distance = find_distance_equal_dohnut(x = x, n_circles = n_circles, point = point)
    distance_growth = 0
    if ("distance_growth" %in% called_args)  message("Set distance to enable distance_growth")
  }
  if(is.null(n_circles)) {
    if (is.null(x)) stop("Please specify either x or n (or both)")
    n_circles = number_of_circles(x, distance, distance_growth, point)
  }
  
  if (length(distance) != n_circles) {
    distance = get_distances(distance, distance_growth, n_circles)
  }
  create_rings(sf::st_geometry(point), n_circles, distance)
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
