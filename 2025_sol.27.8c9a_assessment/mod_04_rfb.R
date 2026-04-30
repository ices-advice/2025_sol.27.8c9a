### Script to apply the rfb rule ###
# Input: catches, biomass survey, freq data
# Output: Advice table
# Author: M. Grazia Pennino


# Create output folder if needed
mkdir("output/RFB")

# Load data
all_catch <- read.csv("data/catch/combined_catch_SOL_8c9a.csv")

#summarize by country and year
catch <- all_catch %>%
  group_by(Year, Country) %>%
  summarise(Catch = sum(Catch_t, na.rm = TRUE), .groups = "drop") %>%
  arrange(Year, Country)

# Add total annual catch and country proportion to each row
data_catch <- catch %>%
  group_by(Year) %>%  # Group data by year
  mutate(
    TotalCatch = sum(Catch, na.rm = TRUE),      # Calculate total catch for each year
    Proportion = Catch / TotalCatch             # Compute the proportion of catch per country
  ) %>%
  ungroup()  # Remove grouping structure

#Create a wide-format table with years as rows and countries as columns
prop_table <- data_catch %>%
  select(Year, Country, Proportion) %>%               # Keep only relevant columns
  pivot_wider(names_from = Country,                   # Use country names as new column headers
              values_from = Proportion)               # Fill cells with proportion values

# Load biomass indices
biomass <- read.csv("data/Biomass/Combined_Indices_SOL_8c9a.csv")

#Combine catch proportions with biomass indices, and then scales the indices for comparison.
rfb_data <- prop_table %>%
  left_join(biomass, by = "Year") %>%
  mutate(
    s_lpue = Portuguese_LPUE / mean(Portuguese_LPUE, na.rm = TRUE), # Scale LPUE by its mean (standardization)
    s_survey = Spanish_Index / mean(Spanish_Index, na.rm = TRUE)# Scale survey index by its mean
  )

rfb_data <- rfb_data %>%
  mutate(
    Combined_Index = Portugal * s_lpue + Spain * s_survey
  )

# View the resulting combined index by year
rfb_data %>%
  select(Year, Combined_Index) %>%
  na.omit()%>%  # Optional: remove rows with NA
write.csv(file = "output/RFB/combined_index.csv", row.names = FALSE)


jpeg("output/RFB/Combined_index.jpg", width = 2000, height = 1600, res = 300)
p=ggplot(rfb_data, aes(x = Year, y = Combined_Index)) +
  geom_line(color = "blue", size = 1.2) +
  geom_point(color = "blue", size = 2) +
  geom_hline(yintercept = mean(rfb_data$Combined_Index, na.rm = TRUE), 
             linetype = "dashed", color = "red") +
  labs(
    title = "Índice combinado (Regla RFB)",
    y = "Índice combinado escalado",
    x = "Año"
  ) +
  theme_minimal()
print(p)
dev.off()

# Create 'A' object representing the most recent catch advice value
# - object = 209 → the reference catch (from ICES advice)
# - basis = "advice" → indicates the value is based on advice
# - units = "tonnes" → catch value units
# - advice_metric = "catch" → defines the type of advised value

A_obj <- A(object = 209, basis = "advice", units = "tonnes", advice_metric = "catch")

# Define recent and reference years to calculate the biomass trend
recent_years <- c(2023, 2024)       # Most recent years for trend
ref_years <- c(2020, 2021, 2022)    # Reference period for comparison

# Calculate mean index for recent years
mean_recent <- rfb_data %>%
  dplyr::filter(Year %in% recent_years) %>%                      # Filter recent years
  summarise(mean_recent = mean(Combined_Index, na.rm = TRUE)) %>%  # Average index (ignore NA)
  pull(mean_recent)                                              # Extract the numeric result

# Calculate mean index for reference years
mean_ref <- rfb_data %>%
  dplyr::filter(Year %in% ref_years) %>%                         # Filter reference years
  summarise(mean_ref = mean(Combined_Index, na.rm = TRUE)) %>%     # Average index (ignore NA)
  pull(mean_ref)                                                 # Extract the numeric result

# Compute the biomass trend ratio: recent vs reference
r_ratio <- mean_recent / mean_ref


# Create a time series object for the combined index
index_df <- rfb_data %>%
  dplyr::select(Year, Index = Combined_Index) %>%  # Select relevant columns and rename for clarity
  arrange(Year)                                    # Ensure chronological order

# Create 'r' object using the full index time series (for RFB rule)
r_obj <- r(object = index_df)

# Load input data
freq_data <- read.csv("data/Lenght_data/data_freq.csv")  # length-frequency matrix

# Clean and pivot the frequency data
freq_long <- freq_data %>%
  rename(Length = MeanLength) %>%
  pivot_longer(
    cols = -Length,
    names_to = "year",
    values_to = "numbers"
  ) %>%
  mutate(
    year = as.integer(gsub("X", "", year)),  # Remove any 'X' from year names
    catch_category = "Total",                # We set 'Total' because you probably have all sources combined
    Length = as.numeric(Length),
    numbers = as.numeric(numbers)
  ) %>%
  select(year, catch_category, length = Length, numbers)


# Length at first capture Lc
lc <- Lc(freq_long)

jpeg("output/RFB/Length_first_capture.jpg", width = 2000, height = 1600, res = 300)
cat3advice::plot(lc)
dev.off()

# Mean length Lmean
### calculate annual mean length
lmean <- Lmean(data = freq_long, Lc = lc, units = "cm")
lmean

jpeg("output/RFB/Mean_length.jpg", width = 2000, height = 1600, res = 300)
cat3advice::plot(lmean)
dev.off()

# Reference length
#we are going to use the Lc used in the last advice Lc 2022 (27.5)
lref <- Lref(Lc = 27.5, Linf = 48.9, units = "cm", Mk=1.41)

f <- f(Lmean = lmean, Lref = lref, units = "cm")
f

jpeg("output/RFB/F.jpg", width = 2000, height = 1600, res = 300)
cat3advice::plot(f)
dev.off()


# Create 'b' object (biomass safeguard)
b_obj <- b(index_df)

jpeg("output/RFB/B_andr.jpg", width = 2000, height = 1600, res = 300)
cat3advice::plot(b_obj, r_obj)
dev.off()


# Create 'm' object (precautionary buffer)
m_obj <- m(object = 0.90)


#  Apply the RFB rule

advice_result <- rfb(
  A = A_obj,
  r = r_obj,
  f = f,
  b = b_obj,
  m = m_obj
)


# Capture the printed output of advice(advice_result)
advice_text <- capture.output(advice(advice_result))

# Create a Word document
doc <- read_docx() %>%
  body_add_par("Catch Advice Results", style = "heading 1") %>%
  body_add_par(paste(advice_text, collapse = "\n"), style = "Normal")

# Save the Word file
print(doc, target = "output/RFB/advice.docx")
