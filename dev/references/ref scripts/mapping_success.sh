#!/usr/bin/env python3

import os
import json
import csv

# Set the input directory containing the summary.json files
input_dir = "/home/s4528540/liv/breseq_output"

# Set the output file name
output_file = "/home/s4528540/liv/percent_aligned.csv"

# Initialize the list of data to write to CSV file
data_list = []

# Iterate over the folders in the input directory
for folder_name in os.listdir(input_dir):
    folder_path = os.path.join(input_dir, folder_name)
    if os.path.isdir(folder_path):
        # Construct the path to the summary.json file
        summary_file = os.path.join(folder_path, "data", "summary.json")

        # Open the summary.json file and load the data
        with open(summary_file, "r") as f:
            summary_data = json.load(f)

        # Extract the "total_fraction_aligned_bases" value and append it to the data list
        aligned_bases_percent = summary_data["reads"]["total_fraction_aligned_bases"]
        data_list.append([folder_name, aligned_bases_percent])

# Write the data to the output CSV file
with open(output_file, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["sample", "percent_aligned_bases"])
    writer.writerows(data_list)
