using Plots

# idea 1: place the nodes in a circle
function displayCircle(n, edges)
    r = n * 0.5    # The radius of the circle

    xy = zeros(n,2)

    plotObject = plot()

    for j in 1:n
        angle = (2π / n) * j;
        x = round(cos(angle); digits = 5)
        y = round(sin(angle); digits = 5)
        xy[j,:] = [(x * r) (y * r)]
    end

    #plotting edges
    for j = 1:length(edges)
        u = edges[j][1]
        v = edges[j][2]
        plot!(plotObject,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :black, linewidth = 1)   
    end

    plot!(plotObject,xlim = [-r-1,r+1], ylim = [-r-1,r+1])
    plot!(plotObject, aspect_ratio=:equal)
    plot!(plotObject, grid = true,legend = false)
    plot!(plotObject, axis = false, xticks = false, yticks = false) 

    ## Now plot the nodes
    nodesize = 12
    txtsize = 12
    plot_font = "computer modern"
    scatter!(plotObject,xy[:,1], xy[:,2],markersize = nodesize, color = :white)

    for j = 1:size(xy,1)
        annotate!(plotObject,xy[j,1], xy[j,2],text("$j",plot_font, txtsize))
    end

    return plotObject
end