# a little function for finding parallel mutations

find_parallel_muts <- function(data, threshold = 2){
  # ARGS:
  # data - post-filter data, but should also work post-QC
  # threshold - # calls above which it's considered "parallel"; can't seem to justify anything
  #   above/below 2, maybe it should be set by default?
  
  callsData <- data |>
    dplyr::group_by(Gene) |>
    dplyr::summarize(totalCalls = n()) |>
    dplyr::ungroup() |>
    dplyr::filter(totalCalls >= threshold)
  
  exportData <- data.frame()
  for(gene in callsData$Gene){
    
    strainList <- data$Name[data$Gene == gene] # all input strains positive for gene
    hasDuplicates <- unique(strainList[duplicated(strainList)]) # strains with >1 call for gene
    uniqueStrains <- sort(unique(strainList)) # makes calledIn easier to read
    currentData <- data.frame(Gene = gene,
                              totalCalls = callsData$totalCalls[callsData$Gene == gene],
                              calledIn = str_flatten_comma(uniqueStrains),
                              multipleCalls = "None")
    
    # populate column listing strains in which <gene> appeared multiple times
    if(length(hasDuplicates) > 0){
      currentData$multipleCalls <- sort(hasDuplicates) |>
        str_flatten_comma()
    }
    
    # fill export dataframe
    exportData <- rbind(exportData, currentData)
    
  }
  
  
  return(exportData)
  
}