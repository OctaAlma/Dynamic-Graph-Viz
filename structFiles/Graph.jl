using Plots, KrylovKit
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

    # Set valid parameters in the case the graph has no nodes:
    if length(g.nodes) == 0
        g.xMax = 1
        g.yMax = 1
        g.xMin = -1
        g.yMin = -1
    end

    # There may be cases where coordinates are not well defined
    # Check that the xCoordinates are not the same
    if (g.xMax == g.xMin)
        g.xMax += 1
        g.xMin -= 1
    end

    if (g.yMax == g.yMin)
        g.yMax += 1
        g.yMin -= 1
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
    # allZeroes = true # Boolean that checks if the xy coordinates are all 0s
    for currNode in g.nodes
        # NOTE: we use the index of the node to identify it
        
        # if (!allZeroes) || (currNode.xCoord != 0) || (currNode.yCoord != 0)
        #     allZeroes = false
        # end

        xy[currNode.index, :] = [currNode.xCoord, currNode.yCoord]
        labels[currNode.index] = currNode.label
    end

    # In the case the coordinates are all zeroes, plot them in a circle
    # if (allZeroes == true)
    #     r = 1.5 * n

    #     xy = createCircularCoords(g)
    #     for currNode in g.nodes
    #         currNode.xCoord = xy[currNode.index, 1]
    #         currNode.yCoord = xy[currNode.index, 2]
    #     end

    #     setGraphLimits(g)
    #     plot!(graphPlot, xlim = [g.xMin*k,g.xMax*k], ylim = [g.yMin*k,g.yMax*k])
    # end

    # Populate the edges vector and plot the edges
    for currEdge in g.edges
        #push!(edges, [currEdge.sourceKey, currEdge.destKey])

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
    newNode = parseNode(commands, length(G.nodes) + 1)

    # We need some way for the user to interact with the node
    # Give it a label equal to its number in the node vector
    if (newNode.label == "")
        
        labelNo = 1
        while (true)
            if (findNodeIndexFromLabel(g, string(labelNo)) == -1)
                break
            end
            labelNo += 1
        end
        
        newNode.label = string(labelNo)
        #newNode.label = string(newNode.index)
    end

    # Check if a node with the same label is already in the graph
    if (findNodeIndexFromLabel(g, newNode.label) != -1)
        println("Node with label ", newNode.label, " already exists in the graph.")
    else
        push!(g.nodes, newNode)
    end
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

# Functions to edit the size of nodes in a graph
function setNodeSize(g::Graph, label::String, newSize::Int64)
    nodeInd = findNodeArrayIndexFromLabel(g, label);
    g.nodes[nodeInd].size = newSize
end

function setGlobalNodeSize(g::Graph, newSize::Int64)
    for currNode ∈ g.nodes
        currNode.size = newSize
    end
end

# Functions to edit the bounds explicitly


function addEdge(g::Graph, sourceLabel::String, destLabel::String, weight::Float64)
    
    if (sourceLabel == destLabel)
        println("Self loops are not allowed")
        return
    end

    if (findEdgeIndex(g, sourceLabel, destLabel) != -1)
        println("Edge from ", sourceLabel, " to ", destLabel, " already exists.")
        return
    end
    
    sourceKey = findNodeIndexFromLabel(g, sourceLabel)
    destKey = findNodeIndexFromLabel(g, destLabel)
    color="black"
    
    if (sourceKey != -1 && destKey != -1)
        newEdge = Edge(sourceKey, destKey, weight, color, 1.0)
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

function moveNode(g::Graph, label::String, xUnits::Float64, yUnits::Float64)
    index = findNodeIndexFromLabel(g, label)

    g.nodes[index].xCoord = xUnits
    g.nodes[index].yCoord = yUnits

    setGraphLimits(g)
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

function magnitude(f::Vector{Float64})::Float64
    return sqrt(f[1]^2 + f[2]^2)
end

# u is the node experiencing the force
# v is the node exerting the force
function f_rep(u::Node, v::Node, k::Float64 = 2.0)::Vector{Float64}
    uPos = [u.xCoord, u.yCoord]
    vPos = [v.xCoord, v.yCoord]

    dir = (uPos - vPos)
    dist = magnitude(dir)

    rep = k .* dir ./ (dist)

    return rep
end

function f_attr(u::Node, v::Node, k::Float64 = 1.25)::Vector{Float64}
    uPos = [u.xCoord, u.yCoord]
    vPos = [v.xCoord, v.yCoord]

    dir = (uPos - vPos)
    dist = magnitude(dir)

    att = k .* dir ./ (dist)

    return -1 .* att
end

function getCoolingFactor(t)::Float64
    # Note: This is just an arbitrary function. Could be tweaked later
    return (200 / Float64(t))
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

# returns the index of a string in a vector. Returns -1 if not found
function findIndex(lineArgs, substr)
    numArgs = length(lineArgs)

    for i in 1:numArgs
        if lineArgs[i] == substr
            return i
        end
    end
    return -1
end

function parseForceDirectedArgs(commands::Vector{SubString{String}})
    # ε::Float64, K::Int64, kRep::Float64 = 1.5, kAttr::Float64 = 3.0
    ε = 1e-2
    K = 20
    rep = 1.5
    attr = 2.0

    for str in commands
        str = lowercase(str)
    end
    
    # epsilon
    i = findIndex(commands, "-e")
    if i != -1
        ε = parse(Float64, commands[i + 1])
    end

    # K
    i = findIndex(commands, "-iters")
    if i != -1
        K = parse(Int64, commands[i + 1])
    end

    i = findIndex(commands, "-rep")
    if i != -1
        rep = parse(Float64, commands[i + 1])
    end

    i = findIndex(commands, "-attr")
    if i != -1
        attr = parse(Float64, commands[i + 1])
    end
    
    return [ε, K, rep, attr]
end


# The following function updates the coordinates of the nodes to meet a force-directed layout
# g is the graph object containing the initial layout
# ε is the threshold. ε > 0. Once forces get smaller than epsilon, we stop the algorithm
# K is the maximum number of iterations
function forceDirectedCoords(g::Graph, ε::Float64, K::Int64, kRep::Float64 = 1.5, kAttr::Float64 = 3.0)
    t = 1
    n = length(g.nodes)

    # Store the positions and forces of each node in a matrix of size nx2
    #positions = [(n .* rand(2) .- (n / 2.0)) for i in 1:n]
    positions = [(n .* rand(2) .- n) for i in 1:n] 
    nodeForces = [zeros(2) for i in 1:n]
    maxForce = -Inf

    # Condition 1: the number of iterations so far is less than K
    # Condition 2: The maximum force we computed in the previous iteration is greater than epsilon
    while (t < K) && (maxForce > ε)
        for u ∈ g.nodes
            # Repellent force must be computed with all vertices
            for v ∈ g.nodes
                if (u.index == v.index)
                    continue # we are in the same node
                end

                nodeForces[u.index] += f_rep(u, v, kRep) 

            end

            # Attractive force must ONLY be computed with adjacent vertices
            for v ∈ adjacentNodes
                if (u.index == v.index)
                    continue # we are in the same node
                end

                nodeForces[u.index] += f_attr(u, v, kAttr)
            end

            if (magnitude(nodeForces[u.index]) > maxForce)
                maxForce = f_u
            end
        end

        for u ∈ g.nodes
            positions[u.index] += (getCoolingFactor(t) .* nodeForces[u.index])

        end

        t = t + 1
    end

    # Apply the new coordinates
    for node ∈ g.nodes
        node.xCoord = positions[node.index][1]
        node.yCoord = positions[node.index][2]
    end
end


# The following functions enable spectral layout

# The following function will create a sparse matrix representing the graph
function createSparseMatrix(g::Graph)::SparseArrays.SparseMatrixCSC{Float64, Int64}
    ei = []
    ej = []
    w = []

    if (g.directed)
        for edge in g.edges
            push!(ei, edge.sourceKey)
            push!(ej, edge.destKey)

            if (g.weighted) 
                push!(w, edge.weight) 
            else 
                push!(w, 1.0) 
            end
        end
    else
        for edge in g.edges
            push!(ei, edge.sourceKey)
            push!(ej, edge.destKey)

            push!(ej, edge.sourceKey)
            push!(ei, edge.destKey)

            if (g.weighted) 
                push!(w, edge.weight) 
                push!(w, edge.weight) 
            else 
                push!(w, 1.0) 
                push!(w, 1.0) 
            end
        end
    end

    A = sparse(ei, ej, w)
    
    return A
end

# The following function will take in a Matrix and return a set of xy coordinates representing the nodes' spectral layout
function spectral_layout(A)
    d = vec(sum(A,dims = 2))
    Dhalf = Diagonal(d.^(-1/2))
    L = I - Dhalf*A*Dhalf
    # Lam, E = eigs(L; nev = 3, which=:SM)

    sc = size(L,1)
    Vl,Vc,convinfo = eigsolve(L + sc*LinearAlgebra.I, 3, :SR; tol = 1e-8, maxiter = 1000, verbosity = 0)
    lam2 = Real(Vl[2])-sc
    E = [Vc[2] Vc[3]] 

    return E
end

# The following function takes in a 
function makeRealMatrix(xy::Matrix{ComplexF64})
    rows = size(xy,1)
    cols = size(xy,2)

    M = zeros(rows, cols)
    
    for i in 1:rows
        for j in 1:cols
            M[i, j] = real(xy[i, j])
            println("M[i, :][j] = ", M[i, :][j])
        end
    end

    return M
end

function spectralCoords(g::Graph)
    A = createSparseMatrix(g)
    xy = spectral_layout(A)

    if (typeof(xy) == Matrix{ComplexF64})
        xy = makeRealMatrix(xy)
    end

    applyNewCoords(g, xy)
end

function parseSetEdgeCommand(commands::Vector{SubString{String}})
    c = undef
    lw = undef
    w = undef

    numCommands = length(commands)

    for i in 2:numCommands
        currCommand = lowercase(String(commands[i]))

        if (currCommand == "-c")
            c = String(commands[i+1])
            i = i + 1
            #println("Setting all edges to color ", c)
            continue

        elseif (currCommand == "-lw" || currCommand == "-t")
            lw = parse(Float64, commands[i+1])
            i = i + 1
            #println("Setting all edges to width ", lw)
            continue

        elseif (currCommand == "-w")
            w = parse(Float64, commands[i+1])
            i = i + 1
            #println("Setting all weights to ", w)
            continue
        end
    end

    return c, lw, w
end

# setAll edges -c -t -w 
function setAllEdges(g::Graph, commands::Vector{SubString{String}})

    c, lw, w = parseSetEdgeCommand(commands)

    numCommands = length(commands)

    for edge in g.edges
        if (c != undef)
            edge.color = c
        end
        
        if (lw != undef)
            edge.lineWidth = lw
        end

        if (w != undef)
            edge.weight = w
        end
    end
end

function setEdge(g::Graph, commands::Vector{SubString{String}})
    # Check if the labels provided exist
    sourceLabel = commands[3]
    destLabel = commands[4]

    edgeInd = findEdgeIndex(g, sourceLabel, destLabel)

    if (edgeInd == -1)
        println("An edge with source ", sourceLabel, " and destination ", destLabel, " could not be found.")
        return
    end

    c, lw, w = parseSetEdgeCommand(commands)

    if (c != undef)
        g.edges[edgeInd].color = c
    end
    
    if (lw != undef)
        g.edges[edgeInd].lineWidth = lw
    end

    if (w != undef)
        g.edges[edgeInd].weight = w
    end
end

function parseSetNodeCommand(commands::Vector{SubString{String}})
    fc = undef
    lc = undef
    oc = undef
    size = undef

    # Parse the user node inputs
    numCommands = length(commands)

    for i in 2:numCommands

        currCommand = lowercase(String(commands[i]))

        if (currCommand == "-fc")
            fc = String(commands[i+1])
            i = i + 1
            continue

        elseif (currCommand == "-lc")
            lc = String(commands[i+1])
            i = i + 1
            continue

        elseif (currCommand == "-oc")
            oc = String(commands[i+1])
            i = i + 1
            continue

        elseif (currCommand == "-s")
            size = parse(Int64, String(commands[i+1]))

            if (size < 1)
                println("Cannot set size to ", size,". Please enter a positive integer.")
                size = undef
            end
            i = i + 1
            continue
        end
    end

    return fc, lc, oc, size
end

function setNode(g::Graph, commands::Vector{SubString{String}})
    
    nodeLabel = String(commands[3])
    nodeInd = findNodeIndexFromLabel(g, nodeLabel)
    if (nodeInd == -1)
        println("Could not find a node with the label ", nodeInd)
        return
    end

    fc, lc, oc, size = parseSetNodeCommand(commands)

    if (fc != undef)
        println("Setting node fill color to ", fc)
        g.nodes[nodeInd].fillColor = fc
    end

    if (oc != undef)
        println("Setting node outline color to ", oc)
        g.nodes[nodeInd].outlineColor = oc
    end

    if (lc != undef)
        println("Setting node label color to ", lc)
        g.nodes[nodeInd].labelColor = lc
    end

    if (size != undef)
        println("Setting node size to ", size)
        g.nodes[nodeInd].size = size
    end

    i = findIndex(commands, "-x")
    if (i != -1)
        print("Changing node x from ",g.nodes[nodeInd].xCoord)
        g.nodes[nodeInd].xCoord = parse(Float64, String(commands[i + 1]))
        println("Setting node x to ", g.nodes[nodeInd].xCoord)
    end

    i = findIndex(commands, "-y")
    if (i != -1)
        print("Changing node y from ",g.nodes[nodeInd].yCoord)
        g.nodes[nodeInd].yCoord = parse(Float64,String(commands[i + 1]))
        println(" y to ", g.nodes[nodeInd].yCoord)
    end
    
end

# setAll nodes -fc -lc -oc -size
function setAllNodes(g::Graph, commands::Vector{SubString{String}})

    fc, lc, oc, size = parseSetNodeCommand(commands)

    for node in g.nodes
        if (fc != undef)
            node.fillColor = fc
        end

        if (oc != undef)
            node.outlineColor = oc
        end

        if (lc != undef)
            node.labelColor = lc
        end

        if (size != undef)
            node.size = size
        end
    end
end