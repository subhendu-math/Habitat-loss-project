# Install and load necessary packages
# install.packages(c("ggplot2", "gridExtra", "cowplot", "dplyr", "RColorBrewer", "paletteer"), dependencies = TRUE)

# Load necessary libraries
library(ggplot2)
library(gridExtra)
library(cowplot)
library(dplyr)
library(RColorBrewer)  # For color palettes
library(paletteer)     # For additional color palettes

# Set color palette for different network types
pal_networks <- paletteer_d("rcartocolor::Safe")  # Example palette, customize as needed
#########################To make data file#########################################
# Parameters
tmax <- 1000  # maximum number of timesteps
cr <- 0.1     # colonisation - resource
cc <- 0.1     # colonisation - consumer
er <- 0.1     # extinction - resource
ec <- 0.1     # extinction - consumer
r1 <- seq(0, 6, by = 0.3)  # range of parameter values
f<-seq(0,1,by=0.05)
interaction_networks <- c("M_PL_010")
# Initialize an empty list to store plots
plot_list <- list()
#A1 <- data.frame()
# Iterate through interaction networks
for (interaction_network in interaction_networks) {
  setwd("~/Evolution_work_20feb/Data/interaction_networks")
  A1 <- data.frame()
  # Read M_inc file
  file_path <- paste0("Minc_", interaction_network, ".csv")
  M_inc <- read.table(file_path, sep = ' ', header = FALSE)
  p<-nrow(M_inc)
  a<-ncol(M_inc)
  # Assuming M_inc is your incidence matrix
  # Calculate row sums (e.g., Plants) and column sums (e.g., Animals)
  row_sums <- rowSums(M_inc)      # Replace with appropriate label if needed
  col_sums <- colSums(M_inc)      # Replace with appropriate label if needed
  
  # Combine the degrees into a single vector
  all_degrees <- c(row_sums, col_sums)
  
  # Create a corresponding vector of labels
  # Adjust the labels based on your specific data representation
  labels <- c(rep("Plant", length(row_sums)), rep("Animal", length(col_sums)))
  
  # Create the data frame
  Species_Degree_df <- data.frame(
    Degree = all_degrees,
    Type = labels
  )
  
  # Optionally, rename the columns for clarity
  colnames(Species_Degree_df) <- c("Degree", "Type")
  
  
  
  
  # Set output path
  setwd("~/Evolution_work_20feb/Output_28oct")
  
  # Read the CSV file line by line for er and ec
  lines_er <- readLines("e_r.csv")
  lines_ec <- readLines("e_c.csv")
  
  
  # Loop over the values of k (1 to 5 for the network types)
  for (k in 1:3) {
    network_type <- c("grid", "random", "scalefree")[k]
    
    # Initialize a master data frame to store all data across ii and jj loops
    master_data <- data.frame()
    
    # Loop over the values of jj and ii for extinction and colonization probabilities
    for (jj in 1:length(r1)) {
      for (ii in 1:length(r1)) {
        
        # Extinction and colonization probabilities
        er <- lines_er[ii + 1]
        ec <- lines_ec[jj + 1]
        
        # Generate the full file name for the current er, ec combination
        full_filename <- paste0("nonrandom_dt_mutualism_", interaction_network, "_", network_type, "_er", er, "_ec", ec, "_cr", cr, "_cc", cc, ".csv")
        
        # Read the data from the CSV file
        data <- read.csv(full_filename, header = TRUE, sep = ",")
        
        # Initialize A2 as an empty data frame before the loop over i (species indices)
        A2 <- data.frame()
        
        # Process resources for specific fraction values (i = 5, 10, 15)
        # for (i in c(5, 10, 15)) {
        for (i in 1:length(f)) { 
          # Select the required rows from the data matrix
          start_resource <- p * (tmax - 900) * (i - 1) + p * (tmax - 900 - 1) + 1
          end_resource <- p * (tmax - 900) * (i - 1) + p * (tmax - 900)
          start_consumer <-p * (tmax - 900)*length(f)+ a * (tmax - 900) * (i - 1) + a * (tmax - 900 - 1) + 1
          end_consumer <- p * (tmax - 900)*length(f)+a * (tmax - 900) * (i - 1) + a * (tmax - 900)
          data_slice <- c(data[start_resource:end_resource, 4],data[start_consumer:end_consumer, 4])
          
          # Check if data_slice length matches existing A2 rows
          if (nrow(A2) == 0) {
            # If A2 is empty, initialize it with data_slice
            A2 <- data.frame(data_slice)
            # Name the column based on i
            colnames(A2) <- paste0("Abundance_", i)
          } else {
            # If A2 already has data, add a new column
            A2 <- cbind(A2, data_slice)
            # Name the new column based on i
            colnames(A2)[ncol(A2)] <- paste0("Abundance_", i)
          }
        }
        
        # After processing for i, append the current A2 to the master_data
        master_data <- rbind(master_data, A2)
      }
    }
    
    # For each network type, process data for each i value (5, 10, 15)
    #  for (i in c(5, 10, 15)) {
    for (i in 1:length(f)) {
      # Perform the study for each species
      for (iiii in 1:(p+a)) {
        
        # Calculate the probability of abundance being greater than zero
        indices <- seq(iiii, nrow(master_data), by = (p+a))  # Select rows corresponding to the current species and i value
        
        # Extract the relevant column for the current value of i
        col_name <- paste0("Abundance_", i)
        
        # Calculate the probability that abundance > 0
        prob_greater_than_zero <- sum(master_data[indices, col_name] > 0) / length(indices)
        
        # Create a temporary data frame for the results for the current i value
        temp_data1 <- data.frame(Species = iiii,
                                 Network_Type = network_type,
                                 Probability = prob_greater_than_zero,
                                 Species_Degree = Species_Degree_df$Degree[iiii],
                                 Species_Type = Species_Degree_df$Type[iiii],
                                 Fraction = i,
                                 Interaction_Network = interaction_network)  # Include interaction network
        
        # Append the results for the current species and i value to A1
        A1 <- rbind(A1, temp_data1)
      }
    }
  }
  write.csv(A1, paste0("nonrandom_probability_", interaction_network, ".csv"))
}