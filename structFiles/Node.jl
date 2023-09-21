mutable struct Node
    label::String # How the node will actually appear on the graph
    key::Int64 # The "key" associated with the node
    size::Int64 # How big the node will appear on the graph
    
    outlineColor::String 
    fillColor::String 
    labelColor::String 

    xCoord::Float64
    yCoord::Float64
end


Node(label="", key=0, size=1, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) = Node(label, key, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
Node(;label="", key=0, size=1, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) = Node(label, key, size, outlineColor, fillColor, labelColor, xCoord, yCoord)