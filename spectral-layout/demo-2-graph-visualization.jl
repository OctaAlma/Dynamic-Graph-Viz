using LinearAlgebra, Plots, MAT
include("graph_visualizations.jl")
include("read_write_build_graphs.jl")

include("../structFiles/Graph.jl")
include("../loaders/matLoader.jl")
include("../loaders/vacLoader.jl")


# The following function will create a sparse matrix representing the graph
function createSparseMatrix(g::Graph)::SparseArrays.SparseMatrixCSC{Float64, Int64}
    ei = []
    ej = []
    w = []

    for edge in g.edges
        push!(ei, edge.sourceKey)
        push!(ej, edge.destKey)

        if !g.directed
            push!(ej, edge.sourceKey)
            push!(ei, edge.destKey)
            if (g.weighted) 
                push!(w, edge.weight) 
            else 
                push!(w, 1.0) 
            end
        end

        if (g.weighted) 
            push!(w, edge.weight) 
        else 
            push!(w, 1.0) 
        end
    end

    A = sparse(ei, ej, w)
    
    return A
end

function makeRealMatrix(xy::Matrix{ComplexF64})
    rows = size(xy,1)
    cols = size(xy,2)

    M = zeros(rows, cols)
    
    for i in 1:rows
        for j in 1:cols
            M[i, j] = real(xy[i, j])
            println("M[i, :][j] = ", M[i, :][j])
        end
    end

    return M
end

resourcePath = "../resources/"
G = MATRead(resourcePath*"Karate.mat");
#G = vacRead(resourcePath*"test.vac")
A = createSparseMatrix(G)


xy = spectral_layout(A)

if (typeof(xy) == Matrix{ComplexF64})
    xy = makeRealMatrix(xy)
end

println(typeof(xy))

println(xy)

f = display_graph(A, xy)


## Load the karate graph with its visualization
# filename = "../resources/Karate.mat"
# M = matread(filename)
# A = M["A"]

# println(typeof(A))

# xy_default = M["xy"]
# f = display_graph(A,xy_default)

# ## Use igraph_layout
# xy = igraph_layout(A)
# f = display_graph(A,xy)

# ## In some cases, we can use eigenvectors to plot a graph
# A = cycle_graph(10)
# xy = spectral_layout(A)
# f = display_graph(A,xy)
