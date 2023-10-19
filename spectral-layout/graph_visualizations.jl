using SparseArrays
using PyCall
const igraph = pyimport_conda("igraph","python-igraph","conda-forge")
const pyrandom = pyimport("random")

"""
This calls a graph layout function in Python, using the PyCall and Conda packages
"""
function igraph_layout(A::SparseMatrixCSC{T}, layoutname::AbstractString="fr") where T
    ei,ej,ew = findnz(A)
    edgelist = [(ei[i]-1,ej[i]-1) for i = 1:length(ei)]
    nverts = size(A)
    G = igraph.Graph(nverts, edges=edgelist, directed=false)
    xy = G.layout(layoutname)
 
    xy = [Float64(xy[i][j]) for i in 1:length(xy),  j in 1:length(xy[1])]
end


"""
Given an adjacency matrix and a 2-D layout, plot the graph
"""
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


using Random
using LinearAlgebra
Random.seed!(1)
"""
From: https://github.com/dgleich/flow-and-eigenvectors
"""
function simple_spectral_eigenvectors(A,k;nsteps=500,tol=1e-6)
  @assert issymmetric(A) # expensive, but useful...
  n = size(A,1)
  d = vec(sum(A,dims=1))
  nd2 = d'*d
  X = randn(n,k)
  # project x orthogonal to d
  X .-= ((d'*X)/nd2).*d
  #x ./= x'*(d.*x) # normalize
  Q = qr!(sqrt.(d).*X).Q
  X = sqrt.(1.0./d).*Matrix(Q)
  for i=1:nsteps
    X .+= (A*X)./d     # matrix-vector with (I + AD^{-1}) X
    X .-= ((d'*X)/nd2).*d
    Q = qr!(sqrt.(d).*X).Q
    X = sqrt.(1.0./d).*Matrix(Q)
  end
  # make sure the first component is positive
  X .*= repeat(sign.(X[1,:])',size(X,1),1)

  return X
end


using Arpack
using KrylovKit
"""
Create a layout of the graph based on eigenvectors
"""
function spectral_layout(A)
    d = vec(sum(A,dims = 2))
    Dhalf = Diagonal(d.^(-1/2))
    L = I - Dhalf*A*Dhalf
    # Lam, E = eigs(L; nev = 3, which=:SM)

    sc = size(L,1)
    Vl,Vc,convinfo = eigsolve(L + sc*LinearAlgebra.I, 3, :SR; tol = 1e-8, maxiter = 1000, verbosity = 0)
    lam2 = Real(Vl[2])-sc
    E = [Vc[2] Vc[3]] 

    return E
end