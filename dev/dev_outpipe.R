# scratchpad for planning the breseq output pipeline
# finally, the R portion

# TODO
# [DONE] Import/wrangle
# [DONE] Key rename
# Cleanup & filter by quality
# Filter (ie. user-defined filter)
# Option for reduced dataframe

# name wrapper functions brsq_<verb>
# name helper functions <purpose>

source("./dev/dev_mutFinders.R")
source("./dev/dev_testObjects.R")

#####

brsq_tidy_output(comparisonsFile, 
                  key,
                  format = "full", # or "reduced"
                  save = FALSE)
# Automated quality check and tidying; takes comparisons file post-compareGDs.sh and
#   tidy df, reducing/renaming columns
#   replace <Name> using key
#     return tidied CSV in "full" or "reduced" format for passing downstream

brsq_QC_output(cleanedCompFile,
               options)
# Remove variants that aren't variants
#   conduct basic QC filtering (by coverage)
#   remove calls by overlap with all mutants (likely assembly problems)
#   remove calls by whether it's called at a high freq in the INIT pops
#   TODO decide if actual samples should be blocked, based on whether their INITs are different

brsq_easyfilter()
# Filters based on some (expected) commonly-used criteria
# importantly, note that the intergenic calls at this point are legitimate
#   takes BOTH full and reduced tables
#   filter by one or more <Gene>, <SNP type>, ...
#   remove things like intergenic and hypothetical proteins...
#   remove calls by overlap with INIT (they're already fixed)
#     returns CSV in "full" or "reduced" versions (shouldn't refer to columns in "full" version anyway)

#####

