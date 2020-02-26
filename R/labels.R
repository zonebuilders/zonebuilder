zb_clock_labels = function(n_circles, segment_center = FALSE) {
  do.call(rbind, lapply(1:n_circles, function(i) {
    if (i==1L && !segment_center) {
      data.frame(circle_id = i, segment_id = 0, label = "A", stringsAsFactors = FALSE)
    } else {
      data.frame(circle_id = i, segment_id = 1:12, label = paste0(LETTERS[i], sprintf("%02d", 1:12)), stringsAsFactors = FALSE)
    }
  }))
}


# zb_quadrant_labels(5)
zb_quadrant_labels = function(n_circles, n_segments = 12, segment_center = FALSE, quadrants = c("N", "E", "S", "W")) {

  # check n_segments
  if (any((n_segments %% 4) != 0 & n_segments != 1)) stop("n_segments should be equal to 1 or a multiple of 4")
  n_segments = rep(n_segments, length.out = n_circles)
  if (!segment_center) n_segments[1] = 1

  two_decimals_required = any(n_segments >= 40)
  
  do.call(rbind, mapply(function(i, j) {
    ring = LETTERS[i]
    quad = quadrants[ceiling(((1:j)/j) * 4)]
    seg = (((1:j - 1)/j) %% 0.25) * j + 1
    
    if (two_decimals_required) {
      seg = sprintf("%02d", seg)
    }
    
    labels = if (j == 1) {
      ring
    } else if (j == 4) {
      paste0(ring, quad)
    } else {
      paste0(ring, quad, seg)
    }
    
    if (j==1) {
      segment_id = 0
    } else {
      segment_id = 1:j
    }
    
    
    data.frame(circle_id = i, segment_id = segment_id, label = labels, stringsAsFactors = FALSE)
  }, 1:n_circles, n_segments, SIMPLIFY = FALSE))
}
