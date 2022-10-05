function make_all_plots(dir, mod_name)
    # Load objects from directory
    PT_results_all = JLD2.load_object(dir * "PT_results_all.jld2")
    PT_to_all = JLD2.load_object(dir * "PT_to_all.jld2")
    PT_names_all = JLD2.load_object(dir * "PT_names_all.jld2")
    n_reps = length(PT_results_all)

    # Make diagnostic plots (individual methods)
    for i in 1:n_reps
        PT_names = PT_names_all[i]
        PT_results = PT_results_all[i]
        for j in 1:length(PT_names)
            name = PT_names[j]
            ParallelTempering.plot_samples(PT_results[j], dir * name * "/samples/" * string(i) * "/", PT = true)
            ParallelTempering.plot_trace(PT_results[j], dir * name * "/traceplots/" * string(i) * "/")
        end
    end

    # Make comparison plots (all methods)
    ParallelTempering.plot_sumroundtrip(PT_results_all, PT_names_all, dir, mod_name)
    ParallelTempering.plot_sumroundtrip_time(PT_results_all, PT_names_all, PT_to_all, dir, mod_name)
    ParallelTempering.plot_globalbarrier(PT_results_all, PT_names_all, dir, mod_name)
    ParallelTempering.plot_localbarrier(PT_results_all, PT_names_all, dir, mod_name)
    ParallelTempering.plot_roundtrip(PT_results_all, PT_names_all, dir, mod_name)
    ParallelTempering.plot_ESS(PT_results_all, PT_to_all, PT_names_all, dir, mod_name)
end