include("./Graph.jl")

mutable struct GraphState
    g::Graph
    desc::String
    meta::Any
end

GraphState(;g = Graph(), desc = "", meta = []) = GraphState(g, desc, meta)

function preview(states::Vector{GraphState}; 
    start::Int64 = 1, finish::Int64 = length(states), interval::Float64 = 1.0,
    showTicks::Bool = true, showLabels = true, plot_font = "computer modern", txtsize = 12)
    
    for i in start:finish
        display(makePlot(states[i].g, showTicks, showLabels, plot_font = plot_font, txtsize = txtsize))
        
        if (states[i].desc != "")
            println(states[i].desc)
        end
        
        sleep(interval)
    end

    printstyled("Preview complete\n", color = :green)
end

function saveGIF(states::Vector{GraphState}, filename::String; 
    start::Int64 = 1, finish::Int64 = length(states), interval::Float64 = 0.5,
    DPI = 150, showTicks::Bool = true, showLabels = true, plot_font = "computer modern", txtsize = 12)

    anim = Animation()

    for i in start:finish
        s = states[i]
        p = makePlot(s.g, showTicks, showLabels, plot_font = plot_font, txtsize = txtsize, DPI=DPI)
        
        frame(anim, p)
    end

    gif(anim, filename, fps=(1.0 / interval))
end