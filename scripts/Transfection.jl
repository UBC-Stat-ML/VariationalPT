# See https://github.com/UBC-Stat-ML/blangDemos/blob/master/src/main/java/ode/MRNATransfection.bl

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
    mod_name = "Transfection"

    # Load data
    df = DataFrame(CSV.File("data/transfection.csv"))
    times = df[:, "times"]
    obs = df[:, "observations"]


    # Simulation settings
    N = 49 # 49
    params = [[-5.0, 5.0, 10.0], [-5.0, 5.0, 10.0], [-5.0, 5.0, 10.0], [-2.0, 1.0, 10.0], [-2.0, 2.0, 10.0]] # km0, δ, β, t0, σ
    InitialState = [map((x) -> params[x][3]^((params[x][1] + params[x][2]) / 2), 1:length(params)) for _ in 1:(N+1)]
    ntotal = 20_000 # 20_000


    # Reference energy
    function V_0(θ, params)
        out = 0.0
        for j in 1:length(θ)
            out -= logpdf_LogUniform(params[j][1], params[j][2], params[j][3], θ[j])
        end
        return out
    end

    # Prior sampler
    function prior_sampler(params)
        out = Vector{Float64}(undef, length(params))
        for j in 1:length(params)
            out[j] = rand_LogUniform(params[j][1], params[j][2], params[j][3])
        end
        return out
    end

    # Target energy
    function V_1(θ, times, obs)
        out = V_0(θ)
        if out != Inf
            for t in 1:length(times)
                μ_t = θ[1] / (θ[2] - θ[3]) * (1.0 - exp(-(θ[2] - θ[3]) * (times[t] - θ[4]))) * exp(-θ[3] * (times[t] - θ[4]))
                if isnan(μ_t) || (μ_t == Inf) || (μ_t == -Inf)
                    μ_t = 10_000 # "hack" from the original transfection example (see the link above)
                end
                out -= logpdf(Normal(μ_t, θ[5]), obs[t])
            end
        end
        return out
    end

    V_0(θ) = V_0(θ, params) # Wrapper
    prior_sampler() = prior_sampler(params)
    V_1(θ) = V_1(θ, times, obs)


    # Start simulation
    seeds = [7835328, 7767816, 5302916, 6772827, 9514940, 4404491, 9943786, 5389242, 2725862, 6259809]
    ParallelTempering.run_simulation(V_0, V_1, InitialState, ntotal, N, prior_sampler, seeds, mod_name, compile = true, n_explore = 1, n_reps = 10, save_results = true)
end

main()