#!/bin/bash

# "easy_breseq.sh"
# A simple script to automatically run breseq over multiple samples in a reasonable way.

# Required folder structure is one <parentDir>; with 
#   one child folder "data", containing reads; and
#   one child folder "references", containing the refFile(s).
#
# Reads are assumed to be in pairs, with filenames differing by the pattern *_R1_* vs *_R2_*.
# If working on Windows, remember to run dos2unix after editing this script.
#
# There's also an option to automatically replace tags in GENBANK reference sequences,
# which isn't useful anymore so it's currently disabled. This would have created a new 
# reference file "<refFile>_fixed.gb", which would then have been used for the breseq run.


# v0.2.1; last updated 09/06/23
# Heavily based on work by O. Delaney.

################################################################################

### User-defined variables ###

parentDir=/mnt/k/SRSBZNZ/breseq
refFile="AB3_220.gb" # reference filename; might be able to automate assigning different refs?
threadCount=10 # CPU threads to use for multithreading, nominally 1 thread/core

### No touchy anything below this line ###

# Define the rest of the path variables
dataDir=$parentDir/data # sequence data location
refDir=$parentDir/references # reference genome location
outputDir=$parentDir/output # breseq outputs, each sampleName a child folder
logDir=$outputDir/_logs # breseq stdout and stderr logs
reference=$refDir/$refFile # absolute path to the reference genome

# Create folders ("-p" creates parent dirs as required)
mkdir -p $outputDir
mkdir -p $logDir

### DISABLED ###################################################################
# Define tags and fix reference sequence
oldTag=
newTag=
# TODO: possibly make this user-defined if I can somehow shield users from regex shenanigans

if [ -n "$oldTag" ]; then
    # Using -z ${oldTag+x} will detect if oldTag is also NULL, not just unset;
    # in this case, I've deliberately used "$oldTag" so a NULL oldTag ("") is treated like unset.
    # -z checks for if value is zero, -n checks for nonzero

    refFileNew=$(basename $refFile .gb)"_fixed.gb" # extract refFile without ext and change name
    sed 's/'"$oldTag"'/'"$newTag"'/' $reference > $refDir/$refFileNew # sed to a new file
    # see https://askubuntu.com/a/76842 for why this is quoted like that

    reference=$refDir/$refFileNew # reassign reference file
    printf "\nFixed reference file; the new file is ./references/%s\n" "$refFileNew"

fi
################################################################################

# Begin looping over files
for filenameR1 in $dataDir/*"_R1_001.fastq.gz"; do # might be able to variable-ize the glob?
  
  if [ -e "$filenameR1" ] ; then # if --exists "filenameR1"
    
    # Extract sample name from the R1 filename
    sampleName=$(basename "$filenameR1" | cut -d "_" -f 1-2)
  
    # Replace the "R1" in filenameR1 with "R2" and keep the rest
    filenameR2="${filenameR1/_R1_/_R2_}"
  
    # Construct the breseq command; if this is borked it's probably the backticks/spaces
    breseqCall="breseq \
    -r $reference \
    $filenameR1 \
    $filenameR2 \
    -p \
    -j $threadCount \
    -n $sampleName \
    -o $outputDir/$sampleName"
    
    # Run the breseq command and capture the exit status
    printf "\nRunning sample %s now...\n" "$sampleName"
    set -o pipefail # otherwise exitStatus reports result of tee instead
    $breseqCall 2>&1 | tee $logDir/$sampleName.log  # combine stderr("2") into stdout, then tee; 
    #   seems most of the stuff displayed in terminal is stderr, so using $exitStatus to 
    #   check log file for errors is impossible if only logging stdout.
    # Also, seems in bash 2>&1 is the same as &>
    exitStatus=$?
    set +o pipefail # reset it for neatness
    
    # TODO:
    # implemented teeing stdout, but maybe hiding it behind a progress bar would be nice?
    # might be neater to hide all stdout except the printfs, and use a progress bar
  
    # Log/display the error status for a sample, if there is one
    if [ $exitStatus -ne 0 ]; then
      printf "%s Error running sample %s: exit code was %s\n" \
      "$(date '+%d/%m/%y %H:%M:%S')" "$sampleName" "$exitStatus" \
      | tee -a $logDir/errors.log # -a is comparable to >>; > is "clobbering" lmao
    fi
  
  fi
  
done


# end. #
