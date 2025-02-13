
<!-- README.md is generated from README.Rmd. Please edit that file -->

# zonebuilder

<!-- badges: start -->

<!-- [![Codecov test coverage](https://codecov.io/gh/zonebuilders/zonebuilder/branch/master/graph/badge.svg)](https://codecov.io/gh/zonebuilders/zonebuilder?branch=master) -->

[![R-CMD-check](https://github.com/zonebuilders/zonebuilder/workflows/R-CMD-check/badge.svg)](https://github.com/zonebuilders/zonebuilder/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/zonebuilder)](https://CRAN.R-project.org/package=zonebuilder)
[![CRAN RStudio mirror
downloads](https://cranlogs.r-pkg.org/badges/grand-total/zonebuilder)](https://www.r-pkg.org/pkg/zonebuilder)
[DOI](https://doi.org/10.5311/JOSIS.2022.24.172) <!-- badges: end -->

The goal of zonebuilder is to break up large geographic regions such as
cities into manageable zones. Zoning systems are important in many
fields, including demographics, economy, health, and transport. The
zones have standard configuration, which enabled comparability across
cities. See its website at
[zonebuilders.github.io/zonebuilder](https://zonebuilders.github.io/zonebuilder/)
and the academic paper that describes the package in detail [here
(Lovelace et al. 2022)](https://doi.org/10.5311/JOSIS.2022.24.172).

## Installation

You can install the released version of zonebuilder from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("zonebuilder")
```

Install it from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("zonebuilders/zonebuilder")
```

## Using zonebuilder

Zonebuilder builds on the `sf` package and works well with mapping
packages such as `ggplot2`, `leaflet`, `mapdeck`, `mapview` and `tmap`,
the last of which we’ll use in the following maps. Attaching the package
provides the example datasets `london_a()` and `london_c()`, the
geographic boundary and the centre of London:

``` r
library(zonebuilder)
library(tmap)
tmap_mode("plot")
tm_shape(london_a()) +
  tm_borders() +
  tm_shape(london_c()) +
  tm_dots("red")
```

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

The main function `zb_zone` breaks this geographical scale into zones.
The default settings follow the **ClockBoard** configuration:

``` r
london_zones <- zb_zone(london_c(), london_a())
zb_plot(london_zones)
```

<img src="man/figures/README-unnamed-chunk-4-1.png" width="100%" />

The idea behind this zoning system is based on the following principles:

- Most cities have a centre, the ‘heart’ of the city. Therefore, the
  zones are distributed around the centre.
- Typically, the population is much denser in and around the centre and
  also the traffic intensity is higher. Therefore, the zones are smaller
  in and around the centre.
- The rings (so A, B, C, D, etc) reflect the proximity to the centre
  point. The distances from the outer borders of the rings A, B, C, D,
  etc. follow the triangular number sequence 1, 3, 6, 10, etc. This
  means that in everyday life use, within zone A everything is in
  walking distance, from ring B to the centre requires a bike, from zone
  C and further to the centre typically requires public transport.
- Regarding direction relative to the centre, we use the clock analogy,
  since most people are familiar with that. So each ring (annuli) is
  divided into 12 segments, where segment 12 is directed at 12:00,
  segment 1 at 1:00 etc.

The package `zonebuilder` does not only create zoning systems based on
the CloadBoard layout as illustrated below.

The function `zb_zone` makes use of `zb_doughnut` and `zb_segment`,
which can also be used directly:

``` r
par(mfrow = c(1, 3))
zb_plot(zb_doughnut(london_c(), london_a(), n_circles = 5), title = "Doughnuts")
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

``` r
zb_plot(zb_segment(london_c(), n_segments = 20), title = "Segments")
```

<img src="man/figures/README-unnamed-chunk-5-2.png" width="100%" />

``` r
zb_plot(zb_zone(london_c(), n_circles = 4, n_segments = 4), title = "4 segments, 4 circles")
```

<img src="man/figures/README-unnamed-chunk-5-3.png" width="100%" />

The package also contains a function to create zones based on a simple
rectangular grid system:

``` r
z = zb_quadrat(london_a(), ncol = 10)
plot(z)
```

<img src="man/figures/README-unnamed-chunk-6-1.png" width="100%" />

## Contribute

Contributions are welcome!

It may be worth checking-in in a [discussion
post](https://github.com/zonebuilders/zonebuilder/discussions/28) before
opening an issue.

## Citation

Please cite the package as follows (Lovelace et al. 2022):

    @article{lovelace_clockboard_2022,
      title = {{{ClockBoard}}: {{A}} Zoning System for Urban Analysis},
      shorttitle = {{{ClockBoard}}},
      author = {Lovelace, Robin and Tennekes, Martijn and Carlino, Dustin},
      date = {2022-06-20},
      journaltitle = {Journal of Spatial Information Science},
      number = {24},
      pages = {63--85},
      issn = {1948-660X},
      doi = {10.5311/JOSIS.2022.24.172},
      url = {https://josis.org/index.php/josis/article/view/172},
      urldate = {2022-07-02},
      abstract = {Zones are the building blocks of urban analysis. Fields ranging from demographics to transport planning routinely use zones - spatially contiguous areal units that break-up continuous space into discrete chunks - as the foundation for diverse analysis techniques. Key methods such as origin-destination analysis and choropleth mapping rely on zones with appropriate sizes, shapes and coverage. However, existing zoning systems are sub-optimal in many urban analysis contexts, for three main reasons: 1) administrative zoning systems are often based on somewhat arbitrary factors; 2) zoning systems that are evidence-based (e.g., based on equal population size) are often highly variable in size and shape, reducing their utility for inter-city comparison; and 3) official zoning systems in many places simply do not exist or are unavailable. We set out to develop a flexible, open and scalable solution to these problems. The result is the zonebuilder project (with R, Rust and Python implementations), which was used to create the ClockBoard zoning system. ClockBoard consists of 12 segments emanating from a central place and divided by concentric rings with radii that increase in line with the triangular number sequence (1, 3, 6 km etc). 'ClockBoards' thus create a consistent visual frame of reference for monocentric cities that is reminiscent of clocks and a dartboard. This paper outlines the design and potential uses of the ClockBoard zoning system in the historical context, and discusses future avenues for research into the design and assessment of zoning systems.},
      issue = {24},
      langid = {english},
      keywords = {modifiable area unit problem},
      file = {C:\Users\georl_admin\Zotero\storage\QRQDMJSH\Lovelace et al. - 2022 - ClockBoard A zoning system for urban analysis.pdf}
    }
