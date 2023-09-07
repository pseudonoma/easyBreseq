# workbench for the straggler RIF sequencing runs
# D3018/J4144, D3575/J5079

#

library(tidyverse)
source("./R/mutfind.R")
source("./R/pipeline.R")
source("./R/wrangle.R")

# define comparisons files etc (careful to keep them separate)
D3018 <- "./data/comparisons_D3018-J4144.csv"
D3575 <- "./data/comparisons_D3575-J5079.csv"

cleanedOutput <- brsq_easyclean(data = D3575, 
                                nameKey = "./data/keys/key 290823.csv",
                                exportFormat = "full",
                                exportTo = "./outputs/D3575/full")

# Step 2: run the filter
filteredOutput <- brsq_easyfilter(cleanedOutput,
                                  removeLocusGenes = TRUE,
                                  removeIntergenic = TRUE,
                                  #removeBaseMuts = TRUE,
                                  exportTo = "./outputs/D3575/full")
