#' @param compile: Whether to run a "garbage" instance of PT so that recorded times are accurate.
#' @param n_explore: Number of exploration steps in the sampler before considering a communication swap
function run_all_PT_methods(V_0, V_1, InitialState, ntotal, N, prior_sampler, seed; compile = true, methods = nothing, n_explore = 1, optimreference_start = 4)
    Random.seed!(seed)
    num_methods = 3
    if isnothing(methods)
        methods = 1:num_methods
    end
    PT_to = Vector{Float64}(undef, num_methods)
    InitialState3 = deepcopy(InitialState[1:3])
    PT_results = Vector{Any}(undef, num_methods)
    PT_names = Vector{String}(undef, num_methods)

    if compile # 20 scans, 3 chains
        PT_temp = ParallelTempering.nrpt(V_0, V_1, InitialState3, 20, 2, optimreference = false, prior_sampler = prior_sampler, n_explore = n_explore)
        PT_temp_2 = ParallelTempering.nrpt(V_0, V_1, InitialState3, 20, 2, optimreference = true, prior_sampler = prior_sampler, two_references = true, n_explore = n_explore, optimreference_start = optimreference_start)
        PT_temp_3 = ParallelTempering.nrpt(V_0, V_1, InitialState3, 20, 2, optimreference = true, prior_sampler = prior_sampler, full_covariance = true, two_references = true, n_explore = n_explore, optimreference_start = optimreference_start)
    end

    for i in methods
        if i == 1 # NRPT
            PT_results[i], PT_to[i] = @timed ParallelTempering.nrpt(V_0, V_1, InitialState, ntotal, N, optimreference = false, prior_sampler = prior_sampler, n_explore = n_explore)
            PT_names[i] = "PT"
        elseif i == 2 # Variational PT (mean-field)
            PT_results[i], PT_to[i] = @timed ParallelTempering.nrpt(V_0, V_1, InitialState, ntotal, N, optimreference = true, prior_sampler = prior_sampler, two_references = true, n_explore = n_explore, optimreference_start = optimreference_start)
            PT_names[i] = "VPT"
        elseif i == 3 # Variational PT (full Σ)
            PT_results[i], PT_to[i] = @timed ParallelTempering.nrpt(V_0, V_1, InitialState, ntotal, N, optimreference = true, prior_sampler = prior_sampler, full_covariance = true, two_references = true, n_explore = n_explore, optimreference_start = optimreference_start)
            PT_names[i] = "VPT_full"
        end
    end

    return PT_results, PT_to, PT_names
end
