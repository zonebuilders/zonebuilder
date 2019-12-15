zb_clock_labels = function(n_circles, segment_center = FALSE) {
  do.call(c, lapply(1:n_circles, function(i) {
    if (i==1L && !segment_center) {
      "A"
    } else {
      paste0(LETTERS[i], sprintf("%02d", 1:12))
    }
  }))
}

# zb_labeler = function(n_circles, n_segments = 12, segment_center = FALSE, starting_angle = -45, angles_mid = FALSE) {
# 
#   # same checks as zb_zone
#   n_segments = rep(n_segments, length.out = n_circles)
#   if (!segment_center) n_segments[1] <- 1
#   
#   get_angles(n_segments = n_segments, starting_angle = starting_angle, angles_mid = angles_mid)
# 
# }
