using AdvancedHMC 
using ForwardDiff
using Random

function sampleNUTSExploration(kernel, state)
    samples, _ = kernel(state)
    return samples[end]
end
