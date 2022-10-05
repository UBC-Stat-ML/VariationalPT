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
using ForwardDiff
using AdvancedHMC


function main()
    mod_name = "MVN"

    # Simulation settings
    N = 2 # 2
    d = 100 # 100
    InitialState = [[0.0 for j in 1:d] for _ in 1:(N+1)]
    ntotal = 20_000 # 20_000

    # Reference energy
    function V_0(θ, d)
        out = 0.0
        for j in 1:d
            out -= logpdf(Normal(10.0, 1.0), θ[j])
        end
        return out
    end

    # Prior sampler
    function prior_sampler(d)
        out = rand(Normal(10.0, 1.0), d)
        return out
    end

    # Target energy
    function V_1(θ, d)
        out = 0.0
        for j in 1:d
            out -= logpdf(Normal(0.0, 1.0), θ[j])
        end
        return out
    end

    V_0(θ) = V_0(θ, d) # Wrapper
    prior_sampler() = prior_sampler(d)
    V_1(θ) = V_1(θ, d)


    # Start simulation
    seeds = [1949412, 6488888, 6478068, 3204321, 2151793, 4912732, 1522438, 3929444, 3819896, 2023981]
    ParallelTempering.run_simulation(V_0, V_1, InitialState, ntotal, N, prior_sampler, seeds, mod_name, compile=true, n_explore=1, optimreference_start=7, n_reps=10, save_results=true)
end

main()