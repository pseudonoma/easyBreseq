# workbench

source("./dev/dev_testObjects.R")

# easyfilter()
if(length(exclInit) == 1){ # reminder: blocking deliberately triggered by initpopMuts length
  outputData <- dplyr::filter(data, !Gene %in% initpopMuts[[1]]) # exclude initpop calls
} else { # TODO: implement blocking somehow
  cat("\nBlocking should be now active, but isn't implemented at the moment :(\n")
  outputData <- dplyr::filter(data, !Gene %in% initpopMuts[[1]])
}

# find_init_mut() mode = filter work

# else if(mode == "filter"){
#   writeLines("# Mutations in INIT populations", con = paste0(path, ".txt")) # prime .txt file
#   for(i in 1:length(initVariants)){ # write the blocks in
#     block <- c(paste0("\n# ", names(initVariants[i])), unique(initVariants[[i]]))
#     write(block, file = paste0(path, ".txt"), append = TRUE, sep = "\n")
#   }
#   saveRDS(initVariants, file = paste0(path, ".rds"))
#   
#   cat("Excluded INIT population mutations are listed in \"/results/initpop_mutations.txt\".\n")
#   
# }

# test loop
ubiquitousCalls <- c()
evals <- c()
mutlist <- unique(paste0(smallData$Gene, "_", smallData$Nt_pos))

for(mutation in mutlist){
  check <- c() # prime/re-prime vector for all() check
  for(sample in unique(smallData$Name)){
    currentSample <- smallData[smallData$Name == sample, ] # subset a single sample
    currentMutations <- paste0(currentSample$Gene, "_", currentSample$Nt_pos)
    check <- append(check, mutation %in% currentMutations)
  }
  evals <- append(evals, all(check)) # generate vector of whether mutations appear in all strains
  ubiquitousCalls <- mutlist[evals] # get list of mutations that do appear everywhere
  
}

# if checks work, then de-index by doing mutations[evals]
mutation <- mutlist[4]
mutlist[mutation]


list <- c(LETTERS[1:3])
evals <- c(TRUE, TRUE, FALSE)

currentMutations <- c("A_100", "B_101", "B_200")
mutlist

list[evals]

rm(list, eval)
  
reducedData <- data[, c("Name", "Gene", "Nt_pos")]
uniqueData <- reducedData[reducedData$Gene %in% unique(reducedData$Gene) &
                            reducedData$Nt_pos %in% unique(reducedData$Nt_pos), ]

# some notes #

# For filtering:
# Jan's implementation for Olivia seems to be by finding genes with >= 4 variants called
#   and excluding these genes entirely from the dataset.
# What is this approach and does it work for me?
minSNPsForExclusion <- 4 # all genes with this or a higher number of variants will tagged for exclusion

geneSummary <- AB3Data %>%
  group_by(locusTag, CDS) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  filter(n>=minSNPsForExclusion)

write_tsv(geneSummary, "./results/excludedGenes.tsv")

geneSummary <- data %>%
  group_by(Locus_tag, Gene) %>%
  summarise(n = n()) %>%
  ungroup() %>%
  filter(n >= 4)

# format(Sys.Date(), "%Y%m%d")

# From tidy_output0
# create test dfs for rename
targetData <- data.frame(Name = c("SE7910_J5079", "SE7911_J5079", "SE7912_J5079", "SE7909_J5079"),
                         Value = LETTERS[1:4],
                         Number = 1:4)
testKey <- data.frame(Sample = c("SE7910", "SE7911", "SE4-00", "SE7912", "SE8000", "SE7909", "SESESE", "J5079"),
                      Job = "J5079",
                      Key = paste("Sample", 1:8))

# old code chunk from find_ubiquitous_muts()
# replaced 24/07/23
ubiquitousCalls <- c() # prime vector of genes
for(gene in unique(smallData$Gene)){
  check <- c() # prime/re-prime vector for all() check
  for(sample in unique(smallData$Name)){
    currentBlock <- smallData[smallData$Name == sample, ] # subset a single strain
    check <- append(check, gene %in% currentBlock$Gene)
  }
  if(all(check)){ # if current gene is in all strain names, put it in the list
    ubiquitousCalls <- append(ubiquitousCalls, gene)
  }
  
  # TODO ======================================
  # Dropping by just $Gene is sloppy, I need to somehow check both Gene and Nt_pos like in
  #   find_initpop() and use it to create the exclusion df. all() is called on check,
  #   which is a vector of LOGICAL, so maybe I can evaluate >1 condition and proceed as
  #   before.
  # There might be also something to Jan's method of excluding if calls >= 4...
}

### DO NOT RUN ###
# just a list of column names in the "reduced" format
data.frame(Name = data$title,
           Gene = data$gene_name,
           Nt_pos = data$gene_position,
           Nt_OtoM = paste(data$ref_seq, "->", data$new_seq),
           Nt_mut_name = paste0(data$gene_name, "_", 
                                data$ref_seq, data$gene_position, data$new_seq),
           Codon_OtoM = paste(data$codon_ref_seq, "->", data$codon_new_seq),
           AA_pos = data$aa_position,
           AA_OtoM = paste(data$aa_ref_seq, "->", data$aa_new_seq),
           AA_mut_name = paste0(data$gene_name, "_", 
                                data$aa_ref_seq, data$aa_position, data$aa_new_seq),
           Frequency = data$frequency,
           Product = data$gene_product,
           Locus = data$locus_tag,
           Genome_pos = data$position,
           Reference = data$seq_id,
           Coverage_mut = data$new_read_count,
           Coverage_original = data$ref_read_count,
           Mutation_type = data$type,
           Mut_type_SNP = data$snp_type)


