# Compute weight distribution matrix from length frequencies
# Input: data_freq.csv
# Output: data_wei.csv

mkdir("data/Lenght_data")

# Load input data
dat <- read.csv("data/Lenght_data/data_freq.csv")

# Check structure
stopifnot("MeanLength" %in% colnames(dat))  # corregido

# Weight-length parameters
a <- 0.00759
b <- 3.06

# Compute weights
lengths <- dat$MeanLength
weights <- a * lengths^b

# Build matrix with weights per length bin
W <- dat
nyears <- ncol(dat) - 1
for (i in 1:nyears) {
  W[, i + 1] <- weights
}

# Save result
write.csv(W, "data/Lenght_data/data_wei.csv", row.names = FALSE)
message("✅ Saved data/Lenght_data/data_wei.csv")
