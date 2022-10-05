# See https://github.com/UBC-Stat-ML/blangDemos/blob/master/src/main/java/glms/SpikeSlabClassification.bl
# Note: This example is inspired by the spike-slab example above ^, but it is *not* a spike-slab GLM.

include("../src/ParallelTempering.jl")
include("../src/utils.jl")
using .ParallelTempering
using Distributions
using Plots
using Statistics
using LinearAlgebra
using Suppressor
using Distributions
using Random
using CSV
using DataFrames
using StatsFuns
using ForwardDiff
using AdvancedHMC


function main()
    mod_name = "Titanic"

    # Load data
    df = DataFrame(CSV.File("data/titanic.csv"))
    y = convert(Vector{Float64}, df[:, "survived"])
    x = Matrix(df[:, filter(x -> x != "survived", names(df))])


    # Simulation settings
    N = 29 # 29 
    params = vcat([0.0 for _ in 1:(size(x)[2]+1)], [1.0]) # β_0, β_1, ..., β_7, σ (*scale*)
    InitialState = [params for _ in 1:(N+1)]
    ntotal = 20_000 # 20_000


    # Reference energy
    function V_0(θ, params)
        p = length(params)
        out = 0.0
        if θ[p] < 0
            out = Inf
        else
            out = -logpdf(Exponential(params[p]), θ[p])
        end
        if out != Inf
            for j in 1:(p-1)
                out -= logpdf(Cauchy(params[j], θ[p]), θ[j])
            end
        end
        return out
    end


    # Prior sampler
    function prior_sampler(params)
        p = length(params)
        out = Vector{Float64}(undef, p)
        out[p] = rand(Exponential(params[p]))
        for j in 1:(p-1)
            out[j] = rand(Cauchy(params[j], out[p]))
        end
        return out
    end


    # Target energy
    # See https://lingpipe-blog.com/2012/02/16/howprevent-overflow-underflow-logistic-regression/
    # Reduce memory allocations by pre-allocating (below)
    Xβ = Vector{Float64}(undef, size(x)[1])
    lin_preds = similar(Xβ)
    neg_lin_preds = similar(lin_preds)
    intercept = similar(lin_preds)
    log_probs = Vector{Float64}(undef, length(y))
    log_one_minus_probs = similar(log_probs)
    zero_vec = zeros(length(lin_preds))
    log_pdf_vec = similar(log_probs)
    slopes = Vector{Float64}(undef, size(x)[2])
    function V_1(θ, x, y, Xβ, lin_preds, neg_lin_preds, intercept, slopes, log_probs, log_one_minus_probs, zero_vec, log_pdf_vec)
        out = V_0(θ)
        if out != Inf
            p = length(θ)
            intercept .= θ[1]
            for j in 2:(p-1)
                slopes[j-1] = θ[j]
            end
            mul!(Xβ, x, slopes) # Xβ = x * slopes
            lin_preds .= Xβ .+ intercept # Slope and intercept
            neg_lin_preds .= lin_preds .* (-1.0)
            ParallelTempering.logsumexp!(log_probs, zero_vec, neg_lin_preds)
            log_probs .= log_probs .* (-1.0)
            ParallelTempering.logsumexp!(log_one_minus_probs, zero_vec, lin_preds)
            log_one_minus_probs .= log_one_minus_probs .* (-1.0)
            log_pdf_vec .= y .* log_probs .+ (1 .- y) .* log_one_minus_probs
            out -= sum(log_pdf_vec)
        end
        return out
    end

    V_0(θ) = V_0(θ, params) # Wrapper
    prior_sampler() = prior_sampler(params)
    V_1(θ) = V_1(θ, x, y, Xβ, lin_preds, neg_lin_preds, intercept, slopes, log_probs, log_one_minus_probs, zero_vec, log_pdf_vec)


    # Start simulation
    seeds = [8602086, 5211083, 9908143, 5390668, 4183391, 3105356, 9912857, 9539006, 4557415, 7368918]
    ParallelTempering.run_simulation(V_0, V_1, InitialState, ntotal, N, prior_sampler, seeds, mod_name, compile = true, n_explore = 1, n_reps = 10, save_results = true)
end

main()