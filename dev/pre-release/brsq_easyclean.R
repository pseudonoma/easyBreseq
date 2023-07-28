# brsq_easyclean()
# 2nd-layer wrapper function that hopefully streamlines/constrains pipeline usage.
# Combines tidy_output() and QC_output() into a single front-end function that handles
#   checking for basepops and ensuring folder structures etc. are valid.

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
  
}
