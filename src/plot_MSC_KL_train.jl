# λ_results: Vector of length n_reps x K x # variational parameters (2*number of parameters in the model)
# method: "MSC" or "KL"
function plot_MSC_KL_train(λ_results, method)
    if !(method in ["MSC", "KL"])
        error("'method' must be either 'MSC' or 'KL'.")
    end

    n_reps = length(λ_results)
    d = length(λ_results[1][1]) # Number of variational parameters

    # Convergence diagnostic plot
    for j in 1:d
        p = Plots.plot(bg = :white, xlab = "Tuning round", ylab = "λ[" * string(j) * "]", legend = false)
        for i in 1:n_reps
            λ = λ_results[i]
            if length(λ[1]) != d
                error("Number of dimensions is not constant.")
            end
            R = length(λ) # Number tuning rounds
            x = collect(1:R)
            y = map((x) -> λ[x][j], 1:R)
            Plots.plot!(p, x, y, linecolor = i, linealpha = 0.3) # Different color for each seed
        end
        save("results/" * method * "/" * method * "_" * string(j) * ".pdf", p)
    end

    # Marginal densities of variational distribution (mean-field approximation, so marginals are OK)
    d_model = convert(Int64, d/2) # Throws an error if 'd' is not even
    for j in 1:d_model
        p = Plots.plot(bg = :white, xlab = "Parameter " * string(j), ylab = "Density", legend = false)
        q = Plots.plot(bg = :white, xlab = "Parameter " * string(j), ylab = "", legend = false)
        μ_min = minimum(map((i) -> λ_results[i][end][j], 1:n_reps))
        μ_max = maximum(map((i) -> λ_results[i][end][j], 1:n_reps))
        σ_max = maximum(map((i) -> exp(λ_results[i][end][j + d_model]), 1:n_reps))
        x_full = range(μ_min - 3*σ_max, stop = μ_max + 3*σ_max, length=1000)
        y_sum = zeros(length(x_full))
        for i in 1:n_reps
            λ = λ_results[i][end] # Take the variational parameters from the last tuning round only!
            if length(λ) != d
                error("Number of dimensions is not constant.")
            end
            μ = λ[j]
            σ = exp(λ[j + d_model])
            y = Vector{Float64}(undef, length(x_full))
            for ii in 1:length(y)
                y[ii] = pdf(Normal(μ, σ), x_full[ii]) # Vectorization seems to be deprecated
            end
            y_sum = y_sum .+ y
            Plots.plot!(p, x_full, y, linecolor = i, linealpha = 0.3) # Different color for each seed
        end
        save("results/" * method * "/" * method * "_" * string(j) * "_density.pdf", p)
        
        Plots.plot!(q, x_full, y_sum, linecolor = 1, linealpha = 1.0) # Sum of normal densities
        save("results/" * method * "/" * method * "_" * string(j) * "_density_sum.pdf", q)
    end
end