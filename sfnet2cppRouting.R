#Author: Felipe Matas, with University Adolfo Ibáñez

pacman::p_install("wrapr", force = FALSE)
pacman::p_install("igraph", force = FALSE)
pacman::p_install("dplyr", force = FALSE)
pacman::p_install("sf", force = FALSE)
pacman::p_install("cppRouting", force = FALSE)

modules::import("wrapr")

sfnet2cppRouting <- function(network, weight){
    #if (is.null(network$libs)){
    #    network$libs <- list()
    #}
    #The idea is insert the graph in the ver, but future lib have
    #problems, and the var is not completely moved inside the new
    #child, causing to fail
    #if (is.null(network$libs$cppRouting)){
    cppRouting_graph <- cppRouting::makegraph(
        network %.>% 
            sfnetworks::activate(., "edges") %.>% 
            sf::st_as_sf(.) %.>%
            sf::st_drop_geometry(.) %.>%
            as.data.frame(.) %.>% 
            dplyr::transmute(., from, to, cost=.data[[weight]])
        ,
        directed = igraph::is_directed(network)
    )
    #}
    original_nodes <- network %.>%
        sfnetworks::activate(., "nodes") %.>%
        sf::st_as_sf(.)
    #This has happened some time ago, no idea why some nodes was deleted on the transformation
    #I tested it again with recent versions of cppRouging, all worked, still I like have this check
    if (nrow(original_nodes) != cppRouting_graph$nbnode){
        stop("The net was simplified by cppRouting, the nodes assignation can be broken.")
    }
    
    cppRouting_graph
}