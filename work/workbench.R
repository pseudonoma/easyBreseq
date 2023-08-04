# additional analysis

library(tidyverse)

cleanData <- read.csv("./results_reduced/02_cleanedOutput.csv")
qcedData <- read.csv("./results_reduced/01_QCedOutput.csv")
comp <- read.csv("./results_reduced/comparisons_2023_07_28_tidied.csv")

# analysis to do:
# by gene (use easyfilter?)

# list genes called >n times, listing also the mutation, what pops, etc
find_parallels <- function(data){
  
  # define threshold (or make it an arg?)
  # how many times should a gene appear? what if a gene repeats within a strain?
  threshold <- 2
  
  # get calls    
  callsAboveThreshold <- baseData |>
    dplyr::group_by(Gene) |>
    # add a column parsing all the strains it's been called?
    # if there's more calls than strains, it means some strains repeated, so how report?
    dplyr::summarize(totalCalls = n()) |>
    dplyr::ungroup() |>
    dplyr::filter(totalCalls >= threshold)
}

# beginning from eyeballed endpoint OD, what mutations are in them?
positives <- paste0("TRT", str_pad(c(3, 10, 13, 14, 20, 23, 27, 32, 33, 34, 36, 39, 40), 
                                   width = 2, pad = 0))
posData <- cleanData[cleanData$Name %in% positives, ]
