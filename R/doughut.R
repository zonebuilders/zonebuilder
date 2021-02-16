#' Make doughnuts
#' 
#' @inheritParams zb_zone
#' 
#' @return An `sf` data frame
#' @export
#' @examples
#' zb_plot(zb_doughnut(london_c(), london_a()))
zb_doughnut = function(x = NULL,
                       area = NULL,
                       n_circles = NA,
                       distance = 1,
                       distance_growth = 1) {
  zb_zone(x = x, area = area, n_circles = n_circles, distance = distance, distance_growth = distance_growth, n_segments = 1)

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
