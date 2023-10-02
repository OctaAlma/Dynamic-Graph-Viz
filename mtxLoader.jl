include("./structFiles/Graph.jl")

function mtxRead(filepath::String)::Graph
    newGraph = Graph()

    newGraph.versionNo = 1

    #For MTX, assume the input graph is directed
    newGraph.directed = false
    
    # Empty the vectors for nodes and edges
    empty!(newGraph.edges)
    empty!(newGraph.nodes)
    
    try
        open(filepath) do file
            lineNo = 1
            numNodes = -1
            numEdges = -1

            for currLine in readlines(file)
                
                if currLine[begin] == '%'
                    # We have a comment line, do not do anything
                    continue
                end

                lineArgs = split(currLine, " ")

                if lineNo == 1
                    # This is the data line
                    # Format: #nodes #nodes #edges    

                    if length(lineArgs) != 3
                        println("Mtx error: line ", currLine, " is not valid")
                        return newGraph
                    end

                    numNodes = parse(Int64, String(lineArgs[1]))
                    numEdges = parse(Int64, String(lineArgs[3]))

                    for i ∈ 1:numNodes
                        newNode = Node(label="$i", index=i, size=10)
                        push!(newGraph.nodes, newNode)
                    end
                else
                    # If we are no longer in the first line, we have a data line
                    # Format: edge source, edge dest, (OPTIONAL) edge weight
                    currSourceNode = parse(Int64, String(lineArgs[1]))
                    currDestNode = parse(Int64, String(lineArgs[2]))
                    currEdgeWeight = 1.0

                    if (length(lineArgs) == 3)
                        newGraph.weighted = true
                        currEdgeWeight = parse(Float64, String(lineArgs[3]))
                    end

                    newEdge = Edge(sourceKey = currSourceNode, destKey = currDestNode, weight = currEdgeWeight)
                    push!(newGraph.edges, newEdge)
                end

                lineNo = lineNo + 1
            
            end
        end
    catch e
        println(filepath, " could not be loaded.")
    end

    setGraphLimits(newGraph)
    
    return newGraph
end

function outputGraphToMtx(g::Graph, filename::String)
    open(filename, "w") do file
        n = length(g.nodes)
        numEdges = length(g.edges)
        matrixInfo = "$n $n $numEdges\n"
        write(file, matrixInfo)

        for edge in g.edges
            sourceIndex = edge.sourceKey
            destIndex = edge.destKey

            edgeString = "$sourceIndex $destIndex\n"
            write(file, edgeString)
        end
    end
end