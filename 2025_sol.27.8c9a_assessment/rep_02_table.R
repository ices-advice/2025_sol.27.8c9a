### report.R — TAF reporting script for report table ###

# Create output folder
mkdir("report")


# ------------------------------
# Load combined soleid catches
# ------------------------------

catch <- read_csv("data/Other_Soleidae/total_catch.csv", show_col_types = FALSE)

# Harmonize species names
catch <- catch %>%
  filter(!is.na(Catch)) %>%
  mutate(Species = case_when(
    str_detect(Species, regex("solea solea", ignore_case = TRUE)) ~ "S. solea",
    str_detect(Species, regex("senegalensis", ignore_case = TRUE)) ~ "S. senegalensis",
    str_detect(Species, regex("pegusa", ignore_case = TRUE)) ~ "P. lascaris",
    str_detect(Species, regex("spp", ignore_case = TRUE)) ~ "Solea spp",
    TRUE ~ Species
  ))

# ------------------------------
# Table 8.1 - Percent composition
# ------------------------------
# Summarise total catch per year and species
catch_pct <- catch %>%
  group_by(Year, Species) %>%
  summarise(Catch = sum(Catch, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = Species, values_from = Catch, values_fill = 0)

# Ensure integer Year and expected columns
catch_pct$Year <- as.integer(catch_pct$Year)
expected_cols <- c("S. solea", "S. senegalensis", "P. lascaris", "Solea spp")
missing <- setdiff(expected_cols, names(catch_pct))
catch_pct[missing] <- 0

# Compute total and percent composition
catch_pct <- catch_pct %>%
  select(Year, all_of(expected_cols)) %>%
  mutate(Total = rowSums(across(-Year))) %>%
  mutate(across(-c(Year, Total), ~ round(100 * .x / Total))) %>%
  select(-Total)

# Reorder
catch_pct <- catch_pct %>%
  arrange(Year)

# Generate flextable
table_8_1 <- flextable(catch_pct) %>%
  set_caption("Table 8.1. Percentage of S. solea, S. senegalensis, P. lascaris and Solea spp. in the total landed weight of sole species from 2009–2024") %>%
  autofit()

# Save to Word
print(read_docx() %>% body_add_flextable(table_8_1), target = "report/Table_8_1.docx")

# ------------------------------
# Table 8.2 - Absolute catch (tonnes)
# ------------------------------

catch_abs <- catch %>%
  group_by(Year, Species) %>%
  summarise(Catch = sum(Catch, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = Species, values_from = Catch, values_fill = 0)

expected_cols <- c("S. solea", "S. senegalensis", "P. lascaris", "Solea spp")
missing_cols <- setdiff(expected_cols, names(catch_abs))
catch_abs[missing_cols] <- 0  # Ensure all species columns exist

catch_abs <- catch_abs %>%
  select(Year, all_of(expected_cols)) %>%
  mutate(`Total catch` = round(rowSums(across(where(is.numeric))))) %>%
  mutate(across(-Year, round)) %>%
  arrange(Year)

table_8_2 <- flextable(catch_abs) %>%
  set_caption("Table 8.2. Catches (in tonnes) of S. solea, S. senegalensis, P. lascaris and Solea spp. from 2009–2024") %>%
  autofit()

print(read_docx() %>% body_add_flextable(table_8_2), target = "report/Table_8_2.docx")


# ------------------------------
# Table 8.3 - Copy LBI results
# ------------------------------

file.copy("output/LBI/LBI_indicators_table.docx", "report/Table_8_3.docx", overwrite = TRUE)
