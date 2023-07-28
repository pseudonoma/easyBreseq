# This script will analyse a file of SNP data that has been produced by
# the scripts "SNP data processing.R".
#
# Author: Jan Engelstaedter
#

#################################################################################################
## Preliminaries
#################################################################################################

### load packages:
library(tidyverse)
library(cowplot)
library(RColorBrewer)
library(VennDiagram)
library(circlize)

# load data:
allData <- read_csv("./results/genetic variants.csv")
excludedGenes <- read_tsv("./results/excludedGenes.tsv")

# ancestral mutations:
ancestrals <- read_csv("./metadata/ancestrals.csv")
ancestralsReduced <- ancestrals %>%
  filter(strain == "AB3") %>%
  select(-strain, -lab_name)

# mapping to be used:
reference <- "AB3 v1.0"

genomeLength<-3598810

#################################################################################################
## Classifying and summarising all mutations
#################################################################################################

# new columns for mutation type and which of the ancestral mutation is present:
allData <- mutate(allData, mutationType = NA, ancestral = NA)
for(i in 1:nrow(allData)) {
  if (is.na(allData$change[i])) {
    allData$mutationType[i] <- "NA_change"
  } else if (str_detect(allData$change[i], "[YRWSKMDVHBXN]")) {  # ambiguous base pair characters involved
    allData$mutationType[i] <- "ambiguous"
  }
  
  if (is.na(allData$mutationType[i]) && !is.na(allData$CDS[i])) { # check if one of the ancestral mutations
    for (j in 1:nrow(ancestralsReduced)) {  
      if (!is.na(allData$gene[i]) && 
         (allData$gene[i] == ancestralsReduced$gene[j] && allData$CDSPos[i] == ancestralsReduced$CDS_position[j] && allData$codonChange[i] == ancestralsReduced$codon_change[j])) {
        allData$mutationType[i] <- "ancestral"
        allData$ancestral[i] <- ancestralsReduced$mutant[j]
      }
    }
  }
  
  if (is.na(allData$mutationType[i]) && !is.na(allData$CDS[i])) {
    if (allData$min[i] == allData$max[i] && is.na(allData$AAChange[i]))
      allData$mutationType[i] <- "synSNP"
    else if (allData$min[i] == allData$max[i] && !is.na(allData$AAChange[i]))
      allData$mutationType[i] <- "nonsynSNP"
    else
      allData$mutationType[i] <- "genicIndel"
  }
}

# turn some columns into ordered factors:
allData <- mutate(allData, strain = factor(strain, levels = c("AB3", "AB13"), ordered = TRUE),
                           treatment = factor(treatment, levels = c("NOD", "RIF", "STP", "CMB", "MIX", "ALL"), ordered = TRUE),
                           replicate = factor(replicate, ordered = TRUE),
                           shift = factor(shift, ordered = TRUE),
                           day = factor(day, ordered = TRUE))

# remove "CDS":
allData <- mutate(allData, CDS = str_replace(CDS, " CDS", ""))


ggplot(allData) + 
  geom_bar(aes(mutationType))

rpoBMutations <- allData %>% filter(gene == "rpoB") %>%
  select(strain, treatment, replicate, shift, min, max, gene, CDSPos, change, codonChange, AAChange, minCoverage, variantFreq, mutationType)

rpsLMutations <- allData %>% filter(gene == "rpsL") %>%
  select(strain, treatment, replicate, shift, min, max, gene, CDSPos, change, codonChange, AAChange, minCoverage, variantFreq, mutationType)

# save data frame of classified mutations:
write_csv(rpsLMutations, "./results/rpsLVariants.csv")
write_csv(rpoBMutations, "./results/rpoBVariants.csv")
#look for de novo potential candidates in here

# produce filtered data set containing only ancestral SNPs and export as table:
ancestralSNPs <- allData %>%
  filter(mutationType == "ancestral")
write_csv(ancestralSNPs, "./results/ancestralSNPs.csv")

# ---> the next script can then load this file and produce plots

