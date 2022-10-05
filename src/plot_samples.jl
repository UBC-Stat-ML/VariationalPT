#' Plot samples from parallel tempering output
#'
#' Plots the output from each of the chains in a PT algorithm. In the univariate case, the output 
#' is a histogram. For 2D, the output is a scatterplot. Otherwise, no output is produced.
#'
#' @param obj Parallel Tempering (PT) object OR other object
#' @param dims Vector of dimensions to plot. Defaults to all dimensions.
#' @param PT Whether output is based on a PT-type object

include("get_chain_states.jl")

function plot_samples(obj, dir; PT = true, tag = "fixed")
    if PT
        if (obj.input_info.two_references == true) && !(:N in keys(obj))
            plot_samples(obj.out_new, dir, PT = true, tag = "variational") # Recursive function call
            plot_samples(obj.out_old, dir, PT = true, tag = "fixed")
        else
            for dims in 1:obj.dim_x
                n = obj.N + 1 # Final chain
                chain_states = get_chain_states(obj, n) # Only for samples after the last tuning round!
                plot_samples_helper(chain_states, dims, dir, tag)
            end
        end
    end
    # else # Not a PT object
    #     chain_states = reduce(vcat, obj) # Concatenate chains into one long chain
    #     dims = 1:length(chain_states[1])
    #     plot_samples_helper(chain_states, dims)
end


function plot_samples_helper(chain_states, dims, dir, tag)
    if length(dims) == 1 # Histogram
        chain_states = map((x) -> chain_states[x][dims[1]], 1:length(chain_states))
        p = CairoMakie.Figure() # using CairoMakie
        CairoMakie.hist(p[1, 1], chain_states, bins=100, normalization = :pdf)
        save(dir * "samples_" * string(dims[1]) * "_" * tag * ".pdf", p)
    elseif length(dims) == 2 # Scatterplot
        chain_states1 = map((x) -> chain_states[x][dims[1]], 1:length(chain_states))
        chain_states2 = map((x) -> chain_states[x][dims[2]], 1:length(chain_states))
        p = CairoMakie.Figure() # using CairoMakie
        CairoMakie.Axis(p[1, 1])
        CairoMakie.scatter!(chain_states1, chain_states2)
    else # Don't plot if 'dim_x' > 2
        println("Plotting functionality not yet available for more than two dimensions.")
    end
end