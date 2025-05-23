# Load necessary packages
library(dplyr)
library(broom)
library(patchwork)
# Example dataframe (replace with your actual data)
setwd("~/Evolution_work_20feb/Output_14june/Output_14oct/nonrandom_probability/Fig1/Data")
df <-read.csv("nonrandom_total_data_fig3.csv", header = TRUE)
df1 <-read.csv("random_total_data_fig3.csv", header = TRUE)
df<-df%>% mutate(habitat_loss="Correlated")
df1<-df1%>% mutate(habitat_loss="Uncorrelated")
df<-rbind(df,df1)
df_summary <- df %>%
  filter(Network_Type %in% c("grid","random","scalefree")) %>%
  group_by(Interaction_Network, Fraction, Network_Type, nest_zscore,habitat_loss) %>%
  summarise(average_probability = mean(Probability))

custom_colors <- c(
  "Correlated" = "#4393C3FF",  # Replace with actual habitat_loss levels and desired hex colors
  "Uncorrelated" = "#F4A582FF"
)

pd = position_dodge(0.02)
Fig1<- ggplot(
  data = df_summary %>%
    mutate(Fraction = as.factor((Fraction - 1)/20)),
  aes(x = Fraction, y = average_probability,color=habitat_loss),  position=pd)+
  geom_boxplot() +
  facet_grid(~Network_Type, labeller = as_labeller(c(`grid` = "Grid", `random` = "Random", `scalefree` = "Scale-free",`Correlated` = "Correlated", `Uncorrelated` = "Uncorrelated"))) +
 # labs(x = "Fraction", y = "Average Probability", color = "Habitat Loss") +
  scale_color_manual(values = custom_colors) +
  scale_x_discrete(breaks = c("0", "0.25", "0.5", "0.75", "1")) +  # Show only specific labels on the x-axis
  theme_minimal()+
  # Set background to white
  theme_minimal(base_size = 18) +  # Increase base font size
  # Customize plot theme
  theme(
    aspect.ratio = 1,
    panel.grid = element_blank(),  # Remove gridlines
    panel.background = element_rect(fill = "white"),  # White background
    plot.title = element_text(size = 18, face = "bold"),  # Larger title size
    axis.title = element_text(size = 18),  # Larger axis titles
    axis.text = element_text(size = 14),  # Larger axis text
    strip.text = element_text(size = 16),  # Larger facet label text
    legend.position = "bottom"  # Place legend below the x-axis
  ) +
  guides(color = guide_legend(ncol = 3)) +  # Arrange legend items in three columns
  labs(
    title = " ",
    x = "Habitat Loss",
    y = "Persistence",
    color = "Habitat Loss Pattern"  # Change legend title
    )



setwd("~/Evolution_work_20feb/Output_14june/Output_14oct/nonrandom_probability/Fig1")

ggsave("Fig1_final.pdf", plot = Fig1, width = 10, height = 5)



