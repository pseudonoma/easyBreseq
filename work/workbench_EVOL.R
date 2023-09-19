# analysis workbench
# source data:
# comparisons_2023_07_28; sampleKey_2023_07_27

###

library(tidyverse)
# source("./R/mutfind.R")
# source("./R/pipeline.R")
# source("./R/wrangle.R")
source("./work/find_parallel_muts.R")
source("./work/extract_by.R")

# reload data
#path <- "./results_full/"
path <- "./outputs/EVOL/"
cleanData <- read.csv(paste0(path, "EVOL_cleaned_reduced.csv"))

###

# by gene
genes <- c("rpoB", "rpsL", "rrs", "gidB")
extractedGenes <- extract_by(cleanData, genes, mode = "gene", split = FALSE)

# by populations (eyeballed endpoint ODs)
positives <- paste0("TRT", str_pad(width = 2, pad = 0, 
                                   string = c(3, 
                                              10, 
                                              13, 14, 
                                              20, 
                                              23, 
                                              27, 
                                              32, 33, 34,
                                              36, 39, 40))) # breaks are by plate
extractedPops <- extract_by(cleanData, positives, mode = "sample", split = FALSE)

# by call count threshold (>= 2 calls)
parallelData <- find_parallel_muts(cleanData) 

