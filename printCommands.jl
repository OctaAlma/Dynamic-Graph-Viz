# There are 4 categories: load/save Graph, edit Graph, edit Coords, display

#=
    println("\tCOMING SOON:")
    println("\t   remove node NODE_LABEL")
    println("\t   add node NODE_LABEL")


    
=#


printLoadCommands() = println("""
\n---------- Load functions ----------------------------------------------------------------------------------
\tload FILENAME.txt                          - Loads a Graph from an .mtx file containing edge connections
\tload FILENAME.mxt                          - Loads a Graph from a .txt file containing edge connections
\tload FILENAME.mat                          - Loads a Graph from a .mat file containing edge connections and (optionally) node coordinates
\tload FILENAME.vac                          - Loads a Graph from a .vac file
""")
printLoadxy() = println("\tloadxy FILENAME.txt                        - Loads node xy coordinates from a .txt file")

printSaveCommands() = println("""
\n---------- Save functions ----------------------------------------------------------------------------------
\tsaveas FILENAME.pdf                        - Saves the current graph to a PDF file"
\tsaveas FILENAME.png                        - Saves the current graph to an image PNG file
\tsaveas FILENAME.txt                        - Saves the current graph edge information to a .txt file
\tsaveas FILENAME.mtx                        - Saves the current graph edge information to a .mtx file
\tsaveas FILENAME.vac                        - Saves the current graph state information into a .vac file
""")
printSavexy() = println("\tsavexy FILENAME                            - Saves the XY coordinates of all nodes to the specified file")

printEdgesCommands() = println("""\tcircularEdges                              - Changes edge structure so nodes are placed in circle
\tcompleteEdges                              - Adds one edge for every pair of nodes
\trandomEdges                                - regenerates random edges"
""")


printsetColorCommands() = println("""\tsetColor node NODE fill NEW_COLOR          - Updates the fill color of specified NODE
\tsetColor node NODE OL NEW_COLOR            - Updates the outline color of the specified NODE
\tsetColor node NODE label NEW_COLOR         - Updates the color of the specified NODE label
\tsetColor edge SRC DST NEW_COLOR        - Updates the color of the edge between the SOURCE and DEST
""")

printexitCommand() = println("""\texit                                       - quits the program and the Julia repl""")

viewCommandhelpStr ="""\tview default                               - Restores the view of the graph to the default view
\tview LABEL RADIUS                          - Centers the window view to the specified node
\tview CENTERx CENTERy RADIUS                - Centers the window view to (CENTERx, CENTERy)
"""
printviewCommands() = println(viewCommandhelpStr)

moveCommandhelpStr = """\tmove NODE_LABEL AXIS UNITS                 - Moves the node specified by NODE_LABEL in the AXIS direction by UNITS units
\tmove node NODE_LABEL AXIS UNITS            - Alias of move command above
\tmove NODE_LABEL to XCoord Ycoord           - Moves the node specified by NODE_LABEL to the position XCoord,Ycoord. One of XCoord and YCoord may be left blank to preserve that coordinate.
\tmove node NODE_LABEL to XCoord Ycoord      - Alias of move command above
"""
printmoveCommands() = println(moveCommandhelpStr)

addCommandhelpStr = """\tadd edge SRC DST WEIGHT                - Adds an edge from START_NODE to END_NODE
\tadd node                                   - Adds a node to the graph. Options: -l LABEL -s SIZE - oc OUTLINECOLOR -fc FILLCOLOR -lc LABELCOLOR -x xCOORD -y yCOORD
"""
printAddCommands() = println(addCommandhelpStr)

removeCommandhelpStr = """\tremove edge SRC DST                    - Removes the edge connecting the nodes labeled SOURCE and DEST
\tremove node LABEL                          - Removes the node with the label LABEL
"""
printRemoveCommands() = println(removeCommandhelpStr)

CommandhelpStr = """"""
CommandhelpStr = """"""











"Commands that interact with the filesystem to load edges, xy coordinates or both as well as saving graphs in various formats"
function printLoadSaveCommands()
    # Load commands
    printLoadCommands()
    printLoadxy()
    # Save graph attribute commands or plot commands
    printSaveCommands()
    printSavexy()
end

function printSetCommands()
    printsetNodeCommand()
    printsetEdgeCommand()
end

function printGetCommands()
    printgetNodeCommand()
    printgetEdgeCommand()  
end

printsetNodeCommand() = print("""\tset node LABEL [OPTIONS]              Updates nodes to match any options provided.  Options: -l LABEL -s SIZE - oc OUTLINECOLOR -fc FILLCOLOR -lc LABELCOLOR -x xCOORD -y yCOORD
""")
printgetNodeCommand() = print("""\tget node LABEL [OPTIONS]               Returns requested node information. Options: -l LABEL -s SIZE -oc OUTLINECOLOR -fc FILLCOLOR -lc LABELCOLOR -x xCOORD -y yCOORD
""")
printsetEdgeCommand() = print("""\tset edge SRC DST [OPTIONS]              Updates the edge to match any options provided. Options: -c COLOR -t LINETHICKNESS -w EDGEWEIGHT (-lw is an allias for -t) 
""")
printgetEdgeCommand() = print("""get edge SRC DST [OPTIONS]               Returns requested edge information. Options: -c COLOR -t LINETHICKNESS -w EDGEWEIGHT (-lw is an allias for -t)
""")




 
"Commands that affect the edges of nodes of the graph object"
function printEditGraphCommands()
    printEdgesCommands()
    # Commands that add elements to the graph
    printAddCommands()
    printRemoveCommands()
    printNodeEditCommands()
end
circularCommandhelpStr= "\tlayout circular                            - Places all nodes in a circle"
printCircularLayoutCommand() = println(circularCommandhelpStr)

degreeCommandhelpStr= """\tlayout degree                              - Places all nodes with a radius proportional to their degree
\tlayout degreedependent                     - Alias of the above command
"""
printDegreeLayoutCommand() = println(degreeCommandhelpStr)

forceCommandhelpStr = """\tlayout force                               - Updates the xy coordinates of all nodes in the graph according to a force-directed layout. Options: -e -iters -rep -attr
\tlayout force-directed                      - Alias of the layout force command
\tlayout forcedirected                       - Alias of the layout force command
"""
printForceLayoutCommand() = println(forceCommandhelpStr)

spectralCommandhelpStr = """\tlayout spectral                            - Updates the xy coordinates of all nodes in the graph according to a spectral layout
"""
printSpectralLayoutCommand() = println(spectralCommandhelpStr)

""
function printLayoutCommands()
    printCircularLayoutCommand()
    printDegreeLayoutCommand()
    printForceLayoutCommand()
    printSpectralLayoutCommand()
    
end

"Commands that affect the xy coordinatse of nodes in the graph"
function printEditCoordCommands()
    printmoveCommands()
    printLayoutCommands()
end



"Commands that do not affect the xy positions of nodes or the edges of th graph object, but can affect the visuliaztion of the graph object."
function printDisplayCommands()
    println("\tdisplay                                    - Output the graph to the window")
    println("\tclearGraph                                 - Clears the currently displayed graph")
    printviewCommands()
    println("\ttoggle grid                                - Will toggle the grid to be on/off")
    println("\ttoggle labels                              - Will toggle the labels to be on/off")
    printsetColorCommands()

end



function printSystemCommands()
    printexitCommand()
end

function printAll()
    printLoadSaveCommands()
    printEditGraphCommands()
    printEditCoordCommands()
    printDisplayCommands()
    printSystemCommands()
    #printComingSoon()
end