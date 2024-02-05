include("../structFiles/Graph.jl")
include("../structFiles/GraphState.jl")

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

function vectorToStr(v::Vector{Any})
    str = ""
    for i in eachindex(v)
        if (isassigned(v, i))
            x = v[i][1]
            y = v[i][2]
            str *= " $x,$y"
        else
            str *= " -,-"
        end
    end
    return str
end

function customCompare(s1::String, s2::String)::Bool
    num1 = undef
    num2 = undef 

    leadingDigits1 = 0
    leadingDigits2 = 0

    for i in eachindex(s1)
        if (s1[i] >= '0' && s1[i] <= '9')
            leadingDigits1 += 1
        else
            break
        end
    end

    for i in eachindex(s2)
        if (s2[i] >= '0' && s2[i] <= '9')
            leadingDigits2 += 1
        else
            break
        end
    end

    if (leadingDigits1 != 0) && (leadingDigits2 != 0)
        return parse(Int64, SubString(s1, 1, leadingDigits1)) < parse(Int64, SubString(s2, 1, leadingDigits2))
    end

    return s1 < s2  

end

#= Will save information from =#
function saveAnimationXY1(states::Vector{GraphState}, filename::String)
    #= 
    Idea 1
        Output to a file where each line is of the form
        label x1,y1 x2,y2 x3,y3
        - In the case that a node was deleted at state i, the x,y will be -,-
    
        This requires creating a dictionary where the keys are the labels, and the values are arrays
        We can then iterate through sort(collect(keys(dict))) and output appropriately
    =#

    labelToXY = Dict();
    numStates = length(states)

    # define all of the valid keys in the dictionary by assigning them to a vector of size n
    for state in states
        for node in state.g.nodes
            labelToXY[node.label] = Vector(undef, numStates)
        end
    end

    currState = 1
    for state in states
        for node in state.g.nodes
            labelToXY[node.label][currState] = [node.xCoord, node.yCoord]
        end
        currState += 1
    end

    # We sort an array containing the keys to output them in lexicographical order
    println(collect(keys(labelToXY)))
    allKeys = sort(collect(keys(labelToXY)), lt=customCompare)
    println(allKeys)

    open(filename, "w") do file
        for key in allKeys
            writeMe = "$key" * vectorToStr(labelToXY[key]) * "\n"
            write(file, writeMe)
        end
    end
end

function saveAnimationXY2(states::Vector{GraphState}, filename::String)
    open(filename, "w") do file
        for state in states
        end
    end
end