# source code chunks for collate_gd.sh

### base code chunk from O.D.

# Copy the annotated.gd file for each sample to the output directory
for SAMPLE_DIR in "$BRESEQ_DIR"/*/; do
    SAMPLE_NAME=$(basename "$SAMPLE_DIR")
    ANNOTATED_GD_FILE="$SAMPLE_DIR/data/annotated.gd"
    OUTPUT_FILE="$ANNOTATED_GD_DIR/$SAMPLE_NAME.gd"
    echo "Copying $ANNOTATED_GD_FILE to $OUTPUT_FILE..."
    cp "$ANNOTATED_GD_FILE" "$OUTPUT_FILE"
done

###

### SO implementation
mkdir folder
for file in Nature_Set_*/*.jpg; do
    mv "$file" "folder/${file/\//_}"
done

for gdfile in ./output/*/output/output.gd; do
    echo basename "$gdfile"
done


# mkdir ./output/_gd

parentDir=/mnt/k/SRSBZNZ/breseq

# copy output.gd files from respective sample output folders and rename
for gdfile in "$parentDir"/output/*/output/output.gd; do
    parent=$(dirname "$gdfile") # get ".." path
    samplePath=$(dirname "$parent")
    sampleName=$(basename "$samplePath")
    cp "$gdfile" "./output/_gd/$sampleName.gd"
done


# for gdfile in ./output/*/output/output.gd; do
#     parent=$(dirname "$gdfile") # get ".." path
#     samplePath=$(dirname "$parent")
#     sampleName=$(basename "$samplePath")
#     cp "$gdfile" "./output/_gd/$sampleName.gd"
# done

# for folder in ./output/*; do
#     echo $(dirname $folder)
# done