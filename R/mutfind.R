# QC helper functions for making variant exclusion lists

find_ubiquitous_muts <- function(data, basePrefix, exportTo){

  # drop baseline-type pops (unless there are none, then everything is valid)
  if(!is.null(basePrefix)){
    smallData <- data[!(stringr::str_detect(data$Name, basePrefix)), ]
  } else {
    smallData <- data
  }

  # find mutations that appear in all strains
  mutParsed <- unique(paste0(smallData$Gene, "_", smallData$Nt_pos)) # parse unique mutation name
  mutList <- unique(data.frame("Gene" = smallData$Gene, "Nt_pos" = smallData$Nt_pos))
  evals <- c()
  ubiquitousCalls <- c()
  for(mutation in mutParsed){
    check <- c() # prime/re-prime vector for all() check
    for(sample in unique(smallData$Name)){
      currentSample <- smallData[smallData$Name == sample, ] # subset a single sample
      currentMutations <- paste0(currentSample$Gene, "_", currentSample$Nt_pos) # parse as above
      check <- append(check, mutation %in% currentMutations)
    }
    evals <- append(evals, all(check)) # vector of whether each mutation appears in all strains
    ubiquitousCalls <- mutList[evals, ] # df of mutations that do appear everywhere

  }

  # export list of mutations
  outputPath <- paste0(exportTo, "/intermediates")
  write.csv(ubiquitousCalls, file = paste0(outputPath, "/ubiquitousMuts.csv"), row.names = FALSE)

  cat("Mutations found across all samples are listed in \"/intermediates/ubiquitousMuts.csv\".\n")


  return(ubiquitousCalls)

}

find_basepop_muts <- function(data, basePrefix, mode, exportTo){
  # DEBUG:
  # smallData <- data[!(str_detect(data$Name, basePrefix)), ]

  # separate baseline populations from the data and get their names
  baseData <- data[(stringr::str_detect(data$Name, basePrefix)), ]
  basePops <- unique(baseData$Name)
  if(nrow(baseData) == 0){
    stop("basePrefix is not NULL but no valid baseline populations were found.")
  }

  # Filtering ----------------------------------------------------------------------------

  if(mode == "qc"){ # ====================================================================
    # Identify calls in basepops that are likely artifacts
    # Nt_pos is included when parsing exact mutation is necessary, but not when
    #   excluding by gene alone (eg. exclByCount).

    # Tag 95% variant calls; in basepops these are likely artifacts
    exclByFreq <- baseData |>
      dplyr::select(Gene, Locus_tag, Nt_pos, Frequency)|>
      dplyr::filter(Frequency >= 0.95)

    # [Jan, modded] Tag genes that get called too many times as well
    # TODO: Why does summarize still cause a warning despite being ungroup()ed?
    exclByCount <- baseData |>
      dplyr::group_by(Gene, Locus_tag) |>
      dplyr::summarize(totalCalls = n()) |>
      dplyr::ungroup() |>
      dplyr::filter(totalCalls >= 2*length(basePops))
    # Ideally I think I should somehow aggregate over each block, but for now cutoff is 2*length

    # make export object
    exclusionData <- list("exclByFreq" = exclByFreq, "exclByCount" = exclByCount)

  } else if(mode == "filter"){ # =========================================================
    # By this point all remaining basepop calls are valid, so separate calls into blocks by popName

    # prime objects
    baseBlocks <- list() # final group list
    mutations <- list() # mutation comparison list
    baseVariants <- list() # export object

    # list calls, separating by the baseline population they came from
    for(popName in basePops){
      baseBlocks[[popName]] <- baseData[baseData$Name == popName, ] # assign pops to their blocks
      mutations[[popName]] <- baseBlocks[[popName]][["mutCheck"]] # get list of gene calls per block
    }

    # check that the different basepops (i.e. "blocks") have the same calls
    blockIntersect <- Reduce(intersect, mutations)
    outcome <- lapply(mutations, intersect_blocks, blockIntersect)
    isIdentical <- sapply(outcome, all)

    # prep export objects depending on basepop call intersect
    if(all(isIdentical)){ # BLOCKS ARE IDENTICAL

      # export only one exclusion list, as the only element in the baseVariants list
      baseVariants <- list("baseVariants" = dplyr::select(baseData, Gene, Locus_tag, Nt_pos, mutCheck))

      cat(paste0("\n", length(basePops), " baseline population(s) found; all appear identical.\n"))

    } else { # BLOCKS ARE NOT IDENTICAL

      # export n exclusion lists, n = len(basepops), each an element in baseVariants

      # make list of dfs containing only the ones that pass the identity check
      # do it by mutCheck being in a particular list (that list is blockIntersect)
      for(popName in basePops){
        baseVariants[[popName]] <- baseData |> # assign pops to their blocks
          dplyr::filter(Name == popName) |>
          dplyr::select(Gene, Locus_tag, Nt_pos, mutCheck)

      }

      cat("\nBaseline populations do not have identical calls.\n")

    }

  } else { # actually shouldn't be necessary since the function is back-end
    stop("Invalid mode set!")
  }

  # TODO: report what mutations *don't* intersect and what their block is?

  # Exporting -----------------------------------------------------------------------

  outputPath <- paste0(exportTo, "/intermediates")
  if(mode == "qc"){
    write.csv(exclusionData[["exclByFreq"]] , row.names = FALSE,
              file = paste0(outputPath, "/fixedBasepopCalls.csv"))
    write.csv(exclusionData[["exclByCount"]], row.names = FALSE,
              file = paste0(outputPath, "/poorlyMappedGenes.csv"))

    cat("Baseline mutations excluded for >95% frequency are listed in \"/intermediates/fixedBasepopCalls.csv\".\n")
    cat("Baseline mutations excluded for too many calls are listed in \"/intermediates/poorlyMappedGenes.csv\".\n")

  } else if(mode == "filter"){

    if(length(baseVariants) > 1){ # note to self: stop changing this condition :S
      # basepops were not identical, so the original data (with popnames) in a single CSV
      exportObject <- dplyr::select(baseData, Name, Gene, Locus_tag, Nt_pos, Frequency)

    } else if(length(baseVariants) == 1){
      # basepops were identical, so export just the one list of calls without popnames
      exportObject <- baseVariants[[1]]

    } else {
      stop("baseVariants neither 1 nor >1? That's unpossible! Contact support (Ian) about this.")

    }

    write.csv(exportObject, file = paste0(outputPath, "/baselinePopVariants.csv"), row.names = FALSE)

    cat("Unexcluded baseline mutations are listed in \"/intermediates/baselinePopVariants.csv\".\n")

  }


  if(mode == "qc"){
    return(exclusionData)
  } else if(mode == "filter"){
    return(baseVariants)
  }

}

# function to check basepop blocks; used in find_basepop_muts()
intersect_blocks <- function(currentBlock, blockIntersect){
  result <- currentBlock %in% blockIntersect
  return(result)
}
