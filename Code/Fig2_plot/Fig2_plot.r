
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

# Fit linear model for each group and extract required information
results <-  df_summary %>% 
  ungroup() %>% 
  group_by(Network_Type, Fraction,habitat_loss) %>% 
  do({
    model <- lm(average_probability ~ nest_zscore, data = .)  # Linear model
    model_summary <- tidy(model)   # Extract model coefficients and p-values
    conf_int <- confint(model)     # Confidence intervals
    
    # Extract slope estimate, CI, and p-value for slope
    data.frame(
      slope_estimate = model_summary$estimate[2],
      slope_p_value = model_summary$p.value[2],
      slope_ci_lower = conf_int[2, 1],
      slope_ci_upper = conf_int[2, 2]
    )
  })

results <- results %>% 
  mutate(significant = if_else(slope_p_value < 0.05, "Significant", "Not Significant"))
pd = position_dodge(0.04)
# View the results
Fig2 <- ggplot(data = results %>%  filter(Fraction %% 2 != 0) %>%
                  mutate(Fraction = (Fraction - 1)/20), 
                aes(x = Fraction, y = slope_estimate,color=habitat_loss)) + 
  # geom_point(stroke = 1.5, alpha = 0.7) + 
  geom_errorbar(aes(ymin = slope_ci_lower, ymax = slope_ci_upper),  position=pd) + 
  geom_point(position=pd, size=2)+
  facet_grid(~Network_Type, labeller =  as_labeller(c(`grid` = "Grid", `random` = "Random", `scalefree` = "Scale-free",`Correlated` = "Correlated", `Uncorrelated` = "Uncorrelated"))) +
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
  #ylim(0, 0.085)+
  labs(
    title = " ",
    x = "Habitat Loss",
    y = "Effect of Nestedness \n on Persistence  ",
    color = "Habitat Loss Pattern"  # Change legend title
  ) 





p2 <-df_summary %>%
  filter(habitat_loss %in% "Uncorrelated") %>%
  filter(Fraction %in% c(3), Network_Type %in% c('grid')) %>%
  mutate(Fraction = (Fraction - 1) / 20) %>%
  ggplot(aes(x = nest_zscore, y = average_probability)) +
  geom_jitter(size = 1) +  # Smaller points
  geom_smooth(method = "lm", color = "Black") +
  theme_minimal(base_size = 2) +  # Smaller base font size
  theme(aspect.ratio = 1,
    panel.grid = element_blank(),
    panel.background = element_rect(fill = "white"),
    plot.title = element_text(size = 2),  # Smaller title
    axis.title = element_text(size = 2),  # Smaller axis titles
    axis.text = element_text(size = 2),  # Smaller axis ticks
    strip.text = element_text(size = 2)  # Smaller facet label text
  ) +
  scale_y_continuous(
    breaks = scales::pretty_breaks(n = 3)  # Ensure only 3 labels on y-axis
  ) +
  labs(
    title = " ",
    x = "Nestedness",
    y = "Persistence",
    color = "Fraction of Habitat Loss"
  )


# Fig2c<-Fig2c +
#   inset_element(p2, 0.13, 0.54, 0.32, 0.79) +
#   theme_classic()
#   (p2,0.13, 0.55, 0.32, 0.99)
# ggsave("Fig2_final.pdf", plot = Fig2c, width = 15, height = 10)

Fig2a<-Fig2 +
  inset_element(p2,0.49, 0.57, 0.64, 0.99)+
  theme_classic()

#Fig2

setwd("~/Evolution_work_20feb/Output_14june/Output_14oct/nonrandom_probability/Fig2")
ggsave("Fig2_final.pdf", plot = Fig2a, width = 10, height = 5)

