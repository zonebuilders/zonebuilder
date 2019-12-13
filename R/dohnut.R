#' Title
#' 
#' @inheritParams sz_quadrat
#' @param x Spatial object
#' @param c Center point
#' @param n Number of dohnuts 
#' @param d Distance between each dohnut ring in km
#' @param intersection Intersection with x?
#' 
#'
#' @return
#' @export
#'
#' @examples
#' x = sz_region
#' plot(sz_dohnut(x, n = 4))
#' plot(sz_dohnut(x, d = 4))
sz_dohnut = function(x, c = sf::st_centroid(x), n = NULL, d = 1, intersection = TRUE) {
  if(is.null(n)) {
    # note: split out into function
    b = sf::st_bbox(x)
    max_dimension = max(c(abs(b[1] - b[3]), abs(b[2] - b[4]))) 
    # / cos(pi / 180 * 45) # add multiplier to account for hypotenuse issue
    n = ceiling(as.numeric(max_dimension) / (1000 * 2 * d))
  }
  dohnuts = NULL
  # convert to a lapply? Probably not worth it from a speed perspective
  for(i in 1:n) {
    if(i == 1) {
      dohnut_i = sf::st_buffer(c, d * 1000)
      circle_previous = dohnut_i
    } else {
      circle_i = sf::st_buffer(c, d * i * 1000)
      dohnut_i = sf::st_difference(
        circle_i,
        circle_previous
        )
      circle_previous = circle_i
    }
    dohnut_i = sf::st_sf(dohnut_i)
    dohnuts = rbind(dohnuts, dohnut_i)
    sf::st_crs(dohnuts) = sf::st_crs(x)
  }
  if(!intersection) {
    return(dohnuts)
  }
  sf::st_sf(geometry = sf::st_intersection(x, dohnuts))
}