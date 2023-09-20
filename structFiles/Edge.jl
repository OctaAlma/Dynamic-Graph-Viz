mutable struct Edge
    directed::Bool
    weight::Float64

    color::String
    
    sourceKey::Int64 #access the dictionary to figure out key from lebel.
    destKey::Int64 #
end

Edge(directed=false, weight=1., color="black", sourceKey=-1, destKey=-1) = Edge(directed, weight, color, sourceKey, destKey)
Edge(;directed=false, weight=1., color="black", sourceKey=-1, destKey=-1) = Edge(directed, weight, color, sourceKey, destKey)

