#!/bin/bash

parentDir=/mnt/k/SRSBZNZ/breseq
refFile="ref_AB3.gb"
refDir=$parentDir/references
reference=$refDir/$refFile

# Create new reference file with correct tags
# Define tags and fix reference sequence
oldTag="\/gene="
newTag="\/name="
# TODO: possibly user-defined if I can somehow shield users from regex shenanigans

if [ -n "$oldTag" ]; then
    # Using -z ${oldTag+x} will detect if oldTag is also NULL, not just unset;
    # in this case, I've deliberately used "$oldTag" so a NULL oldTag ("") is treated like unset.
    # -z checks for if value is zero, -n checks for nonzero

    refFileNew=$(basename $refFile .gb)"_fixed.gb" # extract refFile without ext and change name
    sed 's/'"$oldTag"'/'"$newTag"'/' $reference > $refDir/$refFileNew # sed to a new file
    # see https://askubuntu.com/a/76842 for why this is quoted like that
    
    reference=$refDir/$refFileNew # reassign reference file
    printf "\nNew reference is %s\n" "$reference"
    
fi

# grep "$oldTag" $reference
# 
# syntax: sed 's/\<sample_name\>/sample_01/' [file]
# also: sed s,pattern,replacement,
# sed -i 's,'"$pattern"',Say hurrah to &: \0/,' "$file"

# # mkdir ./output/_gd
# 
# parentDir=/mnt/k/SRSBZNZ/breseq
# 
# # copy output.gd files from respective sample output folders and rename
# for gdfile in "$parentDir"/output/*/output/output.gd; do
#     parent=$(dirname "$gdfile") # get ".." path
#     samplePath=$(dirname "$parent")
#     sampleName=$(basename "$samplePath")
#     cp "$gdfile" "./output/_gd/$sampleName.gd"
# done


# for gdfile in ./output/*/output/output.gd; do
#     parent=$(dirname "$gdfile") # get ".." path
#     samplePath=$(dirname "$parent")
#     sampleName=$(basename "$samplePath")
#     cp "$gdfile" "./output/_gd/$sampleName.gd"
# done

# for folder in ./output/*; do
#     echo $(dirname $folder)
# done

