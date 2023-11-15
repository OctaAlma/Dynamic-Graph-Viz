using DataStructures
include("./VisualizationTools.jl")
include("../loaders/vacLoader.jl")

#= 
We can store graph states in a sparse matrix that keeps track of changes in the label
The pros: 
 - Very space efficient
 - instant lookup to a specific state

The cons: 
 - We can only store float and int values in sparse matrices. This means strings must be stored in some other separate data structure
 - If we wanted to plot a specific data structure, we would have to start from the original graph state, then apply every step

Current approach: Store the whole graph after important steps in an algorithm
Cons:
 - VERY space inneficient

Pros:
 - Instant access to a specific graph state
=#

function runBFS(g::Graph, sLabel::String)::Vector{GraphState}
    graphStates::Vector{GraphState} = []

    sInd = findNodeIndexFromLabel(g, sLabel)

    if (sInd == -1)
        println("Could not find a node with label ", sLabel)
    end
    
    # The attributes vector contains n elements
    # Each element is a Tuple containing the node's distance from the source and the node's "parent"
    attributes::Vector{Tuple{Int64, Int64}} = []
    nodeLabels::Vector{String} = []

    # Setup the attributes vector and the node coloring
    for v in g.nodes
        v.fillColor = "white"
        push!(attributes, (-1, -1))
        push!(nodeLabels, "d = ∞\nπ = NIL")
    end

    attributes[sInd] = (0, -1)

    Q = Queue{Int}()

    desc = "Initialize BFS by setting each node's distance from source to ∞ and the color to white.\nAlso initialize the Queue data structure."
    push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))

    enqueue!(Q, sInd)
    nodeLabels[sInd] = "d = " * string(attributes[sInd][1]) * "\nπ = " * string(attributes[sInd][2])
    desc = "Push the source node " * g.nodes[sInd].label * " to the queue."
    push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))

    while !isempty(Q)

        uInd = dequeue!(Q)
        highlightNode(g, uInd, color="Black")

        adjNodes = getAdjacentNodeIndices(g, uInd)

        for vInd in adjNodes
            highlightEdge(g, uInd, vInd, color="red")
        end

        desc = "Popped the node " * g.nodes[uInd].label * " from the queue and highlighted its neighbors"
        push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))

        for vInd in adjNodes
            highlightEdge(g, uInd, vInd, color="green")

            v = g.nodes[vInd]

            desc = "Visiting node " * g.nodes[uInd].label * "'s adjacent node " * v.label * "."
            push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))

            if v.fillColor == "white"
                v.fillColor = "gray"
                attributes[vInd] = (attributes[uInd][1] + 1, uInd)

                nodeLabels[vInd] = "d = " * string(attributes[vInd][1]) * "\nπ = " * string(attributes[vInd][2])

                enqueue!(Q, vInd)
                
                desc = "Updated node " * v.label * "'s color and distance from source."
                push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))
            else
                desc = "Since node " * v.label * "'s color is not white, we continue to the next adjacent node."
                push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))
            end
            
            resetEdgeColor(g, uInd, vInd)
        end
        
        g.nodes[uInd].fillColor = "black"
        g.nodes[uInd].labelColor = "white"
        
        desc = "Set node " * g.nodes[uInd].label * " color to black"
        push!(graphStates, GraphState(deepcopy(g), collect(Int64, deepcopy(Q)), desc, deepcopy(nodeLabels), []))
        resetNodeColor(g, uInd)
    end

    return graphStates
end

filename = "../resources/testundir.vac"
G = vacRead(filename)
source = "1"

graphStates = runBFS(G, source)

makegif = false
dpi = 400
fps = 2
iterateThroughGraphState(graphStates, "Queue", makegif, Δt = 0.2, FPS = fps, DPI = dpi)