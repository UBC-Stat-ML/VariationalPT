module ParallelTempering 
using Base: Forward
using LinearAlgebra
using Distributions
using Statistics
using StatsBase
using Dierckx
using ForwardDiff
using Plots
using GLMakie
using CairoMakie
using Interpolations
using RCall
using TimerOutputs
@rlibrary mcmcse
using StatsPlots
using Roots
using Dates
using JLD2
using CSV
using DataFrames

export nrpt, sampleNUTS, DEO, computeEtas, roundtrip, plot_samples, summarize_samples, plot_roundtrip, plot_globalbarrier, 
plot_trace, plot_localbarrier, plot_ESS, get_chain_states, plot_sumroundtrip, run_all_PT_methods, run_simulation, 
store_simulation_results, make_all_plots, logsumexp!, plot_Blang_globalbarrier, plot_Blang_localbarrier, MSC_train, 
reverseKL_train, plot_MSC_KL_train, logpdf_LogUniform, rand_LogUniform, plot_sumroundtrip_time, restarts


### Samplers
include("explorationkernels.jl")
include("nutssampler.jl")
include("hmc.jl")
include("slice_sampling.jl")


### NRPT
include("etas.jl")
include("acceptance.jl")
include("communicationbarrier.jl")
include("updateschedule.jl")
include("roundtriprate.jl")
include("lognormalizingconstant.jl")
include("deoscan.jl")
include("deo.jl")
include("NRPT.jl")


### Useful tools
include("plot_samples.jl")
include("summarize_samples.jl")
include("utils.jl")
include("plot_roundtrip.jl")
include("plot_globalbarrier.jl")
include("plot_localbarrier.jl")
include("plot_trace.jl")
include("plot_ess.jl")
include("plot_sumroundtrip.jl")
include("get_chain_states.jl")
include("Winsorized_mean.jl")
include("Winsorized_std.jl")
include("trimmed_mean.jl")
include("run_all_PT_methods.jl")
include("run_all_NUTS_methods.jl")
include("run_simulation.jl")
include("store_simulation_results.jl")
include("make_all_plots.jl")
include("logsumexp.jl")
include("plot_Blang_globalbarrier.jl")
include("plot_Blang_localbarrier.jl")
include("MSC.jl")
include("reverseKL.jl")
include("plot_MSC_KL_train.jl")
include("loguniform.jl")
include("plot_sumroundtrip_time.jl")

end