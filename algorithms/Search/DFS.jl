include("../../GraphPlots.jl")
include("../Search/VisualizationTools.jl")
include("../../loaders/vacLoader.jl")

#= 
    Code is based off of Pseudocode provided in page 604 
    of An Introduction to Algorithms, 3rd Edition by Thomas H Cormen, et. al
=#

function DFS_visit(G::Graph, uInd::Int64, attributes::Vector, time::Int64)
    time = time + 1
    attributes[uInd][1] = "gray"
    attributes[uInd][3] = time # Set the start time 
    
    neighborNodes = getAdjacentNodeIndices(G, uInd)
    for vInd ∈ neighborNodes
        if (attributes[vInd][1] == "white")
            attributes[vInd][2] = uInd
            DFS_visit(G, vInd, attributes, time)
        end
    end
    
    attributes[uInd][1] = "black"
    attributes[uInd][4] = time # set the finish time

    time = time + 1
end

function runDFS(G::Graph)
    n = length(G.nodes)
    
    # The attributes will be:
    #    - Color, represented with string
    #    - Parent node, represented as its integer index
    #    - Discovery time, represented by an integer
    #    - Finish Time, represented by an integer
    attributes = []
    for i ∈ 1:n
        push!(attributes, ["white", -1, -1, -1])
    end

    time = 0

    for u ∈ G.nodes
        if attributes[u.index][1] == "white"
            DFS_visit(G, u.index, attributes, time)
        end
    end

    println(attributes)
end

filename = "../../resources/testDir.vac"
G = vacRead(filename)
runDFS(G)