#' Title
#' 
#' @inheritParams sq_quadrat
#' @param c
#' @param n Number of dohnuts 
#' @param d Distance between each dohnut ring in km
#'
#' @return
#' @export
#'
#' @examples
#' x = sq_study_region
#' c = sf::st_centroid(x)
#' 
#' plot(sq_dohnut(x, n = 4))
#' plot(sq_dohnut(x, d = 4))
sq_dohnut = function(x, c = sf::st_centroid(x), n = NULL, d = 1, intersection = TRUE) {
  if(is.null(n)) {
    # note: split out into function
    b = sf::st_bbox(x)
    max_dimension = max(c(abs(b[1] - b[3]), abs(b[2] - b[4]))) 
    # / cos(pi / 180 * 45) # add multiplier to account for hypotenuse issue
    n = ceiling(as.numeric(max_dimension) / (1000 * 2 * d))
  }
  dohnuts = NULL
  for(i in 1:n) {
    if(i == 1) {
      dohnut_i = sf::st_buffer(c, d * 1000)
    } else {
      dohnut_i = sf::st_difference(
        sf::st_buffer(c, d * i * 1000),
        sf::st_union(dohnuts)
        )
    }
    dohnut_i = sf::st_sf(dohnut_i)
    dohnuts = rbind(dohnuts, dohnut_i)
  }
  if(!intersection) {
    return(dohnuts)
  }
  sf::st_intersection(x, dohnuts)
}