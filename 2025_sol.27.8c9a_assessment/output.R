# Input: combined index, catch, fishing pressure index
# Output: Table for standard graphs
# Author: M. Grazia Pennino


# Create output folder if needed
mkdir("output/SAG")

#Generate table for SAG

# Load data
all_catch <- read.csv("data/catch/combined_catch_SOL_8c9a.csv")

#summarize by  year
catch <- all_catch %>%
  group_by(Year) %>%
  summarise(Catch = sum(Catch_t, na.rm = TRUE), .groups = "drop") %>%
  arrange(Year)

# Load data
biomass <- read.csv("output/RFB/combined_index.csv")

# Load data
ind <- read.csv("output/LBI/LBI_indicators.csv")
Lmean_LFeM=ind$Lmean_LFeM
FishingPressure <- 1 / Lmean_LFeM


# Create fishing pressure dataframe
fp_data <- data.frame(
  Year = 2011:2024,
  Lmean_LFeM = Lmean_LFeM,
  FishingPressure = FishingPressure
)

# Merge all data by Year
combined_df <- biomass |>
  merge(fp_data, by = "Year") |>
  merge(catch, by = "Year")


# Save to CSV 
write.csv(combined_df, file = "output/SAG/combined_summary.csv", row.names = FALSE)
