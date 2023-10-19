using SparseArrays

"""
Given an adjacency matrix, add an edge (i,j) with weight v.
If there alreay was an edge, this will overwrite it.

This assumes the graph is undirected, so the matrix should
be symmetric.

The exclamation point symbol in julia function is the convention for indicating
    that this changes the array that it passed in.

The "= 1.0" indicates that the default value for v is 1.0.
"""
function change_edge!(A,i,j,v = 1.0)
    A[i,j] = v
    A[j,i] = v
end


"""
Read in a matrix A in in matrix market format:

First line is M, N, L (rows, columns, and number of nonzeros)
Subsequent lines are of the format
    i, j, v (row index, column index, v = value of A(i,j))
"""
function read_mm_matrix(filename)

    f = readlines(filename)  # reads in the file, f[i] will be line if

    ind = 1
    searching_for_start = true

    # iterate past the comments parts
    while searching_for_start
        if f[ind][1] == '%'
            ind += 1
        else
            searching_for_start = false
        end
    end
    @show ind
    mnl = f[ind]              # this gives the first line that isn't a comment
    mnl = split(mnl)          # splits based on spaces so each number is an entry
    mnl = parse.(Int64,mnl)   # parses the strings into integers. The . notation means "do this to each entry"

    # allocate space for storing (i,j,v) information
    I = zeros(Int64,mnl[3])
    J = zeros(Int64,mnl[3])
    V = zeros(Int64,mnl[3])
    for k = ind+1:length(f)
        entry = parse.(Int64,split(f[k]))
        I[k-ind] = entry[1]
        J[k-ind] = entry[2]
        if length(entry) == 3
            V[k-ind] = entry[3]
        else
            V[k-ind] = 1.0
        end
    end


    # check that number of rows equals number of columns.
    # We want this because we are assuming this is an adjacency matrix for a graph
    @assert(mnl[1] == mnl[2])
    n = mnl[1] # number of nodes
    A = sparse(I,J,V,n,n)
    A = A+A'
    return A
end

function cycle_graph(n)
    A = sparse(collect(1:n),[collect(2:n);1],ones(n),n,n)
    return max.(A,A')
end
