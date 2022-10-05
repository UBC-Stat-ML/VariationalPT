# Reverse (exclusive) KL optimization with a mean-field Gaussian distribution
# Note that this function assumes that you are using a mean-field Gaussian distribution
# If you don't, then the results will very likely be wrong!
# Input for λ is assumed to be: first half is the sequence of means, second half is the log of the standard deviations

using ForwardDiff

"Train using reverse KL for `K` iterations using `S` Monte Carlo samples in each iteration."
function reverseKL_train(potential, log_q, q_sampler, λ_0::Vector{Float64}, K::Int64, S::Int64, ϵ::Vector{Float64})
    if length(λ_0) % 2 != 0
        error("Check that the input for λ is correct. λ should be a vector with 2*p elements.")
    end
    h = potential_info(potential, log_q, q_sampler)
    λ = Vector{typeof(λ_0)}(undef, K+1)
    λ[1] = deepcopy(λ_0)
    
    for k in 2:(K+1)
        g = reverseKL_gradient(h, λ[k-1], S)
        λ[k] = λ[k-1] + ϵ[k-1] * g
        # println("λ[k]")
        println(λ[k]) # debug
    end
    return λ
end

"Computes the reverse KL gradient at `λ` using `S` MC samples."
function reverseKL_gradient(h::potential_info, λ::Vector{Float64}, S::Int64)
    p = Int64(length(λ)/2)
    g = zeros(2*p)
    
    n_overflow = 0
    for s in 1:S
        Z = randn(p) # p-dimensional standard normal sample
        f1(l) = h.log_q(l[1:p] .+ exp.(l[(p+1):end]) .* Z, l)
        g1 = convert(Vector{Float64}, ForwardDiff.gradient(f1, λ))
        # g1 = vcat([0.0 for _ in 1:p], -1.0 ./ exp.(λ[(p+1):end]))
        f2(l) = -h.potential(l[1:p] .+ exp.(l[(p+1):end]) .* Z)
        g2 = convert(Vector{Float64}, ForwardDiff.gradient(f2, λ))
        println("g1") # debug
        println(g1)
        println("g2")
        println(g2)
        g .= g .+ g2 .- g1
    end
    g .= g ./ S # Average over S MC samples and go in the *negative* direction (KL *minimization*)
    println("g")
    println(g)
    return g
end