using JLD2
include("./matLoader.jl")
include("./txtLoader.jl")
include("./mtxLoader.jl")
include("./vacLoader.jl")
include("../structFiles/GraphState.jl")
include("../GraphPlots.jl")

function genericAnimSave(states::Vector{GraphState}, filename::String)
    extension = lowercase(String(split(filename, ".")[end]))
 
    if (extension == "txt")
        saveAnimationXY1(states, filename)
    elseif extension == "vaca"
        saveAnimToVaca(states, filename)
    elseif extension == "jdl" 
        try
            save_object(filename, states)
        catch
            printstyled("Could not save animation to the file ", filename, ".\n", color = :red) 
        end
    end
end


function genericAnimLoad(filename::String)
    extension = lowercase(String(split(filename, ".")[end]))
    states = nothing
    
    if extension == "vaca"
        states = loadAnimFromVaca(filename)
    elseif extension == "jdl" 
        try
            states = load_object(filename)            
        catch
            printstyled("An error occurred when attempting to reading in ", filename, ".\n", color = :red)
        end
    end

    if (isnothing(states))
        printstyled(filename, " could not be loaded.\n", color = :red)
        println("Creating empty animation...")
        states = []
        push!(states, GraphState())
    end

    return states
end

function genericStateSave(states::Vector{GraphState}, stateInd::Int64, filename::String; showTicks = true, showLabels = true)
    # Check the extension of filename
    extension = lowercase(String(split(filename, ".")[end]))

    if (extension == "png" || extension == "pdf")
        savefig(makePlot(states[stateInd].g, showTicks, showLabels), filename)
    elseif (extension == "vac")
        outputGraphToVac(states[stateInd].g, filename)
    elseif (extension == "mtx" || extension == "txt")
        outputGraphToMtx(states[stateInd].g, filename)
    else
        printstyled("Graph could not be saved with extension ", extension, color=:red)
    end
end

function genericStateLoad(states::Vector{GraphState}, stateInd::Int64, filename::String)
    # Check the extension of filename
    extension = lowercase(String(split(filename, ".")[end]))

    loaded = nothing
    
    if (extension == "vac")
        loaded = vacRead(filename)
    elseif (extension == "mtx") || (extension == "txt")
        loaded = states[stateInd].g = mtxRead(filename)
    elseif (extension == "mat")
        loaded = states[stateInd].g = MATRead(filename)
    end

    if (!isnothing(loaded))
        states[stateInd].g = loaded
    else
        println("Could not load file ", filename)
    end
end

function saveStatesToPNGs(states::Vector{GraphState}, foldername::String, 
    start::Int64, finish::Int64, showTicks::Bool, showLabels::Bool)
    currDir = pwd()

    try
        mkdir(foldername)
        cd(foldername)
        println("Successfully created folder: ", foldername)
        println("Saving files...")
    catch e
        cd(foldername)
        println("Saving files to existing folder: ", foldername)
    end

    for i in start:finish
        filename = "$i.png"
        savefig(makePlot(states[i].g, showTicks, showLabels), filename)
    end

    cd(currDir)
    println("Done\n\n")
end

function saveStatesToPDFs(states::Vector{GraphState}, foldername::String, 
    start::Int64, finish::Int64, showTicks::Bool, showLabels::Bool
    ; txtsize = 12, plot_font = "computer modern")
    currDir = pwd()

    try
        mkdir(foldername)
        cd(foldername)
        println("Successfully created folder: ", foldername)
        println("Saving files...")
    catch e
        cd(foldername)
        println("Saving files to existing folder: ", foldername)
    end

    for i in start:finish
        filename = "$i.pdf"
        savefig(makePlot(states[i].g, showTicks, showLabels, txtsize = txtsize), filename)
    end

    cd(currDir)
    println("Done\n\n")
end