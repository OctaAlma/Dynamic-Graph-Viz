include("../structFiles/GraphState.jl")
include("../loaders/Loaders.jl")
include("../GraphPlots.jl")

function getDegrees(G::Graph)::Vector{Int64}
    degrees = Vector{Int64}()
    sizehint!(degrees, length(G.nodes))
    for i in 1:length(G.nodes)
        push!(degrees, 0)
    end
    
    for edge in G.edges
        degrees[edge.sourceKey] += 1
        degrees[edge.destKey] += 1
    end

    return degrees
end

function allGreaterThan(degrees::Vector{Int64}, k::Int64)
    allNegs = true
    for i in degrees
        if i < k
            return false
        end

        if i != -1
            allnegs = false
        end
    end

    return allNegs
end

function vizRemoveNode(states::Vector{GraphState}, G::Graph, degrees::Vector{Int64}, nodeInd::Int64)
    if length(G.nodes) == 0
        return
    end
    i = 1
    numEdges = length(G.edges)
    while i <= numEdges
        curr = G.edges[i]

        if curr.sourceKey == nodeInd || curr.destKey == nodeInd 
            curr.color = "red"
            curr.lineWidth = 7

            desc = "Removing edge from " * G.nodes[curr.sourceKey].label * " to " * G.nodes[curr.destKey].label
            push!(states, GraphState(deepcopy(G), desc, []))
            
            if (curr.sourceKey == nodeInd)
            # Decrease the degree of the destination
                degrees[curr.destKey] -= 1
            else
            # Decrease the degree of the source
                degrees[curr.sourceKey] -= 1
            end

            deleteat!(G.edges, i)
            i -= 1
            numEdges -= 1
        end
        i += 1
    end
    degrees[nodeInd] = -1 # Indicates that the node has been deleted, so its degree does not matter

    desc = "Removing node " * G.nodes[nodeInd].label * " from the graph"
    push!(states, GraphState(deepcopy(G), desc, []))
    removeNode(G, G.nodes[nodeInd].label)

end

function runKCore(G::Graph, k::Int64)::Vector{GraphState}
    states::Vector{GraphState} = []
    degrees = getDegrees(G)

    while (!allGreaterThan(degrees, k) || length(G.nodes) != 0)
        numDeleted = 0
        for i in eachindex(degrees)
            if degrees[i] < k
                if degrees[i] == -1
                    numDeleted += 1
                    continue
                end

                if (i - numDeleted == 0 || length(G.nodes) == 0)
                    println("sss")
                    break
                end
                
                G.nodes[i - numDeleted].fillColor = "red"
                desc = "Node " * G.nodes[i - numDeleted].label * " has a degree of " * string(degrees[i]) * " which is less than " * string(k) * "!"
                push!(states, GraphState(deepcopy(G), desc, []))
                
                vizRemoveNode(states, G, degrees, i - numDeleted)
                numDeleted += 1
            end
        end
    end

    return states
end 

g = vacRead("../resources/testDir.vac")
s = runKCore(g, 4)
println(s)