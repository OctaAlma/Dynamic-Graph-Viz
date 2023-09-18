function createDegreeDependantCoods(n, r, degree)
    
    xy = zeros(n,2)
    # Updates xy to be degree-dependant
    for j in 1:n
        angle = (2π / n) * j;
        x = round(cos(angle); digits = 5)
        y = round(sin(angle); digits = 5)
        xy[j,:] = [(x * r /(degree[j] * 0.5)) (y * r /(degree[j] * 0.5))]
    end

    return xy
end

function createCircularCoords(n, r)
    xy = zeros(n,2)
    
    # Places nodes in a circle:
    for j in 1:n
        angle = (2π / n) * j;
        x = round(cos(angle); digits = 5)
        y = round(sin(angle); digits = 5)
        xy[j,:] = [(x * r) (y * r)]
    end

    return xy
end

function randomEdges(n, k, degree)
    edges = Vector{Vector{Int64}}()

    # # Creates random edges
    # for j in 1:(n * k)
    #     push!(edges, [rand(range(start=1, stop=n, step=1));rand(range(start=1, stop=n, step=1))])
    # end

    # Creates random edges and updates the degree array
    for j in 1:(n * k)
        u = rand(range(start=1, stop=n, step=1))
        v = rand(range(start=1, stop=n, step=1))
        
        degree[u] = degree[u] + 1
        degree[v] = degree[v] + 1
        
        push!(edges, [u;v])
    end

    return edges
end

function circleEdges(n, xy)
    edges = Vector{Vector{Int64}}()

    #makes edges for all nodes around 
    for j in 1:(n-1)
        push!(edges,[j;((j+1))])
    end
    push!(edges, [1;n])    

    # Places nodes in a circle:
    for j in 1:n
        angle = (2π / n) * j;
        x = round(cos(angle); digits = 5)
        y = round(sin(angle); digits = 5)
        xy[j,:] = [(x * r) (y * r )]
    end

    return edges
end

function completeEdges(n, degree)
    edges = Vector{Vector{Int64}}()

    # The following will create a complete graph:
    for j in 1:n
        for i in 1:n
            push!(edges, [j;i])
        end
        degree[j] = n
    end

    return edges
end
