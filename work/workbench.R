# analysis workbench
# source data:
# comparisons_2023_07_28; sampleKey_2023_07_27

###

library(tidyverse)
source("./R/mutfind.R")
source("./R/pipeline.R")
source("./R/wrangle.R")
source("./work/find_parallel_muts.R")

# reload data
#path <- "./results_full/"
path <- "./results_reduced/"
cleanData <- read.csv(paste0(path, "02_cleanedOutput.csv"))

###

# by gene
# TODO: easyfilter can't be run like this atm
test <- brsq_easyfilter(cleanData, byGene = c("rpoB", "")) 

# by specific (eyeballed) populations
positives <- paste0("TRT", str_pad(width = 2, pad = 0,
                                   string = c(3, 
                                              10, 
                                              13, 14, 
                                              20, 
                                              23, 
                                              27, 
                                              32, 33, 34,
                                              36, 39, 40)))
positivesData <- cleanData[cleanData$Name %in% positives, ]

# by call count threshold
parallelsData <- find_parallel_muts(cleanData) 


