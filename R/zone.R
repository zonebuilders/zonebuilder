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
#' @param x Region of interest
#' @param point Optional midpoint of the region 
#' @param n_circles Number of rings including the central circle
#' @param n_segments Optional sequence of numbers
#' @param distance Distance  (km)
#' @param distance_growth The rate at which the doughnut ring widths grow (km)
#' @param starting_angle The angle of the first of the radii that create the segments (degrees)
#' @param segment_center Should the central circle be divided into segments? `FALSE` by default.
#' @param intersection Not implemented yet
#'
#' @return An `sf` object containing zones covering the region
#' @export
#' @import sf
#' @importFrom graphics plot text
#' @importFrom grDevices hcl
#' @examples
#' z = zb_zone(london_area, point = london_cent)
#' z
#' plot(z)
#' plot(zb_zone(london_area, n_circles = 2))
#' plot(zb_zone(london_area, n_circles = 2, starting_angle = 0))
#' plot(zb_zone(london_area,n_circles = 2, starting_angle = 0, distance_growth = 0.1))
#' 
#' if (require(tmap)) {
#'   # tmap_mode("view") # for interactive maps
#'   z = zb_zone(london_area, point = london_cent)
#'   tm_shape(z) + tm_polygons("circle_id", palette = "plasma", legend.show = FALSE) + tm_text("label")
#' }
zb_zone = function(x = NULL,
                   point = NULL,
                   n_circles = NULL,
                   n_segments = 12,
                   distance = 1,
                   distance_growth = 1,
                   starting_angle = 15,
                   segment_center = FALSE,
                   intersection = TRUE) {
  
  # checks and class coercion    
  # sorry this now appears twice #### ----
  if (is.null(x) && is.null(point)) stop("Please specify either x or point")
  if (is.null(point)) {
    if (is.na(sf::st_crs(x))) stop("crs of x is unkown")
    x = sf::st_geometry(x)
    point = sf::st_centroid(x)
  } else {
    point = sf::st_geometry(point)
  }

  if (!is.null(n_circles) && n_circles == 1 && n_segments > 1 && !segment_center) {
    message("Please set segment_center = TRUE to divide the centre into multiple segments")
  }
  
  
  orig_crs = sf::st_crs(point)
  
  if (is.na(orig_crs)) stop("crs of point is unknown")
  
  if (sf::st_is_longlat(point)) {
    crs = geo_select_aeq(point)
    point = sf::st_transform(point, crs = crs)
    if (!is.null(x)) x = sf::st_transform(x, crs = crs)
  }
  
  # create doughnuts
  doughnuts = zb_doughnut(x, point, n_circles, distance, distance_growth)
  
  # update n_circles
  n_circles = nrow(doughnuts)
  
  clock_labels = (identical(n_segments, 12))
  if(!clock_labels && starting_angle == 15) {
    starting_angle = -45
  }
  # alternatives: add argument use_clock_labels? or another function with different params?
    
  n_segments = rep(n_segments, length.out = n_circles)
  if (!segment_center) n_segments[1] = 1
  
  # create segments
  segments = lapply(n_segments, 
                    zb_segment, 
                    x = point, 
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
  if(!is.null(x) && intersection) {
    if (!all(sf::st_is_valid(x))) {
      if (!requireNamespace("lwgeom")) {
        stop("Combining polygons failed. Please install lwgeom and try again")
      } else {
        x = lwgeom::st_make_valid(x)
      }
    }
    x = st_union(st_buffer(x, dist = 0.01)) #0.01 (in most crs's 1 cm) is arbitrary chosen, but works to resolve strange artefacts
    
    
    zones_ids = which(sapply(sf::st_intersects(doughnuts, x), length) > 0)
    doughnuts = suppressWarnings(sf::st_intersection(doughnuts, x))
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
  if (clock_labels) {
    labels_df = zb_clock_labels(n_circles, segment_center = segment_center)
  } else {
    labels_df = zb_quadrant_labels(n_circles, n_segments, segment_center)
  }
  
  df = merge(doughnut_segments, labels_df, by = c("circle_id", "segment_id"))
  
  order_id = order(df$circle_id * 100 + df$segment_id)
  z = sf::st_transform(df[order_id, ], crs = orig_crs)
  if (!all(sf::st_is_valid(z))) {
    if (!requireNamespace("lwgeom")) {
      warning("sf object invalid. To fix it, install lwgeom, and rerun zb_zone")
    } else {
      z = lwgeom::st_make_valid(z)
      z = suppressWarnings(st_cast(z, "MULTIPOLYGON")) # st_make_valid may return geometrycollections with empty points/lines
    }
  }
  z
}

# Create zones of equal area (to be documented)
# z = zb_zone(london_area, n_circles = 8, distance_growth = 0, equal_area = TRUE) # bug with missing pies
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
  
