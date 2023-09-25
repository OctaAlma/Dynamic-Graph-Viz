include("./structFiles/Graph.jl")

function vacRead(filepath::String)
    intS = 0
    try
        open(filepath) do file
            # do stuff with the open file instance 'f'
            s = readline(file)
            intS = parse(Int64, s)  
        end
    catch
         println("Something went wrong in vacRead")
    end
    if intS == 1
        return vacReadv1(filepath)
    end
    println("vacRead version",intS,"not found")

end

# returns the index of a string in a vector. Returns -1 if not found
function findIndex(lineArgs, substr)
    for i in 1:length(lineArgs)
        if lineArgs[i] == substr
            return i
        end
    end
    return -1
end

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

function findKey(label::SubString{String}, allNodes::Vector{Node})
    
    for i in 1:length(allNodes)
        if allNodes[i].label == label
            return allNodes[i].index
        end
    end

    return -1
end

function parseEdge(lineArgs::Vector{SubString{String}}, allNodes::Vector{Node})
    weight = 1.0
    color = "black"
    sourceKey = -1
    destKey = -1

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

    return Edge(weight, color, sourceKey, destKey)
end

# Parse a version 1 .vac file and return a graph object
function vacReadv1(filepath::String)
    newGraph = Graph()

    newGraph.versionNo = 1
    
    # Empty the vectors for nodes and edges
    empty!(newGraph.edges)
    empty!(newGraph.nodes)

    index = 1

    try
        open(filepath) do file
            # do stuff with the open file instance 'f'
            lineNo = 1
            for currLine in readlines(file)
                if lineNo <= 3
                    if lineNo == 2
                        # Line 2 specifies if the graph is directed or undirected
                        if currLine[1] == "u"
                            newGraph.directed = false
                        else
                            newGraph.directed = true
                        end
                    elseif lineNo == 3
                        # Line 3 specifies if the graph is weighted or unweighted
                        if currLine[1] == "u"
                            newGraph.weighted = false
                        else
                            newGraph.weighted = true
                        end
                    end
                else
                    #Read in the nodes and edges!
                    lineArgs = split(currLine, " ")
                    
                    if lineArgs[1] == "n"
                        newNode = parseNode(lineArgs, index)
                        push!(newGraph.nodes, newNode)
                        newGraph.labelToIndex[newNode.label] = newNode.index
                        index = index + 1


                    elseif lineArgs[1] == "e"
                        push!(newGraph.edges, parseEdge(lineArgs, newGraph.nodes))
                    end
                end
                lineNo = lineNo + 1
            end
        end
    catch e
        println("Something went wrong in reading the file. Version 1.\n")
        rethrow(e)
    end

    for i ∈ newGraph.nodes
        println("Node ",i, " has been added to graph.")
    end

    for i ∈ newGraph.edges
        println("Edge ",i, " has been added to graph.")
    end

    println("New Graph has been created")

    return newGraph
end