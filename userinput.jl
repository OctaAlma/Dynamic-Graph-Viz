include("varrad.jl")
include("./loaders/vacLoader.jl")
include("./loaders/mtxLoader.jl")
include("./loaders/txtLoader.jl")
include("./loaders/matLoader.jl")
include("printCommands.jl")

# NOTE: These are just sample values used for the DEMO


filename::String = ""

global G = Graph()
empty!(G.edges)
empty!(G.nodes)

resourceDir = ""
global debug = false
global showTicks = true
global showLabels = true

global commandsHistory = []
global lastInputValid = false

function displayGraph()
    if (isnothing(G))
        println("There is nothing to plot")
        return
    end
    display(makePlot(G, showTicks, showLabels))
end

function genericLoad(filename::String, optFile::String = "")
    # Check the extension of filename
    extension = String(split(filename, ".")[end])

    # if on debug mode, should append ./resources/ to the filename
    filename = resourceDir * filename
    
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
    
    filename = resourceDir * filename

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
            # move node NODE_LABEL X_OR_Y UNITS
            
            # move LABEL to X Y
            # move node LABEL to X Y
            if majorCommand == 2
                
                continue
            end
            moveCoord = 2
            
            if "node" == commands[2]
                moveCoord = 3
            end

            nodeLabel = String(commands[moveCoord])
            index = findNodeIndexFromLabel(G, nodeLabel)

            if "to" == commands[moveCoord+1]
                xUnits = 0.0
                if commands[moveCoord+2] == "-"
                    xUnits = G.nodes[index].xCoord 
                else
                    xUnits = parse(Float64, commands[moveCoord+2])
                end
                
                yUnits = 0.0

                if commands[moveCoord+3] == "-"
                    yUnits = G.nodes[index].yCoord
                else
                    yUnits = parse(Float64, commands[moveCoord+3])
                end
                
                moveNode(G, nodeLabel, xUnits, yUnits)
            else
                xOrY = lowercase(commands[moveCoord+1]) 
                units = parse(Float64, commands[moveCoord+2])
                moveNode(G, nodeLabel, xOrY, units)
            end
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
        elseif commands[majorCommand] == "layout"
            if majorCommand == 2
                printLayoutCommands()
                continue
            end
            
            layoutType = lowercase(commands[2])

            if (layoutType == "circular")
                applyNewCoords(G, createCircularCoords(G))

            elseif (layoutType == "degree" || layoutType == "degreedependent")
                applyNewCoords(G, createDegreeDependantCoods(G))

            elseif (layoutType == "force-directed" || layoutType == "force" || layoutType == "forcedirected")
                # returns a vector containing [ε, K, rep, attr]
                forceDirArgs = parseForceDirectedArgs(commands)
                ε = forceDirArgs[1]
                K = floor(Int64, forceDirArgs[2])
                rep = forceDirArgs[3]
                attr = forceDirArgs[4]
                println("""Applying force-directed layout with parameters:
                   ⬗ Minimum force magnitude / ε = $ε
                   ⬗ Max Iterations = $K
                   ⬗ Repulsive factor = $rep
                   ⬗ Attractive factor = $attr """)

                forceDirectedCoords(G, ε, K, rep, attr)

            elseif (layoutType == "spectral")
                spectralCoords(G)
            end

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

            if (isnothing(G))
                global G = Graph()
                empty!(G.nodes)
                empty!(G.edges)
            end

            displayGraph()
        
        elseif commands[majorCommand] == "loadxy"
            if majorCommand == 2

                continue
            end
            # File containing the new XY values
            filenamexy = resourceDir * String(commands[2])
            txtReadXY(G, filenamexy)
            
            displayGraph()
        
        elseif commands[majorCommand] == "savexy"
            filename = resourceDir * String(commands[2])
            outputXY(G, filename)

        elseif commands[majorCommand] == "add"
            if majorCommand == 2
                printAddCommands()
                continue
            end
            # if (length(commands) == 2)
            #     println(commands)
            #     commands = split("add node "*commands[2])
            #     println(commands)
            # end
                
            if (lowercase(commands[2]) == "node")
                if (length(commands) == 3)
                    commands[2] = "-l"
                end
                addNode(G, commands)
                displayGraph()
                setGraphLimits(G)
            
            elseif (lowercase(commands[2]) == "edge" || length(commands) == 3)
                sourceNum = 3
                if (length(commands) == 3)
                    sourceNum = 2
                end
                sourceLabel = String(commands[sourceNum])
                destLabel = String(commands[sourceNum+1])
                weight = 1.
                
                if (G.weighted == true)
                    try
                        weight = parse(commands[sourceNum+2], Float64)
                    catch
                        println("Please specify edge weight after NODE_LABEL")
                        continue;
                    end
                end

                addEdge(G, sourceLabel, destLabel, weight)
            end

            displayGraph()
        elseif commands[majorCommand] == "remove"
            if majorCommand == 2
                printRemoveCommands() 
                continue
            end
            if (length(commands) == 2)
                label = String(commands[2])
                removeNode(G, label)
            elseif (lowercase(commands[2]) == "node")
                label = String(commands[3])
                removeNode(G, label)
            elseif (length(commands) == 3)
                sourceLabel = String(commands[2])
                destLabel = String(commands[3])
                removeEdge(G, sourceLabel, destLabel) 
            elseif (lowercase(commands[2]) == "edge" )
                sourceLabel = String(commands[3])
                destLabel = String(commands[4])
                removeEdge(G, sourceLabel, destLabel)
            end

            displayGraph()
        elseif commands[majorCommand] == "getnode"
            if majorCommand == 2
                
                continue
            end
            
            label = String(commands[majorCommand + 1])
            nodeInd = findNodeIndexFromLabel(G, label)

            if (nodeInd != -1)
                getNodeInfo(G.nodes[nodeInd], commands)
            end

        elseif commands[majorCommand] == "updatenode"
            if majorCommand == 2
                
                continue
            end
            
            label = String(commands[majorCommand + 1])
            nodeInd = findNodeIndexFromLabel(G, label)

            if (nodeInd != -1)
                updateNode(G.nodes[nodeInd], commands)
                displayGraph()
            else
                println("Please enter a valid node label.")
            end

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
                if (debug == false)
                    global resourceDir = "./resources/"
                    global debug = true
                    println("Debug mode ON")
                else
                    global resourceDir = ""
                    global debug = false
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
            printstyled("THIS COMMAND WILL CLEAR THE CURRENT GRAPH. THERE IS NO WAY TO RECOVER IT.\n"; color = :red)
            print("Please type ") 
            printstyled("\"YES\""; color = :green) 
            print(" to confirm you want the graph cleared: ")
            confirmation = readline()

            if lowercase(confirmation) == "yes"
                global G = Graph()
                empty!(G.nodes)
                empty!(G.edges)
            end

            displayGraph()
        elseif commands[majorCommand] == "repl"
            println("repl")
            

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