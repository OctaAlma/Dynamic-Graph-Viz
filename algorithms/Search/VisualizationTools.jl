include("../../structFiles/GraphState.jl")
gr()

function printDataStructure(gs::GraphState, dsName::String, dsPrev)
    if (isnothing(dsPrev) || dsPrev != gs.dataStructure)
        print("Updated ", dsName, " contents: ")
        numElements = length(gs.dataStructure)
        for i in 1:numElements
            if (i == numElements)
                println(gs.dataStructure[i])
                break
            end

            print(gs.dataStructure[i], ", ")
        end
    end
end

function iterateThroughGraphState(graphStates::Vector{GraphState}, dsName::String, makegif = false ;Δt::Float64 = 0.5, filename = "output.gif", FPS=10, DPI=250)
    step = 1
    dsPrev = nothing

    anim = Animation()

    for gs in graphStates
        p = makeVizPlot(gs, DPI=DPI)
        
        if (makegif == true)
            frame(anim, p)
        else
            display(p)
            step = step + 1
        
            println("Step ", step, ": ", gs.description)
            printDataStructure(gs, dsName, dsPrev)
            
            sleep(Δt)
            print("\n\n")
            dsPrev = collect(Int64, gs.dataStructure)
        end
    end

    if (makegif)
        gif(anim, filename, fps=FPS)
    end
end

function setNodeAppearance(g::Graph, nodeInd::Int64; size = -1, oc::String = "", fc::String = "", lc::String = "")
    if (nodeInd < 1 || nodeInd > length(g.nodes))
        println("Invalid node index: ", nodeInd)
        return
    end
    
    if (size != -1)
        g.nodes[nodeInd].size = size
    end
    
    if (oc != "")
        g.nodes[nodeInd].outlineColor = oc
    end
    
    if (fc != "")
        g.nodes[nodeInd].fillColor = fc
    end
    
    if (lc != "")
        g.nodes[nodeInd].labelColor = lc
    end
end

function setNodeAppearance(g::Graph, nodeLabel::String; size = -1, oc::String = "", fc::String = "", lc::String = "")
    nodeInd = findNodeIndexFromLabel(g, nodeLabel)
    setNodeAppearance(g, nodeInd, size = size, oc = oc, fc = fc, lc = lc)
end

function setEdgeAppearance(g::Graph, edgeInd::Int64; color::String = "", thickness::Float64 = -1.0)
    if (edgeInd == -1 || edgeInd > length(g.edges))
        println("Could not find an edge with source index ", sourceInd, " and destination index ", destInd)
        return
    end

    if (color != "")
        g.edges[edgeInd].color = color
    end

    if (thickness != -1.0)
        g.edges[edgeInd].lineWidth = thickness
    end
end

function setEdgeAppearance(g::Graph, sourceInd::Int64, destInd::Int64; color::String = "", thickness::Float64 = -1.0)
    edgeInd = findEdgeIndex(g, sourceInd, destInd)
    if (edgeInd == -1)
        println("Could not find an edge with source index ", sourceInd, " and destination index ", destInd)
        return
    end

    setEdgeAppearance(g, edgeInd, color=color, thickness=thickness)
end

function setEdgeAppearance(g::Graph, sourceLabel::String, destLabel::String; color::String, thickness::Float64 = -1.0)
    edgeInd = findEdgeIndex(g, sourceLabel, destLabel)

    if (edgeInd == -1)
        println("Could not find an edge with source label ", sourceLabel, " and destination label ", destLabel)
        return
    end

    setEdgeAppearance(g, edgeInd, color=color, thickness=thickness)
end