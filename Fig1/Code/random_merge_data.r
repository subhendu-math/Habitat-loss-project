library(ggplot2)
library(reshape2)  # Ensure you have the reshape2 package for melt()
library(patchwork)
setwd("~/Evolution_work_20feb/Output_14june/Output_14oct/nonrandom_probability/Fig1/Data")
interaction_networks <- c("M_SD_002", "M_SD_005","M_SD_007", "M_SD_008",  "M_SD_010", "M_SD_012", "M_SD_014", "M_SD_016","M_SD_025", "M_SD_027", "M_PL_006","M_PL_010", "M_PL_025","M_PL_033","M_PL_036", "M_PL_037", "M_PL_039", "M_PL_046", "M_PL_051", "M_PL_059")
# Initialize A2 as an empty data frame
A1 <- data.frame()

# Loop through the interaction networks
for (interaction_network in interaction_networks) {
  
  # Construct the file name dynamically
  file_name <- paste0("random_probability_", interaction_network, ".csv")
  
  # Read the CSV file into A1
  A2 <- read.csv(file_name, header = TRUE)
  
  # Merge A1 into A2
  A1 <- rbind(A1, A2)
}



b <- readRDS("metanetwork_structure_final.Rds")
b <- b %>%
  rename(Interaction_Network = network)



# join A1 and b
A1 <- A1 %>% left_join(b)

A1 <- A1 %>% 
  mutate(
    ratio_resource_to_consumer = n_res/n_con,
    ratio_consumer_to_resource = n_con/n_res
  )

grey_fill_color <- "grey70"

# Ensure Interaction_Network levels match the palette names
network_palettes <- c(
  grid = "darkgreen",
  # kRegular = "darkblue",
  # smallWorld = "#800080",
  random = "#FF8C00",
  scalefree = "#8B0000"
)



write.csv(A1,"random_total_data_fig3.csv")