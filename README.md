
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sfquadrants

<!-- badges: start -->

<!-- badges: end -->

The goal of sfquadrants is to …

## Installation

You can install the released version of sfquadrants from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("sfquadrants")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("robinlovelace/sfquadrants")
```

## Example

``` r
library(sf)
#> Linking to GEOS 3.8.0, GDAL 3.0.2, PROJ 6.2.1
devtools::load_all()
#> Loading sfquadrants
plot(sq_study_region)
```

<img src="man/figures/README-unnamed-chunk-2-1.png" width="100%" />

The aim is to be able to break up geographical space into discrete
chunks. The syntax is designed to be user friendly, e.g.:

``` r
x = sq_study_region
q = sq_quadrat(x, 4) # break into 4
plot(q)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

Or dohnuts

``` r
plot(sq_dohnut(x, n = 4))
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

``` r
plot(sq_dohnut(x, d = 4))
```

<img src="man/figures/README-unnamed-chunk-4-2.png" width="100%" />
