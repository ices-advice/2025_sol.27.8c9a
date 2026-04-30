# Build length distribution matrix with zero-filled bins
# Input: Size.csv (MeanLength in mm)
# Output: data_freq.csv (MeanLength in cm, bins 10.5–83.5 by 1 cm)

library(dplyr)

# Create output folder
mkdir("data/Lenght_data")

# Load input
data <- read.csv("data/Lenght_data/Size.csv")

# Convert MeanLength from mm to cm and shift bin by +0.5 (e.g., 120 → 12.5)
data$MeanLength <- (data$MeanLength / 10) + 0.5

# Round to nearest 1 cm bin to avoid float issues
data$MeanLength <- round(data$MeanLength, 1)

# Filter to expected range
data <- data[data$MeanLength >= 10.5 & data$MeanLength <= 83.5, ]

# Aggregate by MeanLength and Year
agg <- data %>%
  group_by(MeanLength, Year) %>%
  summarise(Number = sum(NumberLanded), .groups = "drop")

# Create full grid of expected lengths and years
lengths <- seq(10.5, 83.5, by = 1)
years <- sort(unique(data$Year))
full_grid <- expand.grid(MeanLength = lengths, Year = years)

# Merge with actual data and fill NAs with 0
full_data <- left_join(full_grid, agg, by = c("MeanLength", "Year"))
full_data$Number[is.na(full_data$Number)] <- 0

# Pivot to wide format: rows = MeanLength, columns = years
library(tidyr)
freq_wide <- pivot_wider(full_data, names_from = Year, values_from = Number)
freq_wide <- as.data.frame(freq_wide)

# Safety check: should be 74 bins
stopifnot(nrow(freq_wide) == length(lengths))

# Save to file
write.csv(freq_wide, "data/Lenght_data/data_freq.csv", row.names = FALSE)
message("✅ Saved data/Lenght_data/data_freq.csv")
