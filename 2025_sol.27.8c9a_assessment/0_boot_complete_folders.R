library(icesTAF)

# We can check the information available at: https://github.com/ices-taf/doc/wiki/Example-datasets-1
# Create a empty project

taf.skeleton() #create structure in the project folder

# Data -------------------------------------------------------------------------
# Move data files to the initial/data folder

#draft.data() # create a empty entry for data. 
#?draft.data  # The help pages are more completed in the TAF package.

assessment_year<-2024

# Create the associated data.bib
# IMPORTANT: When using draft.data() multiple times, make sure to set `append = TRUE` for all entries after the first one.
# Only the first call should omit `append` or set it to FALSE to avoid overwriting data.bib.
# Also, be careful with long titles—use paste() to avoid issues with line breaks.
# If entries are missing in data.bib, taf.boot() will only copy the folders listed there.

draft.data(
  data.files = "Catches",
  originator = "intercatch",
  year = assessment_year,
  title = "NumbersAtAgeLength file provides the length data and StockOverview the catch data",
  file = TRUE,
  append = FALSE)


draft.data(
  data.files = "Historical_catch",
  originator = "WGBIE",
  year = assessment_year,
  period = "1948-2023",
  title = "Catch data (from intercatch) after formatting in the WKANGHAKE benchmark for the period 1948 to 2023",
  file = TRUE,
  append = TRUE)

draft.data(
  data.files = "Biomass_indices",
  originator = "WGBIE",
  year = assessment_year,
  period = "2011-2024",
  title = paste("Biomass relative indices were derived from the standardized procedure defined",
                "during the benchmark process (ICES, 2021). Two standardized indices were used:",
                "one from the Spanish IBTS-Q4 bottom trawl survey (G2784), standardized using a Bayesian geostatistical model",
                "computed with the R-INLA software; and another from a standardized Portuguese commercial LPUE index,",
                "obtained using a Generalized Linear Model (GLM)."),
  file = TRUE,
  append = TRUE)

draft.data(
  data.files = "LFDs nsample intercatch",
  originator = "intercatch",
  year = assessment_year,
  period = "2011-2024",
  title = "LFD (Length Frequency Distribution) Number of samples (NSample) for 1982-2023",
  file = TRUE,
  append = TRUE)

draft.data(
  data.files = "Other_soleidae",
  originator = "WGBIE",
  year = assessment_year,
  period = "2009-2024",
  title = "Catches of other soleidae Pegusa lascaris, Solea senegalensis and Solea spp.",
  file = TRUE,
  append = TRUE)

taf.boot() # Create the data folder in boot with all the files

draft.software("boot/initial/software/utilities_vpaz.R",
               title="Function to create LBI plots", 
               file=TRUE,
               append = TRUE)
taf.boot()
