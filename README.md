# Landscape configuration and community structure jointly determine the persistence of mutualists under habitat loss


This project models and visualizes the effects of habitat loss on mutualistic networks using Julia for simulation and R for data visualization. It includes time series analysis, spatial networks, and extinction-colonization dynamics.


## `Code`
All code was created in either Julia version 1.4.2 or R version 3.6.2.

### 1. Run habitat destruction simulations with spatially explicit metacommunity models

- `Code/Code_tseries/run_mutualistic.jl`  
  Main Julia script to simulate mutualistic dynamics under habitat loss

- Supporting Julia functions used in simulations:
  - `functions_extinction_colonisation_mutualistic.jl` – extinction-colonization dynamics
  - `functions_habitat_destruction.jl` – applies habitat loss
  - `functions_master.jl` – main execution controller
  - `functions_setup.jl` – initializes simulations

This script simulates mutualistic metacommunity dynamics under habitat loss.

---

## Simulation parameters

The following parameters are set inside the script but can be modified by the user:

- **Spatial networks (`spatialNetwork`)**: choose from `"grid"`, `"scalefree"`, `"random"`  
- **Interaction networks (`interactionNetwork`)**: e.g. `"M_SD_002"`, `"M_SD_005"`, …  
- **Replicates (`replicate`)**: integer index for independent runs  
- **Colonization rates (`c_r`, `c_c`)**: default is `0.1`  
- **Extinction/colonization ratio (`r1`)**: a range of values (`0:0.3:6` by default).  
  - Extinction rates are determined as:
    - `e_r = r1 * c_r` (resource extinction rate)  
    - `e_c = r1 * c_c` (consumer extinction rate)  
- **Habitat destruction type (`destruction`)**: `"random"` or `"nonrandom"`  
- **Other parameters**:
  - `tmax` = maximum number of timesteps (default: 1000)  
  - `dD` = fraction of patches destroyed at each step (default: 0.05)  

---
## Run the script with multiple processes

Use Julia’s -p flag to specify the number of processes. For example, to run with 2 processes:
`julia -p 2 run_mutualistic.jl`

## Example setup inside the script

At the bottom of `run_mutualistic.jl`, the following command controls which networks and replicates are run:

 ``` pmap( run_parallel, repeat(["grid","scalefree","random"], n_sim), repeat(["M_SD_002"], n_sim*3),  repeat(collect(1:10), inner=3)  ) ```
## Output files

Simulation outputs are saved in the folder `Output_28oct/`.  

Each output file is named as:
random_dt_mutualism_<interactionNetwork>_<spatialNetwork>_er<e_r>_ec<e_c>_cr<c_r>_cc<c_c>_replicate<rep>.csv
### 2. Postprocess results and generate plots

#### Figure 2: Probability of species survival under habitat loss

- `Code/Fig2_plot/Fig2_plot.r` – generates main plot
- `nonrandom_timeseries_to_average_probability.r` – Calculate probability from time series data (Spatially correlated)
- `random_timeseries_to_average_probability.r` – Calculate probability from time series data (Spatially uncorrelated)
- `nonrandom_merge_data.r`, `random_merge_data.r` – merges result datasets

#### Figure 3: Structural effects on species persistence

- `Code/Fig3_plot/Fig3_plot.r` – produces plot for structural analysis
## Workflow to Reproduce Figures

To reproduce Manuscript Figure 2:

1. Run:
   - `random_timeseries_to_average_probability.r`
   - `random_merge_data.r`
   - `nonrandom_timeseries_to_average_probability.r`
   - `nonrandom_merge_data.r`

2. Then run:
   - `Code/Fig2_plot/Fig2_plot.r`

To reproduce Manuscript Figure 3:

1. Ensure processed data from previous step exists.
2. Run:
   - `Code/Fig3_plot/Fig3_plot.r`

---

## `Data`

This directory contains spatial networks, metanetwork structures, and output from simulations. It is divided into subdirectories:

- `Fig2/` – contains processed CSV and RDS files for nonrandom mutualistic network simulations
- `spatial_networks` – For spatial networks
- `interaction_networks`- For empirical mutualistic network
- Other files and folders store incidence matrices, and intermediate outputs
  
All scripts assume the working directory is the root of the repository.
