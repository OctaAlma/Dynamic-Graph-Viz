include(".././structFiles/Graph.jl")

function vacRead(filepath::String)
    intS = 0
    try
        open(filepath) do file
            # do stuff with the open file instance 'f'
            s = readline(file)
            intS = parse(Int64, s)  
        end
    catch
        println("Could not open file")
        return
    end
    if intS == 1
        return vacReadv1(filepath)
    end
    println("vacRead version", intS, "not found")
end


function findKey(label::SubString{String}, allNodes::Vector{Node})
    
    for i in 1:length(allNodes)
        if allNodes[i].label == label
            return allNodes[i].index
        end
    end

    return -1
end

# Parse a version 1 .vac file and return a graph object
function vacReadv1(filepath::String)::Graph
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
                        if currLine[begin] == 'u'
                            newGraph.directed = false
                        else
                            newGraph.directed = true
                        end
                    elseif lineNo == 3
                        # Line 3 specifies if the graph is weighted or unweighted
                        if currLine[begin] == 'u'
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

    setGraphLimits(newGraph)
    return newGraph
end

function outputGraphToVac(g::Graph, filename::String)
    open(filename, "w") do file
        # Write the .vac version number:
        write(file, "1\n")

        # Write whether the graph is directed
        if (g.directed == true)
            write(file, "d\n")
        else
            write(file, "u\n")
        end

        # Write whether the graph is weighted
        if (g.weighted == true)
            write(file, "w\n")
        else
            write(file, "u\n")
        end

        # Write all the node information
        for currNode in g.nodes
            label = currNode.label
            nodeSize = currNode.size

            outlineColor = currNode.outlineColor
            fillColor = currNode.fillColor
            labelColor = currNode.labelColor

            xCoord = currNode.xCoord
            yCoord = currNode.yCoord

            nodeLine = "n -l $label -x $xCoord -y $yCoord -f $fillColor -o $outlineColor -lc $labelColor -s $nodeSize\n"
            write(file, nodeLine)
        end

        # Write all the edge information
        for edge in g.edges
            weight = edge.weight
            color = edge.color
            lineWidth = edge.lineWidth

            sourceLabel = findNodeLabelFromIndex(g, edge.sourceKey)
            destLabel = findNodeLabelFromIndex(g, edge.destKey)

            edgeLine = "e -s $sourceLabel -d $destLabel -w $weight -c $color -lw $lineWidth\n"
            write(file, edgeLine)
        end
    end
end

function saveAnimToVaca(states::Vector{GraphState}, filename::String)
    numStates = length(states)

    open(filename, "w") do file
        write(file, "$numStates\n")
        for i in 1:numStates
            # Write the .vac version number:
            write(file, "NEXT-STATE\n")
            g = states[i].g
    
            # Write whether the graph is directed
            if (g.directed == true)
                write(file, "d\n")
            else
                write(file, "u\n")
            end
    
            # Write whether the graph is weighted
            if (g.weighted == true)
                write(file, "w\n")
            else
                write(file, "u\n")
            end
    
            # Write all the node information
            for currNode in g.nodes
                label = currNode.label
                nodeSize = currNode.size
    
                outlineColor = currNode.outlineColor
                fillColor = currNode.fillColor
                labelColor = currNode.labelColor
    
                xCoord = currNode.xCoord
                yCoord = currNode.yCoord
    
                nodeLine = "n -l $label -x $xCoord -y $yCoord -f $fillColor -o $outlineColor -lc $labelColor -s $nodeSize\n"
                write(file, nodeLine)
            end
    
            # Write all the edge information
            for edge in g.edges
                weight = edge.weight
                color = edge.color
                lineWidth = edge.lineWidth
    
                sourceLabel = findNodeLabelFromIndex(g, edge.sourceKey)
                destLabel = findNodeLabelFromIndex(g, edge.destKey)
    
                edgeLine = "e -s $sourceLabel -d $destLabel -w $weight -c $color -lw $lineWidth\n"
                write(file, edgeLine)
            end

            xmin = g.xMin
            xmax = g.xMax
            ymin = g.yMin
            ymax = g.yMax
            write(file, "LIMITS $xmin $xmax $ymin $ymax\n")

            write(file, "DESC-START\n")
            write(file, states[i].desc)
            write(file, "\nDESC-END\n")
        end
    end
end

function loadAnimFromVaca(filename::String)
    states = nothing
    numStates = -1

    try
        open(filename, "r") do file
            lineNo = 1
            currState = -1
            numNodes = 0
            readingDesc = false
            for currline in readlines(file)
                words = split(currline, " ")
                if (length(words) == 0)
                    continue
                end

                if (lineNo == 1)
                    numStates = parse(Int64, currline)
                    states = Vector(undef, numStates)
                    currState = 0
                
                elseif currline == "NEXT-STATE"
                    currState += 1
                    numNodes = 0
                    states[currState] = GraphState()
                    empty!(states[currState].g.nodes)
                    empty!(states[currState].g.edges)
                
                elseif words[1] == "LIMITS"
                    if (length(words) >= 5)
                        states[currState].g.xMin = parse(Float64, words[2])
                        states[currState].g.xMax = parse(Float64, words[3])
                        states[currState].g.yMin = parse(Float64, words[4])
                        states[currState].g.yMax = parse(Float64, words[5])
                    end
                
                elseif currline == "DESC-START"
                    readingDesc = true
                
                elseif currline == "DESC-END"
                    readingDesc = false
                
                elseif readingDesc == true
                    states[currState].desc *= currline
                
                elseif currline[1] == 'n'
                    numNodes += 1
                    push!(states[currState].g.nodes, parseNode(split(currline, " "), numNodes))

                elseif currline[1] == 'e'
                    push!(states[currState].g.edges, parseEdge(split(currline, " "), states[currState].g.nodes))
                end
                
                lineNo += 1
            end
        end
    catch e
        println("Error in parsing file: ", filename)
        rethrow(e)
    end

    return states
end
