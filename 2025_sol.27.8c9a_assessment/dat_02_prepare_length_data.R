### Prepare long-format length data from InterCatch LFDs ###
# Output: data/Lenght_data/Size.csv
# Author: M. Grazia Pennino

# Create output folder
mkdir("data/Lenght_data")

# Define years and source directory
years <- 2011:2024
lfd_dir <- file.path("boot", "data", "LFDs nsample intercatch")

# Function to extract trailing digits from column names
substrRight <- function(x, n) substr(x, nchar(x)-n+1, nchar(x))

# Initialize list for all years
data_all <- list()

# Process each year's file
for (yr in years) {
  file_path <- file.path(lfd_dir, paste0(yr, ".csv"))
  message("Reading ", file_path)
  
  df <- read.csv(file_path, sep = ";", dec = ".")
  
  col_start <- 16
  len_cols <- colnames(df)[col_start:ncol(df)]
  mean_lengths <- as.numeric(substrRight(len_cols, 3))  # ← CORREGIDO aquí
  
  data_long <- do.call(rbind, lapply(seq_along(mean_lengths), function(i) {
    valid_rows <- which(df[[col_start + i - 1]] != 0)
    if (length(valid_rows) == 0) return(NULL)
    
    do.call(rbind, lapply(valid_rows, function(j) {
      data.frame(
        Year         = df[j, "Year"],
        MeanLength   = mean_lengths[i],
        Season       = df[j, "Season"],
        Fleets       = df[j, "Fleets"],
        Country      = df[j, "Country"],
        Area         = df[j, "Area"],
        NumberLanded = df[j, col_start + i - 1]
      )
    }))
  }))
  
  data_all[[as.character(yr)]] <- data_long
}

# Combine and save
data <- do.call(rbind, data_all)
write.csv(data, "data/Lenght_data/Size.csv", row.names = FALSE)
message("✅ Saved file: data/Lenght_data/Size.csv")
