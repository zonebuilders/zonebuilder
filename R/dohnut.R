#' Title
#' 
#' @inheritParams sz_quadrat
#' @param n Number of doughnuts 
#' @param intersection Intersection with x?
#' @inheritParams sz_zone
#' 
#'
#' @return An sf object containing concentric donuts
#' @export
#'
#' @examples
#' x = sz_region
#' plot(sz_doughnut(x, n = 4))
#' plot(sz_doughnut(x, d = 4))
sz_doughnut = function(x = NULL, point = NULL, n = NULL, distance = 1, intersection = TRUE) {
  
  if (missing(x) && missing(point)) stop("Please specify either x or point")
  if (missing(point)) {
    point = sf::st_centroid(x)
  } else {
    point <- sf::st_geometry(point)
  }
  
  if(is.null(n)) {
    if (is.null(x)) stop("Please specify either x or n (or both)")
    # note: split out into function
    b = sf::st_bbox(x)
    max_dimension = max(c(abs(b[1] - b[3]), abs(b[2] - b[4]))) 
    # / cos(pi / 180 * 45) # add multiplier to account for hypotenuse issue
    n = ceiling(as.numeric(max_dimension) / (1000 * 2 * distance))
  }

  doughnuts = NULL
  # convert to a lapply? Probably not worth it from a speed perspective
  for(i in 1:n) {
    if(i == 1) {
      doughnut_i = sf::st_buffer(point, distance * 1000)
      circle_previous = doughnut_i
    } else {
      circle_i = sf::st_buffer(point, distance * i * 1000)
      doughnut_i = sf::st_difference(
        circle_i,
        circle_previous
        )
      circle_previous = circle_i
    }
    doughnut_i = sf::st_sf(doughnut_i)
    doughnuts = rbind(doughnuts, doughnut_i)
    sf::st_crs(doughnuts) = sf::st_crs(point)
  }
  if(!intersection || missing(x)) {
    return(doughnuts)
  }
  sf::st_sf(geometry = sf::st_intersection(x, doughnuts))
}