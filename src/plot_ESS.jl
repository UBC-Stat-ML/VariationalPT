#' Compute the log10(*minimum* ESS/sec) and log10(min ESS) over all parameters, n_reps times for each algorithm.
#' Usually, n_reps = 10, and so the boxplots are based on 10 calculations of the log10(min ESS/sec)

function plot_ESS(PT_results_all, PT_to_all, PT_names_all, dir, mod_name)
    n_reps = length(PT_results_all)
    n_methods = length(PT_names_all[1])

    ess_times = Vector{Vector{Float64}}(undef, n_methods)
    ess_vec = similar(ess_times)
    for j in 1:n_methods
        ess_times_inner = Vector{Float64}(undef, n_reps)
        ess_inner = similar(ess_times_inner)
        for i in 1:n_reps
            PT_results = PT_results_all[i]
            PT_to = PT_to_all[i]
            PT_names = PT_names_all[i]
            name = PT_names[j]
            if name in ["VPT", "VPT_full"]
                obj = PT_results[j].out_new
                obj2 = PT_results[j].out_old # Keep track of samples from both PT instances
            else
                obj = PT_results[j]
            end
            if obj.input_info.fulltrajectory == false
                error("'fulltrajectory' must be set to true.")
            end
            
            chain_states = get_chain_states(obj, obj.N + 1; final = false) # Get *all* states from the *final* chain
            if name in ["VPT", "VPT_full"]
                chain_states2 = get_chain_states(obj2, obj2.N + 1; final = false)
            end
            p = length(chain_states[1]) # Number of parameters
            min_ess = Inf
            for k in 1:p # Loop through each variable
                min_ess_temp = ess(map((x) -> chain_states[x][k], 1:length(chain_states)))[1] # Calls R function ess() from 'mcmcse'
                if name in ["VPT", "VPT_full"]
                    min_ess_temp += ess(map((x) -> chain_states2[x][k], 1:length(chain_states2)))[1] # Add second reference
                end
                if min_ess_temp < min_ess
                    min_ess = min_ess_temp
                end
            end
            secs = PT_to[j] # Scalar
            ess_times_inner[i] = min_ess / secs
            if name in ["PT"]
                min_ess *= 2 # For a fair comparison. Note that we *don't* do this for the ESS/second calculation (because time is already accounted for)!
            end
            ess_inner[i] = min_ess
        end
        ess_times[j] = deepcopy(ess_times_inner)
        ess_vec[j] = deepcopy(ess_inner)
    end
    
    x = repeat(PT_names_all[1], inner = n_reps)
    y = log10.(reduce(vcat, ess_times))
    p = StatsPlots.boxplot(x, y, ylab = "log10(min ESS per second)", xrotation = 45, legend = false, ylim = (minimum(y), maximum(y)), title = mod_name)
    save(dir * "plots/ESS_per_second.pdf", p)

    y = log10.(reduce(vcat, ess_vec))
    p = StatsPlots.boxplot(x, y, ylab = "log10(min ESS)", xrotation = 45, legend = false, ylim = (0, maximum(y)), title = mod_name)
    save(dir * "plots/ESS.pdf", p)
end