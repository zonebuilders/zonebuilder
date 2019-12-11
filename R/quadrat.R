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
#' x = sq_study_region
#' c = sf::st_centroid(sq_study_region)
#' plot(sq_quadrat(x, ncol = 2), col = 2:5)
#' plot(c, add = TRUE, col = "white")
#' plot(sq_quadrat(x, ncol = 3))
#' plot(sq_quadrat(x, ncol = 4))
#' plot(sq_quadrat(x, ncol = 4, intersection = FALSE))
sq_quadrat = function(x, ncol, nrow = NULL, intersection = TRUE) {
  g = sf::st_make_grid(x = x, n = ncol)
  if(!intersection) {
    return(g)
  }
  sf::st_intersection(x, g)
}