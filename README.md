# VariationalPT

A Julia implementation of the methods in the paper "Parallel Tempering With a Variational Reference" by 
Surjanovic, Syed, Bouchard-Côté, and Campbell. NeurIPS (2022). https://arxiv.org/abs/2206.00080. 
The Julia experiments from the paper can also be found in this repository.

**Note:** For a more up-to-date and distributed implementation of PT with a variational reference, please visit our 
Pigeons.jl repo: https://github.com/Julia-Tempering/Pigeons.jl.


## Installation
1. Make sure you have the R "mcmcse" package installed. In R, run
```
devtools::install_version("mcmcse", version = "1.5-0", repos = "http://cran.us.r-project.org")
```
(You will need to have `devtools` installed. If not, run `install.packages('devtools')` first.)

2. Clone this repository and navigate to the folder. 

3. Run `julia --project` (sets the workspace).

4. Run
```julia
pkg> activate .
pkg> instantiate
```

(*Troubleshooting:* If there are any issues in the above process, running `Pkg.update()` might help. 
Be sure to check that the R `mcmcse` package is installed in the same directory as the location for
R used by Julia (`ENV["R_HOME"]`).
Additionally, running from VSCode instead of from terminal is more reliable 
for creating plots.)


## NRPT and variational PT comparisons
Once you have completed the steps above, you can run any one of the examples
- Challenger
- Elliptic
- Product
- Simple-Mix
- Titanic
- Transfection

by running
```julia
include("scripts/<example_name>.jl")
```
where `<example_name>` is replaced with `Challenger`, `Elliptic`, etc. The results
will be stored in a new `results/` folder.


## Markovian score climbing (MSC) experiments
To run the MSC experiments,
```julia
include("scripts/Train MSC Reference.jl")
```
Note that to run the MSC experiments you will need to have the `transfection.csv` data set in the `data` folder.
Instructions for obtaining the data are provided in that folder.


## Other experiments
Most of the other experiments are included in the https://github.com/UBC-Stat-ML/bl-vpt-nextflow repository.
Some additional details for running the `Lip Cancer`, `Pollution`, and `Vaccines` examples are included in the `scripts` folder.
