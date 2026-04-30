## Preprocess data 
##
## Before: Catch, length frequency, biomass indices in boot/data/
## After: Files needed to run LBI/lbspr model (e.g., Size.csv, data_freq.csv, data_wei.csv, catch tables, etc.)
##
## Author: M. Grazia Pennino

# Load TAF and other necessary libraries
library(icesTAF)
library(dplyr)
library(readr)
library(readxl)


# Ensure output folders exist
mkdir("data")
mkdir("data/catch")
mkdir("data/Lenght_data")
mkdir("data/Biomass")
mkdir("data/Other_Soleidae")

# Run sequential data preparation scripts

# 1. Combine historical + 2024 catch data (Intercatch overview)
source("dat_01_intercatch.R")

# 2. Prepare tidy long-format length data from Intercatch files
source("dat_02_prepare_length_data.R")

# 3. Build length distribution matrix
source("dat_03_build_length_distribution.R")

# 4. Compute weight-at-length matrix
source("dat_04_compute_weight_distribution.R")

# 5. Combine biomass indices (LPUE PT and INLA ES)
source("dat_05_biomass_indices.R")

# 6. Merge Soleidae species catch data from Other_Soleidae folder
source("dat_06_merge_catch_species.R")


