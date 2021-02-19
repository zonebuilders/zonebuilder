library(xtable)
df = data.frame('Number of rings' = 1:9, 'Diameter across (km)' = zb_100_triangular_numbers[1:9]*2, 'Area (sq. km)' = round(zb_100_triangular_numbers[1:9]^2*pi, 2))
xtable::xtable(df)
