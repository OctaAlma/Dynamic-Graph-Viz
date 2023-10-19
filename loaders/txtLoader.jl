include(".././structFiles/Graph.jl")

#The following function takes in a graph and updates the nodes'
#XY coordinates. It assumes that the text file passed in has a line for each node in the graph
function txtReadXY(g::Graph, filepath::String)
    lineNo = 1    
    if (length(g.nodes) == 0)
        return
    end
    try
        open(filepath) do file
            for currLine in readlines(file)
                if (isempty(currLine))
                    println("Stopped reading at line ", lineNo)
                    break
                end

                if (lineNo > length(g.nodes))
                    break
                end

                lineArgs = split(currLine, " ")

                newX = parse(Float64, String(lineArgs[1]))
                newY = parse(Float64, String(lineArgs[2]))

                g.nodes[lineNo].xCoord = newX
                g.nodes[lineNo].yCoord = newY
            
                lineNo = lineNo + 1
            end
        end
    catch
        println(filepath, " could not be loaded.")
    end

    # if there weren't enough xy lines in the file, set the rest of the nodes' xys to (0,0)
    while (lineNo < length(g.nodes))
        g.nodes[lineNo].xCoord = 0.0
        g.nodes[lineNo].yCoord = 0.0

        lineNo = lineNo + 1
    end
    setGraphLimits(g)
end

function outputXY(g::Graph, filename::String)
    open(filename, "w") do file
        for node in g.nodes
            currX = node.xCoord
            currY = node.yCoord

            coordString = "$currX $currY\n"
            write(file, coordString)
        end
    end
end