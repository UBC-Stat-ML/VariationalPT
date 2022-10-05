function store_simulation_results(mod_name, sim_id, PT_results_all, PT_to_all, PT_names_all)
    n_reps = length(PT_results_all)

    # Make directories
    dir = "results/" * mod_name * "/" * sim_id * "/"
    mkpath(dir) # Creates the directory if it doesn't exist
    mkdir(dir * "plots/")
    
    for name in ["PT", "VPT", "VPT_full"]
        mkdir(dir * name * "/")
        for i in 1:n_reps
            mkpath(dir * name * "/traceplots/" * string(i) * "/")
            mkpath(dir * name * "/samples/" * string(i) * "/")
        end
    end

    # Store simulation files 
    JLD2.save_object(dir * "PT_results_all.jld2", PT_results_all)
    JLD2.save_object(dir * "PT_to_all.jld2", PT_to_all)
    JLD2.save_object(dir * "PT_names_all.jld2", PT_names_all)
    cp("scripts/" * mod_name * ".jl", dir * mod_name * ".jl") # Copy Julia file (for reproducibility)

    # Make plots
    make_all_plots(dir, mod_name)
end