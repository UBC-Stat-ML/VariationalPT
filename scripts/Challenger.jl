# See https://github.com/UBC-Stat-ML/blangDemos/blob/master/src/main/java/glms/Challenger.bl

include("../src/ParallelTempering.jl")
include("../src/utils.jl")
using .ParallelTempering
using Distributions
using Plots
using Statistics
using LinearAlgebra
using BenchmarkTools
using Suppressor
using Distributions
using Random
using CSV
using DataFrames
using StatsFuns
using AdvancedHMC
using ForwardDiff

function main()
    mod_name = "Challenger"

    # Load data
    df = DataFrame(CSV.File("data/challenger.csv"))
    R = nrow(df)
    inc = df[:, "inc"]
    temp = df[:, "temp"]


    # Simulation settings
    N = 14 # 14
    params = [[0.0, 10.0], [0.0, 10.0]] # β_0, β_1
    InitialState = [[params[1][1], params[2][1]] for _ in 1:(N+1)]
    ntotal = 20_000 # 20_000


    # Reference energy
    function V_0(θ, params)
        out = -logpdf(Normal(params[1][1], params[1][2]), θ[1]) - logpdf(Normal(params[2][1], params[2][2]), θ[2])
        return out
    end


    # Prior sampler
    function prior_sampler(params)
        out = Vector{Float64}(undef, length(params))
        out[1] = rand(Normal(params[1][1], params[1][2]))
        out[2] = rand(Normal(params[2][1], params[2][2]))
        return out
    end


    # Target energy
    # See https://lingpipe-blog.com/2012/02/16/howprevent-overflow-underflow-logistic-regression/
    function V_1(θ, inc, temp)
        lin_preds = [θ[1] for _ in 1:length(temp)] + θ[2] * temp
        log_probs = -StatsFuns.logsumexp.(fill(0, length(lin_preds)), -lin_preds)
        log_one_minus_probs = -StatsFuns.logsumexp.(fill(0, length(lin_preds)), lin_preds)
        out = V_0(θ) - sum(inc .* log_probs .+ (1 .- inc) .* log_one_minus_probs)
        return out
    end

    V_0(θ) = V_0(θ, params) # Wrapper
    prior_sampler() = prior_sampler(params)
    V_1(θ) = V_1(θ, inc, temp)


    # Start simulation
    seeds = [9375331, 1135671, 9699092, 5644605, 4023280, 9057856, 3849042, 7497445, 4437392, 43369866]
    ParallelTempering.run_simulation(V_0, V_1, InitialState, ntotal, N, prior_sampler, seeds, mod_name, compile=true, n_explore=1, n_reps=10, save_results=true)
end

main()