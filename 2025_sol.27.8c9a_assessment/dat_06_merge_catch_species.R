### Script to combine Soleidae species catches ###

# Input: cvs by species.
#
# Output: file with Soleidae catches.
#
# Authors: M. Grazia Pennino

# For saving results!
mkdir("data/Other_Soleidae")

rm(list=ls())

# List all .csv files
files <- list.files("boot/data/Other_Soleidae", pattern = "\\.csv$", full.names = TRUE)

# Read and tag each file properly
catch_data <- lapply(files, function(f) {
  df <- read_csv2(f, skip = 1, col_names = c("Year", "Catch", "Country"))  # Skip first row (manual header)
  species <- sub("_catch_.*\\.csv$", "", basename(f))
  df$Species <- gsub("_", " ", species)
  
  # Remove commas and convert Catch to numeric
  df <- df %>%
    mutate(
      Catch = as.numeric(gsub(",", "", Catch)),
      Year = as.integer(Year)
    )
  
  df
})

# Combine all datasets
total_catch <- bind_rows(catch_data)

# Save the result
write.csv(total_catch, "data/Other_Soleidae/total_catch.csv", row.names = FALSE)
