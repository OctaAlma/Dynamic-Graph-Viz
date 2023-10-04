using LinearAlgebra, Plots, MAT, SparseArrays
include("./structFiles/Graph.jl")

# This code was obtained from the provided graph_visualizations.jl file
function display_graph(A::SparseMatrixCSC{Float64,Int64},xy::Matrix{Float64},grayscale = 0.0,ms = 6,lw = 1)
    f = plot(legend=false, axis = false,grid = false,xticks = false,yticks = false)
    ei,ej,w = findnz(triu(A))
    scatter!(f,xy[:,1],xy[:,2],color = RGB(grayscale,grayscale,grayscale),markersize = ms, markerstrokecolor =  RGB(grayscale,grayscale,grayscale))
    lx = [xy[ei,1]';xy[ej,1]']
    ly = [xy[ei,2]';xy[ej,2]']
    for i = 1:length(w)
        # draws line from the first point, to the second point
        plot!(f,lx[:,i],ly[:,i],color = RGB(grayscale,grayscale,grayscale), linewidth = lw)
    end
    return f
end

function extractA(M::Dict{String, Any})
    if (haskey(M, "Problem") == true)
        if (haskey(M["Problem"], "A") == true)
            if (typeof(M["Problem"]["A"]) == SparseArrays.SparseMatrixCSC{Float64, Int64})
                return M["Problem"]["A"]
            end
        end

    elseif (haskey(M, "A") == true)
        if (typeof(M["A"]) == SparseArrays.SparseMatrixCSC{Float64, Int64})
            return M["A"]
        end
        
    end
    return nothing
end 


function extractxy(M::Dict{String, Any})
    if (haskey(M, "Problem") == true)
        if (haskey(M, "xy")== true)
            if (typeof(M["Problem"]["xy"]) == Matrix{Float64})
                return M["Problem"]["xy"]
            end
        end

    elseif (haskey(M, "xy") == true)
        if (typeof(M["xy"]) == Matrix{Float64})
            return M["xy"]
        end
    end

    return nothing
end

function MATRead(filepath::String)::Graph
    newGraph = Graph()

    newGraph.versionNo = 1
    newGraph.directed = false
    newGraph.weighted = true
    empty!(newGraph.edges)
    empty!(newGraph.nodes)

    # matread creates a dictionary containing all of the dictionaries defined
    # in the .mat file
    M = matread(filepath)
    A = extractA(M)
    if (isnothing(A) == true)
        println("Could not define sparse matrix A on file ", filepath)
        return newGraph
    end

    hasXY = true

    xy = extractxy(M)
    if (isnothing(xy) == true)
        println("There are no xys provided in the file ", filepath)
        hasXY = false
    end

    ei,ej,w = findnz(triu(A))

    n = length(ei)
    nodesAdded = []
    nodeIndex = 1
    for i in 1:n
        sourceNode = ei[i] # index and label of the source node
        destNode = ej[i]
        
        if findNodeIndexFromLabel(newGraph, "$sourceNode") == -1
            push!(nodesAdded, nodeIndex)
            
            newNode = Node(label = "$sourceNode", index = nodeIndex, size=10)        
            nodeIndex  = nodeIndex + 1

            if (hasXY)
                newNode.xCoord = xy[sourceNode, 1]
                newNode.yCoord = xy[sourceNode, 2]
            end
            push!(newGraph.nodes, newNode)
            println(newNode)
        end

        if findNodeIndexFromLabel(newGraph, "$destNode") == -1
            push!(nodesAdded, nodeIndex)

            newNode = Node(label = "$destNode", index = nodeIndex, size=10)
            nodeIndex  = nodeIndex + 1
            
            if (hasXY)
                newNode.xCoord = xy[destNode, 1]
                newNode.yCoord = xy[destNode, 2]            
            end
            println(newNode)
            push!(newGraph.nodes, newNode)
        end

        edgeWeight = w[i]

        addEdge(newGraph, "$sourceNode", "$destNode", edgeWeight)
    end

    setGraphLimits(newGraph)
    return newGraph
end