# This script will check which genes in AB3 should be excluded because of poor mapping.
# Specifically, it uses a mapping of AB3 reads to the AB3 v.1.0 reference genome in which 
# all genic variants were called that exhibited >=10% frequency at a coverage of >=50.
# In the script below, genes that show those variants are collated and those with >=4
# variants are saved in a file that will later be used to exclude those genes.
#
# Author: Jan Engelstaedter
#

### load packages:
library(tidyverse)

# set parameters:
fileName <- "./metadata/AB3 Quality control mapping (SB9918_S1_R_001 assembled to AB3 v1.0).tsv"
minSNPsForExclusion <- 4 # all genes with this or a higher number of variants will tagged for exclusion


################################################################################################
# import and tidy data
################################################################################################

AB3Data <- read_tsv(fileName) %>%
            select(`Document Name`, `Sequence Name`, `Sequence`, 
                   `Minimum`, `Min (with gaps)`, `Maximum`, `Max (with gaps)`, 
                   `Length`, `Length (with gaps)`, `# Intervals`,
                   `CDS`, `gene`, `locus_tag`,
                   `CDS Position`, `CDS Position Within Codon`, `CDS Codon Number`,
                   `Change`, `Amino Acid Change`,
                   `Average Quality`, `Coverage`, `Variant Frequency`)

colnames(AB3Data) <- c("sampleName", "refName", "sequence", 
                       "min", "minWithGaps", "max", "maxWithGaps)", 
                       "length", "lengthWithGaps", "nIntervals",
                       "CDS", "gene", "locusTag",
                       "CDSPos", "CDSPosWithinCodon", "CDSCodonNumber",
                       "change", "AAChange",
                       "meanQuality", "coverage", "variantFreq")

# fix coverage column:
AB3Data <- AB3Data %>% 
  mutate(minCoverage = coverage) %>%
  separate(minCoverage, into = c("minCoverage", "maxCoverage"), sep = " -> ") %>%
  mutate(minCoverage = as.numeric(minCoverage)) %>%
  mutate(maxCoverage = as.numeric(maxCoverage))

# fix variantFrequency column:
AB3Data <- AB3Data %>% 
  mutate(minVariantFreq = variantFreq) %>%
  separate(minVariantFreq, into = c("minVariantFreq", "maxVariantFreq"), sep = " -> ") %>%
  mutate(minVariantFreq = as.numeric(sub("%", "e-2", minVariantFreq))) %>%
  mutate(maxVariantFreq = as.numeric(sub("%", "e-2", maxVariantFreq)))


################################################################################################
# identify "problematic" genes
################################################################################################

geneSummary <- AB3Data %>%
  group_by(locusTag, CDS) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  filter(n>=minSNPsForExclusion)

write_tsv(geneSummary, "./results/excludedGenes.tsv")


