#!/bin/bash

# Copy the output files to one directory

# Set the path to the breseq output directory
BRESEQ_DIR="/home/s4528540/liv/breseq_output"

# Set the path to the output directory for the annotated.gd files
ANNOTATED_GD_DIR="/home/s4528540/liv/breseq_annotated_gd"

# Create the output directory if it doesn't exist
mkdir -p "$ANNOTATED_GD_DIR"

# Copy the annotated.gd file for each sample to the output directory
for SAMPLE_DIR in "$BRESEQ_DIR"/*/; do
    SAMPLE_NAME=$(basename "$SAMPLE_DIR")
    ANNOTATED_GD_FILE="$SAMPLE_DIR/data/annotated.gd"
    OUTPUT_FILE="$ANNOTATED_GD_DIR/$SAMPLE_NAME.gd"
    echo "Copying $ANNOTATED_GD_FILE to $OUTPUT_FILE..."
    cp "$ANNOTATED_GD_FILE" "$OUTPUT_FILE"
done

# Run the mapping_success.sh script to generate a CSV file of read mapping success percentages
/home/s4528540/liv/mapping_success.sh

# # remove ^M line endings in csv
# tr -d '\r' < percent_aligned.csv > percent_aligned_unix.csv

# Set the threshold for low read mapping success
THRESHOLD=0.9

# Initialize the list of samples with low read mapping success
LOW_SUCCESS_SAMPLES=""

# Read the percent_aligned_unix.csv file and add the names of samples with low read mapping success to the list
while IFS=, read -r sample percent_aligned_bases; do
    if (( $(echo "$percent_aligned_bases < $THRESHOLD" | bc -l) )); then
        if [[ -z $LOW_SUCCESS_SAMPLES ]]; then
            LOW_SUCCESS_SAMPLES="$sample"
        else
            LOW_SUCCESS_SAMPLES="$LOW_SUCCESS_SAMPLES|$sample"
        fi
    fi
done < percent_aligned.csv

echo "$LOW_SUCCESS_SAMPLES"

# Set the path to the reference genome file
REF_GENOME="/home/s4528540/liv/AB3v2.0.gbk"

# Set the output filename
OUTPUT_FILE1="intersect.gd"

# Get a list of the annotated.gd files
ANNOTATED_GD_FILES=$(ls "$ANNOTATED_GD_DIR"/*.gd | grep -v -E $LOW_SUCCESS_SAMPLES)

# Construct the gdtools compare command
GDTOOLS_CMD1="gdtools intersect -o $OUTPUT_FILE1 $ANNOTATED_GD_FILES"

echo "Running gdtools intersect command..."
$GDTOOLS_CMD1
EXIT_STATUS=$?

# Check the exit status and print an error message if it is non-zero
if [ $EXIT_STATUS -ne 0 ]; then
    echo "Error running gdtools compare command: exit status $EXIT_STATUS"
fi

echo "gdtools intersect command complete"

# Set the path to the output directory for the annotated.gd files
SUBTRACTED_GD_DIR="/home/s4528540/liv/breseq_subtract_gd"

# Create the output directory if it doesn't exist
mkdir -p "$SUBTRACTED_GD_DIR"

# Subtract the intersection from each gd file
for SAMPLE in $ANNOTATED_GD_FILES; do
    SAMPLE_NAME=$(basename "$SAMPLE")
    # Exclude samples with low mapped percentages
    OUTPUT_FILE="${SUBTRACTED_GD_DIR}/${SAMPLE_NAME}"
    INTERSECT_FILE="/home/s4528540/liv/${OUTPUT_FILE1}"
    GDTOOLS_CMD2="gdtools subtract -o $OUTPUT_FILE $SAMPLE $INTERSECT_FILE"
    $GDTOOLS_CMD2
done

# Create Comparisons
OUTPUT_FILE2="comparison.html"
GDTOOLS_CMD3="gdtools compare -o $OUTPUT_FILE2 -f html -r $REF_GENOME $ANNOTATED_GD_DIR/*"
$GDTOOLS_CMD3

OUTPUT_FILE3="simplified_comparison.html"
GDTOOLS_CMD4="gdtools compare -o $OUTPUT_FILE3 -f html -r $REF_GENOME $SUBTRACTED_GD_DIR/*"
$GDTOOLS_CMD4

OUTPUT_FILE4="simplified_comparison.csv"
GDTOOLS_CMD5="gdtools compare -o $OUTPUT_FILE4 -f csv -r $REF_GENOME $SUBTRACTED_GD_DIR/*"
$GDTOOLS_CMD5
