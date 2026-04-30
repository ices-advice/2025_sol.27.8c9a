### report.R — TAF reporting script for exploratory catch plots ###

library(ggplot2)
library(dplyr)
library(readr)
library(icesTAF)
library(tidyverse)
library(flextable)
library(officer)


# Create output folder
mkdir("report")


source('rep_01_plots.R')
source('rep_02_table.R')