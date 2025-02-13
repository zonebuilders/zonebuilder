#' Azimuthal Equidistant Projection
#'
#' @title Azimuthal Equidistant Projection
#' @name geo_select_aeq
#' @description Returns a CRS string for an Azimuthal Equidistant projection centered on the midpoint of an sf object's coordinates.
#'
#' @param shp An sf object.
#' @return A CRS string for an Azimuthal Equidistant projection.
#' @export
geo_select_aeq.sf = function (shp) {
  #cent <- sf::st_geometry(shp)
  coords <- sf::st_coordinates(shp)
  coords_mat <- matrix(coords[, 1:2], ncol = 2)
  midpoint <- apply(coords_mat, 2, mean)
  aeqd <- sprintf("+proj=aeqd +lat_0=%s +lon_0=%s +x_0=0 +y_0=0", 
                  midpoint[2], midpoint[1])
  sf::st_crs(aeqd)
}

#' @rdname geo_select_aeq
#' @export
geo_select_aeq.sfc = function (shp) {
  #cent <- sf::st_geometry(shp)
  coords <- sf::st_coordinates(shp)
  coords_mat <- matrix(coords[, 1:2], ncol = 2)
  midpoint <- apply(coords_mat, 2, mean)
  aeqd <- sprintf("+proj=aeqd +lat_0=%s +lon_0=%s +x_0=0 +y_0=0", 
                  midpoint[2], midpoint[1])
  sf::st_crs(aeqd)
}

#' @rdname geo_select_aeq
geo_select_aeq = function (shp) {
  UseMethod("geo_select_aeq")
}


geo_project = function(shp) {
  crs = geo_select_aeq(shp)
  sf::st_transform(shp, crs = crs)
}
