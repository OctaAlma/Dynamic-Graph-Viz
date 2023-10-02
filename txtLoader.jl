include("./structFiles/Graph.jl")

#The following function takes in a graph and updates the nodes'
#XY coordinates. It assumes that the text file passed in has enough lines
function txtReadXY(g::Graph, filepath::String)
    try
        open(filepath) do file
            lineNo = 1

            for currLine in readlines(file)
                if (isempty(currLine))
                    println("Stopped reading at line ", lineNo)
                    break
                end

                if (lineNo > length(g.nodes))
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
end