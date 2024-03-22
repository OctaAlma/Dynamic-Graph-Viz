include("../structFiles/GraphState.jl")
include("../loaders/Loaders.jl")
include("../GraphPlots.jl")

# This code was based on pseudocode found in 
# https://www.baeldung.com/cs/graph-k-core

function initKCore(core::Graph)
    # Color all nodes some color and make them a size
    p = split("setall nodes -fc white -s 35", " ")
    setAllNodes(core, p)
    p = split("setall edges -t 5 -c grey", " ")
    setAllEdges(core, p)
end

function computeDegreeVec(core::Graph)
    deg = zeros(length(core.nodes))
    
    for e in core.edges
        deg[e.sourceKey] += 1
        deg[e.destKey] += 1    
    end

    return deg
end

# Returns whether there is a degree less than k
function existsDegLTk(deg, k)
    for d in deg
        if (d < k)
            return true    
        end
    end

    return false
end

#=
 Degree Pruning algorithm
 Input: An undirected, unweighted graph and an integer k
=#
function runkCore(G::Graph, k::Int64)::Vector{GraphState}
    states::Vector{GraphState} = []
    core = deepcopy(G)
    n = length(core.nodes)
    deg = computeDegreeVec(core)

    initKCore(core)
    push!(states, GraphState(deepcopy(core), "", deepcopy(deg)))

    while (existsDegLTk(deg, k))
        
        for i in range(1, length(core.nodes))
            if (deg[i] < k)
                
                rmNodeLabel = core.nodes[i].label
                core.nodes[i].fillColor = "firebrick"
                core.nodes[i].outlineColor = "firebrick"

                for e in core.edges
                    if (e.sourceKey == i || e.destKey == i)
                        e.color = "firebrick"
                        e.lineWidth = 8
                        deg[e.sourceKey] -= 1
                        deg[e.destKey] -= 1
                    end
                end

                str = "Removing node: " * rmNodeLabel
                push!(states, GraphState(deepcopy(core), str, deepcopy(deg)))

                # Remove node at index i from graph 
                # note: removeNode() also deletes incident edges
                removeNode(core, core.nodes[i].label)

                # Recompute the degrees of each node from the updated core
                deg = computeDegreeVec(core)

                str = "Removed node " * rmNodeLabel
                push!(states, GraphState(deepcopy(core), str, deepcopy(deg)))
                break
            end
        end
    end

    setAllNodes(core, split("setall nodes -fc black -lc white", " "))
    str = "Final " * string(k) * " core"
    push!(states, GraphState(deepcopy(core), str, deepcopy(deg)))

    return states
end

# Plot the degree below the node label
function plotkCoreLabels(p, g, meta)
    n = length(g.nodes)
    for i in 1:n
        x = g.nodes[i].xCoord
        y = g.nodes[i].yCoord

        # Plot the node's label on top bold
        label = g.nodes[i].label * "\n"
        # Plot the node's degree under the label
        deglabel = "\ndeg=" * string(Int(meta[i]))

        if (g.nodes[i].fillColor == "white")
            annotate!(p, x, y, text(label, "Times Bold", 15, :black))
            annotate!(p, x, y, text(deglabel, "computer modern", 10))
        else            
            annotate!(p, x, y, text(label, "Times Bold", 15, :white))
            annotate!(p, x, y, text(deglabel, "computer modern", 10, :white))
        end
    end
end

function drawkCore(states::Vector{GraphState})
    numStates = length(states)
    foldername = "k-core"
    cd(foldername)
    anim = Animation()
    for i in 1:numStates
        currState = states[i]
        currPlot = makePlot(currState.g, false, false)
        plotkCoreLabels(currPlot, currState.g, currState.meta)
        
        # Save a pdf file of each state
        filename = "$i.pdf"
        savefig(currPlot, filename)

        # Add the current state to a gif
        frame(anim, currPlot)
    end

    # Export the final gif
    gif(anim, "kcore.gif", fps=3)
end

G = vacRead("../resources/kcore.vac")
s = runkCore(G, 3)
drawkCore(s)