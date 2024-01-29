# There are 4 categories: load/save Graph, edit Graph, edit Coords, display

function printHelp(category="")
    # There are 4 categories: load/save Graph, edit Graph, edit Coords, display
    category = lowercase(category)
    print(category)
    if category == ""
        printAll()
    end
end

printLoadCommands() = println("""
\tload FILENAME.txt                          - Loads a Graph from an .txt file containing edge connections
\tload FILENAME.mxt                          - Loads a Graph from a .mtx file containing edge connections
\tload FILENAME.mat                          - Loads a Graph from a .mat file containing edge connections and (optionally) node coordinates
\tload FILENAME.vac                          - Loads a Graph from a .vac file
""")

printLoadxy() = println("""
\tloadxy FILENAME.txt                        - Loads node xy coordinates from a .txt file
""")

printSaveCommands() = println("""
\tsaveas FILENAME.pdf                        - Saves the current graph to a PDF file
\tsaveas FILENAME.png                        - Saves the current graph to an image PNG file
\tsaveas FILENAME.txt                        - Saves the current graph edge information to a .txt file
\tsaveas FILENAME.mtx                        - Saves the current graph edge information to a .mtx file
\tsaveas FILENAME.vac                        - Saves the current graph state information into a .vac file
""")

printSavexy() = println("""
\tsavexy FILENAME                            - Saves the XY coordinates of all nodes to the specified file
""")

printEdgesCommands() = println("""
\tedges circular                             - Changes edge structure so nodes are placed in circle
\tedges complete                             - Adds one edge for every pair of nodes
\tedges random                               - regenerates random edges"
""")

printsetColorCommands() = println("""\tsetColor node NODE fill NEW_COLOR          - Updates the fill color of specified NODE
\tsetColor node NODE OL NEW_COLOR            - Updates the outline color of the specified NODE
\tsetColor node NODE label NEW_COLOR         - Updates the color of the specified NODE label
\tsetColor edge SRC DST NEW_COLOR            - Updates the color of the edge between the SRC and DST
""")

printexitCommand() = println("""\texit                                       - quits the program and the Julia repl""")
printSleepCommand() = println("""\tsleep T                                    - Pauses execution for T seconds.""")

printviewCommands() = println("""
\tview default                               - Restores the view of the graph to the default view
\tview LABEL RADIUS                          - Centers the window view to the specified node
\tview CENTERx CENTERy RADIUS                - Centers the window view to (CENTERx, CENTERy)
""")

printmoveCommands() = println("""
\tmove NODE_LABEL AXIS UNITS                 - Moves the node specified by NODE_LABEL in the AXIS direction by UNITS units
\tmove node NODE_LABEL AXIS UNITS            - Alias of move command above
\tmove NODE_LABEL to xCoord yCoord           - Moves the node specified by NODE_LABEL to the position XCoord,Ycoord. xCoord or yCoord may be left blank to preserve that coordinate.
\tmove node NODE_LABEL to xCoord yCoord      - Alias of move command above
""")

printAddCommands() = println("""
\tadd edge SRC DST WEIGHT                    - Adds an edge from START_NODE to END_NODE
\tadd node                                   - Adds a node to the graph. Options: -l LABEL -s SIZE - oc OUTLINECOLOR -fc FILLCOLOR -lc LABELCOLOR -x xCOORD -y yCOORD
""")

printRemoveCommands() = println("""
\tremove edge SRC DST                        - Removes the edge connecting the nodes labeled SRC and DST
\tremove node LABEL                          - Removes the node with the label LABEL
""")


"Commands that interact with the filesystem to load edges, xy coordinates or both as well as saving graphs in various formats"
function printLoadSaveCommands()
    # Load commands
    println("\n---------- Load functions ----------")
    printLoadCommands()
    printLoadxy()
    # Save graph attribute commands or plot commands
    println("\n---------- Save functions ----------")
    printSaveCommands()
    printSavexy()
end

printSetCommands() = println("""
\tset node LABEL [OPTIONS]                   - Updates nodes to match any options provided.  Options: -l LABEL -s SIZE - oc OUTLINECOLOR -fc FILLCOLOR -lc LABELCOLOR -x xCOORD -y yCOORD
\tset edge SRC DST [OPTIONS]                 - Updates the edge to match any options provided. Options: -c COLOR -t THICKNESS -w WEIGHT (-lw is an allias for -t) 
""")

printGetCommands() = println("""
\tget node LABEL [OPTIONS]                   - Returns requested node information. Options: -l LABEL -s SIZE -oc OUTLINECOLOR -fc FILLCOLOR -lc LABELCOLOR -x xCOORD -y yCOORD
\tget edge SRC DST [OPTIONS]                 - Returns requested edge information. Options: -c COLOR -t THICKNESS -w WEIGHT (-lw is an allias for -t)
""")

printSetAllCommand() = println("""
\tsetall nodes [OPTIONS]                     - Updates all nodes in the graph to match the options provided. Options: -s SIZE -oc OUTLINECOLOR -fc FILLCOLOR -lc LABELCOLOR
\tsetall edges [OPTIONS]                     - Updates all edges in the graph to match the options provided. Options: -c COLOR -t THICKNESS -w WEIGHT (-lw is an allias for -t)
""")

printToggleCommands() = println("""
\ttoggle grid                                - Will toggle the grid to be on/off.
\ttoggle labels                              - Will toggle the labels to be on/off.
\ttoggle weights                             - Will toggle the weight view to be on/off. For unweighted graphs, weights are assumed to be 1.0.
""")

printUndoCommand() = println("""
\tundo                                       - Undoes the last command that changed the Graph object (not a system command) []
\tz                                          - Allias for the above command
""")
 
"Commands that affect the edges of nodes of the graph object"
function printEditGraphCommands()
    println("\n---------- Edit Graph functions ----------")
    printEdgesCommands()
    # Commands that add elements to the graph
    printAddCommands()
    printRemoveCommands()
    printUndoCommand()
end

printCircularLayoutCommand() = println("""
\tlayout circular                            - Places all nodes in a circle
""")

printDegreeLayoutCommand() = println("""
\tlayout degree                              - Places all nodes with a radius proportional to their degree
\tlayout degreedependent                     - Alias of the layout degree command
""")

printForceLayoutCommand() = println("""
\tlayout force                               - Updates the xy coordinates of all nodes in the graph according to a force-directed layout. Options: -e -iters -rep -attr
\tlayout force-directed                      - Alias of the layout force command
\tlayout forcedirected                       - Alias of the layout force command
""")

printSpectralLayoutCommand() = println("""
\tlayout spectral                            - Updates the xy coordinates of all nodes in the graph according to a spectral layout
""")

""
function printLayoutCommands()
    printCircularLayoutCommand()
    printDegreeLayoutCommand()
    printForceLayoutCommand()
    printSpectralLayoutCommand()
    
end

"Commands that affect the xy coordinatse of nodes in the graph"
function printEditCoordCommands()
    println("\n---------- Edit Coord. functions ----------")
    printmoveCommands()
    printLayoutCommands()
end

printDisplayHelp() = println("""
\tdisplay                                    - Output the graph to the window
""")

printClearGraphHelp() = println("""
\tclearGraph                                 - Clears the currently displayed graph
""")

printClearHelp() = println("""
\tclear                                      - Clears the current terminal window.
""")

"Commands that do not affect the xy positions of nodes or the edges of th graph object, but can affect the visuliaztion of the graph object."
function printDisplayCommands()
    println("\n---------- Display Commands ----------")
    printDisplayHelp()
    printClearGraphHelp()
    printviewCommands()
    printToggleCommands()

    printSetCommands()
    printGetCommands()

    printSetAllCommand()
    printsetColorCommands()
end



function printSystemCommands()
    println("---------- System Commands ----------")
    printexitCommand()
    printSleepCommand()
    printClearHelp()
end

function printAll()
    printLoadSaveCommands()
    printEditGraphCommands()
    printEditCoordCommands()
    printDisplayCommands()
    printSystemCommands()
    #printComingSoon()
end