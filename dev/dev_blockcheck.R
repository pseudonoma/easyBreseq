# second attempt at attempting to check sets

# construct problem case
badBlocks <- list("vec1" = c("A", "B", "C", "D"),
                  "vec2" = c("A", "B", "C", "D", "E"),
                  "vec3" = c("A", "B", "D", "F", "C"))
goodBlocks <- list("vec1" = c("A", "B", "C", "D"),
                   "vec2" = c("A", "B", "C", "D"),
                   "vec3" = c("A", "C", "D", "B"))

# assign test blocks and target
blocks <- badBlocks
blockIntersect <- Reduce(intersect, blocks)

# function to check identity against a target
blockChecker <- function(currentBlock, blockIntersect){
  result <- currentBlock %in% blockIntersect
  return(result)
}

# new test
outcome <- lapply(blocks, blockChecker, target = blockIntersect)
if(all(sapply(outcome, all))){
  print("Good outcome: All blocks are identical.")
} else{
  print("Bad outcome: Some blocks different.")
}

# test to replace
if(length(blockIntersect) == length(blocks[[1]])){
  print("All blocks identical.")
} else {
  print("Blocks are not identical.")
}


####

# Copied from dev_mutFinders.R

# check that the INIT blocks have the same calls
blockIntersect <- Reduce(intersect, initBlocks)
if(length(blockIntersect) == length(initBlocks[[1]])){
  # if TRUE, then the intersect is total, and all blocks are identical.
  # not quite; lapply against blockIntersect
  cat(paste(length(initPops), "INIT population(s) detected;
                  All INIT populations appear identical."))
  initVariants <- list("initVariants" = blockIntersect)
} else {
  cat("INIT populations appear to be different; consider blocking your samples.")
  initVariants <- initBlocks
  
  # Note to self: 
  # The initVariants step exists because if you have >1 INIT pops that are identical, 
  #   using initBlocks directly will still give you a list >1 length, 
  #   and it can't be used to trigger blocking later.
  
  # TODO: report what mutations do not intersect and what their block is?
}

