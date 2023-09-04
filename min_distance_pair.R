#Author: Felipe Matas, with University Adolfo Ibáñez

pacman::p_install("wrapr", force = FALSE)
pacman::p_install("cppRouting", force = FALSE)

modules::import("wrapr")

min_distance.pair.node2node <- function(network, cppRouting_graph, from, to){
    #Reset the row numbers to can match with the output
    #cppRouting uses not the row label, uses the row number
    row.names(from) <- NULL
    row.names(to) <- NULL
    distances <- cppRouting::get_distance_pair(
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
    for (id in seq(length(from))){
        from_ <- append(from_, from[[id]])
        to_ <- append(to_, to[[id]])
        if (is.na(distances[[id]])) {
            distance_ <- append(distance_, Inf)
        } else {
            distance_ <- append(distance_, distances[[id]])
        }
    }
    ret <- data.frame(
        from=from_,
        to=to_,
        distance = distance_
    )
    ret
}

