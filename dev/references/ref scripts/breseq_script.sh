#!/bin/bash

# Set the full path to the reference genome file
REF_GENOME="/home/s4528540/liv/AB3v2.0.gbk"

# Set the number of threads to use for breseq
NUM_THREADS=8

# Set the output directory name
OUTPUT_DIR="breseq_output"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

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
