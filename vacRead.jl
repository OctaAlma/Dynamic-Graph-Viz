include("./structFiles/Graph.jl")

function vacRead(filepath::String)
    intS = 0
    try
        open(filepath) do file
            # do stuff with the open file instance 'f'
            s = readline(file)
            println(s)
            intS = parse(Int64, s)  
        end
    catch
         println("Something went wrong in vacRead")
    end
    if intS == 1
        return vacReadv1(filepath)
    end
    println("vacRead version",s,"not found")

end


function vacReadv1(filepath::String)
    newGraph = Graph()

    newGraph.versionNo = 1
    
    empty!(newGraph.edges)
    empty!(newGraph.nodes)
    

    println("newGraph created")
    
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
                end
                lineNo = lineNo + 1
            end
        end
    catch
        println("Something went wrong in reading the file. Version 1.\n")
    end

    println(newGraph.directed)
    println(newGraph.weighted)

    return newGraph
end