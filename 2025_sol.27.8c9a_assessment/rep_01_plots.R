### report.R — TAF reporting script for report plots ###

# Create output folder
mkdir("report")

# Load data
catch_data <- read.csv("data/catch/combined_catch_SOL_8c9a.csv")

# === FIGURE 8.1: Catch by Country ===
# Step 1: Aggregate catch by Year and Country
catch_country <- catch_data %>%
  group_by(Year, Country) %>%
  summarise(TotalCatch = sum(Catch_t, na.rm = TRUE), .groups = "drop")

# Step 2: Create plot
plot_country <- ggplot(catch_country, aes(x = as.factor(Year), y = TotalCatch, fill = Country)) +
  geom_bar(stat = "identity", colour = "black") +
  scale_fill_grey(start = 0.3, end = 0.9) +
  theme_classic() +
  labs(title = " ", y = "Catch (tonnes)", x = "Year")

# Step 3: Save plot
jpeg("report/Figure_8_1.jpg", width = 2000, height = 1600, res = 300)
print(plot_country)
dev.off()

# === FIGURE 8.2: Catch by Category ===
cat <- aggregate(Catch_t ~ Year + Catch.Cat., data = catch_data, sum)
colnames(cat) <- c("Year", "Category", "Catch")
cat <- cat[cat$Category != "", ]  # clean empty categories
cat$Year <- as.factor(cat$Year)

plot_category <- ggplot(cat, aes(x = Year, y = Catch, fill = Category)) +
  geom_bar(stat = "identity", colour = "black") +
  theme_classic() +
  labs(title = " ", y = "Catch (tonnes)", x = "Year") +
  scale_fill_brewer(palette = "Set2")

jpeg("report/Figure_8_2.jpg", width = 2000, height = 1600, res = 300)
print(plot_category)
dev.off()

# === FIGURE 8.3: Catch by Division ===
div <- aggregate(Catch_t ~ Year + Area, data = catch_data, sum)
colnames(div) <- c("Year", "Division", "Catch")
div$Year <- as.factor(div$Year)

plot_division <- ggplot(div, aes(x = Year, y = Catch, fill = Division)) +
  geom_bar(stat = "identity", colour = "black") +
  scale_fill_grey(start = 0.3, end = 0.9) +
  theme_classic() +
  labs(title = " ", y = "Catch (tonnes)", x = "Year")

jpeg("report/Figure_8_3.jpg", width = 2000, height = 1600, res = 300)
print(plot_division)
dev.off()

# === FIGURE 8.4: Catch by Fleet ===
fleet <- aggregate(Catch_t ~ Year + Fleets, data = catch_data, sum)
colnames(fleet) <- c("Year", "Fleet", "Catch")
fleet$Year <- as.factor(fleet$Year)

# Identify top fleets (90% cumulative catch)
top_fleets <- fleet %>%
  group_by(Fleet) %>%
  summarise(TotalCatch = sum(Catch)) %>%
  arrange(desc(TotalCatch)) %>%
  mutate(CumCatch = cumsum(TotalCatch),
         CumPerc = CumCatch / sum(TotalCatch)) %>%
  filter(CumPerc <= 0.9) %>%
  pull(Fleet)

fleet_top90 <- fleet %>% filter(Fleet %in% top_fleets)

plot_fleet <- ggplot(fleet_top90, aes(x = Year, y = Catch, fill = Fleet)) +
  geom_bar(stat = "identity", colour = "black") +
  theme_minimal() +
  labs(title = " ", y = "Catch (tonnes)", x = "Year") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

jpeg("report/Figure_8_4.jpg", width = 2000, height = 1600, res = 300)
print(plot_fleet)
dev.off()

# === FIGURE 8.5: LFds ===
# Copy Figure_8_5 (LFD plot) from LBI to REPORT folder
file.copy(
  from = "output/LBI/Figure_8_5.jpg",
  to   = "report/Figure_8_5.jpg",
  overwrite = TRUE
)

# === FIGURE 8.6: Other soleidae species ===
# Read input file
catch_species <- read_csv("data/Other_Soleidae/total_catch.csv")

# Optional: plot catch by species
jpeg("report/Figure_8_6.jpg", width = 2000, height = 1600, res = 300)
p=ggplot(catch_species, aes(fill=Species, y=Catch, x=Year)) + 
  geom_bar(stat="identity")+ 
  theme_classic()
print(p)
dev.off()

# === FIGURE 8.7: Spanish survey index ===

# Load biomass indices
biomass <- read.csv("data/Biomass/Combined_Indices_SOL_8c9a.csv")

# If CI not present, simulate it (10% width band)
biomass$low <- biomass$Spanish_Index * 0.9
biomass$high <- biomass$Spanish_Index * 1.1

# Plot Spanish survey index
jpeg("report/Figure_8_7.jpg", width = 2000, height = 1600, res = 300)
p=ggplot(data = biomass, aes(x = Year, y = Spanish_Index, group = 1)) +
  geom_line(col = 'red') + 
  geom_ribbon(aes(ymin = low, ymax = high), alpha = 0.1) +
  ylab("Biomass index") + 
  xlab("Year") + 
  ggtitle(" ") +
  theme_light()
print(p)
dev.off()

# === FIGURE 8.8: Spanish survey index ===
# Filter from 2011 onward
biomass_lpue <- biomass %>% filter(Year >= 2011)

# Plot LPUE (Portugal)
jpeg("report/Figure_8_6.jpg", width = 2000, height = 1600, res = 300)
p=ggplot(biomass_lpue, aes(x = Year, y = Portuguese_LPUE)) +
  geom_line(color = "blue", size = 1) +
  # Uncomment next line if you have columns Lower/Upper:
   geom_ribbon(aes(ymin = LPUE_Lower, ymax = LPUE_Upper ), fill = "blue", alpha = 0.2) +
  labs(
    title = " ",
    x = "Year",
    y = "LPUE (kg/trip)"
  ) +
  theme_minimal()
print(p)
dev.off()

# === FIGURE 8.9: LBI plot ===
# Copy Figure_8_9 from LBI to report folder
file.copy(
  from = "output/LBI/Figure_8_9.jpg",
  to   = "report/Figure_8_9.jpg",
  overwrite = TRUE
)

# === FIGURE 8.10: LBI sensitivity plot ===
# Copy Figure_8_10 from LBI to REPORT folder
file.copy(
  from = "output/LBI/Figure_8_10.jpg",
  to   = "report/Figure_8_10.jpg",
  overwrite = TRUE
)

# === FIGURE 8.11: LBSPR plot ===
# Copy Figure_8_11 from LBSPR to REPORT folder
file.copy(
  from = "output/LBSPR/Figure_8_11.jpg",
  to   = "report/Figure_8_11.jpg",
  overwrite = TRUE
)


# === FIGURE 8.12: MLZ plot ===
# Copy Figure_8_12 from MLZ to REPORT folder
file.copy(
  from = "output/MLZ/Figure_8_12.jpg",
  to   = "report/Figure_8_12.jpg",
  overwrite = TRUE
)

