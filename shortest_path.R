#Author: Felipe Matas, with University Adolfo Ibáñez

pacman::p_install("wrapr", force = FALSE)
pacman::p_install("cppRouting", force = FALSE)
pacman::p_install("dplyr", force = FALSE)
pacman::p_install("sf", force = FALSE)
pacman::p_install("coro", force = FALSE)

modules::import("wrapr")

cppRouting.shortest_path.pairs.iterator <- coro::generator(function(ret, from, to) {
  for (id in seq(length(from))){
    coro::yield(list(
      from = from[[id]],
      to = to[[id]],
      path = ret[[paste0(from[[id]], "_", to[[id]])]]
    ))
  }
})

cppRouting.shortest_path.matrix.iterator <- coro::generator(function(ret, from, to) {
    for (ele_from in from){
      for (ele_to in to){
        coro::yield(list(
          from = ele_from,
          to = ele_to,
          path = ret[[as.character(ele_from)]][[as.character(ele_to)]]
        ))
      }
    }
})

networks.shortest_path.node2node.cppRouting <- function(network, cppRouting_graph, from, to, f, iterator){
    #Reset the row numbers to can match with the output
    #cppRouting uses not the row label, uses the row number
    row.names(from) <- NULL
    row.names(to) <- NULL
    paths <- f(
        Graph = cppRouting_graph,
        from = from,
        to = to,
    )
    from_ <- c()
    to_ <- c()
    path_ <- c()
    coro::loop(for (element in iterator(paths, from, to)) {
        from_ <- append(from_, element$from)
        to_ <- append(to_, element$to)
        #From node "a" to node "a"
        #this imply no_path
        if (element$from == element$to) {
          path_ <- net %.>%
                  #Extract the node
                  sfnetworks::activate(., "nodes") %.>%
                  dplyr::filter(., dplyr::row_number() == 4) %.>%
                  sf::st_as_sf(.) %.>%
                  sf::st_geometry(.)[[1]] %.>%
                  #Create a line with the same node two times
                  sf::st_linestring(c(., .)) %.>%
                  sf::st_sfc(.) %.>%
                  #Append
                  append(path_, .)
        #If the nodes are in different components
        } else if (length(element$path) == 0){
          path_ <- append(path_, sf::st_sfc(sf::st_linestring()))
        } else {
            #Append the new route
          path_ <- network %.>%
                  tidygraph::activate(., "nodes") %.>%
                  dplyr::filter(., dplyr::row_number() %in% element$path) %.>%
                  tidygraph::activate(., "edges") %.>%
                  sf::st_as_sf(.) %.>%
                  sf::st_union(.) %.>%
                  append(path_, .)
        }
    })
    ret <- data.frame(
        from=from_,
        to=to_
    )
    ret$path <- path_
    ret <- sf::st_as_sf(ret)
    ret
}

networks.shortest_path.node2node.cppRouting.matrix <- function(network, cppRouting_graph, from, to) {
    networks.shortest_path.node2node.cppRouting(
        network,
        cppRouting_graph,
        from,
        to,
        cppRouting:: get_multi_paths,
        cppRouting.shortest_path.matrix.iterator
    )
}

networks.shortest_path.node2node.cppRouting.pairs <- function(network, cppRouting_graph, from, to) {
    networks.shortest_path.node2node.cppRouting(
        network,
        cppRouting_graph,
        from,
        to,
        cppRouting:: get_path_pair,
        cppRouting.shortest_path.pairs.iterator
    )
}