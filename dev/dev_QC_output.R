# brsq_QC_output()

# Remove variants that aren't variants
#   [DONE] conduct basic QC filtering (by coverage, ...)
#   [DONE] remove calls by overlap with all mutants (likely assembly problems)
#   [DONE] remove calls by overlap with INIT (they're already fixed)
# [DONE] PROBLEM: need to check if the two inits are identical; what does it mean if they're not?
# [DONE]  How do I implement a way to deal with the sample blocks? Is it worth automating this?
# [DONE] PROBLEM: What if there's no initPrefix?

brsq_QC_output <- function(data, initPrefix = NULL){
  # ARGS: 
  # data - tidied comparisons df
  # initPrefix - strainID prefix of initpops. Defaults NULL, which assumes all samples equivalent.
  
  # DEBUG
  # initPrefix <- "REP"
  
  # this shouldn't be necessary given the planned pipeline order, I think
  dir.create("./outputs")
  
  # build mutation exclusion lists
  ubiquitousMuts <- find_ubiquitous_muts(data, initPrefix) # calls in all samples
  if(!is.null(initPrefix)){initpopMuts <- find_initpop_muts(data, initPrefix)} # fixed INIT calls
  
  # exclude initpop mutations if possible
  if(exists("initpopMuts")){ 
    if(length(initpopMuts) == 1){ # reminder: length triggers blocking
      outputData <- dplyr::filter(data, !Gene %in% initpopMuts[[1]]) # exclude initpop calls
    } else { # TODO: implement blocking somehow
      cat("\nBlocking should be now active, but isn't implemented at the moment :(\n")
      outputData <- dplyr::filter(data, !Gene %in% initpopMuts[[1]])
    }
  }
  
  # complete the rest of the filtering
  outputData <- data |>
    dplyr::filter((Coverage_mut + Coverage_original >= 100) & (Coverage_mut >= 5)) |>
    dplyr::filter(!Gene %in% ubiquitousMuts)
  
  
  return(outputData)
  
} # end brsq_QC_output().
