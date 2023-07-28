#!/bin/bash

# an attempt to understand Oscar's breseq bash script

# some notes about bash:
# env vars are uppercase, so conventionally you don't name vars uppercase

#####

# Define reference genome location
genomePath=. # something .gbk

# Define sequence data location
dataPath=/Users/ian/Desktop/J5079_testrun

# Define # threads (arg passed to breseq call)
threadCount=8

# Define the output directory
outputPath="outputs"

###

# Create output folder
mkdir --parent "$outputPath"

# Begin simple test

# Define variables that usually would be in the loop
filenameR1="$genomePath"/*"_R1_001.fastq.gz"

# Note to self: appears not advisable to create array of filenames, better to just use the
#   filenames directly.


# Extract the sample name from the R1 filename
# This is passed to breseq --name arg that names the output human-readably
sampleName=$(basename "$filenameR1" | cut -d "_" -f 1-2)
# basename: return the string common to a bunch of filenames
# cut: return fields 1 through 2; fields defined by delimiter "_"

# Replace "_R1_" in filename with "_R2_"
filenameR2="${R1_FILE/_R1_/_R2_}"
# syntax is ${var/pattern/replacement}.

# Construct the breseq command
breseqCall="breseq\
-r $genomePath\
$filenameR1\
$filenameR2\
-p\
-j $threadCount\
-n $sampleName\
-o $outputPath/$sampleName"

# Run the breseq command and capture the exit status
printf "Currently running: %s\n" "sampleName"
$breseqCall > $outputPath/$sampleName.log
exitStatus=$?

# Check the exit status and print an error message if it is non-zero
if [ $exitStatus -ne 0 ]; then
# if $EXIT_STATUS not equal to 0
  printf "breseq failed for %s with exit status:\n %s\n" "$sampleName" "$exitStatus"
fi

###
# the loop
# Iterate over the R1 files in the sequences folder
for R1_FILE in /home/s4528540/liv/sequences/*_R1_001.fastq.gz; do
    # Extract the sample name from the R1 filename
    SAMPLE_NAME=$(basename "$R1_FILE" | cut -d "_" -f 1-2)

    # Construct the path to the corresponding R2 file
    R2_FILE="${R1_FILE/_R1_/_R2_}"

    # Construct the breseq command
    BRESEQ_CMD="breseq -r $REF_GENOME $R1_FILE $R2_FILE -p -j $NUM_THREADS -n $SAMPLE_NAME -o $OUTPUT_DIR/$SAMPLE_NAME"

    # Run the breseq command and capture the exit status
    echo "Running breseq for $SAMPLE_NAME..."
    $BRESEQ_CMD > $OUTPUT_DIR/$SAMPLE_NAME.log
    EXIT_STATUS=$?

    # Check the exit status and print an error message if it is non-zero
    if [ $EXIT_STATUS -ne 0 ]; then
        echo "Error running breseq for $SAMPLE_NAME: exit status $EXIT_STATUS"
    fi
done

echo "All breseq commands submitted"




$files expands to the first element of the array. Try echo $files, it will only print the first element of the array. The for loop prints only one element for the same reason.

To expand to all elements of the array you need to write as ${files[@]}.

The correct way to iterate over elements of a Bash array:

for file in "${files[@]}"


