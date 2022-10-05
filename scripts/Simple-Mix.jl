# See https://github.com/UBC-Stat-ML/blangDemos/blob/master/src/main/java/mix/SimpleMixture.bl

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
    mod_name = "Simple-Mix"

    # Load data
    df = DataFrame(CSV.File("data/simple-mix.csv"; header=false))
    x = df[:, 1]


    # Simulation settings
    N = 9 # 9
    params = [[0.0, 1.0], [150.0, 100.0], [150.0, 100.0], [0.0, 100.0], [0.0, 100.0]] # π, μ_1, μ_2, σ_1, σ_2
    InitialState = [[0.5, 150.0, 150.0, 50.0, 50.0] for _ in 1:(N+1)]
    ntotal = 20_000 # 20_000


    # Reference energy
    function V_0(θ, params)
        if (params[1][1] <= θ[1]) && (θ[1] <= params[1][2]) && (params[4][1] <= θ[4]) && (θ[4] <= params[4][2]) && (params[5][1] <= θ[5]) && (θ[5] <= params[5][2])
            out = log((params[1][2] - params[1][1]) * (params[4][2] - params[4][1]) * (params[5][2] - params[5][1])) -
                  logpdf(Normal(params[2][1], params[2][2]), θ[2]) - logpdf(Normal(params[3][1], params[3][2]), θ[3])
        else
            out = Inf
        end
        return out
    end

    # Prior sampler
    function prior_sampler(params)
        out = Vector{Float64}(undef, length(params))
        out[1] = rand(Uniform(params[1][1], params[1][2]))
        out[2] = rand(Normal(params[2][1], params[2][2]))
        out[3] = rand(Normal(params[3][1], params[3][2]))
        out[4] = rand(Uniform(params[4][1], params[4][2]))
        out[5] = rand(Uniform(params[5][1], params[5][2]))
        return out
    end

    # Target energy
    function V_1(θ, x)
        out = V_0(θ)
        if out != Inf
            for i in 1:length(x)
                out -= logsumexp([log(θ[1]) + logpdf(Normal(θ[2], θ[4]), x[i]), log(1 - θ[1]) + logpdf(Normal(θ[3], θ[5]), x[i])])
            end
        end
        return out
    end

    V_0(θ) = V_0(θ, params) # Wrapper
    prior_sampler() = prior_sampler(params)
    V_1(θ) = V_1(θ, x)


    # Start simulation
    seeds = [6803467, 1948268, 8985154, 8297870, 66767089, 2670469, 55902485, 7707003, 16973002, 2621094]
    ParallelTempering.run_simulation(V_0, V_1, InitialState, ntotal, N, prior_sampler, seeds, mod_name, compile=true, n_explore=1, n_reps=10, save_results=true)
end

main()
