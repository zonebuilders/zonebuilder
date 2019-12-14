#' Make doughnut
#' 
#' @inheritParams zb_quadrat
#' @param n Number of doughnuts 
#' @param intersection Intersection with x?
#' @inheritParams zb_zone
#' 
#'
#' @return An sf object containing concentric donuts
#' @export
#'
#' @examples
#' x = zb_region
#' plot(zb_doughnut(x, n = 4))
#' plot(zb_doughnut(x, d = 4))
#' x_point = sf::st_centroid(zb_region)
#' zb_doughnut(point = x_point, n = 4)
create_rings = function(point, n_circles, distance = 1) {
  circles <- lapply((1:n) * distance * 1000, function(d) {
    doughnut_i = sf::st_buffer(point, d)
  })
  
  doughnuts_non_center <- mapply(function(x, y) sf::st_sf(geometry = sf::st_difference(x, y)),
                                 circles[-1], 
                                 circles[-n], 
                                 SIMPLIFY = FALSE)
  
  doughnuts <- do.call(rbind, 
                       c(list(sf::st_sf(geometry = circles[[1]])), 
                         doughnuts_non_center))

  doughnuts  
}
