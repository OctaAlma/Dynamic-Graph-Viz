include("./structFiles/GraphState.jl")
include("./GraphPlots.jl")

#=
    - preview - Allows the user to view the states in the order that they appear in the visualization
    - copy i j - Creates a copy of state at index i and inserts it at the index j.
    - duplicate i Opt: n - Creates a duplicate of state i and places it in the index i + 1. If the option n is passed, it will create n duplicates of i and place them in the indices i + 1 … i + n.
    - swap i j - The state at index i is replaced with the state at index j and vice-versa.
    - move i j - Removes state i from its current position and inserts it at state j.
    - delete i - Deletes a specific state from the visualization
=#

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
    
    printstyled("Visualization Creator\n", color = :blue)

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
            

            if command == "help"
            
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
                        if (curr > start && curr < numStates)
                            finish = curr
                            i += 1
                        else
                            println("Invalid input: -finish ", curr)
                        end

                    elseif arg == "-t" || arg == "-interval"

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
                
                i = parse(Int64, commands[2])
                if (inRange(i, 1, numStates))
                    deleteat!(animation, i)
                end

                if (currStateInd > i)
                    currStateInd -= 1
                    currState = animation[currStateInd]
                end
            
            elseif command == "copy" || command == "cp"

            
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

            
            elseif command == "move" || command == "mv"
                # - move i j - Removes state i from its current position and inserts it at state j.
                i = parse(Int64, commands[2])
                j = parse(Int64, commands[3])

                if (inRange(i, 1, numStates + 1) && inRange(j, 1, numStates + 1))
                    insert!(animation, j, animation[i + 1])
                    deleteat!(animation, i)
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

            elseif (graphEditParser(currState.g, commands, 1) < 2)
                continue
            elseif command == "exit" || command == "q" || command == "quit"
                break
            end 
        catch e
            printstyled("Something went wrong. ", color = :red)
            print("Try using the")
            printstyled(" help ", color = :green)
            println("command.")
            rethrow(e)
        end
    end
    return 0
end

