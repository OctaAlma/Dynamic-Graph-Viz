include("varrad.jl")
include("vacLoader.jl")
include("mtxLoader.jl")
include("txtLoader.jl")

# NOTE: These are just sample values used for the DEMO


filename::String = ""

debug = true
global G = Graph()
global graphTicks = true
global commandsHistory = []
global lastInputValid = false

function displayGraph()
    display(makePlot(G, graphTicks))
end

function genericLoad(filename::String, optFile::String = "")
    # Check the extension of filename
    extension = String(split(filename, ".")[end])
    
    if (extension == "vac")
        global G = vacRead(filename)
    elseif (extension == "mtx")
        global G = mtxRead(filename)
    end
end

function genericSave(filename::String)
    # Check the extension of filename
    extension = String(split(filename, ".")[end])
    
    if (extension == "png")
        savefig(makePlot(G, graphTicks), commands[2])
    elseif (extension == "vac")
        outputGraphToVac(G, filename)
    elseif (extension == "mtx")
        outputGraphToMtx(G, filename)
    else
        printstyled("Graph could not be saved with extention ",extension, color=:red)
    end
end

function printHelp(category="")
    println("Currently supported commands:")
    println("\tdisplay                                    - Output the graph to the window")
    println("\tsaveas FILENAME.png                        - Saves the current graph to the specified filename")
    println("\texit                                       - quits the program and the Julia repl")
    println("\tmove NODE_LABEL AXIS UNITS                 - Moves the node specified by NODE_LABEL in the AXIS direction by UNITS units")
    println("\trandomEdges                                - regenerates random edges")
    println("\tcompleteEdges                              - Adds one edge for every pair of nodes")
    println("\tcircularCoords                             - Places all nodes in a circle")
    println("\tdegreeDependent                            - Re-draws the graph for a degree-dependant radius approach")
    println("\tload FILENAME.vac                          - Loads a Graph from a .vac file, IN PROGRESS")
    println("\tadd edge SOURCE DEST WEIGHT                - Adds an edge from START_NODE to END_NODE")   
    println("\tsaveGraphState FILENAME                    - Saves the graph into FILENAME so it can be loaded in at a later session")
    println("\ttoggle GRID                                - Will toggle the grid to be on/off")
    
    println("\tsetColor node NODE fill NEW_COLOR          - Updates the fill color of specified NODE")
    println("\tsetColor node NODE OL NEW_COLOR            - Updates the outline color of the specified NODE")
    println("\tsetColor node NODE label NEW_COLOR         - Updates the color of the specified NODE label")
    println("\tsetColor edge SOURCE DEST NEW_COLOR        - Updates the color of the edge between the SOURCE and DEST")
    println("\texportVac FILENAME                         - Saves the current state of the graph into a .vac file")
    println()
    println("\tCOMING SOON:")
    println("\t   remove node NODE_LABEL")
    println("\t   add node NODE_LABEL")

    println("")
end


# work on user input modifications of graph
while true
    global lastInputValid
    print("\n\nEnter commands: ")
    
    try
        global lastInputValid = true
        #println("Command History is ",commandsHistory)

        global input = readline()
        global commands = split(input, " ")
        #TODO remove *any number of consecutive whitespace
        if commands[1] == ""
            if !isempty(commandsHistory)
                push!(commandsHistory,last(commandsHistory))
                commands = split(last(commandsHistory), " ")
            else
                println("No Commands in History")
            end
        else
            push!(commandsHistory,input)
        end
        

        
        commands[1] = lowercase(commands[1])
        
        if commands[1] == "saveas"
            genericSave(String(commands[2]))
            displayGraph()

        elseif commands[1] == "move"
            # move NODE_LABEL X_OR_Y UNITS
            moveCoord = 2
            if "node" == commands[2]
                moveCoord = 3
            end

            nodeLabel = String(commands[moveCoord])

            xOrY = lowercase(commands[moveCoord+1]) 
            units = parse(Float64, commands[moveCoord+2])

            moveNode(G, nodeLabel, xOrY, units)

            displayGraph()
            
        elseif occursin("quit",commands[1]) ||  occursin("exit",commands[1]) || commands[1] == "q"
            exit()
        
        elseif commands[1] == "display" # Will display the current graph object
            displayGraph()
        
        elseif commands[1] == "circularcoords" # will update the xy coordinates for the node in a graph
            # xy = createCircularCoords(G)   
            # updateGraphNodes(G, xy)
            applyNewCoords(G, createCircularCoords(G))
            displayGraph()
        
        elseif commands[1] == "degreedependent"
            # xy = createDegreeDependantCoods(G)
            # updateGraphNodes(G, xy)
            applyNewCoords(G, createDegreeDependantCoods(G))
            displayGraph()

        elseif commands[1] == "randomedges"
            updateGraphEdges(G, randomEdges(G))
            displayGraph()
        
        elseif commands[1] == "completeedges"
            updateGraphEdges(G,completeEdges(G))
            displayGraph()
        
        elseif commands[1] == "circularedges"
            updateGraphEdges(G, circleEdges(G)  )
            displayGraph()

        elseif commands[1] == "load"
            global filename = commands[2]
            if length(commands)>2
                genericLoad(filename,String(commands[3]))
            else
                genericLoad(filename)
            end
            displayGraph()
        
        elseif commands[1] == "loadxy"
            xyFile = String(commands[2])
            txtReadXY(G, xyFile)
            
            displayGraph()

        elseif commands[1] == "exportvac"
            outFile = String(commands[2])
            outputGraphToVac(G, outFile)

        elseif commands[1] == "add"
            if (lowercase(commands[2]) == "edge")
                sourceLabel = String(commands[3])
                destLabel = String(commands[4])
                weight = 1.
                
                if (G.weighted == true)
                    try
                        weight = parse(commands[5], Float64)
                    catch
                        println("Please specify edge weight after NODE_LABEL")
                        continue;
                    end
                end

                addEdge(G, sourceLabel, destLabel, weight)

            elseif (lowercase(commands[2]) == "node")
                # IMPLEMENT ME
                println("add node is coming soon...")
            end

            displayGraph()
        elseif commands[1] == "remove"
            if (lowercase(commands[2]) == "edge")
                sourceLabel = String(commands[3])
                destLabel = String(commands[4])

                removeEdge(G, sourceLabel, destLabel)

            elseif (lowercase(commands[2]) == "node")
                println("remove node is coming soon...")

            end

            displayGraph()
        
        elseif commands[1] == "setcolor"
            if (lowercase(commands[2]) == "node")

                nodeLabel = String(commands[3])
                ind = findNodeIndexFromLabel(G, nodeLabel)

                if (ind != -1)
                    newFillCol = ""
                    newOutlineCol = ""
                    newLabelCol = ""    
                    
                    changeMe = String(lowercase(commands[4]))
                    newColor = String(lowercase(commands[5]))

                    if (changeMe == "fill")
                        newFillCol = newColor
                    elseif (changeMe == "ol")
                        newOutlineCol = newColor
                    elseif (changeMe == "label")
                        newLabelCol = newColor
                    end

                    updateNodeColor(G.nodes[ind], newFillCol, newOutlineCol, newLabelCol)

                else
                    println("Could not find $nodeLabel in graph.")
                    continue
                end

            elseif (lowercase(commands[2]) == "edge")
                sourceLabel = String(lowercase(commands[3]))
                destLabel = String(lowercase(commands[4]))
                newCol = String(lowercase(commands[5]))

                edgeInd = findEdgeIndex(G, sourceLabel, destLabel)

                if (edgeInd != -1)
                    G.edges[edgeInd].color = newCol
                end
            end

            displayGraph()
        
        elseif commands[1] == "toggle"
            if (lowercase(commands[2]) == "grid")
                global graphTicks = !graphTicks
            end

            displayGraph()
        elseif commands[1] == "add"
            if (lowercase(commands[2]) == "node")
                x = graphTicks #dummy code
            end
            if (lowercase(commands[2]) == "edge")
                x = graphTicks #dummy code
            end

            displayGraph()

        elseif commands[1] == "help"
            printHelp()
        else
            notFound = commands[1]
            println("Command $notFound was not found. Enter \"help\" to view valid commands")
            lastInputValid = false
        end
    catch e
        if debug
            rethrow(e)
        end
        println("Something went wrong. Be careful with the syntax")
        lastInputValid = false
    end
    
    if (!lastInputValid && !isempty(commandsHistory)) 
        pop!(commandsHistory)
    end
end