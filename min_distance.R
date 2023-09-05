#Author: Felipe Matas, with University Adolfo Ibáñez

spsUtil::quiet(pacman::p_install("wrapr", force = FALSE))
spsUtil::quiet(pacman::p_install("cppRouting", force = FALSE))
spsUtil::quiet(pacman::p_install("coro", force = FALSE))


modules::import("wrapr")

cppRouting.min_distance.pairs.iterator <- coro::generator(function(ret, from, to) {
    for (id in seq(length(from))){
      coro::yield(list(
        from = from[[id]],
        to = to[[id]],
        distance = ret[[id]]
      ))
    }
})

cppRouting.min_distance.matrix.iterator <- coro::generator(function(ret, from, to) {
  for (id_from in seq(length(from))){
    for (id_to in seq(length(to))){
      coro::yield(list(
        from = from[[id_from]],
        to = from[[id_to]],
        distance = ret[id_from, id_to]
      ))
    }
  }
})

networks.min_distance.node2node.cppRouting <- function(network, cppRouting_graph, from, to, f, iterator){
    #Reset the row numbers to can match with the output
    #cppRouting uses not the row label, uses the row number
    row.names(from) <- NULL
    row.names(to) <- NULL
    distances <- f(
        Graph = cppRouting_graph,
        from = from,
        to = to,
        #The all cores don't works very well
        #we need to paralelize with something else
        #in this case, with furrr
        allcores = FALSE,
        algorithm = 'phast'
    )
    from_ <- c()
    to_ <- c()
    distance_ <- c()
    coro::loop(for (element in iterator(distances, from, to)) {
        from_ <- append(from_, element$from)
        to_ <- append(to_, element$to)
        #If the nodes are in different components
        if (is.na(element$distance)) {
          distance_ <- append(distance_, Inf)
        } else {
          distance_ <- append(distance_, element$distance)
        }
    })
    ret <- data.frame(
        from=from_,
        to=to_,
        distance = distance_
    )
    ret
}

networks.min_distance.node2node.cppRouting.matrix <- function(network, cppRouting_graph, from, to) {
    networks.min_distance.node2node.cppRouting(
        network,
        cppRouting_graph,
        from,
        to,
        cppRouting::get_distance_matrix,
        cppRouting.min_distance.matrix.iterator
    )
}

networks.min_distance.node2node.cppRouting.pairs <- function(network, cppRouting_graph, from, to) {
    networks.min_distance.node2node.cppRouting(
        network,
        cppRouting_graph,
        from,
        to,
        cppRouting::get_distance_pair,
        cppRouting.min_distance.pairs.iterator
    )
}