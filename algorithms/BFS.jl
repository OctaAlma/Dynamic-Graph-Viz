using DataStructures
include("../structFiles/GraphState.jl")
include("../loaders/Loaders.jl")
include("../GraphPlots.jl")


function BFSSetup(G::Graph, sInd::Int64)
    attributes = []
    for u in G.nodes
        u.size = 38
        u.fillColor = "white"
        push!(attributes, [Inf, "∅"])
    end

    G.nodes[sInd].fillColor = "lightgrey"
    attributes[sInd][1] = 0.0

    for e in G.edges
        e.color = "grey"
        e.lineWidth = 5
    end

    return attributes
end

function runBFS(G::Graph, sInd::Int64)
    states::Vector{GraphState} = []
    qs = []
    attributes = BFSSetup(G, sInd)
    
    Q = Queue{Int}()
    enqueue!(Q, sInd)

    push!(qs, deepcopy(Q))
    push!(states, GraphState(deepcopy(G), "", deepcopy(attributes)))
    
    while (length(Q) != 0)
        uInd = dequeue!(Q)
        adju = getAdjacentNodeIndices(G, uInd)

        edgeInds = []
        edgeCols = []
        for vInd in adju
            eInd = findEdgeIndex(G, vInd, uInd)
            push!(edgeInds, eInd)
            push!(edgeCols, G.edges[eInd].color)
            G.edges[eInd].color = "red"
        end

        push!(qs, deepcopy(Q))
        push!(states, GraphState(deepcopy(G), "", deepcopy(attributes)))

        i = 1

        for vInd in adju
            eInd = edgeInds[i]
            G.edges[eInd].color = "chartreuse3"
            push!(qs, deepcopy(Q))
            push!(states, GraphState(deepcopy(G), "", deepcopy(attributes)))

            if (G.nodes[vInd].fillColor == "white")
                G.nodes[vInd].fillColor = "lightgrey"
                attributes[vInd][1] = attributes[uInd][1] + 1
                attributes[vInd][2] = G.nodes[uInd].label
                enqueue!(Q, vInd)
                push!(qs, deepcopy(Q))
                push!(states, GraphState(deepcopy(G), "", deepcopy(attributes)))
                edgeCols[i] = "gold"
            end
            G.edges[eInd].color = edgeCols[i]
            push!(qs, deepcopy(Q))
            push!(states, GraphState(deepcopy(G), "", deepcopy(attributes)))
            i += 1
        end

        G.nodes[uInd].fillColor = "black"
        G.nodes[uInd].labelColor = "white"
        push!(qs, deepcopy(Q))
        push!(states, GraphState(deepcopy(G), "", deepcopy(attributes)))
        
    end

    return states, qs
end

function plotBFSLabels(p, g, metadata)
    n = length(g.nodes)
    for i in 1:n
        x = g.nodes[i].xCoord
        y = g.nodes[i].yCoord
        
        # Make the node label bold
        if (g.nodes[i].labelColor == "black")
            annotate!(p, x, y, text(g.nodes[i].label * "\n\n", "Times Bold", 12, :black))
            
            if metadata[i][1] != Inf
                str = "\nd=" * string(trunc(Int64, metadata[i][1])) * "\nπ=" * string(metadata[i][2])
                annotate!(p, x, y, text(str, "computer modern", 12))
            else
                str = "\nd=∞\nπ=" * string(metadata[i][2])
                annotate!(p, x, y, text(str, "computer modern", 12))
            end
        
        else
            annotate!(p, x, y, text(g.nodes[i].label * "\n\n", "Times Bold", 12, :white))
            
            if metadata[i][1] != Inf
                str = "\nd=" * string(trunc(Int64, metadata[i][1])) * "\nπ=" * string(metadata[i][2])
                annotate!(p, x, y, text(str, "computer modern", 12, :white))
            else
                str = "\nd=∞\nπ=" * string(metadata[i][2])
                annotate!(p, x, y, text(str, "computer modern", 12, :white))
            end
        end
    end
end

function drawBFS(states::Vector{GraphState}, qs)
    numStates = length(states)

    foldername = "BFS"
    cd(foldername)
    
    anim = Animation()
    for i in 1:numStates
        # Extract all the information for viz
        currState = states[i]

        currq = collect(qs[i])

        currPlot = makePlot(currState.g, false, false, txtsize = 18)
        drawArray(currPlot, currState.g, currq, maxEntries = 4, txtsize = 18)
        plotBFSLabels(currPlot, currState.g, currState.meta)

        # Save a pdf file of each state
        filename = "$i.pdf"
        savefig(currPlot, filename)
        
        # Add the current state to a gif
        frame(anim, currPlot)
    end

    gif(anim, "bfs.gif", fps=3)
end

g = vacRead("../resources/bfs.vac")
s, qs = runBFS(g, 1)
drawBFS(s, qs)
