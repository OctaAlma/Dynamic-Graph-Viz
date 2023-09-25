using Plots
include("Node.jl")
include("Edge.jl")
include("../createEdges.jl")

mutable struct Graph
    edges::Vector{Edge}
    nodes::Vector{Node}

    directed::Bool
    weighted::Bool

    versionNo::Int64
    labelToIndex::Dict
end

Graph(edges=Vector{Edge}(undef,1), nodes=Vector{Node}(undef,1), directed=false, weighted=false, versionNo=1, labelToIndex=Dict()) = Graph(edges, nodes, directed, weighted, versionNo,labelToIndex)
Graph(;edges=Vector{Edge}(undef,1), nodes=Vector{Node}(undef, 1), directed=false, weighted=false, versionNo=1, labelToIndex=Dict()) = Graph(edges, nodes, directed, weighted, versionNo, labelToIndex)

# The display function returns a plot object containing the visualization of the graph object g
function displayGraph(g::Graph, showTicks::Bool)#::Plots.Plot{Plots.GRBackend} 
    n = length(g.nodes)
    xy = zeros(n, 2)
    edges = Vector{Vector{Int64}}()
    labels = Vector{String}()
    plot_font = "computer modern"
    txtsize = 12
    
    for i in 1:n
        push!(labels, "")
    end

    graphPlot = plot()

    plot!(graphPlot, xlim = [-10,10], ylim = [-10,10])
    plot!(graphPlot, aspect_ratio=:equal)
    plot!(graphPlot, grid = true,legend = false)
    plot!(graphPlot, axis = false, xticks = showTicks, yticks = showTicks) 

    # Populate the xy 2-dimmensional vector
    allZeroes = true # Boolean that checks if the xy coordinates are all 0s
    for currNode in g.nodes
        # NOTE: we use the index of the node to identify it
        
        if (currNode.xCoord != 0) || (currNode.yCoord != 0)
            allZeroes = false
        end

        xy[currNode.index, :] = [currNode.xCoord, currNode.yCoord]
        labels[currNode.index] = currNode.label
    end

    # In the case the coordinates are all zeroes, plot them in a circle
    if (allZeroes == true)
        r = 1.5 * n

        xy = createCircularCoords(n, r)

        for currNode in g.nodes
            currNode.xCoord = xy[currNode.index, 1]
            currNode.yCoord = xy[currNode.index, 2]
        end
    end

    # Populate the edges vector and plot the edges
    for currEdge in g.edges
        push!(edges, [currEdge.sourceKey, currEdge.destKey])

        u = currEdge.sourceKey
        v = currEdge.destKey

        plot!(graphPlot,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = currEdge.color, linewidth = 1)
    end

    #Plot the xy circles and node labels
    for currNode in g.nodes
        xyForNode = zeros(1, 2)
        xyForNode[1,:] = [currNode.xCoord, currNode.yCoord]
        scatter!(graphPlot, xyForNode[:,1], xyForNode[:,2], markersize = currNode.size, color = currNode.fillColor)
        annotate!(graphPlot, currNode.xCoord, currNode.yCoord, text(currNode.label, plot_font, txtsize))
    end

    # println(xy)
    # println(labels)
    # println(edges)

    return graphPlot
end

function findNodeIndexFromLabel(g::Graph, label::String)::Int64
    for currNode in g.nodes
        if (currNode.label == label)
            return currNode.index
        end
    end

    return -1
end

function findNodeLabelFromIndex(g::Graph, index::Int64)::String
    for currNode in g.nodes
        if (currNode.index == index)
            return currNode.label
        end
    end

    return "" 
end

function addEdge(g::Graph, sourceLabel::String, destLabel::String, weight::Float64)
    sourceKey = findNodeIndexFromLabel(g, sourceLabel)
    destKey = findNodeIndexFromLabel(g, destLabel)
    color="black"
    
    if (sourceKey != -1 && destKey != -1)
        newEdge = Edge(weight, color, sourceKey, destKey)
        push!(g.edges, newEdge)
    else
        println("Please provide valid node labels for the add edge command")
        return
    end
end

function removeEdge(g::Graph, sourceLabel::String, destLabel::String)
    sourceKey = findNodeIndexFromLabel(g, sourceLabel)
    destKey = findNodeIndexFromLabel(g, destLabel)

    if (sourceKey != -1 && destKey != -1)
        index = 1
        for currEdge in g.edges
            if ((currEdge.sourceKey == sourceKey) && (currEdge.destKey == destKey))
                deleteat!(g.edges, index)                
                break
            end
            index = index + 1
        end
    else
        println("Please provide valid node labels for the removeEdge command")
        return
    end

end

function moveNode(g::Graph, label::String, dir::String, units::Float64)
    index = findNodeIndexFromLabel(g, label)

    if (dir == "left")
        g.nodes[index].xCoord -= units 
    
    elseif (dir == "right" || dir == "x")
        g.nodes[index].xCoord += units
    
    elseif (dir == "up" || dir == "y")
        g.nodes[index].yCoord += units     
    
    elseif (dir == "down")
        g.nodes[index].yCoord -= units
    end
end

function outputGraphToVac(g::Graph, filename::String)
    open(filename, "w") do file
        # Write the .vac version number:
        write(file, "1\n")

        # Write whether the graph is directed
        if (g.directed == true)
            write(file, "d\n")
        else
            write(file, "u\n")
        end

        # Write whether the graph is weighted
        if (g.weighted == true)
            write(file, "w\n")
        else
            write(file, "u\n")
        end

        # Write all the node information
        for currNode in g.nodes
            label = currNode.label
            nodeSize = currNode.size

            outlineColor = currNode.outlineColor
            fillColor = currNode.fillColor
            labelColor = currNode.labelColor

            xCoord = currNode.xCoord
            yCoord = currNode.yCoord

            nodeLine = "n -l $label -x $xCoord -y $yCoord -f $fillColor -o $outlineColor -lc $labelColor -s $nodeSize\n"
            write(file, nodeLine)
        end

        # Write all the edge information
        for edge in g.edges
            weight = edge.weight
            color = edge.color

            sourceLabel = findNodeLabelFromIndex(g, edge.sourceKey)
            destLabel = findNodeLabelFromIndex(g, edge.destKey)

            edgeLine = "e -s $sourceLabel -d $destLabel -w $weight -c $color \n"
            write(file, edgeLine)
        end
    end
end