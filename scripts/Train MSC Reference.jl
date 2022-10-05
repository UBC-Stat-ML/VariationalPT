include("../src/ParallelTempering.jl")
using .ParallelTempering
using StatsFuns
using Distributions
using Random
using DataFrames
using CSV


function main()
    # Copied from Transfection.jl -----------
    # Load data
    df = DataFrame(CSV.File("data/transfection.csv"))
    times = df[:, "times"]
    obs = df[:, "observations"]
    params = [[-5.0, 5.0, 10.0], [-5.0, 5.0, 10.0], [-5.0, 5.0, 10.0], [-2.0, 1.0, 10.0], [-2.0, 2.0, 10.0]] # km0, δ, β, t0, σ
    InitialState = map((x) -> params[x][3]^((params[x][1] + params[x][2]) / 2), 1:length(params))

    # Reference energy
    function V_0(θ, params)
        out = 0.0
        for j in 1:length(θ)
            out -= logpdf_LogUniform(params[j][1], params[j][2], params[j][3], θ[j])
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
    V_1(θ) = V_1(θ, times, obs)

    function logpdf_LogUniform(a, b, d, x)
        if (x < d^a) | (x > d^b)
            out = -Inf
        else
            out = -log(b - a) - log(x) - log(log(d))
        end
        return out
    end
    
    rand_LogUniform(a, b, d) = d^rand(Uniform(a, b))


    # Simulation settings
    λ_0 = vcat(InitialState, [log(100.0) for _ in 1:5])
    z_0 = InitialState
    n_reps = 10 # 10
    K_MSC = 100_000 # 100_000
    S_MSC = 100 # 100
    ϵ_MSC = [0.0005 for _ in 1:K_MSC] # 0.0005
    λ_MSC_results = Vector{Any}(undef, n_reps)

    function log_q(z::AbstractVector, λ::AbstractVector)
        out = 0.0
        for j in 1:5
            out += logpdf(Normal(λ[j], exp(λ[j+5])), z[j])
        end
        return out
    end

    function q_sampler(λ::Vector{Float64})
        out = Vector{Float64}(undef, 5)
        for j in 1:5
            out[j] = rand(Normal(λ[j], exp(λ[j+5])))
        end
        return out
    end

    Random.seed!(9939438)
    for i in 1:n_reps
        λ_MSC_results[i] = ParallelTempering.MSC_train(V_1, log_q, q_sampler, λ_0, z_0, K_MSC, S_MSC, ϵ_MSC)
    end
    ParallelTempering.plot_MSC_KL_train(λ_MSC_results, "MSC")
end

main()