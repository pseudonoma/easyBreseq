# functions for delivering the bash executables and checking if parentDir structure is
# sensible (instead of doing it on the bash side)

get_breseq_scripts <- function(saveTo, check.structure = TRUE){
  
  scriptPaths <- c(breseqFile = system.file("extdata", "easy_breseq", package = "easyBreseq"),
                   compareFile = system.file("extdata", "compare_GDs", package = "easyBreseq"))
  exportPath <- "/scripts"
  
  if(check.structure){
    # check directory structure of target parentDir is sensible
    print("Assuming check passed.")
    dir.create(paste0(saveTo, exportPath))
  }
  
  # copy files
  for(path in scriptPaths){
    success <- file.copy(path, paste0(saveTo, exportPath), copy.mode = TRUE)
    if(success != TRUE){
      warning(paste(basename(path)), "failed to export. Does it already exist?")
    }
  }
  
}

# function to check if parentDir is nominally sensible
check_dir <- function(parentDir){
  # ARGS:
  # parentDir - the data folder to check
  
  if(dir.exists("/data")){
    # count data files
    # div/2 for total samples
    # parse start and end samples
    # check if samples are consecutive
  } else {
    # report that data folder does not exist or is misnamed
  }
  
  if(dir.exists("/references")){
    # check that there's at least one reference file and that it ends with ".gb"
      # report if the folder is empty
    # if >1 reference file, report
  } else {
    # report that references folder does not exist or is misnamed
  }
  
}