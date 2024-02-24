include("./structFiles/GraphState.jl")
include("./GraphPlots.jl")
include("./loaders/Loaders.jl")

function inRange(i, min, max)::Bool
    return (i >= min) && (i <= max)
end

function printQuery(currStateInd::Int64, numStates::Int64) 
    printstyled("\nState ", color = :green)
    printstyled(currStateInd, color = :green)
    printstyled("/", color = :green)
    printstyled(numStates, color = :green)
    print(" > ")
    printstyled("Enter a command: ", color = :blue)
end

function vizInterface(G::Graph, showTicks::Bool, showLabels::Bool, font::String, fontSize::Int)
    animation::Vector{GraphState} = []
    
    printstyled("\n-----VISUALIZATION EDITOR-----\n", color = :cyan)

    push!(animation, GraphState(deepcopy(G), "", []))
    currState = animation[1]
    currStateInd = 1

    while (true)
        try
            # read input from stdin and lowercase everything 
            numStates = length(animation)
            display(makePlot(currState.g, showTicks, showLabels, plot_font = font, txtsize = fontSize))
            printQuery(currStateInd, numStates)
            input = readline()
            commands = split(input, " ")
            command = lowercase(commands[1])
            numCommands = length(commands)

            if command == "help" # IMPLEMENT ME
            
            elseif command == "statesave" || command == "ssave"
                # Format: savestate i FILENAME.txt/vac/mtx
                stateToSave = currStateInd

                if (length(commands) == 3)
                    try
                        stateToSave = parse(Int64, commands[2])
                        if (!inRange(stateToSave, 1, numStates))
                            println("Not a valid state index: ", stateToSave)
                            continue
                        else
                            genericStateSave(animation, stateToSave, String(commands[3]))
                        end
                    catch
                        println("Usage: statesave STATE_IND FILENAME")
                        continue
                    end
                elseif (length(commands) == 2)
                    genericStateSave(animation, stateToSave, String(commands[2]), showTicks = showTicks, showLabels = showLabels)
                else
                    println("Usage: statesave STATE_IND FILENAME")
                end

            elseif command == "stateload" || command == "sload"
                # Format: loadstate i FILENAME.txt/vac/mtx/mat

                stateToLoad = currStateInd

                if (length(commands) == 3)
                    try
                        stateToLoad = parse(Int64, commands[2])
                        if (!inRange(stateToLoad, 1, numStates))
                            println("Not a valid state index: ", stateToLoad)
                            continue
                        else
                            genericStateLoad(animation, stateToLoad, String(commands[3]))
                        end
                    catch
                        println("Usage: stateload STATE_IND FILENAME")
                    end
                elseif (length(commands) == 2)
                    genericStateLoad(animation, stateToLoad, String(commands[2]))
                else
                    println("Usage: stateload STATE_IND FILENAME")
                end

            elseif command == "stateloadxy"
                # Format: loadstate i FILENAME
                stateToLoad = currStateInd

                if (length(commands) == 3)
                    try
                        stateToLoad = parse(Int64, commands[2])
                        if (!inRange(stateToLoad, 1, numStates))
                            println("Not a valid state index: ", stateToLoad)
                            continue
                        else
                            txtReadXY(animation[stateToLoad], String(commands[3]))
                        end
                    catch
                        println("Usage: stateloadxy STATE_IND FILENAME")
                    end
                elseif (length(commands) == 2)
                    txtReadXY(animation[stateToLoad], String(commands[2]))
                else
                    println("Usage: stateloadxy STATE_IND FILENAME")
                end
            
            elseif command == "toggle"

                if (length(commands) < 2)
                    println("Please specify what to toggle")
                    continue
                end

                toggleMe = lowercase(commands[2])
                
                if toggleMe == "grid" || toggleMe == "ticks"
                    showTicks = !showTicks

                elseif toggleMe == "label" || toggleMe == "labels"
                    showLabels = !showLabels
                end
            
            elseif command == "statesavexy"
                # Format: savestate i FILENAME.txt/vac/mtx
                stateToSave = currStateInd

                if (length(commands) == 3)
                    try
                        stateToSave = parse(Int64, commands[2])
                        if (!inRange(stateToSave, 1, numStates))
                            println("Not a valid state index: ", stateToSave)
                            continue
                        else
                            outputXY(animation[stateToSave].g, String(commands[3]))
                        end
                    catch
                        println("Usage: statesavexy STATE_IND FILENAME")
                        continue
                    end
                elseif (length(commands) == 2)
                    outputXY(animation[stateToSave].g, String(commands[2]))
                else
                    println("Usage: statesavexy STATE_IND FILENAME")
                end

            elseif command == "saveas" # IMPLEMENT ME
                filename = String(commands[2])
                
                if (filename == "png" || filename == "pngs" || filename == "pdf" || filename == "pdfs")
                    start = 1
                    finish = numStates
                    try
                        foldername = String(commands[3])

                        for i in 3:numCommands
                            arg = String(lowercase(commands[i]))

                            if arg == "-s" || arg == "-start"
                                curr = parse(Int64, commands[i + 1])
                                if (inRange(curr, 1, numStates))
                                    start = curr
                                    i += 1
                                else
                                    println("Invalid input: -s ", curr)
                                end
                            elseif arg == "-f" || arg == "-finish"
                                curr = parse(Int64, commands[i + 1])
                                
                                if (inRange(curr, 1, numStates))
                                    finish = curr
                                    i += 1
                                else
                                    println("Invalid input: -f ", curr)
                                end
                            end
                        end

                        if (filename == "png" || filename == "pngs")
                            saveStatesToPNGs(animation, foldername, start, finish, showTicks, showLabels)
                        else
                            saveStatesToPDFs(animation, foldername, start, finish, showTicks, showLabels)
                        end

                    catch e
                        printstyled("Error in saving states to pngs\n", color=:red)
                        printstyled("Usage: ", color=:green)
                        println("saveas pngs FOLDER_NAME Opt: -s START_STATE -f FINISH_STATE")
                        rethrow(e)
                    end

                    continue
                end

                extension = lowercase(String(split(filename, ".")[end]))
                if (extension == "gif") 
                    # We do GIF here because we have all the graph information
                    start = 1
                    finish = numStates
                    interval = 0.5    
                    dpi = 150
                    
                    for i in 3:length(commands)
                        arg = lowercase(commands[i])
                        if arg == "-s" || arg == "-start"
                            
                            curr = parse(Int64, commands[i + 1])
                            if (curr < finish && curr > 0)
                                start = curr
                                i += 1
                            else
                                println("Invalid input: -start ", curr)
                            end

                        elseif arg == "-f" || arg == "-finish"
                            
                            curr = parse(Int64, commands[i + 1])
                            if (curr > start && curr <= numStates)
                                finish = curr
                                i += 1
                            else
                                println("Invalid input: -finish ", curr)
                            end

                        elseif arg == "-t" || arg == "-interval" || arg == "-i"

                            curr = parse(Float64, commands[i + 1])
                            if (curr > 0)
                                interval = curr
                                i += 1
                            else
                                println("Invalid input: -interval ", curr)
                            end
                        elseif  arg == "-dpi"
                            curr = parse(Int64, commands[i + 1])
                            if (curr > 0)
                                dpi = curr
                                i += 1
                            else
                                println("Invalid input: -dpi ", curr)
                            end
                        end
                    end
                    
                    saveGIF(animation, filename, start=start, finish=finish, interval=interval,
                            DPI=dpi, showTicks=showTicks, showLabels=showLabels)
                else
                    genericAnimSave(animation, filename)
                end

            elseif command == "load" # IMPLEMENT ME
                filename = String(commands[2])
                animation = genericAnimLoad(filename)
                currStateInd = 1
                currState = animation[currStateInd]
            
            elseif command == "desc" # IMPLEMENT ME
                animation[currStateInd].desc = String(SubString(input, 6, length(input)))

            elseif command == "pr" || command == "prev"
                if (currStateInd > 1)
                    currStateInd -= 1
                    currState = animation[currStateInd]
                else
                    printstyled("There is no previous state to go to.\n", color = :red)
                end
            
            elseif command == "nx" || command == "next"
                if (currStateInd < numStates)
                    currStateInd += 1
                    currState = animation[currStateInd]
                else
                    printstyled("There is no next state to go to.\n", color = :red)
                end

            elseif command == "focus"
                # focus i - makes it so any edits from now on go to state i
                # You could potentially make it so that they can enter a range???
                # e.g: focus i-m 
                # e.g: focus i j k l m

                i = parse(Int64, commands[2])
                if (!inRange(i, 1, numStates))
                    println("Invalid index for focus: ", i, ". Please enter an integer in range [1, ", numStates, "]")
                else
                    currState = animation[i]
                    currStateInd = i
                end

            elseif command == "preview"
                # preview -start x -finish y -time t
                # Start from state x and stop at state y (default is 1 to n)
                # Go to the next state after t seconds (default could be 0.5s)
                start = 1
                finish = numStates
                interval = 0.5

                for i in 1:numCommands
                    arg = lowercase(commands[i])
                    if arg == "-s" || arg == "-start"
                        
                        curr = parse(Int64, commands[i + 1])
                        if (curr < finish && curr > 0)
                            start = curr
                            i += 1
                        else
                            println("Invalid input: -start ", curr)
                        end

                    elseif arg == "-f" || arg == "-finish"
                        
                        curr = parse(Int64, commands[i + 1])
                        if (curr > start && curr <= numStates)
                            finish = curr
                            i += 1
                        else
                            println("Invalid input: -finish ", curr)
                        end

                    elseif arg == "-i" || arg == "-t" || arg == "-interval"

                        curr = parse(Float64, commands[i + 1])
                        if (curr > 0)
                            interval = curr
                            i += 1
                        else
                            println("Invalid input: -interval ", curr)
                        end
                    end
                end

                preview(animation, start = start, finish = finish, interval = interval,
                showTicks = showTicks, showLabels = showLabels, plot_font = "computer modern", txtsize = 12)
                

            elseif command == "delete" || command == "del"
                
                if (numStates == 1)
                    println("You cannot delete your only state!")
                    continue
                end

                i = parse(Int64, commands[2])
                if (inRange(i, 1, numStates))
                    deleteat!(animation, i)
                end

                if (currStateInd >= i)
                    currStateInd -= 1
                    currState = animation[currStateInd]
                end
            
            elseif command == "copy" || command == "cp"

                # We can make it so that it saves a graph into a buffer
                # then we can "paste" it later on
            
            elseif command == "duplicate" || command == "dup"
                # duplicate i -dest j -n x
                copyInd = parse(Int64, commands[2])

                if (!inRange(copyInd, 1, numStates))
                    println("Index ", copyInd, " is out of bounds. There are currently ", numStates, " states in the animation.")
                    continue
                end
                
                numDups = 1
                dest = copyInd + 1
                validArgs = true

                for i in 1:numCommands
                    arg = lowercase(commands[i])
                    if arg == "-dest"
                        curr = parse(Int64, commands[i + 1])
                        if (!inRange(curr, 0, numStates + 1))
                            println("Invalid destination index: ", curr, ". For the current visualization, enter an integer in the range [0, ", numStates + 1, "]")
                            validArgs = false
                            break
                        else
                            dest = curr
                        end
                        i += 1
                    elseif arg == "-n"
                        curr = parse(Int64, commands[i + 1])
                        if (curr < 1)
                            println("Invalid number of copies: ", curr, ". Please enter an integer greater than 0.")
                            validArgs = false
                            break
                        else
                            numDups = curr
                        end
                        i += 1
                    end
                end

                if !validArgs
                    continue
                end
                
                # Create and insert the duplicates at the desired indeces

                for i in 1:numDups
                    insert!(animation, dest, deepcopy(animation[copyInd]))
                end
                
                if (currStateInd > dest)
                    currStateInd += (dest - copyInd)
                end

                println("Successfully created ", numDups, " duplicates of state ", copyInd, ".")

            
            elseif (command == "move" || command == "mv") && (length(commands) == 3) 
                # - move i j - Removes state i from its current position and inserts it at state j.
                i = parse(Int64, commands[2])
                j = parse(Int64, commands[3])

                if (inRange(i, 1, numStates) && inRange(j, 1, numStates))
                    
                    if (i > j)
                        insert!(animation, j, animation[i])
                        deleteat!(animation, i + 1)
                    else
                        insert!(animation, j + 1, animation[i])
                        deleteat!(animation, i)
                    end

                    currState = animation[currStateInd]

                    println("Graph state ", i, " has been successfully moved to index ", j)
                else
                    println("Invalid insertion indices: source ", i, ", dest: ", j)
                end

            elseif command == "swap"
                i = parse(Int64, commands[2])
                if (!inRange(i, 1, numStates))
                    println("Invalid index provided for swap: ", i, ". Please provide an index from [1, ", numStates, "]")
                    continue
                end

                j = parse(Int64, commands[3])
                if (!inRange(j, 1, numStates))
                    println("Invalid index provided for swap: ", j, ". Please provide an index from [1, ", numStates, "]")
                    continue
                end

                tmp = deepcopy(animation[i])
                animation[i] = animation[j]
                animation[j] = tmp

                currState = animation[currStateInd]
            
            elseif command == "sleep"

                sleep(parse(Float64,commands[majorCommand+1]))
            
            elseif command == "clear"

                run(Cmd(`clear`, dir="./")) 

            elseif (graphEditParser(currState.g, commands, 1) < 2)
                continue
            elseif command == "exit" || command == "q" || command == "quit"
                break
            else 
                printstyled("Command ", command, " was not found. ", color = :red)
                print("Enter ") 
                printstyled("\"help\"", color = :green) 
                print(" to view valid commands")
            end 
        catch e
            printstyled("Something went wrong. ", color = :red)
            print("Enter ")
            printstyled("\"help\"", color = :green)
            println(" to view the proper arguments for each command.\n")
            rethrow(e)
        end
    end
    return 0
end

