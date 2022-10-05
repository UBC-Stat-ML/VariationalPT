function plot_Blang_globalbarrier(dir, mod_name, n_reps)
    p = Plots.plot([1, 2], [3, 4])
    for legend in [true, false]
        if legend == true
            tag = "legend"
        else
            tag = "nolegend"
        end
        for j in 1:n_reps
            fixed = DataFrame(CSV.File(dir * "fixed/" * string(j) * "/globalLambda.csv"))
            variational = DataFrame(CSV.File(dir * "variational/" * string(j) * "/globalLambda.csv"))

            x_fixed = fixed[:, "round"] .+ 1
            x_variational = variational[:, "round"] .+ 1
            if any(x_fixed .!= x_variational)
                error("Tuning round numbers for the fixed and variational references are not equal.")
            end
            y_fixed = fixed[:, "value"]
            y_variational = variational[:, "value"]
            y_max = max(maximum(y_fixed), maximum(y_variational))

            if j == 1
                p = Plots.plot(x_fixed, y_fixed, xticks=x_fixed, xlab="Tuning round", ylab="Global communication barrier", ylim=(0, y_max), legend=legend,
                    labels="NRPT", linecolor=1, linealpha=0.3, title=mod_name)
            else
                Plots.plot!(p, x_fixed, y_fixed, labels="NRPT", linecolor=1, linealpha=0.3)
            end
            Plots.plot!(p, x_variational, y_variational, labels="VPT", linecolor=2, linealpha=0.3)
        end
        save(dir * "plots/GCB_" * tag * ".pdf", p)
    end
end