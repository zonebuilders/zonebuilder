<!-- Brief: https://callforpapers.2021.foss4g.org/foss4g-2021-academic/ -->

## Zonebuilders: cross-platform and language-agnostic tools for generating zoning systems for urban analysis

Zones are key building blocks used for analysis and creating models (mental and statistical) of urban and environmental systems.
Used in a range of fields from biodiversity assessment to transport planning, spatially contiguous areal units break-up continuous space into discrete chunks.
Many methods *rely* on good zoning systems, including origin-destination analysis, geographically weighted regression, and choropleth visualisation.

Open access administrative boundaries are increasingly available through national databases and OpenStreetMap but are often inappropriate to geographic research, analysis and map making needs, being often: based on arbitrary factors; inconsistent between different cities/regions; and of highly variable sizes and shapes.

This talk outlines an approach to tackle these problems: tools that can auto-generate zones based on minimal input data.
We propose cross-platform and language agnostic implementations to enable a diverse range of people to generate bespoke zoning systems for their needs based on the understanding that accessibility, flexibility and extensibility are key to usability.
We also demonstrate working tools that take a step in this direction which at the time of writing includes:

-   a core library written in Rust with small and fast binaries available for all major operating systems
-   an R package (published on the Comprehensive R Archive Network, CRAN) that also enables visualisation of zoning systems

We plan to create a Python Package, a QGIS plugin and web user interface based on the core library and welcome suggestions and contributions via our GitHub organization: <https://github.com/zonebuilders>.
Based on the experience of developing these tools, we will discuss next steps towards accessible and flexible zone building tools and language/platform agnostic tools for geospatial work in general.

We conclude that the approach, based on low-level and easy-to-distribute tools that can be used in multiple free and open source frameworks, could be applied to other domains and help join diverse communities (e.g. based on R, Python or QGIS) through use of shared low-level, cross-platform and future-proof implementations.


The source code underlying the approach can be found at <https://github.com/zonebuilders>

# Description

The zonebuilder approach aims to minimise input data requirements, generate consistent zones comparable between widely varying urban systems, and provide geographically contiguous areal units.
Zones with appropriate sizes, shapes and coverage are needed for a range of applications.
However, appropriate areal units are often hard to find and, in cases where no pre-existing zoning systems can be found, to create.
The motivations for generating a new zoning system and use cases envisioned include:

-   Locating cities.
    Automated zoning systems based on a clear centrepoint can support map interpretation by making it immediately clear where the city centre is, and what the scale of the city is.

-   Reference system of everyday life.
    The zone name contains information about the distance to the center as well as the cardinal direction.
    E.g "I live in C12 and work in B3." or "The train station is in the center and our hotel is in B7".
    Moreover, the zones indicate whether walking and cycling is a feasibly option regarding the distance.

-   Aggregation for descriptive statistics / comparability over cities.
    By using the zoning system to aggregate statistics (e.g. on population density, air quality, bicycle use, number of dwellings), cities can easily be compared to each other.

-   Modelling urban cities.
    The zoning system can be used to model urban mobility.
    
We demonstrate a particular implementation of the approach and show how users can use the tools to generate custom zoning systems suited to diverse needs: the ClockBoard zoning system, which consists of 12 segments divided by concentric rings of increasing distance, is highlighted as an example.
The zonebuilder approach also enables people to propose and demonstrate alternative zoning systems.

# Notes

This paper was submitted at a time when the R spatial community is seeking to engage more proactively in the wider FOSS4G movement and aims to take a small step in that direction. See <https://github.com/r-spatial/discuss/blob/master/osgeo-email.md> for details.

# Authors

Robin Lovelace (1)

Martijn Tennekes (2)

Dustin Carlino (3)

(1) University of Leeds

(2) Statistics Netherlands

(3) Lead developer of A/B Street

