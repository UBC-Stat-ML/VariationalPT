function plot_roundtrip(PT_results_all, PT_names_all, dir, mod_name)
    p = Plots.plot([1,2],[3,4]) # Create an empty plot
    n_reps = length(PT_results_all)
    line_types = [:solid, :dash, :dot]

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
                    obj2 = PT_results[j].out_old # Add roundtrips from the second reference
                else
                    obj = PT_results[j]
                end
                
                x = 1:length(obj.RoundTripRates)
                y = obj.RoundTripRates
                if name in ["VPT", "VPT_full"]
                    y2 = obj2.RoundTripRates
                    if length(y) != length(y2)
                        error("'y' and 'y2' are not of the same length")
                    end
                    y = y .+ y2
                elseif name in ["PT"]
                    y = y .* 2.0 # For a fair comparison
                end

                if (i == 1) && (j == 1)
                    p = Plots.plot(x, y, xticks = x, xlab = "Tuning round", ylab = "Round trip rate", ylim = (0, 1.0), legend = legend,
                    labels = name, linecolor = j, linealpha = 0.3, linestyle = line_types[j], title = mod_name)
                else
                    Plots.plot!(p, x, y, labels = name, linecolor = j, linestyle = line_types[j], linealpha = 0.3)
                end
            end
        end
        save(dir * "plots/roundtriprate_" * tag * ".pdf", p)
    end
end