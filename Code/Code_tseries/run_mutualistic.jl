# load packages
using Distributed, Random, DelimitedFiles, DataFrames, CSV, Graphs, StatsBase
@everywhere using Distributed, Random, DelimitedFiles, DataFrames, CSV, Graphs, StatsBase

# load functions
@everywhere include("functions_master.jl")
@everywhere include("functions_setup.jl")
@everywhere include("functions_extinction_colonisation_mutualistic.jl")
@everywhere include("functions_habitat_destruction.jl")

# define function for running replicas and specify model inputs
@everywhere function run_parallel(spatialNetwork, interactionNetwork, replicate)
  
  # simulation parameters
  tmax = 1000   # maximum number of timesteps
  dD = 0.05    # fraction of patches destoryed at a time
  destruction = "random" # type of habitat destruction ("random" / "nonrandom")

  r1=0:0.3:6;
  # simulation parameters
  tmax = 1000   # maximum number of timesteps
  c_r = 0.1    # colonisation - resource
  c_c = 0.1    # colonisation - consumer

for j in 1:length(r1)
    for i in in 1:length(r1)
        # Extinction and colonization probabilities
        e_r = r1[i] * c_r    # Extinction - resource
        e_c = r1[j] * c_c    # Extinction - consumer

        # Construct the file path for output
        output_dir = "../../Output_28oct"
        filename = string(output_dir, "/random_dt_mutualism_", interactionNetwork, "_", spatialNetwork, 
                          "_er", e_r, "_ec", e_c, "_cr", c_r, "_cc", c_c,"_replicate",replicate, ".csv")
        
       # Check if the file already exists and if it's not empty
        if isfile(filename)
            file_stat = stat(filename)
            if file_stat.size > 0
                continue  # Skip this iteration if the file exists and has non-zero size
            end
        end

        # Run simulation (assuming dynamics is a predefined function)
        df_dt = dynamics(spatialNetwork, interactionNetwork, destruction, tmax, dD, e_r, e_c, c_r, c_c, replicate)

        # Create the output directory if it doesn't exist
        isdir(output_dir) || mkdir(output_dir)

        # Write out the simulation output to a CSV file
        CSV.write(filename, df_dt)
    end
end
end
#end
# number of simulations to run in parallel
n_sim = 10
# run simulations in parallel
# pmap(run_parallel, [spatialNetwork], [interactionNetwork], [replicate])
#"M_SD_002","M_SD_005","M_SD_007", "M_SD_008","M_SD_010", "M_SD_012","M_SD_014","M_SD_016","M_SD_025","M_SD_027"
# eg: to run n_sim=2 different spatial networks, and interactionNetwork="M_SD_025", do the following:
pmap(run_parallel, repeat(["grid","scalefree","random"],n_sim), repeat(["M_SD_002"],n_sim*3), repeat(collect(1:10),inner=3))

# Number of simulations to run in parallel
#n_sim = 8

#networks = c("M_SD_002", "M_SD_005","M_SD_007", "M_SD_008", "M_SD_010", "M_SD_012", "M_SD_014", "M_SD_016", "M_SD_025", "M_SD_027",  "M_PL_006", "M_PL_010","M_PL_025", "M_PL_033","M_PL_036", "M_PL_037", "M_PL_039", "M_PL_046", "M_PL_051", "M_PL_059","M_PL_061_33","A_HP_015","A_HP_042", "A_PH_004","A_PH_005")



# List of spatial networks and interaction networks
#spatialNetworks = ["random", "smallWorld05"]
#interactionNetworks = ["M_SD_002", "M_SD_005", "M_SD_007", "M_SD_010"]


# Create combinations of spatial and interaction networks
#combinations = [(spatialNetwork, interactionNetwork) for spatialNetwork in spatialNetworks for interactionNetwork in interactionNetworks]

# Run simulations in parallel using pmap
#pmap(x -> run_parallel(x[1], x[2]), combinations)

#################
# TO RUN THIS SCRIPT
# DO THE FOLLOWING IN THE COMMAND LINE
# CHANGE "2" TO NUMBER OF SIMULATIONS TO BE RUN IN PARALLEL
# julia -p 2 run_mutualistic.jl
