# "extract"-type functions
# possibility of implementing these in easyfilter() instead of in post
# but I can't really think straight atm

###

extract_by <- function(data, byList, mode = "sample", split = FALSE){
  # ARGS:
  # data - the usual
  # byList - vector of whatever it is defined by mode=
  # mode - "sample" or "gene" only
  # split - if TRUE, each item of byList will be extracted separately and put in a list
  #         if FALSE, all elements of byList exported together in a single dataframe
  # TODO: export - whether to fart out CSVs, idk how to implement this neatly
  
  # TODO: detect if the input vector brings up nothing valid in subsetting
  #   (ie. mismatched byList= and mode=)
  
  # define what to extract by
  if(mode == "sample"){
    coltype <- "Name"
  } else if(mode == "gene"){
    coltype <- "Gene"
  } else if(mode == "type"){
    coltype <- "Mutation_type"
  } else {
    stop("mode not supported, only \"sample\" or \"gene\" is available")
  }
  
  if(split){
    exportList <- list()
    for(b in byList){
      exportList[[b]] <- data[data[[coltype]] %in% b, ]
    }
  } else {
    exportData <- data[data[[coltype]] %in% byList, ]
  }
  
  # export as CSV
  # Alternatively, handle CSV export in the pipeline and not here
  # if(export){
  #   stop("No exporting implemented at this time.")
  #   # do some CSV shit
  # }
  
  # # reference code for exporting CSVs
  # if(!is.null(byGene)){
  #   if(byGene == "all"){byGene <- unique(data$Gene)}
  #   
  #   for(currentGene in byGene){
  #     geneData <- data[data$Gene == currentGene, ]
  #     write.csv(geneData, row.names = FALSE, 
  #               file = paste0(outputPath, "mutationsByGene_", currentGene, ".csv"))
  #   }
  #   cat("Mutations specified by gene are in mutationsByGene_*_.csv\n")
  # }
  
  
  if(exists("exportList")){
    return(exportList)
  } else if(exists("exportData")){
    return(exportData)
  }
  
}

#####

# # previous ungeneralized implementation
# extract_samples <- function(data, samples, split = FALSE, export = FALSE){
# 
#   if(split){
#     exportList <- list()
#     for(s in samples){
#       exportList[[s]] <- data[data$Name %in% s, ]
#     }
#   } else {
#     exportData <- data[data$Name %in% samples, ]
#   }
# 
#   # export as CSV
#   if(export){
#     stop("No exporting implemented at this time.")
#     # do some CSV shit
#   }
# 
# 
#   if(exists("exportList")){
#     return(exportList)
#   } else if(exists("exportData")){
#     return(exportData)
#   }
# 
# }
