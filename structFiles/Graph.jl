include("Node.jl")
include("Edge.jl")

# Base.@kwdef mutable struct Graph
#     edges = []
#     nodes = []

#     directed::Bool = false
#     weighted::Bool = false

#     versionNo::Int64 = 0
# end

mutable struct Graph
    edges::Vector{Edge}
    nodes::Vector{Node}

    directed::Bool
    weighted::Bool

    versionNo::Int64
end

Graph(edges=Vector{Edge}(undef,1), nodes=Vector{Node}(undef,1), directed=false, weighted=false, versionNo=1) = Graph(edges, nodes, directed, weighted, versionNo)
Graph(;edges=Vector{Edge}(undef,1), nodes=Vector{Node}(undef, 1), directed=false, weighted=false, versionNo=1) = Graph(edges, nodes, directed, weighted, versionNo)

# Graph( directed=false, weighted=false, versionNo=1) = Graph(directed, weighted, versionNo)
# Graph(;directed=false, weighted=false, versionNo=1) = Graph(directed, weighted, versionNo)

#Node(label="", index=0, size=1, outlineColor="", fillColor="", labelColor="", xCoord=0., yCoord=0.) = Node(label, index, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
#Node(;label="", index=0, size=1, outlineColor=":black", fillColor="", labelColor="", xCoord=0., yCoord=0.) = Node(label, index, size, outlineColor, fillColor, labelColor, xCoord, yCoord)