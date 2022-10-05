# Modified from code for the AdvancedHMC tutorial: https://github.com/TuringLang/AdvancedHMC.jl

function run_all_NUTS_methods(V_1, InitialState, ntotal, N, params; compile = true)
    to2 = Vector{Float64}(undef, N + 1)
    nadapt = Int64(floor(ntotal/2))
    NUTS_results = Vector{Any}(undef, N + 1)
    InitialState1 = InitialState[1]
    ℓπ(θ) = -V_1(θ)
    D = length(params)
    
    metric = DiagEuclideanMetric(D)
    hamiltonian = Hamiltonian(metric, ℓπ, ForwardDiff)
    initial_ϵ = find_good_stepsize(hamiltonian, InitialState1)
    integrator = Leapfrog(initial_ϵ)
    proposal = NUTS{MultinomialTS, GeneralisedNoUTurn}(integrator)
    adaptor = StanHMCAdaptor(MassMatrixAdaptor(metric), StepSizeAdaptor(0.8, integrator))

    if compile
        samples_temp, stats_temp = AdvancedHMC.sample(hamiltonian, proposal, InitialState1, 20, adaptor, 10; verbose = false)
    end

    Threads.@threads for i in 1:(N+1)
        out, to2[i] = @timed AdvancedHMC.sample(hamiltonian, proposal, InitialState1, ntotal, adaptor, nadapt; verbose = false)
        NUTS_results[i] = copy(out.θs)
    end
    return NUTS_results, to2
end