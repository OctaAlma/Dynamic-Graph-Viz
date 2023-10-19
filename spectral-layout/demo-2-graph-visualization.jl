using LinearAlgebra, Plots, MAT
include("graph_visualizations.jl")
include("read_write_build_graphs.jl")

## Load the karate graph with its visualization
filename = "../Karate.mat"
M = matread(filename)
A = M["A"]

xy_default = M["xy"]
f = display_graph(A,xy_default)

## Use igraph_layout
xy = igraph_layout(A)
f = display_graph(A,xy)

## In some cases, we can use eigenvectors to plot a graph
A = cycle_graph(10)
xy = spectral_layout(A)
f = display_graph(A,xy)
