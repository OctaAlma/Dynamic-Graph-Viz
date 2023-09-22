mutable struct Edge
    weight::Float64

    color::String
    
    sourceKey::Int64 #access the dictionary to figure out key from lebel.
    destKey::Int64 #
end

Edge(weight=1., color="black", sourceKey=-1, destKey=-1) = Edge(weight, color, sourceKey, destKey)
Edge(;weight=1., color="black", sourceKey=-1, destKey=-1) = Edge(weight, color, sourceKey, destKey)

