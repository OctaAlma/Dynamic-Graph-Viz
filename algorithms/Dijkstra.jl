using DataStructures
include("../structFiles/GraphState.jl")
include("../loaders/Loaders.jl")
include("../GraphPlots.jl")

function initSingleSource(G::Graph, sInd::Int64)
    attributes = []
    for v in G.nodes
        v.size = 29
        v.fillColor = "white"
        push!(attributes, [Inf, "NIL"])
    end

    attributes[sInd][1] = 0.0

    for e in G.edges
        e.color = "grey"
        e.lineWidth = 3
    end

    return attributes
end

function relax(G::Graph, states, attributes, pqs, pq, uInd::Int64, vInd::Int64)
    edgeInd = findEdgeIndex(G, uInd, vInd)
    edgeuv = G.edges[edgeInd]

    G.edges[edgeInd].lineWidth = 5
    G.edges[edgeInd].color = "gold"

    desc = "Relaxing node " * G.nodes[vInd].label
    push!(states, GraphState(deepcopy(G), desc, deepcopy(attributes)))
    push!(pqs, deepcopy(pq))

    if (attributes[vInd][1] > attributes[uInd][1] + edgeuv.weight)
        if (attributes[vInd][2] != "NIL")
            # Note: we have to remove the edge from its previous parent to node v to denote it's not part of sssp
            G.edges[findEdgeIndex(G, findNodeIndexFromLabel(G, attributes[vInd][2]), vInd)].color = "lightgrey"
        end

        attributes[vInd][1] = attributes[uInd][1] + edgeuv.weight
        attributes[vInd][2] = G.nodes[uInd].label
        pq[vInd] = attributes[vInd][1]

        return true
    end

    return false
end

function runDijkstra(G::Graph, sInd::Int64)

    # The julia priority queue uses key-value pairs, and are sorted by value
    #  - We can update a value with pq[key] = newVal
    #  - Keys must be unique
    #  - In our case, we can make the keys the node indices (unique) and 
    #    the values their shortest path estimate
    pq = PriorityQueue()
    attributes = initSingleSource(G, sInd)
    S = Set()

    currNodeInd = 1
    for i in eachindex(attributes)
        enqueue!(pq, i, attributes[i][1])
    end

    pqs::Vector{PriorityQueue} = []
    states::Vector{GraphState} = []
    
    desc = "Initialized nodes to apply the SSSP procedure"
    push!(states, GraphState(deepcopy(G), desc, deepcopy(attributes)))
    push!(pqs, deepcopy(pq))

    # Unfortunately, we will have to update the attributes of each node AND the pq separately
    while (length(pq) != 0)
        uInd = dequeue!(pq)
        G.nodes[uInd].fillColor = "dodgerblue"
        desc = "Dequeued the node " * G.nodes[uInd].label
        push!(states, GraphState(deepcopy(G), desc, deepcopy(attributes)))
        push!(pqs, deepcopy(pq))

        push!(S, uInd)
        uNeighbors = getAdjacentNodeIndices(G, uInd)
        # Color all of edges connecting u's neighbors
        origColors = [G.nodes[v].fillColor for v in uNeighbors]
        
        for vInd in uNeighbors
            edgeInd = findEdgeIndex(G, uInd, vInd)
            G.edges[edgeInd].color = "red"
            G.edges[edgeInd].lineWidth = 3
            
            if (G.nodes[vInd].fillColor != "orange")
                G.nodes[vInd].fillColor = "chartreuse3"
            end
        end

        desc = "Applying the relax procedure on the neighbors of " * G.nodes[uInd].label
        push!(states, GraphState(deepcopy(G), desc, deepcopy(attributes)))
        push!(pqs, deepcopy(pq))

        i = 1
        
        for vInd in uNeighbors
            edgeInd = findEdgeIndex(G, uInd, vInd)

            # Relax returns true if the edge was relaxed. False otherwise
            if (relax(G, states, attributes, pqs, pq, uInd, vInd))
                desc = "The estimated shortest path for " * G.nodes[vInd].label * " has decreased!"
                push!(states, GraphState(deepcopy(G), desc, deepcopy(attributes)))
                push!(pqs, deepcopy(pq))
                
                G.nodes[vInd].fillColor = "chartreuse3"
                G.edges[edgeInd].color = "black"
            else
                desc = "Could not relax node " * G.nodes[vInd].label
                push!(states, GraphState(deepcopy(G), desc, deepcopy(attributes)))
                push!(pqs, deepcopy(pq))
                G.nodes[vInd].fillColor = origColors[i]
                G.edges[edgeInd].color = "lightgrey"
            end

            G.edges[edgeInd].lineWidth = 3
            desc = "Moving on to " * G.nodes[uInd].label * "'s next neighbor"
            push!(states, GraphState(deepcopy(G), desc, deepcopy(attributes)))
            push!(pqs, deepcopy(pq))

            i += 1
        end

        G.nodes[uInd].fillColor = "orange"
        desc = "Finished exploring all neighbors of " * G.nodes[uInd].label
        push!(states, GraphState(deepcopy(G), desc, deepcopy(attributes)))
        push!(pqs, deepcopy(pq))

    end

    return states, pqs
end

function plotDijkstraLabels(p, g, metadata)
    n = length(g.nodes)
    for i in 1:n
        x = g.nodes[i].xCoord
        y = g.nodes[i].yCoord
        
        # Make the node label bold
        annotate!(p, x, y, text(g.nodes[i].label * "\n\n", "Times Bold", 8, :black))

        if metadata[i][1] != Inf
            str = "\nd=" * string(trunc(Int64, metadata[i][1])) * "\nπ=" * string(metadata[i][2])
            annotate!(p, x, y, text(str, "computer modern", 8))
        else
            str = "\nd=" * string(metadata[i][1]) * "\nπ=" * string(metadata[i][2])
            annotate!(p, x, y, text(str, "computer modern", 8))
        end
    end
end

function drawDijkstra(states::Vector{GraphState}, pqstates::Vector{PriorityQueue})
    numStates = length(states)
    anim = Animation()
    for i in 1:numStates
        # Extract all the information for viz
        currState = states[i]
        currpq = collect(pqstates[i])
        currpqkeys = [ v[1] for v in currpq]

        currPlot = makePlot(currState.g, false, false)
        drawArray(currPlot, currState.g, currpqkeys, maxEntries = 5)
        plotDijkstraLabels(currPlot, currState.g, currState.meta)

        # Save a pdf file of each state
        filename = "$i.pdf"
        savefig(currPlot, filename)
        
        # Add the current state to a gif
        frame(anim, currPlot)
    end

    gif(anim, "dijkstra.gif", fps=3)
end

g = vacRead("../resources/testDir.vac")
s, pqs = runDijkstra(g, 1)
drawDijkstra(s, pqs)
