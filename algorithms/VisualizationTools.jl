include("../structFiles/Graph.jl")

mutable struct GraphState
    G::Graph
    dataStructure::Vector{Int64}

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

function iterateThroughGraphState(graphStates::Vector{GraphState}, dsName::String, Δt::Float64 = 0.5, makegif = false)
    step = 1
    dsPrev = nothing

    a = Animation()

    for gs in graphStates
        p = makeVizPlot(gs)
        
        if (makegif == true)
            frame(a, p)
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

    gif(a, fps = 10)
end


function highlightEdge(g::Graph, sourceLabel::String, destLabel::String, color::String)
    edgeInd = findEdgeIndex(g, sourceLabel, destLabel)

    if (edgeInd == -1)
        println("There is no edge between ", sourceLabel, " and ", destLabel)
    end

    g.edges[edgeInd].color = color
    g.edges[edgeInd].lineWidth = 4
end

function highlightEdge(g::Graph, sourceInd::Int64, destInd::Int64, color::String)
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

    highlightEdge(g, sLabel, dLabel, color)
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

function makeVizPlot(gs::GraphState, showTicks=false, showLabels=true)::Plots.Plot{Plots.GRBackend} 
    g = gs.G
    graphPlot = plot()

    # Create the delta for the bound padding:
    k = 0.25
    deltaX = (g.xMax - g.xMin) * k
    deltaY = (g.yMax - g.yMin) * k
    
    # Create
    plot!(graphPlot, xlim = [g.xMin - deltaX,g.xMax + deltaX], ylim = [g.yMin - deltaY, g.yMax + deltaY])
    plot!(graphPlot, axis = showTicks, xticks = showTicks, yticks = showTicks) 
    plot!(graphPlot, grid = false, legend = false)

    if isempty(g.nodes)
        return graphPlot
    end

    n = length(g.nodes)
    xy = zeros(n, 2)
    plot_font = "computer modern"
    txtsize = 5

    # Populate the xy 2-dimmensional vector    
    for currNode in g.nodes
        xy[currNode.index, :] = [currNode.xCoord, currNode.yCoord]
    end

    # Populate the edges vector and plot the edges
    for currEdge in g.edges

        u = currEdge.sourceKey
        v = currEdge.destKey

        plot!(graphPlot,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = currEdge.color, linewidth = currEdge.lineWidth)
        midx = (xy[u,1] + xy[v,1]) / 2
        midy = (xy[u,2] + xy[v,2]) / 2
        
        if (g.weighted)
            annotate!(graphPlot, midx, midy, text(currEdge.weight, plot_font, txtsize, color="black"))
        end
    end
    
    #Plot the xy circles and node labels
    i = 1
    for currNode in g.nodes
        xyForNode = zeros(1, 2)
        xyForNode[1,:] = [currNode.xCoord, currNode.yCoord]
        scatter!(graphPlot, xyForNode[:,1], xyForNode[:,2], markersize = currNode.size * 2, color = currNode.fillColor, markerstrokecolor = currNode.outlineColor)
        
        if (showLabels == true)
            fullLabel = currNode.label * "\n" * gs.nodeLabels[i]
            annotate!(graphPlot, currNode.xCoord, currNode.yCoord, text(fullLabel, plot_font, txtsize, color=currNode.labelColor))
            i = i + 1
        end
    end

    return graphPlot
end