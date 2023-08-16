# brsq_easyclean()
# 2nd-layer wrapper function that hopefully streamlines/constrains pipeline usage.
# Combines tidy_output() and QC_output() into a single front-end function that handles
#   checking for basepops and ensuring folder structures etc. are valid.

#' @param data The comparisons.csv file to be wrangled and cleaned
#' @param nameKey Sample key file, a CSV with, at minimum, the columns Sample, and Key. For a given
#' sample, Sample is the value that appears under the column Name in comparisons.csv, and Key is
#' the value that Name should be renamed to. If you have more than one baseline population (see
#' below), an additional column Block can be used to designate which samples belong together. The
#' column Block must be the values of the baseline population they are to be grouped by.
#' @param basePrefix The prefix of your baseline population samples. This can be the population
#' used to initialize your experiment, a wildtype sample that should ideally have no variant calls,
#' or some other sample that can be used to establish a baseline set of variants that can then be
#' excluded from your actual samples. If you have more than one of these, eg. if your samples were
#' initialized with different overnight cultures, the nameKey column Block will be used to group
#' samples to their appropriate baseline population.
#' @param exportFormat "full" is the default, and outputs 31 columns. "reduced" returns 19 columns,
#' removing more verbose/expanded columns in favour of a more compact format. For a full list of
#' columns, check the code.
#' 

brsq_easyclean <- function(data, nameKey, basePrefix = NULL, exportFormat = "full"){
  
  # Overwrite protection
  if(dir.exists("./results")){
    
    inputIsValid <- FALSE
    while(!inputIsValid){
      message("\n\"results\" folder already exists! Proceed to overwrite it PERMANENTLY? Y/N")
      userResponse <- readline("Input: ")
      inputIsValid <- 
        (stringr::str_detect(userResponse, stringr::regex("Y", ignore_case = TRUE)) |
           stringr::str_detect(userResponse, stringr::regex("N", ignore_case = TRUE))) &
        nchar(userResponse) == 1
      
    }
    
    # Create results folder
    if(stringr::str_detect(userResponse, stringr::regex("Y", ignore_case = TRUE))){
      # userResponse has to already be exactly y/n before it gets to this point
      message("Overwriting \"results\" folder.")
      unlink("./results/", recursive = TRUE) # would it be safer to just dump new stuff into it?
      dir.create("./results", showWarnings = FALSE)
    } else {
      message("\"results\" folder was not overwritten. Manage it manually and re-run the pipeline.")
      return()
    }
    
  } else {
    dir.create("./results", showWarnings = FALSE)
    
  }
  
  # Run pipeline
  cleanedData <- data |>
    brsq_tidy_output(nameKey, exportFormat) |>
    brsq_QC_output(basePrefix)
  
  
  return(cleanedData)
  
} # end brsq_easyclean().

#####

# brsq_easyfilter()
# Handles the most likely filtering steps after the data has been QC'ed.

#' @param data The cleaned CSV outputted by brsq_easyclean().
#' @param basePrefix See brsq_easyclean().
#' @param removeLocusGenes Drop variant calls that have genes named by their locus tags. This may
#' be due to the CDS being a hypothetical protein, or some other incomplete annotation. This option
#' drops variants that are name *only* "ACIAD...", and leaves intact any genes that are named with
#' at least one legitimate gene abbreviation.
#' @param removeIntergenic  Drop any calls that are mapped to intergenic regions.
#' @param removeBaseMuts Drop calls that also occur in the relevant baseline population(s). This
#' drops legitimate baseline pop calls, as by this point in the pipeline any illegitimate calls 
#' will already have been removed.
#' @param byGene Takes either a vector of gene abbreviations eg. c("rpsL", "rpoB") or simply "all".
#' If a vector, each gene will be exported as a separate CSV. If "all", all unique genes will be
#' exported in this manner.
#' @param byMutType Similar to byGene; mutTypes are "SNP", "SUB", "INS", and "DEL". Also takes "all".
#' @param byBlock Simliar to byGene; if blocks exist, exports by block in the same manner. Also
#' takes "all".

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
    
    # separate basepops from data, or exclusion will take them out too. D'oh.
    baseData <- data[(str_detect(data$Name, basePrefix)), ]
    
    # generate basepop-based exclusion list
    exclBase <- find_basepop_muts(data, basePrefix, mode = "filter")
    
    # filter
    if(length(exclBase) == 1){ # reminder: blocking deliberately triggered by baseVariants length
      data <- dplyr::filter(data, !mutCheck %in% exclBase[[1]][["mutCheck"]])
      data <- rbind(data, baseData)
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
      cat("Removing variants by their baseline population blocks...\n")
      data <- rbind(gluedData, baseData)
      
      # TODO: "blocks supplied but no blocking necessary" or something
    }
    
  }
  
  if(removeLocusGenes){
    data <- data[!(data$Gene == data$Locus_tag), ]
    cat("Removing variants where genes were named by \"locus_tag\" only...\n")
  }
  
  if(removeIntergenic){
    data <- data[!str_detect(data$Nt_pos, "intergenic"), ]
    cat("Removing intergenic variant calls...\n")
  }
  
  # PART 2: REDUCTIONS ===================================================================
  
  outputPath <- "./results/"
  
  # remove mutCheck for final filtering and/or export
  data <- dplyr::select(data, -mutCheck)
  
  # Begin filtering steps
  if(!is.null(byGene)){
    
    if(length(byGene) == 1){
      if(byGene == "all"){byGene <- unique(data$Gene)}
    }
    
    for(currentGene in byGene){
      geneData <- data[data$Gene == currentGene, ]
      write.csv(geneData, row.names = FALSE, 
                file = paste0(outputPath, "mutationsByGene_", currentGene, ".csv"))
    }
    cat("Mutations specified by gene are in mutationsByGene_*_.csv\n")
  }
  
  if(!is.null(byMutType)){
    
    if(length(byMutType) == 1){
      if(byMutType == "all"){byMutType <- unique(data$Mutation_type)}
    }
    
    for(currentType in byMutType){
      typeData <- data[data$Mutation_type == currentType, ]
      write.csv(typeData, row.names = FALSE, 
                file = paste0(outputPath, "mutationsByType_", currentType, ".csv"))
    }
    cat("Mutations specified by mutation type are in mutationsByType_*_.csv\n")
  }
  
  if(!is.null(byBlock)){
    
    if(length(byBlock) == 1){
      if(byBlock == "all"){byBlock <- unique(data$Block)}
    }
    
    for(currentBlock in byBlock){
      blockData <- data[data$Block == currentBlock, ]
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
  
} # end brsq_easyfilter().
