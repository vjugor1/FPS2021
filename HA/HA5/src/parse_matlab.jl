using Pkg, DataFrames, CSV, DelimitedFiles

function get_single_space(input)
    """
    This function unifies spacing the in the input string (only a single space between words and symbols)
    Arguments:
        input (String): input line 
    Returns:
        String: inpute line with unified spaces
    """
    #preprocessing: replacing tabs with spaces
    line = replace(input, "\t" => " ")
    #preprocessing: replacing multiple spaces with single space
    line = replace(line, r" +" => " ")
    return line
end

function parse_ml(case_path)
    """
    This function reads MATPOWER case and writes Bus, Gen, Branch, GenCost DataFrames into csv files in folder "data/"
    Arguments:
        case_path (String): path to the MAPOWER case of interest
    """
    lines = readlines(case_path)
    
    #start saving flag
    flag_bus = false
    flag_gen = false
    flag_branch = false
    flag_gencost = false
    BusData = DataFrame()
    GenData = DataFrame()
    BranchData = DataFrame()
    GenCostData = DataFrame()
    for i in 1:length(lines)
        line = lines[i]
        line = get_single_space(line)
        if occursin("mpc.baseMVA", line)
            row_data = [v for v in split(line, "= ")[2:end]]
            row_data[end] = row_data[end][1:end-1] 
            println("Reading BaseMVA...")
            writedlm("data/" * "BaseMVA" * ".txt", row_data)
            
            #CSV.write("data/" * "BaseMVA" * ".csv", row_data)
        end
        if occursin("];", line)
            println("Reading finished...")
            flag_bus = false
            flag_branch = false
            flag_gen = false
            flag_gencost = false
        end

        if flag_bus
            row_data = [try parse(Float64, v) catch ArgumentError parse(Float64, v[1:end-1]) end for v in split(line, " ")[2:end]]
            push!(BusData, row_data)
        end
        if flag_gen
            row_data = [try parse(Float64, v) catch ArgumentError parse(Float64, v[1:end-1]) end for v in split(line, " ")[2:end]]
            push!(GenData, row_data)
        end
        if flag_branch
            row_data = [try parse(Float64, v) catch ArgumentError parse(Float64, v[1:end-1]) end for v in split(line, " ")[2:end]]
            push!(BranchData, row_data)
        end
        if flag_gencost
            row_data = [try parse(Float64, v) catch ArgumentError parse(Float64, v[1:end-1]) end for v in split(line, " ")[2:end]]
            push!(GenCostData, row_data)
        end

        if occursin("%% bus data", line)
            bus_cols = get_single_space(lines[i+1])
            for col in split(bus_cols, " ")[2:end]
                BusData[!, Symbol(col)] = []
            end
            println("Reading BusData...")
            println("Number of columns: ", length(names(BusData)))

        end
        if occursin("mpc.bus ", line)
            flag_bus = true
        end
        if occursin("%% generator data", line)
            gen_cols = get_single_space(lines[i+1])
            for col in split(gen_cols, " ")[2:end]
                GenData[!, Symbol(col)] = []
            end
            println("Reading GenData...")
            println("Number of columns: ", length(names(GenData)))

        end
        if occursin("mpc.gen ", line)
            flag_gen = true
        end
        if occursin("%% branch data", line)
            branch_cols = get_single_space(lines[i+1])
            for col in split(branch_cols, " ")[2:end]
                BranchData[!, Symbol(col)] = []
            end
            println("Reading BranchData...")
            println("Number of columns: ", length(names(BranchData)))

        end
        if occursin("mpc.branch ", line)
            flag_branch = true
        end
        if occursin("%% generator cost data", line)
            gencost_cols = get_single_space(lines[i+2])
            for col in split(gencost_cols, " ")[2:end]
                if !occursin("c", col) && !occursin("...", col)
                    GenCostData[!, Symbol(col)] = []
                end

            end
            line_ahead = get_single_space(lines[i+4])
            row_ahead = [try parse(Float64, v) catch ArgumentError parse(Float64, v[1:end-1]) end for v in split(line_ahead, " ")[2:end]]
            n_coeffs = length(row_ahead) - length(names(GenCostData))
            for n_ in 1:n_coeffs
                GenCostData[!, Symbol("c" * string(n_coeffs - n_))] = []
            end
            println("Reading GenCostData...")
            println("Number of columns: ", length(names(GenCostData)))

        end
        if occursin("mpc.gencost ", line)
            flag_gencost = true
        end
        if !flag_gencost && flag_gen && flag_branch && flag_bus && 
            !isempty(GenCostData) && !isempty(GenData) && !isempty(BusData) && !isempty(BranchData)
            break
        end
    end
    
    DFs = [BusData, GenData, BranchData, GenCostData]
    DFs_names = ["bus", "gen", "branch", "gencost"]
    if !isdir("data")
        mkdir("data")
    end
    for (df, name) in zip(DFs, DFs_names)
        CSV.write("data/" * name * ".csv", df)
    end
    
    
end