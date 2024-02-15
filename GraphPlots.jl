include("./structFiles/Graph.jl")

function initPlot(p, g, k, showTicks)

    deltaX = (g.xMax - g.xMin) * k
    deltaY = (g.yMax - g.yMin) * k

    plot!(p, xlim = [g.xMin - deltaX,g.xMax + deltaX], ylim = [g.yMin - deltaY, g.yMax + deltaY])
    plot!(p, grid = showTicks, legend = false, aspect_ratio =:none)

    plot!(p, axis = showTicks, xticks = showTicks, yticks = showTicks) 
end

function plotNodes(p, g; showLabels = true, plot_font = "computer modern", txtsize = 12)
    #Plot the xy circles and node labels
    for currNode in g.nodes
        xyForNode = zeros(1, 2) 
        xyForNode[1,:] = [currNode.xCoord, currNode.yCoord]
        scatter!(p, xyForNode[:,1], xyForNode[:,2], markersize = currNode.size, color = currNode.fillColor, markerstrokecolor = currNode.outlineColor)
        
        if (showLabels == true)
            annotate!(p, currNode.xCoord, currNode.yCoord, text(currNode.label, plot_font, txtsize, color = currNode.labelColor))
        end
    end
end

function plotUndirectedEdges(p, g, xy; plot_font = "computer modern", txtsize = 12)
    # If the graph is undirected, we can simply draw a straight line from source to dest:
    for currEdge in g.edges
        u = currEdge.sourceKey
        v = currEdge.destKey

        plot!(p,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]], color = currEdge.color, linewidth = currEdge.lineWidth)
        
        if (g.weighted)
            midx = (xy[u,1] + xy[v,1]) / 2
            midy = (xy[u,2] + xy[v,2]) / 2
            annotate!(p, midx, midy, text(currEdge.weight, plot_font, txtsize, color="black"))
        end
    end
end

function offsetFactor(g, vSize)
    xLen = abs(g.xMax - g.xMin)
    yLen = abs(g.yMax - g.yMin)

    factor = (vSize) / min(xLen, yLen)
    # println(factor)

    return factor
end

function getOffset(g, vSize)
    xLen = abs(g.xMax - g.xMin)
    yLen = abs(g.yMax - g.yMin)

    aspect = xLen / yLen

    return [(vSize) / xLen, (vSize) / yLen] * aspect
end

function plotDirectedEdges2(p, g, xy; plot_font = "computer modern", txtsize = 12, arrowSize = 0.8)
    # Vector to keep track of all edges that have been drawn
    edgesDrawn::Vector{Tuple{Int64, Int64}} = []
    # GR.setarrowsize(arrowSize)

    for i in eachindex(g.edges)
        currEdge = g.edges[i]
        u = currEdge.sourceKey
        v = currEdge.destKey

        edgeNodeIndices = (u, v)

        if (edgeNodeIndices in edgesDrawn)
            continue
        end

        # Check if the inverse edge is in the graph
        invertedEdgeInd = findEdgeIndex(g, v, u)

        # The inverted edge is in the graph! We draw parallel lines between the nodes
        uvDir = [g.nodes[v].xCoord, g.nodes[v].yCoord] - [g.nodes[u].xCoord, g.nodes[u].yCoord]
        uvNormDir = uvDir / √(uvDir[1]^2 + uvDir[2]^2) # The normalized direction from nodes u to v
        invNormDir = [-uvNormDir[2], uvNormDir[1]]
        uSize = g.nodes[u].size
        vSize = g.nodes[v].size

        if (invertedEdgeInd == -1)
            # offset = uvNormDir * 0.5
            # offset = uvNormDir * offsetFactor(g, vSize)
            offset = uvNormDir .* getOffset(g, vSize)

            # Plot the edge from node u to node v
            xCoords = [xy[u,1]; xy[v,1] - offset[1]]
            yCoords = [xy[u,2]; xy[v,2] - offset[2]]
            plot!(p, xCoords, yCoords, color = currEdge.color, linewidth = currEdge.lineWidth, arrow = (:closed, 1.0))
        else
            offset = uvNormDir * 0.4
            sideOffset = invNormDir * 0.3
            # offset = uvNormDir * offsetFactor(g, vSize)
            offset = uvNormDir .* getOffset(g,vSize)

            # Plot the edge from node u to node v
            xCoords = [xy[u,1] + sideOffset[1]; xy[v,1] + sideOffset[1] - offset[1]]
            yCoords = [xy[u,2] + sideOffset[2]; xy[v,2] + sideOffset[2] - offset[2]]
            plot!(p, xCoords, yCoords, color = currEdge.color, linewidth = currEdge.lineWidth, arrow = (:closed, 1.0))
            
            invEdge = g.edges[invertedEdgeInd]
            offset = uvNormDir * offsetFactor(g, uSize)

            # Plot the edge from node v to node u
            xCoords = [xy[v,1] - sideOffset[1]; xy[u,1] - sideOffset[1] + offset[1]]
            yCoords = [xy[v,2] - sideOffset[2]; xy[u,2] - sideOffset[2] + offset[2]]
            plot!(p, xCoords, yCoords, color = invEdge.color, linewidth = invEdge.lineWidth, arrow = (:closed, 1.0))

            invEdgeNodeIndices = (v, u)
            push!(edgesDrawn, invEdgeNodeIndices)
        end

        if (g.weighted)
            midx = (xy[u,1] + xy[v,1]) / 2
            midy = (xy[u,2] + xy[v,2]) / 2
            annotate!(p, midx, midy, text(currEdge.weight, plot_font, txtsize, color="black"))
        end
    end
end

# This function returns a plot object containing the visualization of the graph object g
function makePlot(g::Graph, showTicks::Bool, showLabels::Bool; plot_font = "computer modern", txtsize = 12, DPI = 250)::Plots.Plot{Plots.GRBackend} 
    gr()
    graphPlot = plot(dpi = DPI)

    initPlot(graphPlot, g, 0.25, showTicks)

    # Check if there are no nodes in the graph:
    if isempty(g.nodes)
        return graphPlot
    end
    
    if !isassigned(g.nodes,1)
        empty!(g.nodes)
        empty!(g.edges)
        return graphPlot
    end

    n = length(g.nodes) # n = |V|
    xy = zeros(n, 2) # Stores the xy coordinates of nodes for edge plotting
    
    labels = Vector{String}()
    for i in 1:n
        push!(labels, "")
    end
    
    for currNode in g.nodes
        # NOTE: we use the index of the node to identify it
        xy[currNode.index, :] = [currNode.xCoord, currNode.yCoord]
        labels[currNode.index] = currNode.label
    end

    # Plot the edges by drawing lineArgs
    if (g.directed)
        plotDirectedEdges2(graphPlot, g, xy, plot_font = plot_font, txtsize = txtsize)
    else
        plotUndirectedEdges(graphPlot, g, xy, plot_font = plot_font, txtsize = txtsize)
    end

    plotNodes(graphPlot, g, showLabels = showLabels, plot_font = plot_font, txtsize = txtsize)

    return graphPlot
end