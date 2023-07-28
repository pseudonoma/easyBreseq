# quick load everything for testing

library(tidyverse)

data <- read.csv("./data/tidied_outputs_2023_07_20.csv")
colnames(data)[colnames(data) == "Locus"] <- "Locus_tag"
initPrefix <- "INIT"

