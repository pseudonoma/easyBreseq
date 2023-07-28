# collection of code for running the breseq analysis

# On Win10
# dos2unix "/mnt/d/Dropbox/Ian/All Projects/2022-11 Bioinformatics Pipelines Project/breseq/R/easy_breseq.sh"
# bash "/mnt/d/Dropbox/Ian/All Projects/2022-11 Bioinformatics Pipelines Project/breseq/R/easy_breseq.sh"
# dos2unix "/mnt/d/Dropbox/Ian/All Projects/2022-11 Bioinformatics Pipelines Project/breseq/R/compare_GDs.sh"
# bash "/mnt/d/Dropbox/Ian/All Projects/2022-11 Bioinformatics Pipelines Project/breseq/R/compare_GDs.sh"

# Otherwise, just do bash <script> on a UNIX-type machine. Beware zsh may have some quirks.
# Also, remember to run a timer on the calls.

###

# R-side comparisons-wrangling pipeline

### TODO
# [DONE] "baseline" changes
# [DONE] /intermediates/ folder
# [DONE] 2nd-layer wrapper
# [DONE] (in easyfilter) Manage basepop detection and parsing of blocking column in tidying stage
# [DONE] Organize the functions into fewer files

library(tidyverse)
source("./R/easy_brsq.R")
source("./R/wranglers.R")
source("./R/mutfinders.R")

comparisons <- "./data/comparisons_2023_07_28.csv"
sampleKey <- "./data/sampleKey_2023_07_27.csv"

# run complete pipeline in the intended way
cleanedOutput <- brsq_easyclean(comparisons, 
                                sampleKey, 
                                basePrefix = "INIT", 
                                exportFormat = "full")
filteredOutput <- brsq_easyfilter(cleanedOutput, 
                                  basePrefix = "INIT",
                                  removeLocusGenes = TRUE,
                                  removeIntergenic = TRUE,
                                  removeBaseMuts = TRUE,
                                  byGene = NULL, # all by* options take a vector or "all"
                                  byMutType = NULL,
                                  byBlock = "all")

# testing: run them separately
tidiedOutput <- brsq_tidy_output(file = comparisons, sampleKey, format = "redo") # format is invalid
QCedOutput <- brsq_QC_output(tidiedOutput, basePrefix = "INIT")
filteredOutput <- brsq_easyfilter(QCedOutput, 
                                  basePrefix = "INIT",
                                  removeLocusGenes = TRUE,
                                  removeIntergenic = TRUE,
                                  removeBaseMuts = TRUE,
                                  byGene = NULL, # all by* options take a vector or "all"
                                  byMutType = NULL,
                                  byBlock = "all")

# alternatively, pipes for the pipeline, as the gods intended
cleanedOutput <- 
  brsq_tidy_output(comparisons, sampleKey, format = "reduced") |>
  brsq_QC_output(initPrefix = "TRT") |>
  brsq_easyfilter(basePrefix = "INIT",
                  removeLocusGenes = TRUE,
                  removeIntergenic = TRUE,
                  removeBaseMuts = TRUE,
                  byGene = NULL, # all by* options take a vector or "all"
                  byMutType = NULL,
                  byBlock = "all")
