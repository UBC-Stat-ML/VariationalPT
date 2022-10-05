# See https://github.com/UBC-Stat-ML/blangDemos/blob/master/src/main/java/demos/UnidentifiableEllipticCurve.bl

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
using TimerOutputs
using ForwardDiff
using AdvancedHMC


function main()
    mod_name = "Elliptic"

    # Load data
    trials = 100_000
    failures = trials / 2


    # Simulation settings
    N = 29 # 29
    params = [[-3.0, 3.0], [-3.0, 3.0]] # x, y
    InitialState = [[0.0, 1.0] for _ in 1:(N+1)]
    # Comment: Need to be careful with initial state here. It is important to initialize in a place with non-zero posterior and/or prior density!
    ntotal = 20_000 # 20_000


    # Reference energy
    function V_0(θ, params)
        if (params[1][1] <= θ[1]) && (θ[1] <= params[1][2]) && (params[2][1] <= θ[2]) && (θ[2] <= params[2][2])
            out = log((params[1][2] - params[1][1]) * (params[2][2] - params[2][1]))
        else
            out = Inf
        end
        return out
    end

    # Prior sampler
    function prior_sampler(params)
        out = Vector{Float64}(undef, length(params))
        for j in 1:length(params)
            out[j] = rand(Uniform(params[j][1], params[j][2]))
        end
        return out
    end

    # Target energy
    function V_1(θ, trials, failures)
        out = V_0(θ)
        if out != Inf
            p = θ[2]^2 - θ[1]^3 + 2.0 * θ[1] - 0.5
            if p <= 0.0
                p = 0.0
            elseif p >= 1.0
                p = 1.0
            end
            out -= logpdf(Binomial(trials, p), failures)
        end
        return out
    end

    V_0(θ) = V_0(θ, params) # Wrapper
    prior_sampler() = prior_sampler(params)
    V_1(θ) = V_1(θ, trials, failures)


    # Start simulation
    seeds = [8217557, 5244025, 72368543, 1034240, 73149169, 6497223, 7988226, 4018574, 8426734, 1312964]
    ParallelTempering.run_simulation(V_0, V_1, InitialState, ntotal, N, prior_sampler, seeds, mod_name, compile=true, n_explore=1, n_reps=10, save_results=true)
end

main()