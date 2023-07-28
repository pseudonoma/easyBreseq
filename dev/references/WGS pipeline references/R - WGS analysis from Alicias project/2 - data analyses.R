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

# load data:
allData <- read_tsv("./results/genetic_variants.tsv")

phenos <- c("R17", "R18", "R21", "R22", "R26", "R9", "R29", "R30", "R34", "R36", 
            "S3", "S5", "S6", "S8", "S11", "S14", "S20", "S21", "S22", "S24") # strains that Alicia phenotyped

#################################################################################################
## SNPs filtering
#################################################################################################

allData <- allData %>%
  mutate(mutID = paste0("(", min, ":", max, ") = (", change,")")) %>%
  mutate(phenotyped = (strain %in% phenos))
  
ancestralMuts <- allData %>%
  filter(strain == "MG1655") %>%
  pull(mutID) %>%
  unique()

# filtering out (1) ancestral SNPs,
# (2) those associated with IS elements, and
# (3) those in an rrn operon that seems to be a mis-alignment:
filteredData <- allData %>%
  filter(!(mutID %in% ancestralMuts)) %>%
  filter(!((min >= 257911) & (max <= 258673))) %>%
  filter(!((min >= 1299500) & (max <= 1300693))) %>%
  filter(!((min >= 3424235) & (max <= 3424237)))

#################################################################################################
## Annotating mutations and summarizing for each strain
#################################################################################################

annotatedData <- filteredData %>%
  mutate(gene = ifelse(is.na(gene), "intergenic", gene)) %>%
  mutate(CDSPos = ifelse(gene == "intergenic", min, CDSPos)) %>%
  separate(change, c("from", "to"), 
           sep = " -> ", remove = FALSE, fill = "left") %>%
  separate(AAChange, c("AAfrom", "AAto"), 
           sep = " -> ", remove = FALSE, fill = "left") %>%
  mutate(from = ifelse(is.na(from), "", from)) %>%
  mutate(mutName = paste0(gene, "_", from, CDSPos, to)) %>%
  mutate(AAmutName = ifelse(is.na(AAChange), 
                            "na", 
                            paste0(gene, "_", AAfrom, CDSCodonNumber, AAto))) %>%
  mutate(phenotyped = ifelse(strain %in% phenos, TRUE, FALSE))

strainSummary <- annotatedData %>%
  select(strain, phenotyped, mutName, AAmutName) %>%
  group_by(strain, phenotyped) %>%
  summarise(mutations = paste(mutName, collapse = ", "),
            AAchanges = paste(AAmutName, collapse = ", ")) %>%
  write_csv("./results/mutation_summary.csv")
