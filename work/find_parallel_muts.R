# a little function for finding parallel mutations

find_parallel_muts <- function(data, threshold = 2){
  
  callsData <- cleanData |>
    dplyr::group_by(Gene) |>
    dplyr::summarize(totalCalls = n()) |>
    dplyr::ungroup() |>
    dplyr::filter(totalCalls >= threshold)
  
  df <- data.frame()
  for(gene in callsData$Gene){
    
    strainList <- cleanData$Name[cleanData$Gene == gene] # all strains positive for gene
    hasDuplicates <- unique(strainList[duplicated(strainList)]) # strains with >1 call for gene
    uniqueStrains <- sort(unique(strainList)) # makes calledIn easier to read
    currentData <- data.frame(Gene = gene,
                              totalCalls = callsData$totalCalls[callsData$Gene == gene],
                              calledIn = str_flatten_comma(uniqueStrains),
                              multipleCalls = "None")
    
    # populate column listing what strains a gene appeared multiple times
    if(length(hasDuplicates) > 0){
      currentData$multipleCalls <- sort(hasDuplicates) |>
        str_flatten_comma()
    }
    
    # fill export dataframe
    df <- rbind(df, currentData)
    
  }
  
  
  return(df)
  
}