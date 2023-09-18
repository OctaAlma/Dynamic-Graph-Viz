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


Node(label="", index=0, size=1, outlineColor="", fillColor="", labelColor="", xCoord=0., yCoord=0.) = Node(label, index, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
Node(;label="", index=0, size=1, outlineColor=":black", fillColor="", labelColor="", xCoord=0., yCoord=0.) = Node(label, index, size, outlineColor, fillColor, labelColor, xCoord, yCoord)

n1 = Node(size = 5, label="A")
@show n1