function redirect_to_files(dofunc, args, outfile, errfile)
    """ Redirects output of `dofunc` writtent into stdout and stderr stream into specified files
        Arguments:
            dofunc    (function)   : function which's outputs should be captured
            args      (Array{Any}) : arguments that should be passed to `dofunc`. pass [] if no arguments needed
            outfile   (String)     : path and name of file to dump stdout strem
            errfile   (String)     : path and name of file to dump stderr strem
    """
    
    open(outfile, "w") do out
        open(errfile, "w") do err
            redirect_stdout(out) do
                redirect_stderr(err) do
                    dofunc(args...)
                end
            end
        end
    end
end

function get_iterations(filename)
    """ Get the iteration values from the output of Ipopt solver dumped into `filename`
        Arguments:
            filename (String) : the path to the file contains stdout dump of optimize!(Model) function
        Returns:
            iteations results (Tuple) : objectives, dual infeasibilities,
                                        constraint violations, complementarity condition values,
                                        overall NLP errors through iterations
    """
    lines = []
    #read the file line-wise
    open(filename) do f
        # read till end of file
        while ! eof(f) 
            # read a new / next line for every iteration          
            s = readlines(f)         
            append!(lines, s)
        end
    end
    #preparing place to add to
    Objectives = []
    DualInfeas = []
    ConstrViol = []
    Complement = []
    OverallNLP = []
    
    for line in lines
        #Put Objectives
        if occursin("Objective...............:", line)
            #split line as in file
            splitted = split(line, "   ")
            #cast it to float
            val = parse(Float64, splitted[2])
            append!(Objectives, val)
        end
        #Put dual infeas.
        if occursin("Dual infeasibility......:", line)
            splitted = split(line, "   ")
            val = parse(Float64, splitted[2])
            append!(DualInfeas, val)
        end
        #Put constr violation
        if occursin("Constraint violation....:", line)
            splitted = split(line, "   ")
            val = parse(Float64, splitted[2])
            append!(ConstrViol, val)
        end
        #Put Complementarity
        if occursin("Complementarity.........:", line)
            splitted = split(line, "   ")
            val = parse(Float64, splitted[2])
            append!(Complement, val)
        end
        #Put NLP error
        if occursin("Overall NLP error.......:", line)
            splitted = split(line, "   ")
            val = parse(Float64, splitted[2])
            append!(Complement, val)
        end
    end
    return Objectives, DualInfeas, ConstrViol, Complement, OverallNLP
end