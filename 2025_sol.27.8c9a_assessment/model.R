## Run analysis, write model results

## Before: input data for LBI, LBSPR and MLZ
## After: indicators, plots and table

# Load required libraries
library(MLZ)
library(readxl)
library(officer)
library(LBSPR) 
library(ggplot2)
library(icesTAF)
library(tidyverse)
library(reshape2)
library(flextable)
library(conflicted)
library(cat3advice)

conflicts_prefer(dplyr::filter)
conflicts_prefer(dplyr::mutate)
conflicts_prefer(dplyr::summarize)
conflicts_prefer(reshape2::melt)
conflicts_prefer(dplyr::arrange)


# Ensure output folders exist
mkdir("output")
mkdir("output/LBI")
mkdir("output/LBSPR")
mkdir("output/MLZ")


source("boot/initial/software/utilities_vpaz.R")
source("mod_01_LBI.R")
source("mod_02_LBSPR.R")
source("mod_03_MLZ.R")
source("mod_04_rfb.R")
