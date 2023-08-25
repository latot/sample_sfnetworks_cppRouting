#Author: Felipe Matas, with University Adolfo Ibáñez

pacman::p_install("wrapr", force = FALSE)
pacman::p_install("cppRouting", force = FALSE)
pacman::p_install("dplyr", force = FALSE)
pacman::p_install("sf", force = FALSE)

modules::import("wrapr")

shortest_path.pair.node2node <- function(network, cppRouting_graph, from, to){
    #Reset the row numbers to can match with the output
    #cppRouting uses not the row label, uses the row number
    row.names(from) <- NULL
    row.names(to) <- NULL
    paths <- cppRouting:: get_path_pair(
        Graph = cppRouting_graph,
        from = from,
        to = to,
    )
    from_ <- c()
    to_ <- c()
    path_ <- c()
    for (id in seq(length(from))){
        from_ <- append(from_, from[[id]])
        to_ <- append(to_, to[[id]])
        path__ <- network %.>%
                sfnetworks::activate(., "nodes") %.>%
                dplyr::filter(., dplyr::row_number() %in% paths[[paste0(from[[id]], "_", to[[id]])]]) %.>%
                sfnetworks::activate(., "edges") %.>%
                sf::st_as_sf(.) %.>%
                sf::st_union(.)
        #In case is the node it self, there will be no rute
        #and the append will not append anything
        if (length(path__) == 0){
            path_ <- append(path_, sf::st_sfc(sf::st_linestring()))
        } else {
            #Append the new route
            path_ <- append(path_, path__)
        }
    }
    ret <- data.frame(
        from=from_,
        to=to_
    )
    #This is a trick, the idea is get a SF object where
    # the geometry columns has the "path" name
    ret$path <- path_
    ret <- sf::st_as_sf(ret)
    ret
}


