using StatsFuns
using Distributions
using Plots
using Random

μ = 100.0
M = 100_000_000 # Number of Monte Carlo simulations

function π_1(x, μ)
    return StatsFuns.logsumexp([log(0.5) + logpdf(Normal(μ, 1.0), x), log(0.5) + logpdf(Normal(-μ, 1.0), x)])
end

function q(x, μ)
    return logpdf(Normal(0.0, sqrt(μ^2 + 1.0)), x)
end

π_1(x) = π_1(x, μ)
q(x) = q(x, μ)

function f(x)
    return abs(π_1(x) - q(x)) # These are already on the log scale
end


samples1 = Vector{Float64}(undef, M)
samples2 = Vector{Float64}(undef, M)

function run_simulation(samples1, samples2)
    for m in 1:M
        x2 = rand(Normal(0.0, sqrt(μ^2 + 1.0)))
        z = rand(Bernoulli(0.5))
        if z == 0
            y = rand(Normal(μ, 1.0))
        elseif z == 1
            y = rand(Normal(-μ, 1.0))
        end
        samples1[m] = f(x2)
        samples2[m] = f(y)
    end
end


Random.seed!(23775467)
run_simulation(samples1, samples2)

println(mean(samples1))
println(std(samples1)/sqrt(length(samples1)))

println(mean(samples2))
println(std(samples2)/sqrt(length(samples2)))

println(sqrt((mean(samples1) + mean(samples2))/2.0))