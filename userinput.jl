include("varrad.jl")
include("vacRead.jl")

# NOTE: These are just sample values used for the DEMO


filename::String = ""


global G = Graph()
global graphTicks = true

function printHelp()
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
    println("\t   removeNode NODE_LABEL")
    println("\t   add node NODE_LABEL")

    println("")
end


# work on user input modifications of graph
while true
    try
        print("Please load a graph (load) or add notes (add)")
    catch e
        printstyled("Graph could not be displayed.", color=:red)
        rethrow(e)
    end
    print("\n\nEnter commands: ")
    
    try
        global input = readline()
        global linput = lowercase(input)

        global commands = split(input, " ")
        commands[1] = lowercase(commands[1])
        
        if commands[1] == "saveas"
            savefig(makePlot(G, graphTicks), commands[2])
            display(makePlot(G, graphTicks))

        elseif commands[1] == "move"
            # move NODE_LABEL X_OR_Y UNITS

            nodeLabel = parse(Int64, commands[2])
            xOrY = lowercase(commands[3]) 
            units = parse(Float64, commands[4])

            moveNode(G, nodeLabel, xOrY, units)
            display(makePlot(G, graphTicks))
            
        elseif occursin("quit",commands[1]) ||  occursin("exit",commands[1])
            exit()
        
        elseif commands[1] == "display" # Will display the current graph object
            display(makePlot(G, graphTicks))
        
        elseif commands[1] == "circularcoords" # will update the xy coordinates for the node in a graph
            xy = createCircularCoords(G)   
            updateGraphNodes(G, xy)
            display(makePlot(G, graphTicks))
        
        elseif commands[1] == "degreedependent"
            xy = createDegreeDependantCoods(G)
            updateGraphNodes(G, xy)
            display(makePlot(G, graphTicks))

        elseif commands[1] == "randomedges"
            
            edges = randomEdges(G)
            updateGraphEdges(G, edges)

            display(makePlot(G, graphTicks))
        
        elseif commands[1] == "completeedges"
            edges = completeEdges(G)
            updateGraphEdges(G,edges)
            display(makePlot(G, graphTicks))
        
        elseif commands[1] == "circularedges"
            edges = circleEdges(G)  
            updateGraphEdges(G, edges)
            display(makePlot(G, graphTicks))

        elseif commands[1] == "load"
            global filename = commands[2]
            global G = vacRead(filename)
            display(makePlot(G, graphTicks))
        
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

            display(makePlot(G, graphTicks))
        elseif commands[1] == "remove"
            if (lowercase(commands[2]) == "edge")
                sourceLabel = String(commands[3])
                destLabel = String(commands[4])

                removeEdge(G, sourceLabel, destLabel)

            elseif (lowercase(commands[2]) == "node")
                println("remove node is coming soon...")

            end

            display(makePlot(G, graphTicks))
        
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

            display(makePlot(G, graphTicks))
        
        elseif commands[1] == "toggle"
            if (lowercase(commands[2]) == "grid")
                global graphTicks = !graphTicks
            end

            display(makePlot(G, graphTicks))

        elseif commands[1] == "help"
            printHelp()
        else
            notFound = commands[1]
            println("Command $notFound was not found. Enter \"help\" to view valid commands")
        end
    catch e
        #rethrow(e)
        println("Something went wrong. Be careful with the syntax")
    end
end