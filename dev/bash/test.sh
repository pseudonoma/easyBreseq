#!/bin/bash

# test assigning printf
testCall="echo \"UHHHHH\""

$testCall | tee testCall.txt


# temp test of a single breseq call

# Portsmouth
# breseq \
# -r "/mnt/e/SRSBZNZ/breseq/AB3_ref.gb" \
# /mnt/e/SRSBZNZ/breseq/SE7909_J5079_S7_R1_001.fastq.gz \
# /mnt/e/SRSBZNZ/breseq/SE7909_J5079_S7_R2_001.fastq.gz \
# -p \
# -j 10 \
# -n "testSample" \
# -o /mnt/e/SRSBZNZ/breseq/test_output

# Mulberry
# breseq \
# -r "/Users/ian/Desktop/J5079_testrun/references/AB3.gb" \
# /Users/ian/Desktop/J5079_testrun/SE7909_J5079_S7_R1_001.fastq.gz \
# /Users/ian/Desktop/J5079_testrun/SE7909_J5079_S7_R2_001.fastq.gz \
# -p \
# -j 6 \
# -n "testSample" \
# -o /Users/ian/Desktop/J5079_testrun/testOutput