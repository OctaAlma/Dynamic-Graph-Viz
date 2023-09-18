using LinearAlgebra, Plots, MAT, SparseArrays
include("graph_visualizations.jl")
M = matread("Karate.mat")
print(M)
A = M["A"]
xy = M["xy"]

## Plot the graph
s = 34
t = 1
f = display_graph(A,xy)
annotate!(f,xy[s,1],xy[s,2]-2,"President",:red)
annotate!(f,xy[t,1]+1,xy[t,2]-2,"Instructor",:blue)