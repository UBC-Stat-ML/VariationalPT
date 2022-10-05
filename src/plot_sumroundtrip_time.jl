#' small: Fraction of scans/times to include in the "inset" zoomed-in plot
function plot_sumroundtrip_time(PT_results_all, PT_names_all, PT_to_all, dir, mod_name; small = 1/40)
    line_types = [:solid, :dash, :dot]
    n_reps = length(PT_results_all)
    n_methods = length(PT_names_all[1])
    n_scan = length(restarts(reduce(hcat, PT_results_all[1][1].Indices)'; cumulative=true))

    mean_times = zeros(n_methods)
    mean_counts = [zeros(n_scan) for _ in 1:n_methods]
    for j in 1:n_methods
        for i in 1:n_reps
            PT_results = PT_results_all[i]
            PT_to = PT_to_all[i]
            PT_names = PT_names_all[i]
            name = PT_names[j]

            if name in ["VPT", "VPT_full"]
                obj = PT_results[j].out_new
                obj2 = PT_results[j].out_old
            else
                obj = PT_results[j]
            end
            if obj.input_info.fulltrajectory == false
                error("'fulltrajectory' must be set to true.")
            end

            Indices_mat = reduce(hcat, obj.Indices)'
            y = restarts(Indices_mat; cumulative=true)
            if length(y) != n_scan
                error("Number of scans is not constant across all experiments.")
            end

            if name in ["VPT", "VPT_full"]
                if obj2.input_info.fulltrajectory == false
                    error("'fulltrajectory' must be set to true.")
                end
                Indices_mat2 = reduce(hcat, obj2.Indices)'
                if size(Indices_mat)[1] != size(Indices_mat2)[1]
                    error("Dimension of 'Indices_mat' and 'Indices_mat2' for two references are not the same")
                end
                y2 = restarts(Indices_mat2; cumulative=true)
                y = y .+ y2 # Add counts from *both* references!
            end

            mean_times[j] += PT_to[j]
            mean_counts[j] = mean_counts[j] .+ y
        end
        mean_times[j] = mean_times[j] / n_reps
        mean_counts[j] = mean_counts[j] ./ n_reps
    end
    min_time = minimum(mean_times)
    min_time_small = min_time * small

    for legend in [false, true]
        if legend == false
            tag = "nolegend"
        else
            tag = "legend"
        end

        y_max = maximum(map((i) -> mean_counts[i][end], 1:n_methods)) / 1.8 # NRPT should be roughly twice as fast as variational PT (2x fewer chains)
        y_max_small = y_max * small
        p = Plots.plot(bg = :white, xlab="Time (seconds)", ylab="Number of restarts", legend=legend, title=mod_name, xlim=(0, min_time), ylim=(0, y_max))
        q = Plots.plot(bg = :white, xlab="Time (seconds)", ylab="Number of restarts", legend=legend, title=mod_name, xlim=(0, min_time_small), ylim=(0, y_max_small))
        for j in 1:n_methods
                name = PT_names_all[1][j]
                y = mean_counts[j]
                x = range(0, stop = mean_times[j], length = length(y))
                Plots.plot!(p, x, y, labels=name, linecolor=j, linealpha=1.0, linestyle=line_types[j])
                Plots.plot!(q, x, y, labels=name, linecolor=j, linealpha=1.0, linestyle=line_types[j])
        end
        save(dir * "plots/sumroundtrips_time_" * tag * ".pdf", p)
        save(dir * "plots/sumroundtrips_time_" * tag * "_small.pdf", q)
    end
end