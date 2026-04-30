### Script to perform MLZ data analysis (ML and MLeffort models) ###
# Inputs: 
#   - data_freq.csv (length-frequency matrix)
#   - Solea_solea_catch_2009_2024.csv (catch data)
#   - PT_LPUE.xlsx (LPUE index)
# Outputs:
#   - MLZ model objects (.rds)
#   - Fishing mortality timeseries (.csv)
#   - Diagnostic plots (.png)
# Author: M. Grazia Pennino

# --- Create output folder ---
mkdir("output/MLZ")

# --- Load and reshape length-frequency data ---
freq_data <- read.csv("data/Lenght_data/data_freq.csv")

# Ensure the column name is correct
stopifnot("MeanLength" %in% colnames(freq_data))

# Convert wide to long format
freq_long <- freq_data %>%
  pivot_longer(
    cols = -MeanLength,
    names_to = "Year",
    values_to = "Frequency"
  ) %>%
  mutate(
    Year = as.numeric(gsub("X", "", Year))
  ) %>%
  filter(Frequency > 0)

# Expand frequency data to individual fish records
expanded_data <- freq_long %>%
  rowwise() %>%
  do(data.frame(
    Year = rep(.$Year, round(.$Frequency)),
    Length = rep(.$MeanLength, round(.$Frequency))
  )) %>%
  ungroup()

# --- Compute mean length per year (optional) ---
mean_length_data <- expanded_data %>%
  group_by(Year) %>%
  summarise(MeanLength = mean(Length)) %>%
  ungroup()

# --- Create MLZ_data object for ML analysis ---
years_available <- sort(unique(expanded_data$Year))

my_data <- new("MLZ_data",
               Year = years_available,
               Len_df = expanded_data,
               length.units = "cm")

# --- Set biological parameters ---
my_data@vbLinf <- 48.9   # Asymptotic length (cm)
my_data@vbK    <- 0.22   # Growth rate (from literature)
my_data@Lc     <- 27.5   # Length at first capture
my_data@vbt0   <- 0      # t0 assumed 0

# Calculate annual mean length above Lc
my_data <- calc_ML(my_data)

# --- Fit ML model (Beverton-Holt) ---
model1 <- ML(my_data, ncp = 1)
saveRDS(model1, file = "output/MLZ/results_MLZ.rds")

# Plot ML model results
jpeg("output/MLZ/Figure_MLZ.jpg", width = 2000, height = 1600, res = 300)
plot(model1)
dev.off()

# ======================
# PART 2: MLeffort MODEL
# ======================

# --- Load catch and effort data ---
data_catch <- read.csv("data/catch/combined_catch_SOL_8c9a.csv")
biomass_in <- read_csv("data/Biomass/Combined_Indices_SOL_8c9a.csv")

# Step 1: Summarize catch per year
total_catch <- data_catch %>%
  group_by(Year) %>%
  summarise(Total_Catch = sum(Catch_t, na.rm = TRUE), .groups = "drop")

# Step 2: Get LPUE values from Portuguese index (not NA)
lpue_df <- biomass_in %>%
  select(Year, LPUE = Portuguese_LPUE) %>%
  filter(!is.na(LPUE))

# Step 3: Merge with total catches and compute effort
effort_df <- left_join(lpue_df, total_catch, by = "Year") %>%
  mutate(Effort = round(Total_Catch / LPUE, 2)) %>%
  filter(!is.na(Effort) & is.finite(Effort))

# --- Create new MLZ_data object for MLeffort ---
my_data_effort <- my_data
my_data_effort@Year <- effort_df$Year
my_data_effort@Effort <- effort_df$Effort
my_data_effort@M <- 0.31  # Natural mortality (Cerim et al., 2020)
my_data_effort@vbt0 <- 0  # t0

# Guess initial catchability
q0 <- 0.2 / mean(my_data_effort@Effort)

# --- Fit MLeffort model ---
res_effort_fixedM <- MLeffort(
  my_data_effort,
  start = list(q = q0),
  n_age = 24,
  estimate.M = FALSE,
  n_season = 1,
  obs_season = 1,
  timing = 0.5
)

# --- Save outputs ---
df_F <- res_effort_fixedM@time.series
saveRDS(res_effort_fixedM, "output/MLZ/results_MLeffort.rds")
write.csv(df_F, "output/MLZ/F_MLeffort.csv", row.names = FALSE)

# --- Plot Fishing Mortality over time ---
jpeg("output/MLZ/Figure_8_12.jpg", width = 2000, height = 1600, res = 300)
p=ggplot(df_F, aes(x = Year, y = F)) +
  geom_line(color = "#d95f02", size = 1.2) +
  geom_point(color = "#d95f02", size = 2.5) +
  labs(
    title = "Fishing Mortality (F) estimated by MLeffort",
    x = "Year",
    y = "Fishing Mortality (F)"
  ) +
  theme_minimal()
print(p)
dev.off()