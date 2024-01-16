using DataStructures
include("../../GraphPlots.jl")
include(".././VisualizationTools.jl")
include("../../loaders/vacLoader.jl")

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

function findSetIndex(nodeSets, v::Node)::Int64
    n = length(nodeSets)
    for setInd in 1:n
        currSet = nodeSets[setInd]

        for e ∈ currSet
            if (v.index == e.index)
                return setInd
            end
        end
    end

    return -1
end

function runKruskal(G::Graph)
    if G.weighted != true
        return
    end
    
    # MST starts as empty set
    mstSet = Set()
    
    # For each node, create a set containing only itself
    nodeSets = []
    for v in G.nodes
        push!(nodeSets, Set([v]))
    end

    # Sort edges by weight (lowest to highest)
    sortedEdges = sort!(deepcopy(G.edges), by = e -> e.weight)

    for edge in sortedEdges
        u = getNode(G, edge.sourceKey)
        v = getNode(G, edge.destKey)
        
        uSetInd = findSetIndex(nodeSets, u)
        vSetInd = findSetIndex(nodeSets, v)
        # If nodes u and v are NOT in the same set, create a superset containing both of the sets they belong in
        if (uSetInd != vSetInd)
            superSet = union(nodeSets[uSetInd], nodeSets[vSetInd])
            
            if (uSetInd > vSetInd)
                deleteat!(nodeSets, uSetInd)
                deleteat!(nodeSets, vSetInd)
            else
                deleteat!(nodeSets, vSetInd)
                deleteat!(nodeSets, uSetInd)
            end

            push!(nodeSets, superSet)
            mstSet = union(mstSet, Set([edge]))
        end
    end

    println(mstSet)
end

filename = "../resources/testDir.vac"
G = vacRead(filename)
runKruskal(G)