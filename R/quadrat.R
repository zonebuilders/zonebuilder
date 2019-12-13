#' Divide a region into quadrats
#'
#' @param x x 
#' @param ncol ncol 
#' @param nrow nrow
#' @param intersection intersection
#'
#' @return An sf object
#' @export
#'
#' @examples
#' x = sz_region
#' c = sf::st_centroid(sz_region)
#' plot(sz_quadrat(x, ncol = 2), col = 2:5)
#' plot(c, add = TRUE, col = "white")
#' plot(sz_quadrat(x, ncol = 3))
#' plot(sz_quadrat(x, ncol = 4))
#' plot(sz_quadrat(x, ncol = 4, intersection = FALSE))
sz_quadrat = function(x, ncol, nrow = NULL, intersection = TRUE) {
  g = sf::st_make_grid(x = x, n = ncol)
  if(!intersection) {
    return(g)
  }
  sf::st_intersection(x, g)
}