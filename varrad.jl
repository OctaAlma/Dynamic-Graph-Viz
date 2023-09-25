using Plots

function drawGraph(xy, edges)

    plotObject = plot()

    #plot the edges
    for j = 1:length(edges)
        u = edges[j][1]
        v = edges[j][2]
        plot!(plotObject,[xy[u,1]; xy[v,1]], [xy[u,2]; xy[v,2]],color = :black, linewidth = 1)   
    end

    #make the graph look pretty
    plot!(plotObject,xlim = [-r-1,r+1], ylim = [-r-1,r+1])
    plot!(plotObject, aspect_ratio=:equal)
    plot!(plotObject, grid = false,legend = false)
    plot!(plotObject, axis = false, xticks = false, yticks = false) 

    ## Now plot the nodes
    nodesize = 12
    txtsize = 12
    plot_font = "computer modern"
    scatter!(plotObject, xy[:,1], xy[:,2],markersize = nodesize, color = "white")
    for j = 1:size(xy,1)
        annotate!(plotObject,xy[j,1], xy[j,2],text("$j",plot_font, txtsize))
    end

    display(typeof(plotObject))

    return plotObject
end
