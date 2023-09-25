mutable struct Edge
    sourceKey::Int64 #access the dictionary to figure out key from lebel.
    destKey::Int64 #

    weight::Float64
    color::String
end

#Edge(weight=1., color="black", sourceKey=-1, destKey=-1) = Edge(weight, color, sourceKey, destKey)
Edge(;sourceKey=-1, destKey=-1, weight=1., color="black") = Edge(sourceKey, destKey ,weight, color)

#takes in a vector of edges, and returns a vector of edges
function createEdgeVectorFromVVI(edges::Vector{Vector{Int64}})
    edgeVec::Vector{Edge} = []
    n = length(edges)
    
    for edge in edges
        newEdge = Edge(edge[1], edge[2],1,"black")
        push!(edgeVec, newEdge)
    end

    return edgeVec
end

