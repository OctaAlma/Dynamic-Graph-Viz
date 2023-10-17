# There are 4 categories: load/save Graph, edit Graph, edit Coords, display

#=
    println("\tCOMING SOON:")
    println("\t   remove node NODE_LABEL")
    println("\t   add node NODE_LABEL")


    
=#

loadhelpStr = 
"""
\n---------- Load functions ----------------------------------------------------------------------------------
\tload FILENAME.txt                          - Loads a Graph from an .mtx file containing edge connections
\tload FILENAME.mxt                          - Loads a Graph from a .txt file containing edge connections
\tload FILENAME.mat                          - Loads a Graph from a .mat file containing edge connections and (optionally) node coordinates
\tload FILENAME.vac                          - Loads a Graph from a .vac file
\tloadxy FILENAME.txt                        - Loads node xy coordinates from a .txt file"""

savehelpStr = """
\n---------- Save functions ----------------------------------------------------------------------------------
\tsaveas FILENAME.pdf                        - Saves the current graph to an image PNG file"
\tsaveas FILENAME.png                        - Saves the current graph to an image PNG file
\tsaveas FILENAME.txt                        - Saves the current graph edge information to a .txt file
\tsaveas FILENAME.mtx                        - Saves the current graph edge information to a .mtx file
\tsaveas FILENAME.vac                        - Saves the current graph state into a .vac file"""

randomEdgeshelpStr = """\trandomEdges                                - regenerates random edges"""

completeEdgeshelpStr = """\tcompleteEdges                              - Adds one edge for every pair of nodes"""

circularEdgeshelpStr = """\tcircularEdges                              - Changes edge structure so nodes are placed in circle"""

setColorhelpStr = """\tsetColor node NODE fill NEW_COLOR          - Updates the fill color of specified NODE
\tsetColor node NODE OL NEW_COLOR            - Updates the outline color of the specified NODE
\tsetColor node NODE label NEW_COLOR         - Updates the color of the specified NODE label
\tsetColor edge SOURCE DEST NEW_COLOR        - Updates the color of the edge between the SOURCE and DEST
"""
exitCommandhelpStr = """\texit                                       - quits the program and the Julia repl"""

function printLoadCommands()
    println(loadhelpStr)
end

function printSaveommands()
    println(savehelpStr)
end

"Commands that interact with the filesystem to load edges, xy coordinates or both as well as saving graphs in various formats"
function printLoadSaveCommands()
    # Load commands
    printLoadCommands()
    # Save graph attribute commands or plot commands
    printSaveommands()
end

"Commands that affect the edges of nodes of the graph object"
function printEditGraphCommands()
    println(randomEdgeshelpStr)
    println(completeEdgeshelpStr)
    println(circularEdgeshelpStr)

    # Commands that add elements to the graph
    println("\tadd edge SOURCE DEST WEIGHT                  - Adds an edge from START_NODE to END_NODE")   
    println("\tadd node -l label -s size - oc outlineColor -fc fillColor -lc labelColor -x xCoord -y yCoords")

    println("\tremove edge SOURCE DEST                       - Removes the edge connecting the nodes labeled SOURCE and DEST")   
    println("\tremove node LABEL                             - Removes the node with the label LABEL")
end

"Commands that affect the xy coordinatse of nodes in the graph"
function printEditCoordCommands()
    println("\tmove NODE_LABEL AXIS UNITS                 - Moves the node specified by NODE_LABEL in the AXIS direction by UNITS units")
    println("\tmove node NODE_LABEL AXIS UNITS            - Alias of move command above")
    
    println("\tcircularCoords                             - Places all nodes in a circle")
    println("\tdegreeDependent                            - Re-draws the graph for a degree-dependant radius approach")
end

function printsetColorCommands()
    println(setColorhelpStr)
end

"Commands that do not affect the xy positions of nodes or the edges of th graph object, but can affect the visuliaztion of the graph object."
function printDisplayCommands()
    println("\tdisplay                                    - Output the graph to the window")
    println("\tclearGraph                                 - Clears the currently displayed graph")

    
    println("\tview default                               - Restores the view of the graph to the default view")
    println("\tview LABEL RADIUS                          - Centers the window view to the specified node")
    println("\tview CENTERx CENTERy RADIUS                - Centers the window view to (CENTERx, CENTERy)")

    println("\ttoggle grid                                - Will toggle the grid to be on/off")
    println("\ttoggle labels                              - Will toggle the labels to be on/off")
    printsetColorCommands()

end

function printexitCommand()
    println(exitCommandhelpStr)
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
    printComingSoon()
end