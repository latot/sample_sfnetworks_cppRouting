# Sample of cppRouting with SfNetworks

Sample code to use sfnetworks with cppRouting

First load the functions.

``` r
library(wrapr)

#Transform the sfnetworks network, in cppRouting format
sfnet2cppRouting <- modules::use("sfnet2cppRouting.R")

shortest_path <- modules::use("shortest_path.R")
min_distance <- modules::use("min_distance.R")
```

Then load the network and get the cppRouting one too.

``` r
network <- "oldenburg_walking_network.geojson" %.>%
  #Read the file
  sf::st_read(., quiet = TRUE) %.>%
  #Only linestrings
  sf::st_cast(., "LINESTRING") %.>%
  #Set a column for the weight of the line as the distance
  dplyr::mutate(., weight = sf::st_length(.)) %.>%
  #Get the sfnetworks object
  sfnetworks::as_sfnetwork(., directed = FALSE)
```

    Warning in st_cast.sf(., "LINESTRING"): repeating attributes for all
    sub-geometries for which they may not be constant

``` r
weight <- "weight"

cppRouting_graph <- sfnet2cppRouting$sfnet2cppRouting(network, weight)
```

Set some random nodes to use:

``` r
from <- c(1, 2, 3)
to <- c(5, 6, 7)
```

## Shortest Path Matrix:

``` r
shortest_path$networks.shortest_path.node2node.cppRouting.matrix(network, cppRouting_graph, from, to)
```

    Simple feature collection with 9 features and 2 fields
    Geometry type: GEOMETRY
    Dimension:     XY
    Bounding box:  xmin: 8.208518 ymin: 53.13685 xmax: 8.219401 ymax: 53.14239
    Geodetic CRS:  WGS 84
      from to                           path
    1    1  5 MULTILINESTRING ((8.213525 ...
    2    1  6 MULTILINESTRING ((8.213525 ...
    3    1  7 LINESTRING (8.218106 53.140...
    4    2  5 MULTILINESTRING ((8.213525 ...
    5    2  6 MULTILINESTRING ((8.213525 ...
    6    2  7 MULTILINESTRING ((8.218106 ...
    7    3  5 LINESTRING (8.21851 53.1405...
    8    3  6 LINESTRING (8.2183 53.14049...
    9    3  7 LINESTRING (8.218106 53.140...

## Shortest Path Pairs

``` r
shortest_path$networks.shortest_path.node2node.cppRouting.pairs(network, cppRouting_graph, from, to)
```

    Simple feature collection with 3 features and 2 fields
    Geometry type: GEOMETRY
    Dimension:     XY
    Bounding box:  xmin: 8.208733 ymin: 53.13902 xmax: 8.219401 ymax: 53.14239
    Geodetic CRS:  WGS 84
      from to                           path
    1    1  5 MULTILINESTRING ((8.213525 ...
    2    2  6 MULTILINESTRING ((8.213525 ...
    3    3  7 LINESTRING (8.218106 53.140...

## Min Distance Matrix

``` r
min_distance$networks.min_distance.node2node.cppRouting.matrix(network, cppRouting_graph, from, to)
```

      from to   distance
    1    1  1 1089.56645
    2    1  2 1103.61466
    3    1  3 1178.87029
    4    2  1 1041.89042
    5    2  2 1055.93863
    6    2  3 1132.26373
    7    3  1   73.89156
    8    3  2   59.84335
    9    3  3  460.52335

## Min Distance Paris

``` r
min_distance$networks.min_distance.node2node.cppRouting.pairs(network, cppRouting_graph, from, to)
```

      from to  distance
    1    1  5 1089.5664
    2    2  6 1055.9386
    3    3  7  460.5234

## Notes

All returns are a dataframe with “from”, “to” columns with the nodes,
the last column depends if is distance or shortestpath.

- distance: Use the column distance
- shortestpath: Use the “path” column, is a geom column
