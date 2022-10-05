function plot_Blang_localbarrier(dir, mod_name, n_reps)
    p = Plots.plot([1, 2], [3, 4])
    for legend in [true, false]
        if legend == true
            tag = "legend"
        else
            tag = "nolegend"
        end

        for j in 1:n_reps
            fixed = DataFrame(CSV.File(dir * "fixed/" * string(j) * "/lambdaInstantaneous.csv"))
            fixed = subset(fixed, :round => r -> r .== maximum(fixed[:, "round"])) # Use only the last tuning round

            variational = DataFrame(CSV.File(dir * "variational/" * string(j) * "/lambdaInstantaneous.csv"))
            variational = subset(variational, :round => r -> r .== maximum(variational[:, "round"]))

            x_fixed = fixed[:, "beta"]
            x_variational = variational[:, "beta"]
            if any(x_fixed .!= x_variational)
                error("Annealing parameters for the fixed and variational references are not equal.")
            end
            if any(fixed[:, "round"] .!= fixed[:, "round"])
                error("Tuning round numbers for the fixed and variational references are not equal.")
            end
            y_fixed = fixed[:, "value"]
            y_variational = variational[:, "value"]
            y_max = max(maximum(y_fixed), maximum(y_variational))

            if j == 1
                p = Plots.plot(x_fixed, y_fixed, xticks=[0.0, 0.25, 0.5, 0.75, 1.0], xlab="β", ylab="λ", ylim=(0, y_max), legend=legend,
                               labels="NRPT", linecolor=1, linealpha=0.3, title=mod_name)
            else
                Plots.plot!(p, x_fixed, y_fixed, labels="NRPT", linecolor=1, linealpha=0.3)
            end
            Plots.plot!(p, x_variational, y_variational, labels="VPT", linecolor=2, linealpha=0.3)
        end
        save(dir * "plots/LCB_" * tag * ".pdf", p)
    end
end