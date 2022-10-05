#' Create trace plots
#'
#' Create trace plots for 1D MCMC output
#'
#' @param obj Parallel Tempering (PT) object
#' @param dims Vector of dimensions to plot. Defaults to all dimensions.

include("get_chain_states.jl")

function plot_trace(obj, dir; tag = "fixed")
    if (obj.input_info.two_references == true) && !(:N in keys(obj))
        plot_trace(obj.out_new, dir, tag = "variational") # Recursive function call
        plot_trace(obj.out_old, dir, tag = "fixed")
    else
        for dims in 1:obj.dim_x
            n = obj.N + 1 # Final chain
            chain_states = get_chain_states(obj, n) # Only for the states after the final tuning round!
            if length(dims) == 1 
                chain_states = map((x) -> chain_states[x][dims[1]], 1:length(chain_states))
                p = CairoMakie.Figure() # using CairoMakie
                CairoMakie.Axis(p[1, 1])
                CairoMakie.lines!(1:length(chain_states), chain_states)
                save(dir * "traceplots_" * string(dims[1]) * "_" * tag * ".pdf", p)
            else # Don't plot if length(dims) > 1
                println("Trace plot functionality not available for greater than one dimension.")
            end
        end
    end
end