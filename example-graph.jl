using Plots 

## Nodes
n = 14  # number of nodes in the graph

# xy stores (x,y) coordinates for plotting the nodes.
# You can tweak these to get a good graph visualization
xy = zeros(n,2)
xy[1,:] = [-1 10]
xy[2,:] = [-2 8]
xy[3,:] = [0 6]
xy[4,:] = [1.0 8.5]
xy[5,:] = [-1.5 4]
xy[6,:] = [2 4]
xy[7,:] = [0 2]
xy[8,:] = [3.9 6]
xy[9,:] = [5.7 3.6]
xy[10,:] = [8 5]
xy[11,:] = [6.9 7]
xy[12,:] = [5 9]
xy[13,:] = [10 7]
xy[14,:] = [9 9]
#xy[15,:] = [5.8 4.5]

using Random
g = randperm(n)

# xy = xy[g,:]
# edges is a vector of edges, where each edge is a vector of size two.
# you could also store this information as an adjacency matrix
edges = Vector{Vector{Int64}}()
push!(edges,[1;2])  # this command just means "add edge [1;2] to the vector 'edges' "
push!(edges,[4;2])
push!(edges,[1;4])
push!(edges,[3;2])
push!(edges,[1;3])
push!(edges,[12;3])
push!(edges,[8;3])
push!(edges,[6;3])
push!(edges,[5;3])
push!(edges,[7;3])
push!(edges,[5;6])
push!(edges,[5;7])
push!(edges,[6;7])
push!(edges,[8;9])
push!(edges,[8;10])
push!(edges,[10;11])
push!(edges,[11;12])
push!(edges,[11;13])
push!(edges,[11;14])
push!(edges,[11;8])
push!(edges,[10;13])
push!(edges,[11;9])
push!(edges,[8;12])
push!(edges,[6;9])


## Here is how to plot the edges
f = plot()  
@show typeof(f)  # f is an object of type "Plot", which we will fill in with the graph visualization
i = true
# Plot the edges, one at a time. 
for j = 1:length(edges)

    global i 
    u = edges[j][1]
    v = edges[j][2]
    #println("$u $v")
    #println("$(xy[u,1])")
    #print([xy[u,1]; xy[v,1]])
    if i
        plot!(f,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :black, linewidth = 1)
    end
    
end
f

## These things just make the plot look nicer. 
# When building the graph and choosing (x,y) coordinates for the nodes,
# it can be helpful to leave the axes and grid up, but afterwards get rid of them with this code
plot!(f,xlim = [-3,14], ylim = [-3,14])
plot!(f, aspect_ratio=:equal)
plot!(f, grid = false,legend = false)
plot!(f, axis = false, xticks = false, yticks = false) 
f


## Now plot the nodes
nodesize = 12
txtsize = 12
plot_font = "computer modern"
scatter!(f,xy[:,1], xy[:,2],markersize = nodesize, color = :black)

for j = 1:size(xy,1)
    annotate!(f,xy[j,1], xy[j,2],text("$j",plot_font, txtsize))
end
f
 