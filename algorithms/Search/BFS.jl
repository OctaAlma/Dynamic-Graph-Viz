using DataStructures
include("../../GraphPlots.jl")
include("./VisualizationTools.jl")
include("../../loaders/vacLoader.jl")

#= 
We can store graph states in a sparse matrix that keeps track of changes in the label
The pros: 
 - Very space efficient
 - instant lookup to a specific state

The cons: 
 - We can only store float and int values in sparse matrices. This means strings must be stored in some other separate data structure
 - If we wanted to plot a specific data structure, we would have to start from the original graph state, then apply every step

Current approach: Store the whole graph after important steps in an algorithm
Cons:
 - VERY space inneficient

Pros:
 - Instant access to a specific graph state
=#

function makeVizPlot(gs::GraphState, showTicks=false, showLabels=true; DPI=250)::Plots.Plot{Plots.GRBackend} 
    gr()
    graphPlot = plot(dpi = DPI)
    g = gs.G
    k = 0.25
    initPlot(graphPlot, g, k, showTicks)

    if isempty(g.nodes)
        return graphPlot
    end

    n = length(g.nodes)
    xy = zeros(n, 2)
    plot_font = "computer modern"
    txtsize = 6

    plotDataStructure(graphPlot, gs)

    # Populate the xy 2-dimmensional vector. The ith entry corresponds to the ith node's (x,y) coordinates    
    for currNode in g.nodes
        xy[currNode.index, :] = [currNode.xCoord, currNode.yCoord]
    end

    # Populate the edges vector and plot the edges
    if (g.directed)
        plotDirectedEdges2(graphPlot, g, xy)
    else
        plotUndirectedEdges(graphPlot, g, xy)
    end
    
    #Plot the xy circles and node labels
    i = 1
    for currNode in g.nodes
        xyForNode = zeros(1, 2)
        xyForNode[1,:] = [currNode.xCoord, currNode.yCoord]
        
        outlineThickness = 1.0
        if (currNode.outlineColor == "Black")
            outlineThickness = 3.0
        end

        nodeSize = 25

        scatter!(graphPlot, xyForNode[:,1], xyForNode[:,2], markersize = nodeSize, color = currNode.fillColor, markerstrokecolor = currNode.outlineColor, markerstrokewidth=outlineThickness)
        
        if (showLabels == true)
            fullLabel = currNode.label * "\n" * gs.nodeLabels[i]
            annotate!(graphPlot, currNode.xCoord, currNode.yCoord, text(fullLabel, plot_font, txtsize, color=currNode.labelColor))
            i = i + 1
        end
    end

    return graphPlot
end

rect(w, h, x, y) = Shape(x .+ [0, w, w, 0, 0], y .+ [0, 0, h, h, 0])

function plotDataStructure(p, gs; maxEntries = 7, hlFirstEntry = false)
    
    # Create and plot the rectangle containing the data structure's elements:
    w = abs(gs.G.xMax - gs.G.xMin)
    h = abs(gs.G.yMax - gs.G.yMin) * 0.1
    
    yMaxBox = gs.G.yMin - h
    yMinBox = gs.G.yMin - 2 * h
    yMidBox = (yMaxBox + yMinBox) / 2.0

    queueBox = rect(w, h, gs.G.xMin, yMinBox)
    plot!(p, queueBox, fillcolor = "light grey")

    # dividerXs contains an array of equally spaced values that represent where the dividers 
    # separating the contents of the queue should be placed on the rectangle
    dividerXs = nothing 
    
    dividerXs = LinRange(gs.G.xMin, gs.G.xMax, maxEntries + 1)

    # We want to plot a line that goes from the (dividerXs[i], yMinBox) to (dividerXs[i], yMaxBox)
    xyBottom = zeros(length(dividerXs), 2)
    xyTop = zeros(length(dividerXs), 2)
    xyMid = []

    # Populate the xy 2-dimmensional vector. The ith entry corresponds to the ith node's (x,y) coordinates    
    i = 1
    xPrev = nothing
    for xi in dividerXs
        xyBottom[i, :] = [xi, yMinBox]
        xyTop[i, :] = [xi, yMaxBox]

        if (i > 1)
            push!(xyMid, (xi + xPrev) / 2.0)
        end

        xPrev = xi
        i = i + 1
    end

    for i in 1:maxEntries
        plot!(p,[xyBottom[i,1]; xyTop[i,1]], [xyBottom[i,2]; xyTop[i,2]], color = "black", linewidth = 1)
    end

    if (maxEntries == 0)
        return
    end

    plot_font = "computer modern"
    txtsize = 12
    i = 1

    numElements = length(gs.dataStructure)

    for xi in xyMid
        if (i > numElements)
            break
        end

        if (i == length(xyMid) && numElements > i)
            annotate!(p, xi, yMidBox, text("...", plot_font, txtsize, color="black"))
        else
            annotate!(p, xi, yMidBox, text(gs.dataStructure[i], plot_font, txtsize, color="black"))
        end

        i = i + 1
    end
end

function runBFS(g::Graph, sLabel::String)::Vector{GraphState}
    println("BFS procedure initialized.")

    graphStates::Vector{GraphState} = []

    sInd = findNodeIndexFromLabel(g, sLabel)

    if (sInd == -1)
        println("Could not find a node with label ", sLabel)
    end
    
    # The attributes vector contains n elements
    # Each element is a Tuple containing the node's distance from the source and the node's "parent"
    attributes::Vector{Tuple{Int64, Int64}} = []
    nodeLabels::Vector{String} = []

    # Setup the attributes vector and the node coloring
    for v in g.nodes
        v.size = 25
        v.fillColor = "white"
        push!(attributes, (-1, -1))
        push!(nodeLabels, "d = ∞\nπ = NIL")
    end

    attributes[sInd] = (0, -1)

    Q = Queue{Int}()

    desc = "Initialize BFS by setting each node's distance from source to ∞ and the color to white.\nAlso initialize the Queue data structure."
    push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))

    enqueue!(Q, sInd)
    nodeLabels[sInd] = "d = " * string(attributes[sInd][1]) * "\nπ = " * string(attributes[sInd][2])
    desc = "Push the source node " * g.nodes[sInd].label * " to the queue."
    push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))

    while !isempty(Q)
        # Pop a node from the queue and highlight its edge
        uInd = dequeue!(Q)
        setNodeAppearance(g, uInd, oc = "Black") # Note: the capital B in "Black" is used to denote a thicker outline

        # highlight the edges connecting node u to all of its adjacent nodes
        adjNodes = getAdjacentNodeIndices(g, uInd)
        adjEdgeColors = []

        for vInd in adjNodes
            # We want to save the original edge color so it can be restored later
            edgeInd = findEdgeIndex(g, uInd, vInd)
            push!(adjEdgeColors, g.edges[edgeInd].color)

            setEdgeAppearance(g, edgeInd, color="red", thickness = 3.0)
        end

        desc = "Popped the node " * g.nodes[uInd].label * " from the queue and highlighted its neighbors"
        push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))

        for i in eachindex(adjNodes)
            vInd = adjNodes[i]

            edgeInd = findEdgeIndex(g, uInd, vInd)

            setEdgeAppearance(g, edgeInd, color="green", thickness = 3.0)

            v = g.nodes[vInd]

            desc = "Visiting node " * g.nodes[uInd].label * "'s adjacent node " * v.label * "."
            push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))

            if v.fillColor == "white"
                setEdgeAppearance(g, edgeInd, color="gold", thickness = 3.0)

                desc = "Since node " * v.label * "'s color is white, the edge from " * g.nodes[uInd].label * " to " * v.label * " is a tree edge."
                push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))

                v.fillColor = "gray"
                attributes[vInd] = (attributes[uInd][1] + 1, uInd)

                nodeLabels[vInd] = "d = " * string(attributes[vInd][1]) * "\nπ = " * string(attributes[vInd][2])

                enqueue!(Q, vInd)

                desc = "Updated node " * v.label * "'s color to gray and distance from source."
                push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))
            else
                # If node v is not white, then we simply restore the color of the edge connecting u to v
                setEdgeAppearance(g, edgeInd, color = adjEdgeColors[i], thickness = 1.0)
                
                # If the edge connecting u to v is gold, then we want to keep it thick to highlight that it is a tree edge
                if (g.edges[edgeInd].color == "gold")
                    setEdgeAppearance(g, edgeInd, thickness = 3.0)
                end

                desc = "Since node " * v.label * "'s color is not white, we continue to the next adjacent node."
                push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))
            end
        end
        
        setNodeAppearance(g, uInd, oc = "black", lc = "white", fc = "black")
        
        desc = "Set node " * g.nodes[uInd].label * " color to black"
        push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))
    end

    println("BFS procedure finished. All graph states created.")

    return graphStates
end

filename = "../resources/testDir.vac"
G = vacRead(filename)
source = "1"

graphStates = runBFS(G, source)

makegif = false
dpi = 400
fps = 10
iterateThroughGraphState(graphStates, "Queue", makegif, Δt = 0.2, FPS = fps, DPI = dpi)