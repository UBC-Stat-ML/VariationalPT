# Note: Don't use this function!
# It has been replaced by 'get_chain_states'
function grabsamples(samples, startindex, chain)
    return [samples[i][chain][1] for i in startindex:size(samples)[1]]
end