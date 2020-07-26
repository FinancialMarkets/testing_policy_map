library(tidyverse)
library(readr)
library(viridis)
library(scales)
library(highcharter)
library(htmlwidgets)
options(browser = "/usr/bin/firefox")

mapdata <- get_data_from_map(download_map_data("custom/africa"))

african_data <- read_csv("../../african_data.csv")
african_data$Date <- as.Date(as.character(african_data$Date), format = "%Y-%m-%d")

names(african_data)[26] <- "Testing_Policy"
african_data$y <- african_data$CountryName

testing_data <- african_data[, names(african_data) %in% c("Date", "CountryName", "Testing_Policy", "CountryCode")]

testing_data <- testing_data[complete.cases(testing_data), ]

testing_data$CountryName <- factor(testing_data$CountryName,levels=rev(unique(testing_data$CountryName)))

## testing_data <- testing_data[testing_data$Date > "2020-02-14", ]

testing_data <- testing_data[testing_data$CountryName != "France",]

## just get max------------------
just_testing_data_latest <- testing_data %>% 
    group_by(CountryName) %>%
    arrange(Date) %>%
    mutate(max_testing_data = max(unique(Date)))

just_testing_data_latest <- just_testing_data_latest[(just_testing_data_latest$Date == just_testing_data_latest$max_testing_data), ]

names(just_testing_data_latest)[2] <- "iso-a3"

## graphic

x <- c("Country", "Date", "Testing Policy")
y <- c("{point.CountryName}" , "{point.Date}", "{point.Testing_Policy}")

tltip <- tooltip_table(x, y)

carmine <- "#960018"
dark_midnight_blue <- "#003366"
white <- "#FFFFFF"
milken <- "#0066CC"
milken_red <- "#ff3333"

## map cases per of pop
testing_policy_map <- hcmap("custom/africa", data = just_testing_data_latest, value = "Testing_Policy",
      joinBy = c("iso-a3"), name = "Testing Policy",
      borderColor = "#FAFAFA", borderWidth = 0.1) %>%
      hc_tooltip(useHTML = TRUE, headerFormat = "", pointFormat = tltip) %>%
    hc_legend(align = "center", layout = "horizontal", verticalAlign = "middle", x = -160, y= 120, valueDecimals = 0) %>%
    hc_colorAxis(minColor = "#e2e2e2", maxColor = milken_red,
             type = "linear")


## testing_policy_map

## Save vis
saveWidget(testing_policy_map, file="testing_policy_map.html")


