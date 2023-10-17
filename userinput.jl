include("varrad.jl")
include("vacLoader.jl")
include("mtxLoader.jl")
include("txtLoader.jl")
include("matLoader.jl")
include("printCommands.jl")

# NOTE: These are just sample values used for the DEMO


filename::String = ""

global G = Graph()
empty!(G.edges)
empty!(G.nodes)

global debug = false
global showTicks = true
global showLabels = true

global commandsHistory = []
global lastInputValid = false

function displayGraph()
    display(makePlot(G, showTicks, showLabels))
end

function genericLoad(filename::String, optFile::String = "")
    # Check the extension of filename
    extension = String(split(filename, ".")[end])
    
    if (extension == "vac")
        global G = vacRead(filename)
    elseif (extension == "mtx") || (extension == "txt")
        global G = mtxRead(filename)
    elseif (extension == "mat")
        global G = MATRead(filename)
    end
    setGraphLimits(G)
    displayGraph()

end

function genericSave(filename::String)
    # Check the extension of filename
    extension = String(split(filename, ".")[end])
    
    if (extension == "png" || extension == "pdf")
        savefig(makePlot(G, showTicks, showLabels), commands[2])
    elseif (extension == "vac")
        outputGraphToVac(G, filename)
    elseif (extension == "mtx" || extension == "txt")
        outputGraphToMtx(G, filename)
    else
        printstyled("Graph could not be saved with extention ",extension, color=:red)
    end
end

function printHelp(category="")
    # There are 4 categories: load/save Graph, edit Graph, edit Coords, display
    category = lowercase(category)
    print(category)
    if category == ""
        printAll()

    elseif category == "load"
        printLoadCommands()
    elseif category == "save"
        printSaveCommands()

    elseif category == "edit graph"
        printEditGraphCommands()

    elseif category == "edit xy"
        printEditCoordCommands()
    end
end


while true
    global lastInputValid
    print("\nEnter commands: ")
    
    try
        global lastInputValid = true

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

        majorCommand = 1
        if commands[1] == "help"
            if length(commands) < 2
                printHelp()
                continue
            else
                majorCommand = 2
            end
        end
        
        if commands[majorCommand] == "saveas" || commands[majorCommand] == "save"
            if majorCommand == 2
                printSaveommands()
                continue
            end
            genericSave(String(commands[2]))
            displayGraph()
            

        elseif commands[majorCommand] == "move"
            # move NODE_LABEL X_OR_Y UNITS
            if majorCommand == 2
                
                continue
            end
            moveCoord = 2
            if "node" == commands[2]
                moveCoord = 3
            end

            nodeLabel = String(commands[moveCoord])

            xOrY = lowercase(commands[moveCoord+1]) 
            units = parse(Float64, commands[moveCoord+2])

            moveNode(G, nodeLabel, xOrY, units)

            displayGraph()
            
        elseif occursin("quit",commands[majorCommand]) ||  occursin("exit",commands[majorCommand]) || commands[majorCommand] == "q"
            if majorCommand == 2
                printexitCommand()
                continue
            end
            exit()
        
        elseif commands[majorCommand] == "display" # Will display the current graph object
            if majorCommand == 2

                continue
            end
            displayGraph()
        
        elseif commands[majorCommand] == "circularcoords" # will update the xy coordinates for the node in a graph
            if majorCommand == 2

                continue
            end
            # xy = createCircularCoords(G)   
            # updateGraphNodes(G, xy)
            applyNewCoords(G, createCircularCoords(G))
            displayGraph()
        
        elseif commands[majorCommand] == "degreedependent"
            if majorCommand == 2

                continue
            end
            # xy = createDegreeDependantCoods(G)
            # updateGraphNodes(G, xy)
            applyNewCoords(G, createDegreeDependantCoods(G))
            displayGraph()

        elseif commands[majorCommand] == "randomedges"
            if majorCommand == 2

                continue
            end
            updateGraphEdges(G, randomEdges(G))
            displayGraph()
        
        elseif commands[majorCommand] == "completeedges"
            if majorCommand == 2

                continue
            end
            updateGraphEdges(G,completeEdges(G))
            displayGraph()
        
        elseif commands[majorCommand] == "circularedges"
            if majorCommand == 2

                continue
            end
            updateGraphEdges(G, circleEdges(G)  )
            displayGraph()

        elseif commands[majorCommand] == "load"
            if majorCommand == 2

                continue
            end
            global filename = commands[2]
            if length(commands)>2
                genericLoad(filename,String(commands[3]))
            else
                genericLoad(filename)
            end
            displayGraph()
        
        elseif commands[majorCommand] == "loadxy"
            if majorCommand == 2

                continue
            end
            xyFile = String(commands[2])
            txtReadXY(G, xyFile)
            
            displayGraph()

        elseif commands[majorCommand] == "add"
            if majorCommand == 2

                continue
            end
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
                addNode(G, commands)
                displayGraph()
            end

            displayGraph()
        elseif commands[majorCommand] == "remove"
            if majorCommand == 2

                continue
            end
            if (lowercase(commands[2]) == "edge")
                sourceLabel = String(commands[3])
                destLabel = String(commands[4])

                removeEdge(G, sourceLabel, destLabel)

            elseif (lowercase(commands[2]) == "node")
                label = String(commands[3])
                removeNode(G, label)
            end

            displayGraph()
        
        elseif commands[majorCommand] == "setcolor"
            if majorCommand == 2

                continue
            end
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
        
        elseif commands[majorCommand] == "toggle"
            if majorCommand == 2

                continue
            end

            if (lowercase(commands[2]) == "grid")
                global showTicks = !showTicks
            
            elseif (commands[2] == "labels")
                global showLabels = !showLabels
            elseif (commands[2] == "debug")
                global debug = !debug
                if (debug)
                    println("Debug mode ON")
                else
                    println("Debug mode OFF")
                end
            end
            
            displayGraph()
        elseif commands[majorCommand] == "view"
            if majorCommand == 2

                continue
            end
            
            if (lowercase(commands[2]) == "default")
                setGraphLimits(G)
            else
                if (length(commands) == 4)
                    # view CENTERx CENTERy RADIUS
                    centerX = parse(Float64, commands[2])
                    centerY = parse(Float64, commands[3])
                    radius = parse(Float64, commands[4])
                    applyView(G, centerX, centerY, radius)
                
                elseif (length(commands) == 3)
                    # view NODE_ID RADIUS
                    nodeLabel = String(commands[2])
                    radius = parse(Float64, commands[3])
                    
                    applyView(G, nodeLabel, radius)
                end
            end

            displayGraph()
        
        elseif commands[majorCommand] == "cleargraph"
            println("THIS COMMAND WILL CLEAR THE CURRENT GRAPH. THERE IS NO WAY TO RECOVER IT.")
            print("Please type \"YES\" to confirm you want the graph cleared: ")
            confirmation = readline()

            if lowercase(confirmation) == "yes"
                global G = Graph()
                empty!(G.nodes)
                empty!(G.edges)
            end

            displayGraph()

        elseif majorCommand == 2
                printHelp(String(commands[2]))
        
        
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