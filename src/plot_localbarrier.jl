function plot_localbarrier(PT_results_all, PT_names_all, dir, mod_name)
    p = Plots.plot([1,2],[3,4]) # Create an empty plot
    ys = []
    n_reps = length(PT_results_all)
    line_types = [:solid, :dash, :dot]

    for i in 1:n_reps
        PT_results = PT_results_all[i]
        PT_names = PT_names_all[i]
        for j in 1:length(PT_names)
            name = PT_names[j]
            if name in ["VPT", "VPT_full"]
                obj = PT_results[j].out_new
            else
                obj = PT_results[j]
            end
            ys = vcat(ys, obj.LocalBarriers[2:end, end]) # Take only from the last tuning round (removed the first β value for better plotting limits)
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
                else # NRPT/PT
                    obj = PT_results[j]
                end
                
                x = range(0, 1, length = obj.input_info.resolution)
                y = obj.LocalBarriers[:, end]
                if (i == 1) & (j == 1)
                    p = Plots.plot(x, y, xticks = [0.0, 0.25, 0.5, 0.75, 1.0], xlab = "β", ylab = "λ", ylim = (0, y_max), legend = legend,
                                   labels = name, linecolor = j, linealpha = 0.3, linestyle = line_types[j], title = mod_name)
                else
                    Plots.plot!(p, x, y, labels = name, linecolor = j, linestyle = line_types[j], linealpha = 0.3)
                end
            end
        end
        save(dir * "plots/LCB_" * tag * ".pdf", p)
    end
end