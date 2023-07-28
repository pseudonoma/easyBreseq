#!/bin/bash

# "compare_GDs.sh"
# Another simple script to automatically collate all output.gd files after an easy_breseq run.

# Required folder structure is one <parentDir>; with
#   one child folder "references", containing the refFile(s).
#
# If you've run easy_breseq.sh the correct folder structure should already exist, and you
# shouldn't have to change much.
# This script outputs a CSV file called "comparisons.csv" to /output, which contains all
# mutations in a detailed manner. For more information call "gdtools compare" in the terminal.
# If working on Windows, remember to run dos2unix after editing this script.


# v0.1; last updated 06/06/23

################################################################################

### User-defined variables ###

parentDir=/mnt/k/SRSBZNZ/breseq
refFile="AB3_v2.2.gb"

### Don't change anything under this line ###

# Define other vars
outputDir=$parentDir/output
reference=$parentDir/references/$refFile
logDir=$outputDir/_logs

# Create folder for copied .GD files
mkdir -p $outputDir/_gd

# Copy output.gd files from respective sample output folders and rename
for gdfile in $parentDir/output/*/output/output.gd; do
    parent=$(dirname "$gdfile") # get ".." path
    samplePath=$(dirname "$parent")
    sampleName=$(basename "$samplePath")
    cp "$gdfile" "$parentDir/output/_gd/$sampleName.gd"
done

printf "\n.GD files have been copied to folder $outputDir/_gd\n\n"

# run gdtools COMPARE
printf "Running gdtools COMPARE...\n"
gdtools compare -r "$reference" -o $outputDir/comparisons.csv -f CSV $outputDir/_gd/*.gd \
1> /dev/null \
2> >(tee $logDir/comparisons.log >&2)
# running -f CSV/TSV sends file contents to stdout for some reason, so suppress stdout
# and tee stderr for later eyeballing.

# Report outcome
exitStatus=$?
if [ $exitStatus -ne 0 ]; then
   printf "\n\ngdtools failed with exit code %s. Check $logDir/comparisons.log for details.\n" "$exitStatus"
else
   printf "\n\nDone. Comparison file is at $outputDir/comparisons.csv\n"
   printf "Sample output.gd files were copied to $outputDir/_gd\n"
fi


# end. #
