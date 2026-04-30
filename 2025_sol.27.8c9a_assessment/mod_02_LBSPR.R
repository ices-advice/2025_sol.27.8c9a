### Script to perform LBSPR data analysis ###
# Input: data_freq.csv (length-frequency matrix)
# Output: LBSPR indicators, diagnostic plot, and RDS file with model results
# Author: M. Grazia Pennino

# Create output folder if needed
mkdir("output/LBSPR")

# --- Load input data ---
# This file contains the length-frequency data (rows = length bins, columns = years)
freq <- read.csv("data/Lenght_data/data_freq.csv")

# --- Define reference biological parameters for Solea solea ---
# Create an LB_pars object with known life-history parameters
Solea1Pars <- new("LB_pars")
Solea1Pars@Linf   <- 48.9    # Asymptotic length (L∞) in cm
Solea1Pars@L50    <- 26      # Length at 50% maturity (L50)
Solea1Pars@L95    <- 27.5    # Length at 95% maturity (L95)
Solea1Pars@MK     <- 1.41    # M/K ratio (natural mortality / growth rate)
Solea1Pars@L_units <- "cm"   # Length unit used in the data

# --- Prepare length-frequency data for LBSPR model ---
# Create an LB_lengths object using the parameters and the data
SoleaLenFreq1 <- new("LB_lengths",
                     LB_pars = Solea1Pars,
                     file = "data/Lenght_data/data_freq.csv",
                     dataType = "freq",
                     header = TRUE)

# Ensure units match between parameter and data objects
SoleaLenFreq1@L_units <- Solea1Pars@L_units

# --- Fit the LBSPR model ---
# Estimate SPR and selectivity parameters
Fit1 <- LBSPRfit(Solea1Pars, SoleaLenFreq1, verbose = FALSE)

# --- Save diagnostic plot of LBSPR results ---
# Generates a visual summary of SPR, selectivity curve, and comparison to reference points
jpeg("output/LBSPR/Figure_8_11.jpg", width = 2000, height = 1600, res = 300)
plotEsts(Fit1)
dev.off()

# --- Save full model results as RDS ---
# This R object can be loaded later for reporting or additional analyses
saveRDS(Fit1, file = "output/LBSPR/results_LBSPR.rds")
