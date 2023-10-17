using Plots
include("Node.jl")
include("Edge.jl")
#include("../createEdges.jl")

mutable struct Graph
    edges::Vector{Edge}
    nodes::Vector{Node}

    directed::Bool
    weighted::Bool

    versionNo::Int64
    labelToIndex::Dict

    xMin::Float64
    xMax::Float64
    yMin::Float64
    yMax::Float64
end

Graph(edges=Vector{Edge}(undef,1), nodes=Vector{Node}(undef,1), directed=false, weighted=false, versionNo=1, labelToIndex=Dict(), xMin = Inf, xMax = -Inf , yMin = Inf, yMax = -Inf ) = Graph(edges, nodes, directed, weighted, versionNo,labelToIndex, xMin, xMax, yMin,yMax)
Graph(;edges=Vector{Edge}(undef,1), nodes=Vector{Node}(undef, 1), directed=false, weighted=false, versionNo=1, labelToIndex=Dict(), xMin = Inf, xMax = -Inf , yMin = Inf, yMax = -Inf  ) = Graph(edges, nodes, directed, weighted, versionNo, labelToIndex, xMin, xMax, yMin,yMax)

# Computes a the Graph's limits as a bounding box of the graph's nodes
function setGraphLimits(g::Graph)
    g.xMin = Inf
    g.xMax = -Inf
    g.yMin = Inf
    g.yMax = -Inf
    if (length(g.nodes) == 0)
        return
    end
    
    for node ∈ g.nodes
        if (node.xCoord < g.xMin)
            g.xMin = node.xCoord
        end

        if (node.xCoord > g.xMax)
            g.xMax = node.xCoord
        end

        if (node.yCoord < g.yMin)
            g.yMin = node.yCoord
        end

        if (node.yCoord > g.yMax)
            g.yMax = node.yCoord
        end
    end
end

function applyView(g::Graph, centerX::Float64, centerY::Float64, radius::Float64)
    g.xMax = centerX + radius
    g.yMax = centerY + radius
    g.xMin = centerX - radius
    g.yMin = centerY - radius
end

function applyView(g::Graph, label::String, radius::Float64)
    centerX = Inf
    centerY = Inf

    for node ∈ g.nodes
        if node.label == label
            centerX = node.xCoord
            centerY = node.yCoord
            break
        end
    end

    if (centerX != Inf)
        return applyView(g, centerX, centerY, radius)
    else
        println("No node with label ", label, " was found.")
    end
end

# This function returns a plot object containing the visualization of the graph object g
function makePlot(g::Graph, showTicks::Bool, showLabels::Bool)::Plots.Plot{Plots.GRBackend} 
    graphPlot = plot()
    limit = length(g.nodes)*2
    k = 0.25
    #     plot!(graphPlot, xlim = [-10,10], ylim = [-10,10])

    deltaX = (g.xMax - g.xMin) * k
    deltaY = (g.yMax - g.yMin) * k
    
    plot!(graphPlot, xlim = [g.xMin - deltaX,g.xMax + deltaX], ylim = [g.yMin - deltaY, g.yMax + deltaY])
    #plot!(graphPlot, aspect_ratio=:equal)
    plot!(graphPlot, grid = false, legend = false)
    plot!(graphPlot, axis = showTicks, xticks = showTicks, yticks = showTicks) 

    if isempty(g.nodes)
        return graphPlot
    end
    
    if !isassigned(g.nodes,1)
        empty!(g.nodes)
        empty!(g.edges)
        return graphPlot
    end

    n = length(g.nodes)
    xy = zeros(n, 2)
    edges = Vector{Vector{Int64}}()
    labels = Vector{String}()
    plot_font = "computer modern"
    txtsize = 12
    
    for i in 1:n
        push!(labels, "")
    end

    # plot!(graphPlot, xlim = [-10,10], ylim = [-10,10])
    plot!(graphPlot, xlim = [g.xMin - deltaX,g.xMax + deltaX], ylim = [g.yMin - deltaY, g.yMax + deltaY])
    #plot!(graphPlot, aspect_ratio=:equal)
    plot!(graphPlot, grid = showTicks, legend = false)
    plot!(graphPlot, axis = showTicks, xticks = showTicks, yticks = showTicks) 

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

        xy = createCircularCoords(g)
        for currNode in g.nodes
            currNode.xCoord = xy[currNode.index, 1]
            currNode.yCoord = xy[currNode.index, 2]
        end

        setGraphLimits(g)
        plot!(graphPlot, xlim = [g.xMin*k,g.xMax*k], ylim = [g.yMin*k,g.yMax*k])
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
        scatter!(graphPlot, xyForNode[:,1], xyForNode[:,2], markersize = currNode.size, color = currNode.fillColor, markerstrokecolor = currNode.outlineColor)
        
        if (showLabels == true)
            annotate!(graphPlot, currNode.xCoord, currNode.yCoord, text(currNode.label, plot_font, txtsize, color=currNode.labelColor))
        end
    end

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

function findNodeArrayIndexFromLabel(g::Graph, label::String)::Int64
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

function updateGraphEdges(g::Graph, edgeVec::Vector{Edge})
    g.edges = edgeVec
end

# VVI is a Vector{Vector{Int64}}, which will be used to create a Vector{Edge}
function updateGraphEdges(g::Graph, VVI::Vector{Vector{Int64}})
    newEdges = createEdgeVectorFromVVI(VVI)
    updateGraphEdges(g, newEdges)
end 

function updateGraphNodes(g::Graph,nodeVec::Vector{Node})
    g.nodes = nodeVec
end

function updateGraphNodes(g::Graph,VVF::Matrix{Float64})
    updateGraphNodes(g, createNodeVectorFromFM(VVF))
end

function findEdgeIndex(g::Graph, sourceLabel::String, destLabel::String)::Int64
    sourceKey = findNodeIndexFromLabel(g, sourceLabel)
    destKey = findNodeIndexFromLabel(g, destLabel)
    
    if ((sourceKey != -1) && (destKey != -1))
        index = 1
        if (g.directed == true)
            # In the case of a directed graph, edge direction specification matters
            for currEdge in g.edges
                if ((currEdge.sourceKey == sourceKey) && (currEdge.destKey == destKey))
                    return index
                end
                index = index + 1
            end
        else
            # in the case of an undirected graph, the edge directions do not matter
            for currEdge in g.edges
                if (((currEdge.sourceKey == sourceKey) && (currEdge.destKey == destKey)) || ((currEdge.sourceKey == destKey) && (currEdge.destKey == sourceKey)))
                    return index
                end
                index = index + 1
            end
        end
    end

    return -1

end

"""
Adds a new Node object to the graph from the provided parameters
"""
function addNode(g::Graph, label::String, size=1, outlineColor="black", fillColor="white", labelColor="black", xCoord=0., yCoord=0.) 
    newIndex = length(g.nodes) + 1
    newNode = Node(label, newIndex, size, outlineColor, fillColor, labelColor, xCoord, yCoord)
    push!(g.nodes, newNode)
end

"""
Adds a new node constructed from the arguments in `commands`.
Assumes commands is of the form:
\t\t add node -l label -s size - oc outlineColor -fc fillColor -lc labelColor -x xCoord -y yCoords

"""
function addNode(g::Graph, commands::Vector{SubString{String}})
    newIndex = length(g.nodes) + 1
    newNode = parseNode(commands, length(G.nodes) + 1)
    push!(g.nodes, newNode)
end

"""
Removes the node at index string and all the edges associated with it
Goes through `g.nodes` and finds the node with the label `label`
Will save the index from the found node and remove/pop! that node from `g.nodes`.
It will then traverse `g.nodes` and decrement the index of every node with an `index` > the popped node's index.
Finally, it will traverse `g.edges` and decrement 
"""
function removeNode(g::Graph, label::String)
    index = -1
    
    # Iterate through all the nodes in the graph and modify appropriately
    i = 1
    n = length(g.nodes)
    while (i <= n)
        # do stuff
        node = g.nodes[i]

        if index == -1
            if node.label == label
                index = i
                deleteat!(g.nodes, i)
                i = i - 1
                n = n - 1
            end        
        else 
            g.nodes[i].index = i
        end

        i = i + 1
    end
    
    if (index == -1)
        println("A node with label", label, " was not found.")
        return
    end

    # Iterate through all of the edges in the graph and modify appropriately
    i = 1
    n = length(g.edges)
    while (i <= n)
        # if either the source or dest is index, then we remove the edge!
        if (g.edges[i].sourceKey == index) || (g.edges[i].destKey == index)
            deleteat!(g.edges, i)
            n = n - 1
            continue
        end
        
        # Then, if either one of its dest or source is greater than index
        if (g.edges[i].sourceKey > index)
            g.edges[i].sourceKey = g.edges[i].sourceKey -1
        end

        if (g.edges[i].destKey > index)
            g.edges[i].destKey = g.edges[i].destKey - 1
        end

        i = i + 1
    end
end

function addEdge(g::Graph, sourceLabel::String, destLabel::String, weight::Float64)
    sourceKey = findNodeIndexFromLabel(g, sourceLabel)
    destKey = findNodeIndexFromLabel(g, destLabel)
    color="black"
    
    if (sourceKey != -1 && destKey != -1)
        newEdge = Edge(sourceKey, destKey, weight, color)
        push!(g.edges, newEdge)
    else
        println("Please provide valid node labels for the add edge command")
        return
    end
end

function removeEdge(g::Graph, sourceLabel::String, destLabel::String)
    
    edgeInd = findEdgeIndex(g, sourceLabel, destLabel)

    if (edgeInd != -1)
        deleteat!(g.edges, edgeInd)

    else
        println("Please provide valid node labels for the removeEdge command")
        return
    end

end

function moveNode(g::Graph, label::String, dir::String, units::Float64)
    index = findNodeIndexFromLabel(g, label)

    if (dir == "left" || dir == "l")
        g.nodes[index].xCoord -= units 
    
    elseif (dir == "right" || dir == "x" ||  dir == "r")
        g.nodes[index].xCoord += units
    
    elseif (dir == "up" || dir == "y" ||  dir == "u")
        g.nodes[index].yCoord += units     
    
    elseif (dir == "down" || dir == "d")
        g.nodes[index].yCoord -= units
    else
        print("Invalid Direction in moveNode")
    end

    setGraphLimits(g)
end

function getInDegrees(g::Graph)::Matrix{Float64}
    n = length(g.nodes)
    inDegree = zeros(n,1)
    
    for currEdge in g.edges
        inDegree[currEdge.destKey] += 1
    end

    return inDegree
end

function getOutDegrees(g::Graph)::Matrix{Float64}
    n = length(g.nodes)
    outDegree = zeros(n,1)
    for edge ∈ g.edges
        outDegree[edge.sourceKey] += 1
    end
    return outDegree 
end

function getTotalDegrees(g::Graph)::Matrix{Float64}
    return getInDegrees(g) + getOutDegrees(g)
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
#TODO change so that the work after deletions
function applyNewCoords(g::Graph, xy::Matrix{Float64})
    if length(g.nodes) != (size(xy)[1])
        println("Number of nodes in graph ", g.nodes, " != ", (size(xy)[1]))
        return
    end
    for nodeIndex in 1:length(g.nodes)
        g.nodes[nodeIndex].xCoord = xy[nodeIndex,1]
        g.nodes[nodeIndex].yCoord = xy[nodeIndex,2]
    end

    setGraphLimits(g)
end

## BELONGED IN CREATE EDGES FUNCTION ############################################
function createDegreeDependantCoods(g::Graph)::Matrix{Float64}
    n = length(g.nodes)
    r = .9 * n
    degree = getTotalDegrees(g) .+ 1
    
    xy = zeros(n,2)
    # Updates xy to be degree-dependant
    for j in 1:n
        angle = (2π / n) * j;
        x = round(cos(angle); digits = 5)
        y = round(sin(angle); digits = 5)
        xy[j,:] = [(x * r /(degree[j] * 0.5)) (y * r /(degree[j] * 0.5))]
    end

    return xy
end

function createCircularCoords(g::Graph)::Matrix{Float64}
    n = length(g.nodes)
    r = 1.5 * n
    xy = zeros(n,2)
    
    # Places nodes in a circle:
    for j in 1:n
        angle = (2π / n) * j;
        x = round(cos(angle); digits = 5)
        y = round(sin(angle); digits = 5)
        xy[j,:] = [(x * r) (y * r)]
    end

    return xy
end

function randomEdges(g::Graph)
    n = length(g.nodes)

    edges = Vector{Vector{Int64}}()

    maxEdges = n * (n - 1.0) / 2.0
    randomNumber = rand(1:maxEdges)
    
    # Creates random edges and updates the degree array
    for j in 1:randomNumber
        u = rand(range(start=1, stop=n, step=1))
        v = rand(range(start=1, stop=n, step=1))
        
        push!(edges, [u;v])
    end

    return edges
end

function circleEdges(g::Graph)
    n = length(g.nodes)
    edges = Vector{Vector{Int64}}()

    #makes edges for all nodes around 
    for j in 1:(n-1)
        push!(edges,[j;((j+1))])
    end
    push!(edges, [1;n])    

    return edges
end

function completeEdges(g::Graph)
    n = length(g.nodes)
    edges = Vector{Vector{Int64}}()

    # The following will create a complete graph:
    for j in 1:n
        for i in 1:n
            push!(edges, [j;i])
        end
    end

    return edges
end
####################################################################

# The following functions are used to create a Force-Directed Layout

function f_rep(node1::Node, node2::Node)::Vector{Float64}
    return [-1.0, -1.0]
end

function f_attr(node1::Node, node2::Node)::Vector{Float64}
    return [1.0, 1.0]
end

function getCoolingFactor(t)::Float64
    # Note: This is just an arbitrary function. Could be tweaked later
    return (1.0 / Float64(t))
end

# Returns a COPY of the Node in the graph with the specified index/key
function getNode(g::Graph, key::Int64)
    for node ∈ g.nodes
        if (node.key == key)
            return Node(label=node.label, index=node.index, size=node.size, outlineColor=node.outlineColor, fillColor=node.fillColor, labelColor=node.labelColor, xCoord=node.xCoord, yCoord=node.yCoord)
        end
    end

    println("Could not find node with key ", key)
end

# Returns a vector of Nodes that are adjacent to the Node v
# - If g is directed, it will return only nodes of the form (v,u)
# - If g is undirected, it will return nodes of the form (v,u) and (u,v)
function getAdjacentNodes(g::Graph, v::Node)
    adjacentNodes = Vector{Node}()
    for edge ∈ g.edges
        if (edge.sourceKey == v.index)
            push!(adjacentNodes, getNode(g, edge.destKey))
        end

        if (!g.directed)
            if (edge.destKey == v.index)
                push!(adjacentNodes, getNode(g, edge.sourceKey))
            end
        end
    end

    print("the adjacent nodes are ", adjacentNodes)

    return adjacentNodes
end

function magnitude(f::Vector{Float64})::Float64
    return sqrt(f[1]^2 + f[2]^2)
end


# The following function updates the coordinates of the nodes to meet a force-directed layout
# g is the graph object containing the initial layout
# ε is the threshold. ε > 0. Once forces get smaller than epsilon, we stop the algorithm
# K is the maximum number of iterations
function forceDirectedCoords(g::Graph, ε::Float64, K::Int64)
    t = 1

    # We can keep track of the position of each variable in a vector of float64 tuples
    maxForce = -Inf

    # Store the positions and forces of each node in a matrix of size nx2
    position = zeros(length(g.nodes), 2)
    forces = zeros(length(g.nodes), 2)

    # Condition 1: the number of iterations so far is less than K
    # Condition 2: The maximum force we computed in the previous iteration is greater than epsilon
    while (t < K) && (maxForce > ε)
        for u ∈ g.nodes
            f_rep_u = [0.0, 0.0]
            # Repellent force must be computed with all vertices
            for v ∈ g.nodes
                # some way to add f_rep_u with the result of f_rep(u,v)

            end

            # Attractive force must ONLY be computed with adjacent vertices
            f_attr_u = [0.0, 0.0]
            adjacentNodes = getAdjacentNodes(g, u)
            for v ∈ adjacentNodes
                # some way to add f_attr_u with the result of f_attr(u,v)
            end

            # find some way to store f_u so that we can update the node's coordinates later
            f_u = f_rep_u + f_attr_u

            if (magnitude(f_u) > maxForce)
                maxForce = f_u
            end
        end

        for u ∈ g.nodes
            pos_u = [u.xCoord, u.yCoord] + getCoolingFactor(t) .* [0.0, 0.0] # SOME WAY TO FETCH f_u

        end

        t = t + 1
    end
end