include("varrad.jl")
include("vacRead.jl")

# NOTE: These are just sample values used for the DEMO


filename::String = ""


global G = Graph()
global graphTicks = false

function pringtHelp()
    println("Currently supported commands:")
    println("\tdisplay                    - Output the graph to the window")
    println("\tsaveas FILENAME.png        - Saves the current graph to the specified filename")
    println("\texit                       - quits the program and the Julia repl")
    println("\tmove NODE_LABEL AXIS UNITS - Moves the node specified by NODE_LABEL in the AXIS direction by UNITS units")
    println("\trandomEdges                - regenerates random edges")
    println("\tcompleteEdges              - Adds one edge for every pair of nodes")
    println("\tcircularCoords             - Places all nodes in a circle")
    println("\tdegreeDependent            - Re-draws the graph for a degree-dependant radius approach")
    println("\tload FILENAME.vac          - Loads a Graph from a .vac file, IN PROGRESS")
    println()
    println("\tCOMING SOON:")
    
    println("\tsaveGraph FILENAME ")
    println("\tremoveNode NODE_LABEL")
    println("\tadd node NODE_LABEL")
    println("\tadd edge START_NODE END_NODE")
    println("")
end


# work on user input modifications of graph
while true
    try
        test = makePlot(G, graphTicks)
        print("Please load a graph (load) or add notes (add)")
    catch e
        printstyled("Graph could not be displayed.", color=:red)
        rethrow(e)
    end
    print("\nEnter commands: ")
    
    try
        global input = readline()
        global linput = lowercase(input)

        global commands = split(input, " ")
        commands[1] = lowercase(commands[1])
        
        if commands[1] == "saveas"
            savefig(test, commands[2])
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

        elseif commands[1] == "help"
            printHelp()
        else
            notFound = commands[1]
            println("Command $notFound was not found. Enter \"help\" to view valid commands")
        end
    catch e
        rethrow(e)
        println("Something went wrong. Be careful with the syntax")
    end
end