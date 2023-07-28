### load packages:
library(tidyverse)

rpoBMutations <- read_csv("./results/allVariants.csv")

# rpoB sequence of the ancestor
AB3rpoB <- read_file("./metadata/AB3 rpoB sequence.txt")

mysteryRpoB <- AB3rpoB
  

# SNPs in rpoB in one example population:
examplePop <- rpoBMutations %>% 
  filter(strain == "AB3" & treatment == "NOD" & replicate == "R1" & shift == "S1") %>%
  separate(change, into = c("old", "new"))

for(i in 1:nrow(examplePop)) {
  if (!is.na(examplePop$old[i]) && (nchar(examplePop$old[i]) == nchar(examplePop$new[i]))) {
    pos <- examplePop$CDSPos[i]
    len <- nchar(examplePop$old[i])
    if (substr(AB3rpoB, pos, pos + len - 1) != examplePop$old[i])
      warning(paste0("Ancestral sequence not identical to ancestral variant at variant #", i, "."))
    else
      substr(mysteryRpoB, pos, pos + len + 1) <- examplePop$new[i]
  }
}

# sanity check:
substr(AB3rpoB, 60, 70)
substr(mysteryRpoB, 60, 70)

write_file(mysteryRpoB, "./results/mystery rpoB sequence.txt")
