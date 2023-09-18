include("Node.jl")

mutable struct Edge
    directed::Bool
    weight::Float64

    color::String
    
    sourceKey::Int64 #access the dictionary to figure out key from lebel.
    destKey::Int64 #
end