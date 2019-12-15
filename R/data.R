#' Region representing London in projected coordinate system
#' 
#' `zb_region` and `zb_region_cent` represent the city boundaries and centre point of London, respectively.
#'
#' @note `zb_region` is a projected version of the `lnd` object in the `spDataLarge` package.
#' See the `data-raw` folder in the package's repo to reproduce these datasets
#'
#' @docType data
#' @keywords datasets
#' @name zb_region
#' @aliases zb_region_cent
#' @examples 
#' plot(zb_region, reset = FALSE)
#' plot(zb_region_cent$geometry, add = TRUE)
NULL

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
