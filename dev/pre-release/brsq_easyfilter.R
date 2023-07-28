# brsq_easyfilter()

brsq_easyfilter <- function(data, basePrefix = NULL,
                            removeLocusGenes = FALSE,
                            removeIntergenic = FALSE,
                            removeBaseMuts = FALSE,
                            byGene = NULL, # all "by" options take a vector or "all"
                            byMutType = NULL,
                            byBlock = NULL){
  
  # add mutCheck column (like in QC_output())
  data <- data |>
    dplyr::mutate(mutCheck = paste0(Locus_tag, "_", Nt_pos))
  
  # PART 1 : GLOBAL FILTERS ==============================================================
  
  if(removeBaseMuts){
    # This is being run first because it seems less destructive to run the filters from
    # least to most (likely to be?) broad
    
    if(is.null(basePrefix)){
      stop("removeBaseMuts is TRUE but no basePrefix was provided for doing this!")
    }
    
    # generate basepop-based exclusion list
    exclBase <- find_basepop_muts(data, basePrefix, mode = "filter")
    
    # filter
    if(length(exclBase) == 1){ # reminder: blocking deliberately triggered by baseVariants length
      data <- dplyr::filter(data, !mutCheck %in% exclBase[[1]][["mutCheck"]])
    } else {
      blocks <- unique(data$Block)
      gluedData <- data.frame()
      for(currentBlock in blocks){
        # TODO: Get Jan to look at this and check if it's actually deleting by blocks
        currentData <- dplyr::filter(data[data$Block == currentBlock, ], 
                                     !mutCheck %in% exclBase[[currentBlock]][["mutCheck"]])
        gluedData <- rbind(gluedData, currentData)
      } # newData gets overwritten, append then turn it into data outside the loop?
      
      # Return data
      cat("Variants have been removed according to their baseline population blocks.\n")
      data <- gluedData
      
      # TODO: "blocks supplied but no blocking necessary" or something
    }
    
  }
  
  if(removeLocusGenes){
    data <- data[!(data$Gene == data$Locus_tag), ]
  }
  
  if(removeIntergenic){
    data <- data[!str_detect(data$Nt_pos, "intergenic"), ]
  }
  
  
  
  # PART 2: REDUCTIONS ===================================================================
  
  outputPath <- "./results/"
  
  # remove mutCheck for final filtering and/or export
  data <- dplyr::select(data, -mutCheck)
  
  # Begin filtering steps
  if(!is.null(byGene)){
    if(byGene == "all"){byGene <- unique(data$Gene)}
    
    for(currentGene in byGene){
      geneData <- data[data$Gene == currentGene, ]
      write.csv(geneData, row.names = FALSE, 
                file = paste0(outputPath, "mutationsByGene_", currentGene, ".csv"))
    }
    cat("Mutations specified by gene are in mutationsByGene_*_.csv\n")
  }
  
  if(!is.null(byMutType)){
    if(byMutType == "all"){byMutType <- unique(data$Mutation_type)}
    
    for(currentType in byMutType){
      typeData <- data[data$Mutation_type == currentType, ]
      write.csv(typeData, row.names = FALSE, 
                file = paste0(outputPath, "mutationsByType_", currentType, ".csv"))
    }
    cat("Mutations specified by mutation type are in mutationsByType_*_.csv\n")
  }
  
  if(!is.null(byBlock)){
    if(byBlock == "all"){byBlock <- unique(data$Block)} # could be implemented for the others too?
    
    for(currentBlock in byBlock){
      blockData <- data[data$Name == currentBlock, ]
      write.csv(blockData, row.names = FALSE, 
                file = paste0(outputPath, "mutationsByBlock_", currentBlock, ".csv"))
    }
    cat("Mutations specified by block are in mutationsByBlock_*_.csv\n")
  }
  
  # Export full mutation table as well
  outputName <- "02_cleanedOutput.csv"
  write.csv(data, row.names = FALSE, 
            file = paste0(outputPath, outputName))
  
  cat("\nDone! ")
  cat(paste0("The cleaned comparisons file has been saved as ", outputName, "\n"))
  
  
  return(data)
  
}
