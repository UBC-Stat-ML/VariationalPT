function plot_sumroundtrip(PT_results_all, PT_names_all, dir, mod_name)
    p = Plots.plot([1, 2], [3, 4]) # Create an empty plot
    q = Plots.plot([1, 2], [3, 4])
    ys = []
    n_reps = length(PT_results_all)
    line_types = [:solid, :dash, :dot]
    n_scan_small = 500

    for i in 1:n_reps
        PT_results = PT_results_all[i]
        PT_names = PT_names_all[i]
        for j in 1:length(PT_names)
            name = PT_names[j]
            if name in ["VPT", "VPT_full"]
                obj = PT_results[j].out_new
                obj2 = PT_results[j].out_old # Store the sum of the roundtrips for the two instances of PT
            else
                obj = PT_results[j]
            end
            Indices_mat = reduce(hcat, obj.Indices)'
            y = roundtrip(Indices_mat; cumulative=true)
            if name in ["VPT", "VPT_full"]
                Indices_mat2 = reduce(hcat, obj2.Indices)'
                y2 = roundtrip(Indices_mat2; cumulative=true)
                y = y .+ y2
            end
            ys = vcat(ys, y) 
        end
    end
    y_max = maximum(ys)

    for legend in [false, true]
        if legend == false
            tag = "nolegend"
        else
            tag = "legend"
        end
        for i in 1:n_reps
            PT_results = PT_results_all[i]
            PT_names = PT_names_all[i]
            for j in 1:length(PT_names)
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
                x = 1:size(Indices_mat)[1]
                y = roundtrip(Indices_mat; cumulative=true)

                if name in ["VPT", "VPT_full"]
                    if obj2.input_info.fulltrajectory == false
                        error("'fulltrajectory' must be set to true.")
                    end
                    Indices_mat2 = reduce(hcat, obj2.Indices)'
                    if size(Indices_mat)[1] != size(Indices_mat2)[1]
                        error("Dimension of 'Indices_mat' and 'Indices_mat2' for two references are not the same")
                    end
                    y2 = roundtrip(Indices_mat2; cumulative=true)
                    y = y .+ y2 # Add roundtrips from *both* references!
                elseif name in ["PT"]
                    y = y .* 2.0 # For a fair comparison between the two methods
                end
                
                if (i == 1) && (j == 1)
                    p = Plots.plot(x, y, xlab = "Number of scans", ylab = "Number of round trips", ylim = (0, y_max), legend = legend,
                        labels = name, linecolor = j, linealpha = 0.3, linestyle = line_types[j], title = mod_name)
                    q = Plots.plot(x[1:n_scan_small], y[1:n_scan_small], xlab = "Number of scans", ylab = "Number of round trips", legend = legend,
                        labels = name, linecolor = j, linealpha = 0.3, linestyle = line_types[j], title = mod_name)
                else
                    Plots.plot!(p, x, y, labels = name, linecolor = j, linealpha = 0.3, linestyle = line_types[j])
                    Plots.plot!(q, x[1:n_scan_small], y[1:n_scan_small], labels = name, linecolor = j, linealpha = 0.3, linestyle = line_types[j])
                end
            end
        end
        save(dir * "plots/sumroundtrips_" * tag * ".pdf", p)
        save(dir * "plots/sumroundtrips_" * tag * "_small.pdf", q)
    end
end