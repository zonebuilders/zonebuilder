% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/from_stplanr.R
\name{geo_select_aeq}
\alias{geo_select_aeq}
\alias{geo_select_aeq.sf}
\alias{geo_select_aeq.sfc}
\title{Azimuthal Equidistant Projection}
\usage{
\method{geo_select_aeq}{sf}(shp)

\method{geo_select_aeq}{sfc}(shp)

geo_select_aeq(shp)
}
\arguments{
\item{shp}{An sf object.}
}
\value{
A CRS string for an Azimuthal Equidistant projection.
}
\description{
Returns a CRS string for an Azimuthal Equidistant projection centered on the midpoint of an sf object's coordinates.
}
\details{
Azimuthal Equidistant Projection
}
