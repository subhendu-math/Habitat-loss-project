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

### 2. Postprocess results and generate plots

#### Figure 1: Probability of species survival under habitat loss

- `Code/Fig1_plot/Fig1_plot.r` – generates main plot
- `nonrandom_timeseries_to_average_probability.r` – Calculate probability from time series data (Spatially correlated)
- `random_timeseries_to_average_probability.r` – Calculate probability from time series data (Spatially uncorrelated)
- `nonrandom_merge_data.r`, `random_merge_data.r` – merges result datasets

#### Figure 2: Structural effects on species persistence

- `Code/Fig2_plot/Fig2_plot.r` – produces plot for structural analysis

---

## `Data`

This directory contains spatial networks, metanetwork structures, and output from simulations. It is divided into subdirectories:

- `Fig1/` – contains processed CSV and RDS files for nonrandom mutualistic network simulations
- `spatial_networks` – For spatial networks
- `interaction_networks`- For empirical mutualistic network
- Other files and folders store incidence matrices, and intermediate outputs
