# QC helper functions for making variant exclusion lists

# Currently works by $Gene, but maybe they can exclude by something else?
# I had a thought that left me; initpop mut exclusion should be done by mutation not gene? Why?

find_ubiquitous_muts <- function(data, initPrefix){
  
  # drop INIT-type pops
  if(!is.null(initPrefix)){
    smallData <- data[!(str_detect(data$Name, initPrefix)), ] 
  } else {
    smallData <- data
  }
  
  # find gene calls that appear in all strains
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
    
  }
  
  # export list of mutations
  exportText <- c("# Mutations common to all non-INIT samples\n", ubiquitousCalls)
  writeLines(exportText, con = "./outputs/ubiquitous_genes.txt")
  cat("Ubiquitous mutations are listed in \"/outputs/ubiquitous_genes.txt\".\n")
  
  
  return(ubiquitousCalls)
  
}

# function to check INIT blocks
intersect_blocks <- function(currentBlock, blockIntersect){
  result <- currentBlock %in% blockIntersect
  return(result)
}

find_initpop_muts <- function(data, initPrefix){
  
  # DEBUG
  # smallData <- data[!(str_detect(data$Name, initPrefix)), ]
  
  # separate INIT populations from data
  smallData <- data[(str_detect(data$Name, initPrefix)), ]
  if(nrow(smallData) == 0){
    stop("initPrefix is not NULL but no valid INIT populations were found.")
  }
  
  # get INIT pop names for grouping variant calls
  initPops <- unique(smallData$Name)
  
  # list calls that may be fixed, separating by the INIT population they came from
  initBlocks <- list()
  for(popName in initPops){
    blockData <- smallData[smallData$Name == popName, ]
    initBlocks[[popName]] <- blockData$Gene[blockData$Frequency >= 0.95]
  }
  
  # check that the INIT blocks have the same calls
  blockIntersect <- Reduce(intersect, initBlocks)
  outcome <- lapply(initBlocks, intersect_blocks, blockIntersect)
  if(all(sapply(outcome, all))){
    cat(paste0("\n", length(initPops), " INIT population(s) found; all appear identical.\n"))
    initVariants <- list("initVariants" = blockIntersect) # make a new list of only the intersect
  } else {
    cat("\nINIT populations appear to be different; consider blocking your samples.\n")
    initVariants <- initBlocks # return initBlocks directly
    
    # Note to self: 
    # The initVariants step exists because if you have >1 INIT pops that are identical, 
    #   initBlocks itself will still be a list >1 length, so you can't trigger blocking 
    #   later by using its length.
    
  }
  
  # export list of mutations from all initpops
  path <- "./outputs/initpop_genes.txt"
  writeLines("# Mutations in INIT populations", con = path) # prime .txt file
  for(i in 1:length(initVariants)){ # write the blocks in
    block <- c(paste0("\n# ", names(initVariants[i])), unique(initVariants[[i]]))
    write(block, file = path, append = TRUE, sep = "\n")
  }
  cat("INIT population mutations are listed in \"/outputs/initpop_genes.txt\".")
  
  # TODO: report what mutations *don't* intersect and what their block is?

  
  return(initVariants) # downstream blocking is intended to be triggered by initVariants length
  
}
