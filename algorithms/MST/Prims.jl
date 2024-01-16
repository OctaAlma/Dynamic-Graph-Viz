using DataStructures
include("../../GraphPlots.jl")
include("../Search/VisualizationTools.jl")
include("../../loaders/vacLoader.jl")

#=
MST-Prim (G, w, r)
    for each u ∈ G.V 
        u.key = ∞
        u.π = NIL 

    r.key = 0
    Q = G.V 
    while (Q ≠ ∅)
        u = extractMin(Q)
        for each v ∈ G.Adj[u]
            if (v ∈ Q and w(u,v) < v.key)
                v.π = u 
                v.key = w(u,v)
=#

function inQueue(Q::PriorityQueue{Int64, Float64}, key::Int64)
    try
        Q[key]
    catch e
        if isa(e, KeyError)
            return false
        end
    end

    return true
end

function runPrims(G::Graph, sourceLabel::String)
    # Attributes is a vector of tuples that store
    #   - The index/key of the parent node (Int64)
    #   - The weight from the source node (Float64)
    
    # Create a way to store each of the node's parents
    attributes::Vector{Tuple{Float64, Int64}} = []
    n = length(G.nodes)
    for i ∈ 1:n
        push!(attributes, (Inf, -1))
    end

    # Initialize a priority queue
    # The keys will be the indices of nodes and the weight will be the value
    pq = PriorityQueue{Int64, Float64}()

    for u ∈ G.nodes
        enqueue!(pq, u.index, Inf)
    end

    # Set the value for the source node to be 0
    sourceInd = findNodeIndexFromLabel(G, sourceLabel)
    pq[sourceInd] = 0.0

    while (!isempty(pq))
        # Pop the element with lowest weight
        uInd = dequeue!(pq)
        println(uInd)

        # Get all of the adjacent nodes
        uAdjNodes = getAdjacentNodeIndices(G, uInd)

        for vInd in uAdjNodes
            uvWeight = getEdgeWeight(G, uInd, vInd)
            if (inQueue(pq, vInd) && (uvWeight < pq[vInd]))
                pq[vInd] = uvWeight
                attributes[vInd] = (uvWeight, uInd)
            end
        end
    end

    println("attributes: ", attributes)
end

filename = "../resources/testDir.vac"
G = vacRead(filename)
runPrims(G, "3")