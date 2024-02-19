include("../structFiles/GraphState.jl")
include("../loaders/Loaders.jl")
include("../GraphPlots.jl")

function initKruskal(G::Graph)
    # Set all nodes to different colors
    colors = ["red", "green", "blue", "yellow", "purple", "orange", "maroon",
        "lavender", "pink", "magenta", "brown", "coral", "cyan"]
    
    if (length(G.nodes) > length(colors))
        println("Too many nodes\n")
        return
    end
    
    currColorInd = 1
    for node in G.nodes
        node.fillColor = colors[currColorInd]
        currColorInd += 1
        node.size = 20
    end

    for edge in G.edges
        edge.color = "lightgrey"
        edge.lineWidth = 2
    end

end

function findSet(a, parents)
    if parents[a] == a
        return a
    end

    parents[a] = findSet(parents[a], parents)
    return parents[a]
end

function mergeSet(a, b, parents, G)
    setColor = "dodgerblue"

    aSet = findSet(a, parents)
    bSet = findSet(b, parents)

    if (aSet != bSet)
        # Merge sets by making all nodes the same color             
        for i in eachindex(parents)
            findSet(i, parents)
            if parents[i] == bSet || parents[i] == aSet
                G.nodes[i].fillColor = G.nodes[bSet].fillColor
                # G.nodes[i].fillColor = setColor
                parents[i] = bSet
            end
        end
    end

end

function allNodesSameSet(parents)
    prev = -1

    for i in eachindex(parents)
        if (prev == -1)
            prev = findSet(i, parents)
            continue
        end
        
        if (findSet(i, parents) != prev)
            return false
        end
    end
    return true
end

#=
Kruskal's algorithm
    A = ∅
    for each vertex v ∈ G.V:
        Make-Set(v)

    sort the edges of G.E into nondecreasing order by weight w 

    for each edge (u, v) ∈ G.E, taken in nondecreasing order by weight
        if find-set(u) ≠ find-set(v)
            A = A ∪ {(u, v)}
            Union(u, v)

    return A
=#

function runKruskal(G::Graph)::Vector{GraphState}
    
    states::Vector{GraphState} = []
    parents = collect(1:length(G.nodes))
    initKruskal(G) # sets up node colors and edge colors

    # Sort edges by weight (lowest to highest)
    sortedEdges = sort!(deepcopy(G.edges), by = e -> e.weight)
    
    iteration = 1
    for edge in sortedEdges
        edgeInd = findEdgeIndex(G, edge.sourceKey, edge.destKey)
        G.edges[edgeInd].color = "black"
        G.edges[edgeInd].lineWidth = 5

        u = getNode(G, edge.sourceKey)
        v = getNode(G, edge.destKey)
        
        desc = "We are now focusing on the edge from " * u.label * " to " * v.label
        push!(states, deepcopy(GraphState(G, desc, [])))

        uSet = findSet(u.index, parents)
        vSet = findSet(v.index, parents)

        if (uSet != vSet)
            mergeSet(uSet, vSet, parents, G)
            desc = "We merged the sets " * u.label * " to " * v.label
            push!(states, deepcopy(GraphState(G, desc, [])))
            desc = "The nodes now belong to the same set. Continue"
        else
            desc = "The nodes already belong to the same set. Continue"
            G.edges[edgeInd].color = "lightgrey"
        end

        G.edges[edgeInd].lineWidth = 3
        push!(states, deepcopy(GraphState(G, desc, [])))

        iteration += 1

        # Check if all nodes have been visited
        if allNodesSameSet(parents)
            desc = "All nodes are now in the same set. We are done!"
            push!(states, deepcopy(GraphState(G, desc, [])))
            break
        end
    end

    return states
end

g = vacRead("../resources/testDir.vac")
s = runKruskal(g)
saveGIF(s, "kruskal.gif", interval = 0.2, showLabels = false, showTicks = false)
saveStatesToPDFs(s, "kruskal", 1, length(s), false, false)

println("Done!")