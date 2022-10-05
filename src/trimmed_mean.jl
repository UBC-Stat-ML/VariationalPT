# # α: Percentage of observations to trim/drop at bottom and top (use only 1 - 2α observations and drop the rest)
# function trimmed_mean(x; α=0.1)
#     x = sort(x)
#     n = length(x)
#     n_lower = convert(Int64, floor(α*n))
#     out = 1/(n - 2*n_lower) * sum(x[(n_lower + 1):(n - n_lower)])
#     return out
# end