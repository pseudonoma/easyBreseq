# code I used to run the R wrangler portion
# circa. early Aug 2023

###

install.packages("tidyverse")
library(tidyverse)

# load functions
source("./R/pipeline.R") # main user functions
source("./R/wrangle.R")
source("./R/mutfind.R")

# load data
comparisons <- "./data/comparisons_2023_07_28.csv"
sampleKey <- "./data/sampleKey_2023_07_27.csv"

# Step 1: run the QC/cleaner
# (for an explanation of what the options do, look at pipeline.R)
cleanedOutput <- brsq_easyclean(comparisons, 
                                sampleKey, 
                                basePrefix = "INIT", 
                                exportFormat = "reduced")

# Step 2: run the filter
filteredOutput <- brsq_easyfilter(cleanedOutput, 
                                  basePrefix = "INIT",
                                  removeLocusGenes = TRUE,
                                  removeIntergenic = TRUE,
                                  removeBaseMuts = TRUE,
                                  byGene = NULL,
                                  byMutType = NULL,
                                  byBlock = "all")

# alternatively, use actual pipes for the pipeline, like the gods intended
filteredOutput <- comparisons |>
  brsq_easyclean(sampleKey, 
                 basePrefix = "INIT", 
                 exportFormat = "reduced") |>
  brsq_easyfilter(basePrefix = "INIT",
                  removeLocusGenes = TRUE,
                  removeIntergenic = TRUE,
                  removeBaseMuts = TRUE,
                  byGene = NULL,
                  byMutType = NULL,
                  byBlock = "all")
