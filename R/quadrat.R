#' Title
#'
#' @param x 
#' @param ncol 
#' @param nrow 
#' @param intersection 
#'
#' @return
#' @export
#'
#' @examples
#' x = sz_study_region
#' c = sf::st_centroid(sz_study_region)
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