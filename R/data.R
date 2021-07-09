#' Region representing London in projected coordinate system
#' 
#' `london_a()` and `london_c()` return the city boundaries and centre
#'   point of London, respectively.
#'
#' @note `london_a()`  returns a projected version of `lnd` in `spDataLarge`.
#' See the `data-raw` folder in the package's repo to reproduce these datasets
#' The `lonlat` versions of the data have coordinates in units of degrees.
#'
#' @docType data
#' @keywords datasets
#' @name london_area
#' @aliases london_cent london_c london_a london_cent_lonlat london_area_lonlat
#' @export
#' @examples 
#' plot(london_a(), reset = FALSE)
#' plot(london_c(), add = TRUE)
london_a = function() {
  sf::st_set_crs(zonebuilder::london_area, 27700)
}
#' @rdname london_area
#' @export
london_c = function() {
  sf::st_set_crs(zonebuilder::london_cent, 27700)
}

#' The first 100 triangular numbers
#' 
#' The first 100 in the sequence of [triangular numbers](https://en.wikipedia.org/wiki/Triangular_number)
#' 
#' @note See the `data-raw` folder in the package's repo to reproduce these datasets
#'
#' @docType data
#' @keywords datasets
#' @name zb_100_triangular_numbers
NULL
