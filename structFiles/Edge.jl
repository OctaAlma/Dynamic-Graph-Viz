mutable struct Edge
    sourceKey::Int64 #access the dictionary to figure out key from label.
    destKey::Int64 #

    weight::Float64
    color::String
    lineWidth::Float64
end

Edge(;sourceKey=-1, destKey=-1, weight=1.0, color="black", lineWidth=1.0) = Edge(sourceKey, destKey, weight, color, lineWidth)

#takes in a vector of edges, and returns a vector of edges
function createEdgeVectorFromVVI(edges::Vector{Vector{Int64}})
    edgeVec::Vector{Edge} = []
    n = length(edges)
    
    for edge in edges
        newEdge = Edge(edge[1], edge[2], 1, "black", 1.0)
        push!(edgeVec, newEdge)
    end

    return edgeVec
end

# Parses a new edge based on the vac file format
function parseEdge(lineArgs::Vector{SubString{String}}, allNodes::Vector{Node})
    weight = 1.0
    color = "black"
    sourceKey = -1
    destKey = -1
    lineWidth = 1.0

    i = findIndex(lineArgs, "-s")
    if (i != -1)
        label = lineArgs[i + 1]
        sourceKey = findKey(label, allNodes)
    end
    i = findIndex(lineArgs, "-d")
    if (i != -1)
        label = lineArgs[i + 1]
        destKey = findKey(label, allNodes)
    end
    i = findIndex(lineArgs, "-w")
    if (i != -1)
        weight = parse(Float64, lineArgs[i+1])
    end
    i = findIndex(lineArgs, "-c")
    if (i != -1)
        color = lineArgs[i + 1]
    end
    i = findIndex(lineArgs, "-lw")
    if (i != -1)
        lineWidth = parse(Float64, lineArgs[i+1])
    end

    return Edge(sourceKey, destKey, weight, color, lineWidth)
end

function getEdgeInfo(e::Edge, source::String, dest::String, lineArgs::Vector{SubString{String}}, override::Bool=false)
    anyCommand = false
    i = findIndex(lineArgs, "-w")
    if i != -1 || override == true
        println("⬗ weight: ", e.weight)
        anyCommand = true
    end
    i = findIndex(lineArgs, "-c")
    if i != -1 || override == true
        println("⬗ color: ", e.color)
        anyCommand = true
    end
    
    i = findIndex(lineArgs, "-t")
    if (i == -1)
        i = findIndex(lineArgs, "-lw")
    end
    if i != -1 || override == true
        println("⬗ linewidth ", e.lineWidth)
        anyCommand = true
    end
    i = findIndex(lineArgs, "-s")
    if i != -1 || override == true
        println("⬗ source node: ", source)
        anyCommand = true
    end
    i = findIndex(lineArgs, "-d")
    if i != -1 || override == true
        println("⬗ destination node: ", dest)
        anyCommand = true
    end

    if anyCommand == false
        getEdgeInfo(e, source, dest, lineArgs, true)
    end
end

Base.:(==)(c1::Edge, c2::Edge) = 
c1.sourceKey == c2.sourceKey &&
c1.destKey == c2.destKey &&
c1.weight == c2.weight &&
c1.color == c2.color &&
c1.lineWidth == c2.lineWidth