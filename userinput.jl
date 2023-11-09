include("./loaders/vacLoader.jl")
include("./loaders/mtxLoader.jl")
include("./loaders/txtLoader.jl")
include("./loaders/matLoader.jl")
include("printCommands.jl")

# NOTE: These are just sample values used for the DEMO

filename::String = ""

resourceDir = ""
global debug = false 
global showTicks = true
global showLabels = true
global commandsHistory = []
global sessionCommands = []
global commandQueue = []
global graphStack = []
global lastInputValid = false
global sleepInterval = 0
global maxGraphStackSize = 10
global G = Graph()

global emptyGraph = Graph()
empty!(emptyGraph.nodes)
empty!(emptyGraph.edges)
global emptyGraphStack = [emptyGraph]

empty!(G.edges)
empty!(G.nodes)
push!(graphStack, G)

if ("debug" in ARGS || "-d" in ARGS )
    global resourceDir = "./resources/"
    global debug = true
    println("Debug mode ON")
end

if ("load" in ARGS || "-l" in ARGS )
    println("Load not yet implemented")
end

if ("tiggle-grod" in ARGS)
    println("Tiggle Grod")
    #do something
end

function outputGraphToVacs(filepath::String)
    try
        open(filepath, "w") do file
            println("Saving command history to ", filepath, "...")
            for command in sessionCommands
                if !occursin("save",command) && !occursin("saveas",command) 
                    writeMe = "$command\n"
                    write(file, writeMe)
                end
            end
        end
    catch e
        println(filepath, " could not be created.")
    end
end

function scriptloader(filepath::String)
    try
        open(filepath) do file
            for currLine in readlines(file)
                push!(commandQueue,String(currLine))
            end
        end
    catch e
        println(filepath, " could not be loaded.")
    end
end

function displayGraph()
    if (isnothing(G))
        global G = Graph()
        empty!(G.nodes)
        empty!(G.edges)
    end
    display(makePlot(G, showTicks, showLabels))
end

function genericLoad(filename::String)
    # Check the extension of filename
    extension = String(split(filename, ".")[end])

    # if on debug mode, should append ./resources/ to the filename
    filename = resourceDir * filename
    
    if (extension == "vac")
        global G = vacRead(filename)
    elseif (extension == "vacs")
        scriptloader(filename)
    elseif (extension == "mtx") || (extension == "txt")
        global G = mtxRead(filename)
    elseif (extension == "mat")
        global G = MATRead(filename)
    end

    if (isnothing(G))
        println("Load Failed, Constructing empty Graph...")
        global G = Graph()
        empty!(G.nodes)
        empty!(G.edges)
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
    elseif (extension == "vacs")
        outputGraphToVacs(filename)
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
    
    # elseif category == "load"
    #     printLoadCommands()
    # elseif category == "save"
    #     printSaveCommands()

    # elseif category == "edit graph"
    #     printEditGraphCommands()

    # elseif category == "edit xy"
    #     printEditCoordCommands()
    end
end

global executingScript = false
while true
    global executingScript
    global lastInputValid
    global sleepInterval
    
    executingScript = false
    if !isempty(commandQueue)
        executingScript = true
    end

    if !executingScript
        print("\nEnter a command: ")
    else
        sleep(sleepInterval)
    end

    if (isnothing(G)) # G can sometimes become nothing if any a function returns nothing
        global G = Graph()
        empty!(G.nodes)
        empty!(G.edges)
    end
    
    try
        global lastInputValid = true        

        global input = if executingScript popfirst!(commandQueue) else readline() end
        
        global commands = split(input, " ")
    
        #TODO remove *any number of consecutive whitespace
        if commands[1] == ""
            if !isempty(commandsHistory)
                push!(commandsHistory,last(commandsHistory))
                push!(sessionCommands,last(commandsHistory))
                commands = split(last(commandsHistory), " ")
            else
                println("No Commands in History")
            end
        elseif !executingScript
            push!(commandsHistory,input)
            push!(sessionCommands,input)
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
        
        if (commands[majorCommand] == "undo" || commands[majorCommand] == "z")
            if majorCommand == 2
                printUndoCommand()
                continue
            end
            
            if (!isempty(graphStack))
                if (graphStack == emptyGraphStack)
                    global G = deepcopy(emptyGraph)
                else
                    global G = pop!(graphStack)
                end
            else
                println("Undo history is empty. ")
            end

            displayGraph()
            continue
            
        elseif (!isempty(graphStack) && G != graphStack[end])
            while (length(graphStack) >= maxGraphStackSize)
                popfirst!(graphStack)
            end
            push!(graphStack, deepcopy(G))
        end

        if commands[majorCommand] == "saveas" || commands[majorCommand] == "save"
            if majorCommand == 2
                printSaveCommands()
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
                printmoveCommands() 
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
                printDisplayHelp() 
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

            setGraphLimits(G)
            displayGraph()
        
        elseif commands[majorCommand] == "edges"
            if majorCommand == 2
                printEdgesCommands()
                continue
            end
            if (commands[majorCommand+1] == "circle" || commands[majorCommand+1] == "circular" || commands[majorCommand+1] == "circ" || commands[majorCommand+1] == "cir")
                updateGraphEdges(G, circleEdges(G))
            elseif (commands[majorCommand+1] == "complete" || commands[majorCommand+1] == "comp" || commands[majorCommand+1] == "com")
                updateGraphEdges(G,completeEdges(G))
            elseif (commands[majorCommand+1] == "random" || commands[majorCommand+1] == "rand" || commands[majorCommand+1] == "ran" || commands[majorCommand+1] == "r")
                updateGraphEdges(G, randomEdges(G))
            end
            
            displayGraph()    
            

        elseif commands[majorCommand] == "load"
            if majorCommand == 2
                printLoadCommands()
                continue
            end
            global filename = commands[2]
            if length(commands) > 2
                global sleepInterval = parse(Float64, commands[3])
            end
            genericLoad(filename)
            

            if (isnothing(G))
                global G = Graph()
                empty!(G.nodes)
                empty!(G.edges)
            end

            displayGraph()
        
        elseif commands[majorCommand] == "loadxy"
            if majorCommand == 2
                printLoadxy()
                continue
            end
            # File containing the new XY values
            filenamexy = resourceDir * String(commands[2])
            txtReadXY(G, filenamexy)
            
            displayGraph()
        
        elseif commands[majorCommand] == "savexy"
            if majorCommand == 2
                printSavexy()
                continue
            end
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
                setGraphLimits(G)
                displayGraph()
            
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
                        weight = parse(Float64, commands[sourceNum+2])
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
        elseif commands[majorCommand] == "get"
            if majorCommand == 2
                printGetCommands()
                continue
            end
            getWhat = lowercase(String(commands[majorCommand + 1]))
            if (getWhat == "node")
                label = String(commands[majorCommand + 2])
                nodeInd = findNodeIndexFromLabel(G, label)

                if (nodeInd != -1)
                    println("Requested Info for node: ",label)
                    getNodeInfo(G.nodes[nodeInd], commands)
                end
            elseif (getWhat == "edge")
                src = String(commands[majorCommand + 2]) #should these be pasred 
                dst = String(commands[majorCommand + 3])
                #nodeInd = findNodeIndexFromLabel(G, label) #figure out how to get edge
                #TODO add a function to Graph.jl that takes 2 node labels and returns an edge
                if (nodeInd != -1)
                    println("Requested Info for edge: ",src,dst)
                    println("Not yet Implemented")
                    #getNodeInfo(G.nodes[nodeInd], commands) # change getNodeInfo to getEdgeInfo
                end
            else
                println("Please specify whether you want to set node or set edge.")
            end

        elseif commands[majorCommand] == "set"
            if majorCommand == 2
                printSetCommands()
                continue
            end

            # did they write "set node ..." or "set edge ..."?
            editMe = lowercase(String(commands[majorCommand + 1]))

            if (editMe == "node")
                # set node LABEL -lc -fc -oc -s
                setNode(G, commands)

            elseif (editMe == "edge")
                # set edge SOURCE DEST -c -w -t/-lw
                setEdge(G, commands)

            else
                println("Please specify whether you want to set node or set edge.")
            end

            displayGraph()

        elseif commands[majorCommand] == "setcolor"
            if majorCommand == 2
                printsetColorCommands()
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
        
        elseif commands[majorCommand] == "setall"
            if majorCommand == 2
                printSetAllCommand()
                continue
            end

            if (length(commands) >= 2)
                whatToSet = lowercase(String(commands[2]))

                if (whatToSet == "node" || whatToSet == "nodes")
                    setAllNodes(G, commands)

                elseif (whatToSet == "edge" || whatToSet == "edges")
                    setAllEdges(G, commands)

                else
                    println("Second command must be \"nodes\" or \"edges\" followed by the options.")
                end
            else
                println("Not enough commands provided for setall. Please enter \"help\" for documentation.")
            end

            displayGraph()

        elseif commands[majorCommand] == "toggle"
            if majorCommand == 2
                printToggleCommands()
                continue
            end

            if (lowercase(commands[2]) == "grid")
                global showTicks = !showTicks
            
            elseif (lowercase(commands[2]) == "labels")
                global showLabels = !showLabels

            elseif (lowercase(commands[2]) == "weights")
                G.weighted = !G.weighted

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
                printviewCommands()
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
        elseif commands[majorCommand] == "sleep"
            if majorCommand == 2
                printSleepCommand()
                continue
            end
            sleep(parse(Float64,commands[majorCommand+1]))
        
        elseif commands[majorCommand] == "cleargraph"
            if majorCommand == 2
                printClearGraphHelp()
                continue
            end
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
        
        elseif commands[majorCommand] == "clear"
            if majorCommand == 2
                printClearHelp()
                continue
            end
            run(Cmd(`clear`, dir="./"))
            
        elseif commands[majorCommand] == "repl"
            if majorCommand == 2
                # printviewCommands()
                continue
            end
            run(Cmd(`julia`, dir="./"))
        elseif commands[majorCommand] == "instance"
            if majorCommand == 2
                printviewCommands()
                continue
            end
            run(Cmd(`julia userinput.jl`, dir="./"))
        
        # easter egg:
        elseif commands[majorCommand] == "tiggle"
            if commands[majorCommand + 1] == "grod"                
                run(Cmd(`julia userinput.jl tiggle-grod`, dir="./"))
            end

       
        
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
        println("Something went wrong. Try the help command.")
        lastInputValid = false
    end
    
    if (!lastInputValid && !isempty(commandsHistory)) 
        pop!(commandsHistory)
    end

    
end