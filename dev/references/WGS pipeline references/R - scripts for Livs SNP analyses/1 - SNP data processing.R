# This script will process raw SNP data coming out of Geneious as a tsv file.
#
# Author: Jan Engelstaedter
#

### load packages:
library(tidyverse)

# set parameters:
fileNames <- list.files("./data")

################################################################################################
# import and tidy data
################################################################################################

# number of columns in the original data files:
nOriginalColumns <- paste0("./data/", fileNames[1]) %>%
  read_csv() %>%
  length()

coltypeString <- rep("c", nOriginalColumns) %>%
  paste(collapse = "")

allData <- paste0("./data/", fileNames) %>%
           map(read_csv, col_types = coltypeString) %>%
           map(select, `Document Name`, `Sequence Name`, `Sequence`, 
               `Minimum`, `Maximum`, `Length`, 
               `CDS`, `gene`, `locus_tag`,
               `CDS Position`, `CDS Position Within Codon`, `CDS Codon Number`,
               `Change`, `Codon Change`, `Amino Acid Change`,
               `Average Quality`, `Coverage`, `Variant Frequency`) %>%
           bind_rows()

colnames(allData) <- c("sampleName", "refName", "sequence", 
                       "min", "max", "length", 
                       "CDS", "gene", "locusTag",
                       "CDSPos", "CDSPosWithinCodon", "CDSCodonNumber",
                       "change", "codonChange", "AAChange",
                       "meanQuality", "coverage", "variantFreq")

allData$min <- as.integer(allData$min)
allData$max <- as.integer(allData$max)
allData$length <- as.integer(allData$length)


# add new columns with job ID and sample no., extracted from sampleName column:
allData <- mutate(allData, sampleNo = str_sub(sampleName, 1, 6))
allData <- select(allData, sampleNo, everything())

# fix coverage column:
allData <- allData %>% 
  mutate(minCoverage = coverage) %>%
  separate(minCoverage, into = c("minCoverage", "maxCoverage"), sep = " -> ") %>%
  mutate(minCoverage = as.numeric(minCoverage)) %>%
  mutate(maxCoverage = as.numeric(maxCoverage))

# fix variantFrequency column:
allData <- allData %>% 
             mutate(minVariantFreq = variantFreq) %>%
             separate(minVariantFreq, into = c("minVariantFreq", "maxVariantFreq"), sep = " -> ") %>%
             mutate(minVariantFreq = as.numeric(sub("%", "e-2", minVariantFreq))) %>%
             mutate(maxVariantFreq = as.numeric(sub("%", "e-2", maxVariantFreq)))

# sort:
allData <- arrange(allData, sampleNo, min)

################################################################################################
# combine with sample information and save
################################################################################################

sampleInfo <- read_csv("./metadata/sampleInfo.csv") %>%
  select("#Sample ID", "name") %>%
  rename(sampleNo = `#Sample ID`, info = name)

allData <- left_join(allData, sampleInfo, by = "sampleNo") %>%
           separate(info, c("strain", "treatment", "replicate", "shift", "day"), sep = "_") %>%
           select(sampleNo, strain, treatment, replicate, shift, day, everything())

write_csv(allData, "./results/genetic variants.csv")

