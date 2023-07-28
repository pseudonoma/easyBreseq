#!/bin/bash

# almost there bitches

### user-defined variables ###

# Global variables
parentDir=/Users/ian/Desktop/J5079_testrun
dataDir=$parentDir/data # sequence data location
refDir=$parentDir/references # reference genome location; GENBANK format
threadCount=10 # threads to use
refFile="AB3.gb" # reference filename; might be able to automate assigning different refs?

### No touchy anything below this line ###

# Create folders ("-p" creates parent dirs as required)
mkdir -p $parentDir/output # processed output folder
mkdir -p $outputDir/logs # breseq call log folder

# Define the rest of the path variables
outputDir=$parentDir/output
logDir=$outputDir/logs
reference=$refDir/$refFile

# Begin looping over files
for filenameR1 in $dataPath/*"_R1_001.fastq.gz"; do
  
  # Extract sample name from the R1 filename
  sampleName=$(basename "$filenameR1" | cut -d "_" -f 1-2)
  
  # Replace the "R1" in filenameR1 with "R2" and keep the rest
  filenameR2="${filenameR1/_R1_/_R2_}"
  
  # debug
  echo
  echo "#####"
  echo "BEGIN SET"
  printf "Reference path: %s\n" "$reference"
  printf "filenameR1: %s\n" "$filenameR1"
  printf "filenameR2: %s\n" "$filenameR2"
  printf "threadCount: %s\n" "$threadCount"
  printf "sampleName: %s\n" "$sampleName"
  printf "output location: %s\n" "$outputDir/$sampleName"

  # Construct the breseq command; if borked it's probably the backticks
  breseqCall="breseq \
  -r $reference \
  $filenameR1 \
  $filenameR2 \
  -p \
  -j $threadCount \
  -n $sampleName \
  -o $outputDir/$sampleName"
  
  # Run the breseq command and capture the exit status
  echo
  printf "\nRunning sample %s now...\n" "$sampleName"
  $breseqCall | tee $logDir/$sampleName.log # using > would entirely redirect to log
  exitStatus=$?
  # currently teeing stdout but maybe hiding it behind a progress bar would be nice?

  # Check the exit status and print an error message if it is non-zero
  if [ $exitStatus -ne 0 ]; then
    printf "Error running sample %s: exit status was %s" "$sampleName" "$exitStatus" \
      | tee >> $logDir/errors.log
  fi

done

