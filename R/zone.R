#' Generate zones covering a region of interest
#' 
#' This function first divides geographic space into [annuli](https://en.wikipedia.org/wiki/Annulus_(mathematics)) 
#' (concentric 2d rings or 'doughnuts') and then subdivides each annulus
#' into a number of segments.
#' 
#' By default 12 segments are used for each annuli, resulting in a zoning system that can 
#' be used to refer to segments in [clock position](https://en.wikipedia.org/wiki/Clock_position),
#' with 12 representing North, 3 representing East, 6 Sounth and 9 Western segments.
#' 
#' @param x Centre point. Should be an \code{\link[sf:sf]{sf}} or \code{\link[sf:sfc]{sfc}} object containing one point, or a name of a city (which is looked up with OSM geocoding).
#' @param area (optional) Area. Should be an \code{\link[sf:sf]{sf}} or \code{\link[sf:sfc]{sfc}} object containing one (multi) polygon  
#' @param n_circles Number of rings including the central circle. By default 5, unless \code{area} is specified (then it is set automatically to fill the area).
#' @param n_segments (optional) Number of segments. The number of segments. Either one number which determines the number of segments applied to all circles, or a vector with a number for each circle (which should be a multiple of 4, see also the argument \code{labeling}). By default, the central circle is not segmented (see the argument \code{segment_center}).
#' @param distance Distance The distances between the circles. For the center circle, it is the distance between the center and the circle. If only one number is specified, \code{distance_growth} determines the increment at which the distances grow for the outer circles.   
#' @param distance_growth The rate at which the distances between the circles grow. Only applicable when \code{distance} is one number and \code{n_circles > 1}. See also \code{distance}.
#' @param labeling The labeling of the zones. Either \code{"clock"} which uses the clock ananolgy (i.e. hours 1 to 12) or \code{"NESW"} which uses the cardinal directions N, E, S, W. If the number of segments is 12, the clock labeling is used, and otherwise NESW. Note that the number of segments should be a multiple of four. If, for instance the number of segments is 8, than the segments are labeled N1, N2, E1, E2, S1, S2, W1, and W2.  
#' @param starting_angle The angle of the first of the radii that create the segments (degrees). By default, it is either 15 when \code{n_segments} is 12 (i.e. the ClockBoard setting) and -45 otherwise.
#' @param segment_center Should the central circle be divided into segments? `FALSE` by default.
#' @param intersection Should the zones be intersected with the area? \code{TRUE} by default.
#' @param city (optional) Name of the city. If specified, it adds a column `city` to the returned `sf` object.
#'
#' @return An `sf` object containing zones covering the region
#' @export
#' @import sf
#' @importFrom graphics plot text
#' @importFrom grDevices hcl
#' @examples
#' # default settings
#' z = zb_zone(london_c(), london_a())
#' \donttest{
#' zb_plot(z)
#' if (require(tmap)) {
#'   zb_view(z)
#'   
#'   z = zb_zone("Berlin")
#'   zb_view(z)
#'}
#' 
#' # variations
#' zb_plot(zb_zone(london_c(), london_a(), n_circles = 2))
#' zb_plot(zb_zone(london_c(), london_a(), n_circles = 4, distance = 2, distance_growth = 0))
#' zb_plot(zb_zone(london_c(), london_a(), n_circles = 3, n_segments = c(1,4,8)))
#' }
zb_zone = function(x = NULL,
                   area = NULL,
                   n_circles = NA,
                   n_segments = 12,
                   distance = 1,
                   distance_growth = 1,
                   labeling = NA,
                   starting_angle = NA,
                   segment_center = FALSE,
                   intersection = TRUE,
                   city = NULL) {
  
  # checks and preprosessing x and area 
  if (is.null(x) && is.null(area)) stop("Please specify either x or area")

  if (!is.null(area)) {
    area = sf::st_geometry(area)
    if (!inherits(area, c("sfc_POLYGON", "sfc_MULTIPOLYGON"))) stop("area is not a (multi)polygon")
    if (!(length(area) == 1)) stop("area should contain only one (multi)polygon")
    if (is.na(sf::st_crs(area))) stop("crs of area is unkown")
  }

  if (is.null(x)) {
    x = sf::st_centroid(area)
  } else {
    if (!inherits(x, c("sf", "sfc"))) {
      if (is.character(x)) {
        if (!requireNamespace("tmaptools")) {
          stop("Please install tmaptools first")
        } else {
          x = tmaptools::geocode_OSM(x, as.sf = TRUE)
        }
      } else {
        stop("x should be an sf(c) object or a city name")
      } 
    }
    
    x = sf::st_geometry(x)
    if (!inherits(x, "sfc_POINT")) stop("x is not a point")
    if (!(length(x) == 1)) stop("x should contain only one point")
    if (is.na(sf::st_crs(x))) stop("crs of x is unkown")
    if (!is.null(area) && !identical(sf::st_crs(area), sf::st_crs(x))) {
      area = sf::st_transform(area, sf::st_crs(x))
    }
  }
  
  if (!is.null(area) && !sf::st_contains(area, x, sparse = FALSE)[1]) stop("x is not located in area")
  
  # other checks / preprosessing
  if (is.na(n_circles)) {
    if (!is.null(area)) {
      n_circles = number_of_circles(area, distance, distance_growth, x)
    } else {
      n_circles = 5
    }
  }

  if (n_circles == 1 && n_segments > 1 && !segment_center) {
    message("Please set segment_center = TRUE to divide the centre into multiple segments")
  }
  if (length(distance) != n_circles) {
    distance = get_distances(distance, distance_growth, n_circles)
  }
  if (is.na(labeling)) labeling = ifelse(all(n_segments == 12), "clock", "NESW")
  if (is.na(starting_angle)) starting_angle = ifelse(labeling == "clock", 15, -45)
  
  # project if needed (and reproject back at the end)
  orig_crs = sf::st_crs(x)
  if (sf::st_is_longlat(orig_crs)) {
    crs = geo_select_aeq(x)
    x = sf::st_transform(x, crs = crs)
    if (!is.null(area)) area = sf::st_transform(area, crs = crs)
  }
  
  # create doughnuts
  doughnuts = create_rings(x, n_circles, distance)
  
  # update n_circles
  n_circles = nrow(doughnuts)
  
  # clock_labels = (identical(n_segments, 12))
  # if (is.na(starting_angle)) starting_angle = ifelse(clock_labels, 15, -45)
  
  # alternatives: add argument use_clock_labels? or another function with different params?
    
  n_segments = rep(n_segments, length.out = n_circles)
  if (!segment_center) n_segments[1] = 1
  
  # create segments
  segments = lapply(n_segments, 
                    create_segments, 
                    x = x, 
                    # starting_angle = ifelse(clock_labels, 15, -45))
                    starting_angle = starting_angle)
  
  # transform to sf and number them
  segments = lapply(segments, function(x) {
    if (is.null(x)) return(x)
    y = sf::st_as_sf(x)
    y$segment_id = 1:nrow(y)
    y
  })
  
  # intersect doughnuts with x (the area polygon)
  if(!is.null(area) && intersection) {
    if (!all(sf::st_is_valid(area))) {
      if (!requireNamespace("lwgeom")) {
        stop("Combining polygons failed. Please install lwgeom and try again")
      } else {
        x = sf::st_make_valid(x)
      }
    }
    area = st_union(st_buffer(area, dist = 0.01)) #0.01 (in most crs's 1 cm) is arbitrary chosen, but works to resolve strange artefacts
    
    zones_ids = which(sapply(sf::st_intersects(doughnuts, area), length) > 0)
    doughnuts = suppressWarnings(sf::st_intersection(doughnuts, area))
    segments = segments[zones_ids]
  } else {
    zones_ids = 1:n_circles
  }
  
  # intersect the result with segments
  doughnut_segments = do.call(rbind, mapply(function(i, x, y) {
    if (is.null(y)) {
      x$segment_id = 0
      x$circle_id = i
      x
    } else {
      if (i==1 && !segment_center) {
        res = x
        res$segment_id = 0
        res$circle_id = i
      } else {
        res = suppressWarnings(sf::st_intersection(x, y))
        res$circle_id = i
      }
      res
    }
  }, zones_ids, split(doughnuts, 1:length(zones_ids)), segments, SIMPLIFY = FALSE))
  
  # doughnut_segments$segment_id = formatC(doughnut_segments$segment_id, width = 2, flag = 0)
  # doughnut_segments$circle_id = formatC(doughnut_segments$circle_id, width = 2, flag = 0)
  
  # attach labels
  if (labeling == "clock") {
    labels_df = zb_clock_labels(n_circles, segment_center = segment_center)
  } else {
    labels_df = zb_quadrant_labels(n_circles, n_segments, segment_center)
  }
  
  df = merge(doughnut_segments, labels_df, by = c("circle_id", "segment_id"))
  df = df[c("label", "circle_id", "segment_id")]
  
  order_id = order(df$circle_id * 100 + df$segment_id)
  z = sf::st_transform(df[order_id, ], crs = orig_crs)
  if (!all(sf::st_is_valid(z))) {
    if (!requireNamespace("lwgeom")) {
      warning("sf object invalid. To fix it, install lwgeom, and rerun zb_zone")
    } else {
      z = sf::st_make_valid(z)
      z = suppressWarnings(st_cast(z, "MULTIPOLYGON")) # st_make_valid may return geometrycollections with empty points/lines
    }
  }
  
  z$centroid = sf::st_geometry(st_centroid_within_poly(z))
  
  if (!is.null(city)) {
    z$city = city
  }
  
  z
}


st_centroid_within_poly <- function (poly) {
  
  # check if centroid is in polygon
  centroid <- suppressWarnings(sf::st_centroid(poly)) 
  in_poly <- diag(sf::st_within(centroid, poly, sparse = F))
  
  if (any(!in_poly)) {
    suppressWarnings({
      centroid$geometry[!in_poly] <- st_point_on_surface(poly[!in_poly,])$geometry 
    })
  }
  
  return(centroid)
}

# Create zones of equal area (to be documented)
# z = zb_zone(london_a(), n_circles = 8, distance_growth = 0, equal_area = TRUE) # bug with missing pies
# suggestion: split out new new function, reduce n. arguments
# plot(z, col = 1:nrow(z))
zb_zone_equal_area = function(x = NULL,
                   point = NULL,
                   n_circles = NULL,
                   # n_segments = c(1, (1:(n_circles - 1)) * 4), # NA
                   n_segments = NA,
                   distance = 1,
                   distance_growth = 1,
                   intersection = TRUE) {
  # Functions to calculate distances
  n_segments = number_of_segments(n_circles = n_circles, distance = distance)
  zb_zone(x, point, n_circles, n_segments, distance, intersection = intersection)
  
}
  
