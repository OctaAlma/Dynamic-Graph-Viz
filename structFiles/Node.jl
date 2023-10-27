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

function createNodeVectorFromFM(xy::Matrix{Float64})::Vector{Node}
    nodeVec::Vector{Node} = []
    n = size(xy,1)
    
    for i in 1:n
        newNode = Node("$i", i, 10, "black", "white", "black", xy[i,1], xy[i,2])
        push!(nodeVec, newNode)
    end

    return nodeVec
end

function updateNodeColor(n::Node, fc::String, oc::String, lc::String)
    if (fc != "")
        n.fillColor = fc
    end

    if (oc != "")
        n.outlineColor = oc
    end

    if (lc != "")
        n.labelColor = lc
    end
end

# The following functions are incredibly inneficient. A refactoring would be nice 

# Parses a node based on vac file commands
function parseNode(lineArgs::Vector{SubString{String}}, currIndex)
    label = ""
    size = 10
    outlineColor = "black"
    fillColor = "white"
    labelColor = "black"
    xCoord = 0.0
    yCoord = 0.0

    i = findIndex(lineArgs, "-l")
    if i != -1
        label = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-x")
    if i != -1
        xCoord = parse(Float64, lineArgs[i+1])
    end
    i = findIndex(lineArgs, "-y")
    if i != -1
        yCoord = parse(Float64, lineArgs[i+1])
    end
    i = findIndex(lineArgs, "-f")
    if i != -1
        fillColor = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-o")
    if i != -1
        outlineColor = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-lc")
    if i != -1
        labelColor = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-s")
    if i != -1
        size = parse(Int64, lineArgs[i+1])
    end

    return Node(String(label), currIndex, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
end

function updateNode(n::Node, lineArgs::Vector{SubString{String}})
    # NOTE: USERS SHOULD NOT BE ABLE TO MODIFY NODE LABELS
    # i = findIndex(lineArgs, "-l")
    # if i != -1
    #     n.label = lineArgs[i+1]
    # end
    i = findIndex(lineArgs, "-x")
    if i != -1
        n.xCoord = parse(Float64, lineArgs[i+1])
    end
    i = findIndex(lineArgs, "-y")
    if i != -1
        n.yCoord = parse(Float64, lineArgs[i+1])
    end
    i = findIndex(lineArgs, "-f")
    if i != -1
        n.fillColor = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-o")
    if i != -1
        n.outlineColor = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-lc")
    if i != -1
        n.labelColor = lineArgs[i+1]
    end
    i = findIndex(lineArgs, "-s")
    if i != -1
        n.size = parse(Int64, lineArgs[i+1])
    end
end

function getNodeInfo(n::Node, lineArgs::Vector{SubString{String}}, override::Bool=false)
    anyCommand = false
    i = findIndex(lineArgs, "-l")
    if i != -1 || override == true
        println("label: ",n.label)
        anyCommand = true
    end
    i = findIndex(lineArgs, "-x")
    if i != -1 || override == true
        println("x: ",n.xCoord)
        anyCommand = true
    end
    i = findIndex(lineArgs, "-y")
    if i != -1 || override == true
        println("y: ",n.yCoord)
        anyCommand = true
    end
    i = findIndex(lineArgs, "-fc")
    if i != -1 || override == true
        println("fill Color: ",n.fillColor)
        anyCommand = true
    end
    i = findIndex(lineArgs, "-oc")
    if i != -1 || override == true
        println("outline Color: ",n.outlineColor)
        anyCommand = true
    end
    i = findIndex(lineArgs, "-lc")
    if i != -1 || override == true
        println("label Color: ",n.labelColor)
        anyCommand = true
    end
    i = findIndex(lineArgs, "-s")
    if i != -1 || override == true
        println("node Size: ", n.size)
        anyCommand = true
    end
    if anyCommand == false
        getNodeInfo(n,lineArgs,true)
    end
end