# This script will process raw SNP data coming out of Geneious as a tsv file.
#
# Author: Jan Engelstaedter
#

### load packages:
library(tidyverse)

# set parameters:
fileNames <- c("J4722_mutations.tsv")

################################################################################################
# import and tidy data
################################################################################################

originalColumns <- c('Document Name', 'Track Name', 'Sequence', 
                     'Minimum', 'Min (with gaps)', 'Maximum', 'Max (with gaps)', 
                     'Length', 'Length (with gaps)', '# Intervals',
                     'CDS', 'gene', 'locus_tag',
                     'CDS Position', 'CDS Position Within Codon', 'CDS Codon Number',
                     'Change', 'Codon Change', 'Amino Acid Change',
                     'Average Quality', 'Coverage', 'Variant Frequency')

allData <- paste0("./data/", fileNames) %>%
           map(read_tsv) %>%
           bind_rows() %>%
           select(originalColumns)

colnames(allData) <- c("reference", "trackName", "sequence", 
                       "min", "minWithGaps", "max", "maxWithGaps", 
                       "length", "lengthWithGaps", "nIntervals",
                       "CDS", "gene", "locusTag",
                       "CDSPos", "CDSPosWithinCodon", "CDSCodonNumber",
                       "change", "codonChange", "AAChange",
                       "meanQuality", "coverage", "variantFreq")

# add new columns with job ID and sample no., extracted from sampleName column:
allData <- allData %>%
  mutate(sampleNo = str_match(trackName, "Variants: \\s*(.*?)\\s*_")[, 2]) %>%
  mutate(jobID = str_match(trackName, "_\\s*(.*?)\\s*_S")[, 2]) %>%
  select(jobID, sampleNo, reference, trackName, everything())
  
# fix coverage column:
allData <- allData %>% 
  mutate(minCoverage = coverage) %>%
  separate(minCoverage, into = c("minCoverage", "maxCoverage"), sep = " -> ") %>%
  mutate(minCoverage = as.numeric(minCoverage)) %>%
  mutate(maxCoverage = ifelse(is.na(maxCoverage), minCoverage, as.numeric(maxCoverage)))

# fix variantFrequency column:
allData <- allData %>% 
             mutate(minVariantFreq = variantFreq) %>%
             separate(minVariantFreq, into = c("minVariantFreq", "maxVariantFreq"), sep = " -> ") %>%
             mutate(minVariantFreq = as.numeric(sub("%", "e-2", minVariantFreq))) %>%
             mutate(maxVariantFreq = ifelse(is.na(minVariantFreq), minVariantFreq, as.numeric(sub("%", "e-2", maxVariantFreq))))

# sort:
allData <- arrange(allData, jobID, sampleNo, min)

################################################################################################
# combine with sample information and save
################################################################################################

sampleInfo <- read_tsv("./data/sampleInfo.tsv")
allData <- left_join(allData, sampleInfo, by = c("jobID", "sampleNo")) %>%
           select(jobID, sampleNo, strain, info, everything())
write_tsv(allData, "./results/genetic_variants.tsv")

