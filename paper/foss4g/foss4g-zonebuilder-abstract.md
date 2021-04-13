
<!-- Brief: https://callforpapers.2021.foss4g.org/foss4g-2021-academic/ -->

## Zonebuilders: cross-platform and language-agnostic tools for generating zoning systems for urban analysis

Zones are key building blocks of analysis and models (mental and
statistical) of urban and ecological systems. Used in a range of fields
from biodiversity assessment to transport planning, spatially contiguous
areal units that break-up continuous space into discrete chunks are a
foundation on which many approaches to geographical research build.
Techniques including origin-destination analysis, geographically
weighted regression, and choropleth mapping rely on zones with
appropriate sizes, shapes and coverage. However, open access
administrative boundaries representing locally specific zoning systems
are either inappropriate or non-existent in many places, for a number of
reasons. Administrative zoning systems are often based on arbitrary
factors; they are generally inconsistent between different
cities/regions; and their highly variable sizes and shapes make them
hard to analyse.

In this paper we propose a scalable solution to these problems: tools
that can auto-generate zones based on minimal input data. We demonstrate
a particular implementation of the approach — the ClockBoard zoning
system, which consists of 12 segments divided by concentric rings of
increasing distance, creating a consistent visual frame of reference for
cities that is reminiscent of a clock and a dartboard — and propose
alternative zoning systems. Vitally from software freedom, transparency
and accessibility perspectives, we propose cross-platform and language
agnostic implementations to enable as many people as possible to
generate bespoke zoning systems for their own purposes. We present work
in progress towards a framework enabling cross-platform and
language-agnostic generation of zoning systems, with a core library
written in Rust with small and fast binaries available for all major
operating systems. Higher level implementations are provided through an
R package (published on the Comprehensive R Archive Network, CRAN), a
Python Package, a QGIS plugin (work in progress) and web user interface.
We conclude by discussing future directions of travel in zoning system
development and the possibilities of publishing new geographical methods
for use in multiple free and open source frameworks by using low level
and cross-platform implementations such as Rust as the foundation.
