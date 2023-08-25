# Code to use sfnetworks with cppRouting

Sample code to use sfnetworks with cppRouting

First load the functions.

```R
library(wrapr)

#Transform the sfnetworks network, in cppRouting format
sfnetworks2cppRouting <- modules::use("sfnetworks2cppRouting.R")

#One to all, computed by every "from"
shortest_path_matrix <- modules::use("shortest_path_matrix.R")
min_distance_matrix <- modules::use("min_distance_matrix.R")

#Is a pair with the from/to vectors, be sure has the same length
shortest_path_pair <- modules::use("shortest_path_pair.R")
min_distance_pair <- modules::use("min_distance_pair.R")
```

Then load the network and get the cppRouting one too.

```{r}
network <- sf::st_read("network.gpkg", quiet = TRUE) %.>%
  sf::st_cast(., "LINESTRING") %.>%
  sfnetworks::as_sfnetwork(., directed = FALSE)

weight <- "TRAVEL_COST"

cppRouting_graph <- sfnetworks2cppRouting$sfnetworks2cppRouting(network, weight)
```

Run different costs.

```{r}
from <- c(1, 2, 3)
to <- c(5, 6, 7)

spm <- shortest_path_matrix$shortest_path.pair.node2node(network, cppRouting_graph, from, to)

spp <- shortest_path_pair$shortest_path.pair.node2node(network, cppRouting_graph, from, to)

mdp <- min_distance_pair$min_distance.pair.node2node(network, cppRouting_graph, from, to)

mdm <- min_distance_matrix$min_distance.matrix.node2node(network, cppRouting_graph, from, to)
```

All returns are a dataframe with "from", "to" columns with the nodes, the last column depends if is distance or shortestpath.

- distance: Use the column distance
- shortestpath: Use the "path" column, is a geom column
