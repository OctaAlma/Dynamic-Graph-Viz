include("../structFiles/Graph.jl")

mutable struct GraphState
    G::Graph
    dataStructure

    description::String

    nodeLabels::Vector{String}
    edgeLabels::Vector{String}
end

function printDataStructure(gs::GraphState, dsName::String, dsPrev)
    if (isnothing(dsPrev) || dsPrev != gs.dataStructure)
        print("Updated ", dsName, " contents: ")
        numElements = length(gs.dataStructure)
        for i in 1:numElements
            if (i == numElements)
                println(gs.dataStructure[i])
                break
            end

            print(gs.dataStructure[i], ", ")
        end
    end
end

function iterateThroughGraphState(graphStates::Vector{GraphState}, dsName::String, makegif = false ;Δt::Float64 = 0.5, filename = "output.gif", FPS=10, DPI=250)
    step = 1
    dsPrev = nothing

    anim = Animation()

    for gs in graphStates
        p = makeVizPlot(gs, DPI=DPI)
        
        if (makegif == true)
            frame(anim, p)
        else
            display(p)
            step = step + 1
        
            println("Step ", step, ": ", gs.description)
            printDataStructure(gs, dsName, dsPrev)
            
            sleep(Δt)
            print("\n\n")
            dsPrev = collect(Int64, gs.dataStructure)
        end
    end

    if (makegif)
        gif(anim, filename, fps=FPS)
    end
end

function highlightNode(g::Graph, nodeInd::Int64; color="red")
    
    if (nodeInd < 1 || nodeInd > length(g.nodes))
        println("Invalid node index: ", nodeInd)
        return
    end

    g.nodes[nodeInd].outlineColor = color

end

function resetNodeColor(g::Graph, nodeInd::Int64)

    if (nodeInd < 1 || nodeInd > length(g.nodes))
        println("Invalid node index: ", nodeInd)
        return
    end

    g.nodes[nodeInd].outlineColor = "black"
end

function highlightNode(g::Graph, nodeLabel::String)
    nodeInd = findNodeIndexFromLabel(g, nodeLabel)

    if (nodeInd == -1)
        println("Could not find node with label ", nodeLabel)
    else
        highlightNode(g, nodeInd)
    end
end

function highlightEdge(g::Graph, sourceLabel::String, destLabel::String; color::String)
    edgeInd = findEdgeIndex(g, sourceLabel, destLabel)

    if (edgeInd == -1)
        println("There is no edge between ", sourceLabel, " and ", destLabel)
    end

    g.edges[edgeInd].color = color
    g.edges[edgeInd].lineWidth = 4
end

function highlightEdge(g::Graph, sourceInd::Int64, destInd::Int64; color::String)
    sLabel = findNodeLabelFromIndex(g, sourceInd)
    dLabel = findNodeLabelFromIndex(g, destInd)

    if (sLabel == "")
        println("Invalid source label passed into highlightEdge ", sLabel)
        return
    end

    if (dLabel == "")
        println("Invalid destination label passed into highlightEdge ", dLabel)
        return
    end

    highlightEdge(g, sLabel, dLabel, color=color)
end

function resetEdgeColor(g::Graph, sourceLabel::String, destLabel::String)
    edgeInd = findEdgeIndex(g, sourceLabel, destLabel)

    if (edgeInd == -1)
        println("There is no edge between ", sourceLabel, " and ", destLabel)
    end

    g.edges[edgeInd].color = "black"
    g.edges[edgeInd].lineWidth = 1.0
end

function resetEdgeColor(g::Graph, sourceInd::Int64, destInd::Int64)
    sLabel = findNodeLabelFromIndex(g, sourceInd)
    dLabel = findNodeLabelFromIndex(g, destInd)

    if (sLabel == "")
        println("Invalid source label passed into highlightEdge ", sLabel)
        return
    end

    if (dLabel == "")
        println("Invalid destination label passed into highlightEdge ", dLabel)
        return
    end

    resetEdgeColor(g, sLabel, dLabel)
end

function makeVizPlot(gs::GraphState, showTicks=false, showLabels=true; DPI=250)::Plots.Plot{Plots.GRBackend} 
    
    graphPlot = plot(dpi=DPI)
    # plotDataStructure(graphPlot, gs)
    g = gs.G

    # Create the delta for the bound padding:
    k = 0.25
    deltaX = (g.xMax - g.xMin) * k
    deltaY = (g.yMax - g.yMin) * k
    
    # Setup the graph Plot by setting its limits and other attributes
    plot!(graphPlot, xlim = [g.xMin - deltaX,g.xMax + deltaX], ylim = [g.yMin - deltaY, g.yMax + deltaY])
    plot!(graphPlot, axis = showTicks, xticks = showTicks, yticks = showTicks) 
    plot!(graphPlot, grid = false, legend = false)

    if isempty(g.nodes)
        return graphPlot
    end

    n = length(g.nodes)
    xy = zeros(n, 2)
    plot_font = "computer modern"
    txtsize = 6

    # Populate the xy 2-dimmensional vector. The ith entry corresponds to the ith node's (x,y) coordinates    
    for currNode in g.nodes
        xy[currNode.index, :] = [currNode.xCoord, currNode.yCoord]
    end

    # Populate the edges vector and plot the edges
    for currEdge in g.edges

        u = currEdge.sourceKey
        v = currEdge.destKey
        
        plot!(graphPlot,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]], color = currEdge.color, linewidth = currEdge.lineWidth)
        midx = (xy[u,1] + xy[v,1]) / 2
        midy = (xy[u,2] + xy[v,2]) / 2
        
        # Display the edge weight if the graph is weighted
        if (g.weighted)
            annotate!(graphPlot, midx, midy, text(currEdge.weight, plot_font, txtsize, color="black"))
        end
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

        scatter!(graphPlot, xyForNode[:,1], xyForNode[:,2], markersize = currNode.size * 2, color = currNode.fillColor, markerstrokecolor = currNode.outlineColor, markerstrokewidth=outlineThickness)
        
        if (showLabels == true)
            fullLabel = currNode.label * "\n" * gs.nodeLabels[i]
            annotate!(graphPlot, currNode.xCoord, currNode.yCoord, text(fullLabel, plot_font, txtsize, color=currNode.labelColor))
            i = i + 1
        end
    end

    return graphPlot
end

rect(w, h, x, y) = Shape(x .+ [0, w, w, 0, 0], y .+ [0, 0, h, h, 0])

function plotDataStructure(p, gs; maxEntries = 6, hlFirstEntry = false)

    # Create and plot the rectangle containing the data structure's elements:
    w = abs(gs.G.xMax - gs.G.xMin)
    h = abs(gs.G.yMax - gs.G.yMin) * 0.2
    
    queueBox = rect(w, h, gs.G.xMin, gs.G.yMin - h)

    plot!(p, queueBox, fillcolor = "light grey")
    
    yMidBox = gs.G.yMin - (h / 2)
    yMinBox = gs.G.yMin - h
    yMaxBox = gs.G.yMin

    dividerXs = LinRange(gs.G.xMin, gs.G.xMax, maxEntries)
    println(collect(dividerXs))

    for i in 1:maxEntries
        plot!(p, [dividerXs[i]; yMinBox], [dividerXs[i]; yMaxBox], linewidth = 2, color = :black)
    end

    gs.G.yMin = gs.G.yMin - h

end