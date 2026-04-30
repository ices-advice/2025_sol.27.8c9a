
### Script to read intercatch data ###

# Input: historical catches and intercatch files for the assessment year.
#
# Output: files for report.
#
# Authors: M. Grazia Pennino

# For saving results!
mkdir("data/catch")

rm(list=ls())

#----------------------------------------------------------------------------
# Combine historical catches with the ones of the assessment year 
#----------------------------------------------------------------------------


# 1. Read historical catch data
catches_hist <-read.csv("boot/data/Historical_catch/Catches.csv", sep=";")

# Convert comma decimal to dot and parse Catch..kg as numeric
catches_hist <- catches_hist %>%
  mutate(Catch..kg = gsub(",", ".", Catch..kg),
         Catch..kg = as.numeric(Catch..kg))

# 2. Read current assessment year catch data from StockOverview.txt
stock_2024 <- read.delim("boot/data/Catches/StockOverview.txt")

# 3. Clean and bind 2024 data to historical
catches_combined <- catches_hist %>%
  bind_rows(stock_2024)

# 4. Convert to tonnes
catches_combined$Catch_t=catches_combined$Catch..kg/1000

# 5. Save combined dataset
write_csv(catches_combined, "data/catch/combined_catch_SOL_8c9a.csv")

#--------------------------------------
# Sample level 
#--------------------------------------
# 1. Read INTERCATCH length distribution data 
IC2020LengthSamples <- read.table("boot/data/Catches/NumbersAtAgeLength.txt", sep = "\t",  header=TRUE, dec = "." , fill = TRUE, skip=2) 
IC2020LengthSamples$NumSamplesLength[IC2020LengthSamples$NumSamplesLength == -9] <- 0
IC2020LengthSamples$NumLengthMeasurements[IC2020LengthSamples$NumLengthMeasurements == -9] <- 0

TableReport1.4 <- IC2020LengthSamples %>%
  group_by(Country, Catch.Cat.) %>%
  summarise(
    NsamplesLength = sum(NumSamplesLength),
    NmeasuresLength = sum(NumLengthMeasurements),
    .groups = "drop"
  )


write.table(TableReport1.4, "data/catch/WGBIE_ReportTable1.4.csv", append=F, sep=",", row.names=F)
