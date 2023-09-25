mutable struct Node
    label::String # How the node will actually appear on the graph
    index::Int64 # The "key" associated with the node
    size::Int64 # How big the node will appear on the graph
    
    outlineColor::String 
    fillColor::String 
    labelColor::String 

    xCoord::Float64
    yCoord::Float64
end


#Node(label="", index=0, size=1, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) = Node(label, index, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
Node(;label="", index=0, size=1, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) = Node(label, index, size, outlineColor, fillColor, labelColor, xCoord, yCoord)

function createNodeVectorFromVVF(xy::Matrix{Float64})::Vector{Node}
    nodeVec::Vector{Node} = []
    n = size(xy,1)
    
    for i in 1:n
        newNode = Node("$i", i, 10, "black", "white", "black", xy[i,1], xy[i,2])
        push!(nodeVec, newNode)
    end

    return nodeVec
end