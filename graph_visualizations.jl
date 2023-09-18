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

