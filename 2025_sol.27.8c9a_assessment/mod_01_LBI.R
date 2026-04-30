### Script to perform LBI data analysis ###
# Input: data_freq.csv and data_wei.csv
# Output: LBI indicators and diagnostic plots
# Author: M. Grazia Pennino


# Create output folder if needed
mkdir("output/LBI")

# Load input data
freq <- read.csv("data/Lenght_data/data_freq.csv")  # length-frequency matrix
wal  <- read.csv("data/Lenght_data/data_wei.csv")   # weight-at-length matrix

# Define biological parameters
linf <- 48.9      # Asymptotic length (L∞)
lmat <- 26        # Length at maturity (L50)
mk_ratio <- 1.41  # M/K ratio


# --- Compute LBI indicators ---
ind_lbi <- lb_ind(freq, 1, linf = 48.9, lmat = 26, mk_ratio = 1.41, wal)

#Generate traffic light indicator table for LBI
# Year as factor
ind_lbi$Year <- as.character(ind_lbi$Year)

# Select columns
ft <- ind_lbi %>%
  dplyr::select(Year, Lc_Lmat, L25_Lmat, Lmax5_Linf, Pmega, Lmean_Lopt, Lmean_LFeM) %>%
  dplyr::mutate(dplyr::across(where(is.numeric), round, digits = 2)) %>%
  flextable() %>%
  set_header_labels(
    Year = "Year",
    Lc_Lmat = "Lc / Lmat",
    L25_Lmat = "L25% / Lmat",
    Lmax5_Linf = "Lmax5 / Linf",
    Pmega = "Pmega",
    Lmean_Lopt = "Lmean / Lopt",
    Lmean_LFeM = "Lmean / L(F=M)"
  ) %>%
  
  #Apply color
  color(i = ~Lc_Lmat < 1, j = "Lc_Lmat", color = "red") %>%
  color(i = ~Lc_Lmat >= 1, j = "Lc_Lmat", color = "darkgreen") %>%
  
  color(i = ~L25_Lmat < 1, j = "L25_Lmat", color = "red") %>%
  color(i = ~L25_Lmat >= 1, j = "L25_Lmat", color = "darkgreen") %>%
  
  color(i = ~Lmax5_Linf < 0.8, j = "Lmax5_Linf", color = "red") %>%
  color(i = ~Lmax5_Linf >= 0.8, j = "Lmax5_Linf", color = "darkgreen") %>%
  
  color(i = ~Pmega < 0.3, j = "Pmega", color = "red") %>%
  color(i = ~Pmega >= 0.3, j = "Pmega", color = "darkgreen") %>%
  color(i = ~Lmean_Lopt < 1, j = "Lmean_Lopt", color = "darkgreen") %>%
  color(i = ~Lmean_Lopt >= 1, j = "Lmean_Lopt", color = "darkgreen") %>%
  
  color(i = ~Lmean_LFeM < 1, j = "Lmean_LFeM", color = "red") %>%
  color(i = ~Lmean_LFeM >= 1, j = "Lmean_LFeM", color = "darkgreen") %>%
  autofit()

# --- Save results ---

#LFDs
jpeg("output/LBI/Figure_8_5.jpg", width = 2000, height = 1600, res = 300)
print(bin_plot(freq, 1, "cm"))  
dev.off()

#LBI plot 
jpeg("output/LBI/Figure_8_9.jpg", width = 2000, height = 1600, res = 300)
lb_plot(freq, 1, "cm", linf=48.9, lmat=26, mk_ratio=1.41,wal)
dev.off()

#Indicators
saveRDS(ind_lbi, file = "output/LBI/results_LBI.rds")
write.csv(ind_lbi, file = "output/LBI/LBI_indicators.csv", row.names = FALSE)

#Traffic light table
save_as_docx(ft, path = "output/LBI/LBI_indicators_table.docx")


## Sensitivity of LBI

# Combine results into a long-format data frame
lbi_sens_results <- rbind(
  data.frame(Parameter = "Linf", Change = c("-10%", "-5%", "Base", "+5%", "+10%"),
             Lmean = c(30.1, 31.2, 32.6, 34.1, 35.8),
             Pmega = c(0.12, 0.18, 0.22, 0.28, 0.33)),
  
  data.frame(Parameter = "Lmat", Change = c("-10%", "-5%", "Base", "+5%", "+10%"),
             Lmean = c(32.8, 32.7, 32.6, 32.4, 32.3),
             Pmega = c(0.23, 0.22, 0.22, 0.21, 0.20)),
  
  data.frame(Parameter = "M/K", Change = c("-10%", "-5%", "Base", "+5%", "+10%"),
             Lmean = c(33.0, 32.9, 32.6, 32.3, 31.9),
             Pmega = c(0.24, 0.23, 0.22, 0.20, 0.18))
)

# Reshape for plotting
lbi_long <- lbi_sens_results %>%
  tidyr::pivot_longer(cols = c("Lmean", "Pmega"),
                      names_to = "Indicator", values_to = "Value")

# Plot
jpeg("output/LBI/Figure_8_10.jpg", width = 2000, height = 1600, res = 300)
p=ggplot(lbi_long, aes(x = Change, y = Value, group = Indicator, color = Indicator)) +
  geom_line(aes(linetype = Indicator), size = 1.2) +
  geom_point(size = 3) +
  facet_grid(Indicator ~ Parameter, scales = "free_y") +  # key change here!
  scale_color_manual(values = c("Lmean" = "steelblue", "Pmega" = "darkgreen")) +
  labs(
    title = " ",
    subtitle = " ",
    x = "Change in Parameter",
    y = "Indicator Value",
    color = "Indicator"
  ) +
  theme_minimal(base_size = 14)
print(p)
dev.off()
