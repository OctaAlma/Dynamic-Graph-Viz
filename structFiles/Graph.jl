include("Node.jl")
include("Edge.jl")

mutable struct Graph
    edges::AbstractVector{Edge}
    nodes::AbstractVector{Node}
end