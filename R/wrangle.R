# brsq_tidy_output()

brsq_tidy_output <- function(file, sampleKey = NULL, format){
  
  # Import source file
  data <- read.csv(file)
  
  # Create new data frame with appropriate column names
  # cols marked ### are dropped when format = "reduced"
  data <- data.frame(Name = data$title,
                     Block = NA,
                     Gene = data$gene_name,
                     Nt_pos = data$gene_position,
                     Nt_original = data$ref_seq, ###
                     Nt_mutation = data$new_seq, ###
                     Nt_OtoM = paste(data$ref_seq, "->", data$new_seq),
                     Nt_mut_name = paste0(data$gene_name, "_", 
                                          data$ref_seq, data$gene_position, data$new_seq),
                     Codon_original = data$codon_ref_seq, ###
                     Codon_mutation = data$codon_new_seq, ###
                     Codon_OtoM = paste(data$codon_ref_seq, "->", data$codon_new_seq),
                     AA_pos = data$aa_position,
                     AA_original = data$aa_ref_seq, ###
                     AA_mutation = data$aa_new_seq, ###
                     AA_OtoM = paste(data$aa_ref_seq, "->", data$aa_new_seq),
                     AA_mut_name = paste0(data$gene_name, "_", 
                                          data$aa_ref_seq, data$aa_position, data$aa_new_seq),
                     Frequency = data$frequency,
                     Product = data$gene_product,
                     Locus_tag = data$locus_tag,
                     Genome_pos = data$position,
                     Genome_start = data$position_start, ###
                     Genome_end = data$position_end, ###
                     Reference = data$seq_id,
                     Coverage_mut = data$new_read_count,
                     Coverage_original = data$ref_read_count,
                     Cvrg_mut_basis = data$new_read_count_basis, ###
                     Cvrg_org_basis = data$ref_read_count_basis, ###
                     Mutation_type = data$type,
                     Mut_type_SNP = data$snp_type,
                     Mut_category = data$mutation_category, ###
                     Mut_size = data$size) ###
  
  # Fix inappropriately parsed and blank values
  data$Nt_OtoM[(data$Nt_original == "") | (data$Nt_mutation == "")] <- NA
  data$Nt_mut_name[(data$Nt_original == "") | (data$Nt_mutation == "")] <- NA
  data$Codon_OtoM[(data$Codon_original == "") | (data$Codon_mutation == "")] <- NA
  data$AA_OtoM[(data$AA_original == "") | (data$AA_mutation == "")] <- NA
  data$AA_mut_name[(data$AA_original == "") | (data$AA_mutation == "")] <- NA
  data[data == ""] <- NA # not sure why/how this actually works
  
  # Load key & use it
  if(!is.null(sampleKey)){
    
    key <- read.csv(sampleKey)
    colnames(key) <- tolower(colnames(key)) # deals with inconsistent user colnames
    
    # assign blocks
    if("block" %in% colnames(key)){
      for(i in 1:nrow(key)){
        data$Block[stringr::str_detect(data$Name, key$sample[i])] <- key$block[i]
      }
    } else {
      warning("No blocks were detected. To enable sample blocking, make sure sampleKey has a column called \"block\".")
    }
    
    # rename
    for(i in 1:nrow(key)){
      data$Name[stringr::str_detect(data$Name, key$sample[i])] <- key$key[i]
      # has to be done after block assignment or things get irritating
    }
    # Alternate implementation is to use key<JobID> col to parse sampleID_JobID pattern for string
    # detection. Not sure if this is more robust than just detecting sampleID directly.
    
    # Also, rename has to be done after block assigning or things get irritating.
    
  }
  
  # Reduce dataframe if required
  if(format == "reduced"){
    drops <- c("Nt_original", "Nt_mutation",
               "Codon_original", "Codon_mutation",
               "AA_original", "AA_mutation",
               "Genome_start", "Genome_end",
               "Cvrg_mut_basis", "Cvrg_org_basis",
               "Mut_category", "Mut_size")
    data <- data[ ,!(names(data) %in% drops)]
  } else if(!(format == "full" | format == "reduced")){
    warning("\"format\" argument is invalid; defaulting to \"full\" output.")
  }
  
  # Save/export
  exportFolder <- "./results/"
  baseName <- tools::file_path_sans_ext(basename(file))
  write.csv(data, row.names = FALSE,
            file = paste0(exportFolder, baseName, "_tidied", ".csv"))
  
  
  return(data)
  
} # end brsq_tidy_output().

#####

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
