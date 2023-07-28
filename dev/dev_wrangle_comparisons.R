# finally, the R portion

# TODO
# [DONE] Import/wrangle
# [DONE] Key rename
# Cleanup & filter by quality
# Filter (ie. user-defined filter)

library(tidyverse)

# overall function

# import source file
data <- read.csv("./data/comparisons_v2-1-0.csv")

# create new data frame with appropriate column names
cleanData <- data.frame(Name = data$title,
                      Gene = data$gene_name,
                      Nt_pos = data$gene_position,
                      Nt_original = data$ref_seq,
                      Nt_mutation = data$new_seq,
                      Nt_OtoM = paste(data$ref_seq, "->", data$new_seq),
                      Nt_mut_name = paste0(data$gene_name, "_", 
                                           data$ref_seq, data$gene_position, data$new_seq),
                      Codon_original = data$codon_ref_seq,
                      Codon_mutation = data$codon_new_seq,
                      Codon_OtoM = paste(data$codon_ref_seq, "->", data$codon_new_seq),
                      AA_pos = data$aa_position,
                      AA_original = data$aa_ref_seq,
                      AA_mutation = data$aa_new_seq,
                      AA_OtoM = paste(data$aa_ref_seq, "->", data$aa_new_seq),
                      AA_mut_name = paste0(data$gene_name, "_", 
                                           data$aa_ref_seq, data$aa_position, data$aa_new_seq),
                      Frequency = data$frequency,
                      Product = data$gene_product,
                      Locus = data$locus_tag,
                      Genome_pos = data$position,
                      Genome_start = data$position_start,
                      Genome_end = data$position_end,
                      Reference = data$seq_id,
                      Coverage_mut = data$new_read_count,
                      Cvrg_mut_basis = data$new_read_count_basis,
                      Coverage_original = data$ref_read_count,
                      Cvrg_org_basis = data$ref_read_count_basis,
                      Mutation_type = data$type,
                      Mut_type_SNP = data$snp_type,
                      Mut_category = data$mutation_category,
                      Mut_size = data$size)



# key <- read.csv("./data/sample key.csv")
key <- data.frame(Sample = c("SE7909", "SE7910", "SE7911"),
                  Job = "J5079",
                  Key = c("Sample 1", "Sample 2", "Sample 3"))

# implement rename
for(i in 1:nrow(key)){
  cleanData[["Name"]][str_detect(cleanData[["Name"]], 
                                  key[["Sample"]][i])] <- key[["Key"]][i]
}

# fix inappropriately parsed columns
# TODO decide between NA or "".
cleanData$Nt_OtoM[(cleanData$Nt_original == "") | (cleanData$Nt_mutation == "")] <- NA
cleanData$Nt_mut_name[(cleanData$Nt_original == "") | (cleanData$Nt_mutation == "")] <- NA
cleanData$Codon_OtoM[(cleanData$Codon_original == "") | (cleanData$Codon_mutation == "")] <- NA
cleanData$AA_OtoM[(cleanData$AA_original == "") | (cleanData$AA_mutation == "")] <- NA
cleanData$AA_mut_name[(cleanData$AA_original == "") | (cleanData$AA_mutation == "")] <- NA


# filter (by quality/other heuristics)
cleanData <- cleanData |>
  filter((Coverage_mut + Coverage_original >= 100) & (Coverage_mut >= 5)) #|>

# filter (by gene/other user input)
testData <- cleanData |>
  filter(!(Gene == Locus))


### testing and debugging ###

# # create test dfs for rename
# targetData <- data.frame(Name = c("SE7910_J5079", "SE7911_J5079", "SE7912_J5079", "SE7909_J5079"),
#                          Value = LETTERS[1:4],
#                          Number = 1:4)
# testKey <- data.frame(Sample = c("SE7910", "SE7911", "SE4-00", "SE7912", "SE8000", "SE7909", "SESESE", "J5079"),
#                       Job = "J5079",
#                       Key = paste("Sample", 1:8))


