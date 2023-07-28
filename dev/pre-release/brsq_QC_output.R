# brsq_QC_output()

brsq_QC_output <- function(data, basePrefix = NULL){
  
  # this shouldn't be necessary given the planned pipeline order, I think
  if(!dir.exists("./results")){
    stop("\"results\" folder does not exist! This shouldn't have happened...")
  } else {
    dir.create("./results/intermediates", showWarnings = FALSE)
  }
  
  # add mutCheck column (seems to keep getting used)
  data <- data |>
    dplyr::mutate(mutCheck = paste0(Locus_tag, "_", Nt_pos))
  
  # OPTIONAL: Work on baseline pop-based exclusions if necessary
  if(!is.null(basePrefix)){
    
    # get baseline pop exclusion data and parse appropriate test vectors
    exclBase <- find_basepop_muts(data, basePrefix, mode = "qc")
    freqExList <- paste0(exclBase$exclByFreq$Locus_tag, "_", exclBase$exclByFreq$Nt_pos) # 95% calls
    countExList <- exclBase$exclByCount # too many calls in a gene
    
    # filter
    data <- data |>
      dplyr::filter(!(mutCheck %in% freqExList)) |> # drop by freq
      dplyr::filter(!(Locus_tag %in% countExList$Locus_tag)) # drop by # of calls  

  }
  
  # Work on other exclusions
  # get ubiquitous call exclusion data and parse
  exclUbis <- find_ubiquitous_muts(data, basePrefix) # df; calls common to all samples
  ubiExList <- paste0(exclUbis$Gene, "_", exclUbis$Nt_pos)
  
  # filter
  data <- data |>
    dplyr::filter(!(mutCheck %in% ubiExList)) |>
    dplyr::filter((Coverage_mut + Coverage_original >= 100) & (Coverage_mut >= 5))
  
  # remove mutCheck column and prepare for export
  outputData <- data |>
    dplyr::select(-mutCheck)
  
  # export
  outputPath <- "./results/"
  outputName <- "01_QCedOutput.csv"
  write.csv(outputData, file = paste0(outputPath, outputName), row.names = FALSE)
  
  cat("Done! ")
  cat(paste0("QC'ed comparisons have been saved as ", outputName, "\n"))
  
  return(outputData)
  
} # end brsq_QC_output().
