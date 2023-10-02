using LinearAlgebra, Plots, MAT, SparseArrays
include("graph_visualizations.jl")
M = matread("ash85.mat")
print(M)
print(M["Problem"]["A"])
A = M["Problem"]["A"]
xy = M["Problem"]["xy"]


## Plot the graph
s = 34
t = 1
f = display_graph(A,xy)
annotate!(f,xy[s,1],xy[s,2]-2,"President",:red)
annotate!(f,xy[t,1]+1,xy[t,2]-2,"Instructor",:blue) 
f