
talkback <- function(){
  
  test <- FALSE
  while(!test){
    cat("Oh no, something has happened! Do something about it? Y/N\n")
    response <- readline("Input: ")
    test <- 
      (str_detect(response, regex("Y", ignore_case = TRUE)) |
      str_detect(response, regex("N", ignore_case = TRUE))) &
      nchar(response) == 1
  }
  
  if(stringr::str_detect(response, regex("Y", ignore_case = TRUE))){
    print("Good luck.")
  } else {
    print("That's fine, it'll fix itself. Probably.")
  }
  
}

  
  

if(grep("Y", response, ignore.case = TRUE){
  cat("Your response was affirmative.")
} else if(response == "N"){
  message("YOU FOOL")
  quit()