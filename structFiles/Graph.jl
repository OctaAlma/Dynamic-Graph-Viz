include("Node.jl")
include("Edge.jl")

mutable struct Graph
    edges::Vector{Edge}
    nodes::Vector{Node}

    directed::Bool
    weighted::Bool

    versionNo::Int64
    labelToIndex::Dict
end

Graph(edges=Vector{Edge}(undef,1), nodes=Vector{Node}(undef,1), directed=false, weighted=false, versionNo=1, labelToIndex=Dict()) = Graph(edges, nodes, directed, weighted, versionNo,labelToIndex)
Graph(;edges=Vector{Edge}(undef,1), nodes=Vector{Node}(undef, 1), directed=false, weighted=false, versionNo=1, labelToIndex=Dict()) = Graph(edges, nodes, directed, weighted, versionNo, labelToIndex)