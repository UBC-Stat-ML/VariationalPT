function run_simulation(V_0, V_1, InitialState, ntotal, N, prior_sampler, seeds, mod_name; compile = true, methods = nothing, n_explore = 1, optimreference_start = 4, n_reps = 10, run_MCMC = false, save_results = true)
    sim_id = Random.randstring(15)

    # Input checks
    if length(seeds) < n_reps
        error("Length of 'seeds' < 'n_reps'.")
    end

    # Run simulation
    PT_results_all = Vector{Any}(undef, n_reps)
    PT_to_all = Vector{Any}(undef, n_reps)
    PT_names_all = Vector{Any}(undef, n_reps)
    for i in 1:n_reps # You can parallelize this if you want!
        seed = seeds[i]
        PT_results_all[i], PT_to_all[i], PT_names_all[i] = run_all_PT_methods(V_0, V_1, InitialState, ntotal, N, prior_sampler, seed; compile = compile, methods = methods, n_explore = n_explore, optimreference_start = optimreference_start)
    end
    
    # Store results
    if save_results
        println("Storing simulation results and making plots")
        store_simulation_results(mod_name, sim_id, PT_results_all, PT_to_all, PT_names_all)
    end
end