using DataStructures
include("SSSP-helpers.jl")

function runDijkstra(G::Graph, sourceLabel::String)

    sourceInd = findNodeIndexFromLabel(G, sourceLabel)

    if (sourceInd == -1)
        println("Could not find node with label ", sourceLabel)
        return
    end

    
    attributes = initSingleSource(G, sourceInd)
    PQ = PriorityQueue()

    for v in attributes
        PQ[v[1]] = v[2]
    end

    while (!isempty(PQ))
        uInd = dequeue!(PQ)
        neighbors = getAdjacentNodeIndices(G, uInd)

        for vInd ∈ neighbors
            relax(G, attributes, uInd, vInd)
        end
    end

    print(attributes)

end

filename = "../../resources/testDir.vac"
G = vacRead(filename)
runDijkstra(G, "1")