include("../../GraphPlots.jl")
include("../Search/VisualizationTools.jl")
include("../../loaders/vacLoader.jl")

function initSingleSource(G::Graph, sourceInd::Int64)
    
    attributes = Dict{Int64, Tuple{Float64, Int64}}()
    #=
        - Each node will have an entry in the attributes dictionary, and the value will be a tuple where:
         - The node's distance from source is represented by a float 
         - The node's parent is represented by an Integer (parent node index)
    =# 
    
    n = length(G.nodes)

    for i in 1:n
        attributes[i] = (Inf, -1)
    end

    attributes[sourceInd] = (0, -1)

    return attributes
end

function relax(G::Graph, attributes, edgeInd::Int64)
    if ((edgeInd < 1) || (edgeInd > length(G.edges)))
        println("Edge index, ", edgeInd, " not in range.")
        return
    end

    w = G.edges[edgeInd].weight
    uInd = G.edges[edgeInd].sourceKey
    vInd = G.edges[edgeInd].destKey  
    
    if (attributes[vInd][1] > attributes[uInd][1] + w)
        attributes[vInd] = (attributes[uInd][1] + w, uInd)
    end
end

function relax(G::Graph, attributes, sourceInd, destInd)
    edgeInd = findEdgeIndex(G, sourceInd, destInd)
    relax(G, attributes, edgeInd)
end