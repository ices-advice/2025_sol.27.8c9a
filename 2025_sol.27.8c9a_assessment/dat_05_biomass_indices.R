### Script to combine biomass indices ###

# Input: Excel LPUE from portugal and txt from INLA.
#
# Output: file with biomass indeces.
#
# Authors: M. Grazia Pennino

# For saving results!
mkdir("data/Biomass")

rm(list=ls())

#0. Load data
Bayes <-  read.csv("boot/data/Biomass_indices/Bayes.txt", sep=";")
PT_LPUE <- read_excel("boot/data/Biomass_indices/PT_LPUE.xlsx")


# 1. Select and rename relevant columns from the Portuguese LPUE
pt_clean <- PT_LPUE %>%
  select(
    Year,
    Portuguese_LPUE = `LPUE (kg/trip)`,
    LPUE_Lower = `Lower bound (95%)`,
    LPUE_Upper = `Upper bound (95%)`
  )

# 2. Rename columns from Spanish Bayesian index
bayes_clean <- Bayes %>%
  rename(
    Year = year,
    Spanish_Index = pred
  )

# 3. Create full year sequence
years <- data.frame(Year = 2001:2024)

# 4. Merge all indices
final_df <- years %>%
  left_join(pt_clean, by = "Year") %>%
  left_join(bayes_clean, by = "Year")


# 5. Save the final combined table as a CSV file
write.csv(final_df, "data/Biomass/Combined_Indices_SOL_8c9a.csv", row.names = FALSE)
