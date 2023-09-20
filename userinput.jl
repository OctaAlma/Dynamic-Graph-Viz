include("createEdges.jl")
include("varrad.jl")
include("vacRead.jl")

# NOTE: These are just sample values used for the DEMO

n = 10   # Number of nodes
r = n * 2    # The radius of the circle
k = 1.5    # there will be k * n edges in the output graph
filename::String = ""
degree = ones(n) # array used to keep track of the degree of each node

function printHelp()
    println("Currently supported commands:")
    println("\tdisplay                    - Output the graph to the window")
    println("\tsaveas FILENAME.png        - Saves the current graph to the specified filename")
    println("\texit                       - quits the program and the Julia repl")
    println("\tmove NODE_LABEL AXIS UNITS - Moves the node specified by NODE_LABEL in the AXIS direction by UNITS units")
    println("\trandomEdges                - regenerates random edges")
    println("\tcompleteEdges              - Adds one edge for every pair of nodes")
    println("\tcircularCoords             - Places all nodes in a cirlce")
    println("\tdegreeDependent            - Re-draws the graph for a degree-dependant radius approach")
    println()
    println("\tCOMING SOON:")
    println("\tload FILENAME")
    println("\tsaveGraph FILENAME ")
    println("\tremoveNode NODE_LABEL")
    println("\taddNode NODE_LABEL")
    println("\taddEdge START_NODE END_NODE")
    println("")
end

global edges = randomEdges(n, k, degree)

global xy = createDegreeDependantCoods(n, r, degree)

# work on user input modifications of graph
while true
    try
        test = drawGraph(xy, edges)
    catch
        printstyled("Graph could not be displayed.", color=:red)
    end
    print("\nEnter commands: ")
    
    try
        global input = readline()
        global linput = lowercase(input)

        global commands = split(input, " ")
        commands[1] = lowercase(commands[1])
        
        if commands[1] == "saveas"
            savefig(test, commands[2])
            display(drawGraph(xy, edges))

        elseif commands[1] == "move"
            # move NODE_LABEL X_OR_Y UNITS

            nodeLabel = parse(Int64, commands[2])
            xOrY = commands[3] 
            units = parse(Float64, commands[4])

            if (nodeLabel ∈ range(1,n))
                
                if (lowercase(xOrY) == "x")
                    xy[nodeLabel, 1] = xy[nodeLabel, 1] + units
                    print("Moved node $nodeLabel by $units units in $xOrY direction\n")

                elseif (lowercase(xOrY) == "y")

                    xy[nodeLabel, 2] = xy[nodeLabel, 2] + units
                    print("Moved node $nodeLabel by $units units in $xOrY direction\n")
                end
                drawGraph(xy, edges)
            end 

            display(drawGraph(xy, edges))

        elseif occursin("quit",commands[1]) ||  occursin("exit",commands[1])
            exit()
        
        elseif commands[1] == "display"
            display(drawGraph(xy, edges))
        
        elseif commands[1] == "circularcoords"
            global xy = createCircularCoords(n, r)
            display(drawGraph(xy, edges))
        
        elseif commands[1] == "degreedependent"
            global xy = createDegreeDependantCoods(n, r, degree)
            display(drawGraph(xy, edges))

        elseif commands[1] == "randomedges"
            global degree = ones(n)
            global edges = randomEdges(n, k, degree)
            display(drawGraph(xy, edges))
        
        elseif commands[1] == "completeedges"
            global degree = ones(n)
            global edges = completeEdges(n, degree)
            
            display(drawGraph(xy, edges))
        
        elseif commands[1] == "circularedges"
            global degree = 2 .* ones(n) 

            global edges = circleEdges(n, xy)
            
            display(drawGraph(xy, edges))

        elseif commands[1] == "load"
            global filename = commands[2]
            vacRead(filename)
        
        elseif commands[1] == "help"
            printHelp()
        else
            notFound = commands[1]
            println("Command $notFound was not found. Enter \"help\" to view valid commands")
        end
    catch
        println("Something went wrong. Be careful with the syntax")
    end
end