# Markovian Score Climbing (MSC)
# See Markovian Score Climbing: Variational Inference with KL(p||q) by Naesseth et al. (2020)

using ForwardDiff
using StatsBase

struct potential_info{T<:Any, U<:Any, V<:Any}
    potential::T # -log(target density) as a function of z
    log_q::U # log(variational density) as a function of z and λ (*in that order*!)
    q_sampler::V # Sample from q, given λ
end


"Train a variational reference using MSC. `λ_0`: starting variational parameter. `z_0`: starting sample. 
`K`: number of MSC iterations. `S`: number of internal samples for CIS. `ϵ`: step size."
function MSC_train(potential, log_q, q_sampler, λ_0::Vector{Float64}, z_0::Vector{Float64}, K::Int64, S::Int64, ϵ::Vector{Float64})
    if length(ϵ) != K
        error("Step size sequence is not of appropriate length.")
    end

    h = potential_info(potential, log_q, q_sampler)
    λ = Vector{typeof(λ_0)}(undef, K+1)
    λ[1] = deepcopy(λ_0)
    z = Vector{typeof(z_0)}(undef, K+1)
    z[1] = deepcopy(z_0)

    for k in 2:(K+1)
        z[k] = CIS(h, z[k-1], λ[k-1], S) # Conditional importance sampling
        log_qz(l) = h.log_q(z[k], l) # log(variational density) at z as a function of λ
        g = Array{Float64}(ForwardDiff.gradient(log_qz, λ[k-1])) # Derivative of log(var dens) wrt λ at λ[k-1] and z[k]
        λ[k] = λ[k-1] + ϵ[k-1] * g
    end
    return λ
end


function CIS(h::potential_info, z_old::Vector{Float64}, λ::Vector{Float64}, S::Int64)
    z_new = similar(z_old)
    z = Vector{typeof(z_old)}(undef, S)
    z[1] = deepcopy(z_old)
    w = Vector{Float64}(undef, S)
    wbar = Vector{Float64}(undef, S)

    for s in 1:S
        if s >= 2 # s == 1 already done
            z[s] = h.q_sampler(λ)
        end
        w[s] = exp(-h.potential(z[s]) - h.log_q(z[s], λ))
    end

    wsum = sum(w)
    for s in 1:S
        wbar[s] = w[s]/wsum
    end
    J = StatsBase.sample(1:S, Weights(wbar))
    z_new = deepcopy(z[J])
    return z_new
end
