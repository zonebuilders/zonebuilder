geo_select_aeq.sf = function (shp) {
  #cent <- sf::st_geometry(shp)
  coords <- sf::st_coordinates(shp)
  coords_mat <- matrix(coords[, 1:2], ncol = 2)
  midpoint <- apply(coords_mat, 2, mean)
  aeqd <- sprintf("+proj=aeqd +lat_0=%s +lon_0=%s +x_0=0 +y_0=0", 
                  midpoint[2], midpoint[1])
  sf::st_crs(aeqd)
}


geo_select_aeq.sfc = function (shp) {
  #cent <- sf::st_geometry(shp)
  coords <- sf::st_coordinates(shp)
  coords_mat <- matrix(coords[, 1:2], ncol = 2)
  midpoint <- apply(coords_mat, 2, mean)
  aeqd <- sprintf("+proj=aeqd +lat_0=%s +lon_0=%s +x_0=0 +y_0=0", 
                  midpoint[2], midpoint[1])
  sf::st_crs(aeqd)
}

geo_select_aeq = function (shp) {
  UseMethod("geo_select_aeq")
}


geo_project = function(shp) {
  crs = geo_select_aeq(shp)
  st_transform(shp, crs = crs)
}
