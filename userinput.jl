include("./loaders/Loaders.jl")
include("./GraphPlots.jl")
include("./printCommands.jl")
include("./visualization.jl")

# NOTE: These are just sample values used for the DEMO

filename::String = ""

resourceDir = ""
global debug = false 
global showTicks = true
global showLabels = true
global commandsHistory = []
global sessionCommands = []
global commandQueue = []
global graphStack = []
global lastInputValid = false
global sleepInterval = 0
global maxGraphStackSize = 10
global G = Graph()

global emptyGraph = Graph()
empty!(emptyGraph.nodes)
empty!(emptyGraph.edges)
global emptyGraphStack = [emptyGraph]

empty!(G.edges)
empty!(G.nodes)
push!(graphStack, G)

if ("debug" in ARGS || "-d" in ARGS )
    global resourceDir = "./resources/"
    global debug = true
    println("Debug mode ON")
end

if ("load" in ARGS || "-l" in ARGS )
    println("Load not yet implemented")
end

if ("tiggle-grod" in ARGS)
    println("Tiggle Grod")
    #do something
end

function outputGraphToVacs(filepath::String)
    try
        open(filepath, "w") do file
            println("Saving command history to ", filepath, "...")
            for command in sessionCommands
                if !occursin("save",command) && !occursin("saveas",command) 
                    writeMe = "$command\n"
                    write(file, writeMe)
                end
            end
        end
    catch e
        println(filepath, " could not be created.")
    end
end

function scriptloader(filepath::String)
    try
        open(filepath) do file
            for currLine in readlines(file)
                push!(commandQueue,String(currLine))
            end
        end
    catch e
        println(filepath, " could not be loaded.")
    end
end

function genericLoad(filename::String)
    # Check the extension of filename
    extension = String(split(filename, ".")[end])

    # if on debug mode, should append ./resources/ to the filename
    filename = resourceDir * filename
    
    if (extension == "vac")
        global G = vacRead(filename)
    elseif (extension == "vacs")
        scriptloader(filename)
    elseif (extension == "mtx") || (extension == "txt")
        global G = mtxRead(filename)
    elseif (extension == "mat")
        global G = MATRead(filename)
    end

    if (isnothing(G))
        println("Load Failed, Constructing empty Graph...")
        global G = Graph()
        empty!(G.nodes)
        empty!(G.edges)
    end

    setGraphLimits(G)
    displayGraph(G)

end

function genericSave(filename::String)
    # Check the extension of filename
    extension = String(split(filename, ".")[end])
    
    filename = resourceDir * filename

    if (extension == "png" || extension == "pdf")
        savefig(makePlot(G, showTicks, showLabels), commands[2])
    elseif (extension == "vac")
        outputGraphToVac(G, filename)
    elseif (extension == "mtx" || extension == "txt")
        outputGraphToMtx(G, filename)
    elseif (extension == "vacs")
        outputGraphToVacs(filename)
    else
        printstyled("Graph could not be saved with extension ", extension, color=:red)
    end
end

function printHelp(category="")
    # There are 4 categories: load/save Graph, edit Graph, edit Coords, display
    category = lowercase(category)
    print(category)
    if category == ""
        printAll()
    end
end

global executingScript = false
while true
    global executingScript
    global lastInputValid
    global sleepInterval
    
    executingScript = false
    if !isempty(commandQueue)
        executingScript = true
    end

    if !executingScript
        printstyled("\nEnter a command: ", color = :yellow)
    else
        sleep(sleepInterval)
    end

    if (isnothing(G)) # G can sometimes become nothing if any a function returns nothing
        global G = Graph()
        empty!(G.nodes)
        empty!(G.edges)
    end
    
    try
        global lastInputValid = true        

        global input = if executingScript popfirst!(commandQueue) else readline() end
        
        global commands = split(input, " ")
    
        #TODO remove *any number of consecutive whitespace
        if commands[1] == ""
            if !isempty(commandsHistory)
                push!(commandsHistory,last(commandsHistory))
                push!(sessionCommands,last(commandsHistory))
                commands = split(last(commandsHistory), " ")
            else
                println("No Commands in History")
            end
        elseif !executingScript
            push!(commandsHistory,input)
            push!(sessionCommands,input)
        end
        
        commands[1] = lowercase(commands[1])

        majorCommand = 1
        if commands[1] == "help"
            if length(commands) < 2
                printHelp()
                continue
            else
                majorCommand = 2
            end
        end
        
        if (commands[majorCommand] == "undo" || commands[majorCommand] == "z")
            if majorCommand == 2
                printUndoCommand()
                continue
            end
            
            if (!isempty(graphStack))
                if (graphStack == emptyGraphStack)
                    global G = deepcopy(emptyGraph)
                else
                    global G = pop!(graphStack)
                end
            else
                println("Undo history is empty. ")
            end

            displayGraph(G)
            continue
            
        elseif (!isempty(graphStack) && G != graphStack[end])
            while (length(graphStack) >= maxGraphStackSize)
                popfirst!(graphStack)
            end
            push!(graphStack, deepcopy(G))
        end

        if commands[majorCommand] == "saveas" || commands[majorCommand] == "save"
            if majorCommand == 2
                printSaveCommands()
                continue
            end
            genericSave(String(commands[2]))
            displayGraph(G)
            
        elseif occursin("quit",commands[majorCommand]) ||  occursin("exit",commands[majorCommand]) || commands[majorCommand] == "q"
            if majorCommand == 2
                printexitCommand()
                continue
            end
            exit()
        
        elseif commands[majorCommand] == "load"
            if majorCommand == 2
                printLoadCommands()
                continue
            end
            global filename = commands[2]
            if length(commands) > 2
                global sleepInterval = parse(Float64, commands[3])
            end
            genericLoad(filename)
            

            if (isnothing(G))
                global G = Graph()
                empty!(G.nodes)
                empty!(G.edges)
            end

            displayGraph(G)
        
        elseif commands[majorCommand] == "loadxy"
            if majorCommand == 2
                printLoadxy()
                continue
            end
            # File containing the new XY values
            filenamexy = resourceDir * String(commands[2])
            txtReadXY(G, filenamexy)
            
            displayGraph(G)
        
        elseif commands[majorCommand] == "savexy"
            if majorCommand == 2
                printSavexy()
                continue
            end
            filename = resourceDir * String(commands[2])
            outputXY(G, filename)

        elseif commands[majorCommand] == "toggle"
            if majorCommand == 2
                printToggleCommands()
                continue
            end

            if (lowercase(commands[2]) == "grid")
                global showTicks = !showTicks
            
            elseif (lowercase(commands[2]) == "labels")
                global showLabels = !showLabels

            elseif (lowercase(commands[2]) == "weights")
                G.weighted = !G.weighted

            elseif (commands[2] == "debug")
                if (debug == false)
                    global resourceDir = "./resources/"
                    global debug = true
                    println("Debug mode ON")
                else
                    global resourceDir = ""
                    global debug = false
                    println("Debug mode OFF")
                end
            end
            
            displayGraph(G)

        elseif commands[majorCommand] == "sleep"
            if majorCommand == 2
                printSleepCommand()
                continue
            end
            sleep(parse(Float64,commands[majorCommand+1]))
        
        elseif commands[majorCommand] == "clear"
            if majorCommand == 2
                printClearHelp()
                continue
            end
            run(Cmd(`clear`, dir="./"))
            
        elseif commands[majorCommand] == "repl"
            if majorCommand == 2
                # printviewCommands()
                continue
            end
            run(Cmd(`julia`, dir="./"))
        elseif commands[majorCommand] == "instance"
            if majorCommand == 2
                printviewCommands()
                continue
            end
            run(Cmd(`julia userinput.jl`, dir="./"))
        
        # easter egg:
        elseif commands[majorCommand] == "tiggle"
            if commands[majorCommand + 1] == "grod"                
                run(Cmd(`julia userinput.jl tiggle-grod`, dir="./"))
            end
        
        elseif (graphEditParser(G, commands, majorCommand) < 2)
            print("")

        elseif commands[majorCommand] == "viz"
            vizInterface(G, showTicks, showLabels, "computer modern", 12)

        elseif majorCommand == 2
            printHelp(String(commands[2]))
    
        else
            notFound = commands[1]
            println("Command $notFound was not found. Enter \"help\" to view valid commands")
            lastInputValid = false
        end
    catch e
        if debug
            rethrow(e)
        end
        
        printstyled("Something went wrong. ", color = :red)
        print("Try using the ")
        printstyled("help", color = :green)
        print(" command.")

        lastInputValid = false
    end
    
    if (!lastInputValid && !isempty(commandsHistory)) 
        pop!(commandsHistory)
    end    
end