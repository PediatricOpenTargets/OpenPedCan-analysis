#!/bin/bash
# JN Taroni for ALSF CCDL 2022
# Use git shortlog and git log to extract git contributions to the current
# branch

set -euo pipefail

# Set the working directory to the directory of this file
cd "$(dirname "${BASH_SOURCE[0]}")"

# Create directory to hold intermediate files
comp_dir="../../scratch/count-contributions"
mkdir -p ${comp_dir}

# Total contributors in this branch, removing the leading whitespace
#git shortlog -s -n --since="2021-03-11" HEAD | sed 's/^ *//g' > "${comp_dir}/total_contributions.tsv"
#git log --pretty=format:"%an" --since="2021-03-11" | \
#sort | \
#uniq -c | \
#sort -nr | \
#awk '{print $1"\t"$2}' > ${comp_dir}/total_contributions.tsv

git log --pretty=format:"%an" --since="2021-03-11" | \
sort | \
uniq -c | \
sort -nr | \
awk '{count=$1; $1=""; print count"\t"$0}' | \
sed 's/^[ \t]*//' > ${comp_dir}/total_contributions.tsv

# This will capture all the directories in analyses/
analyses_directories=(../*/)

# Loop through and add author names to a module specific txt file
for dir in "${analyses_directories[@]}"; do
  modulename=$(echo "$dir" | tr -d '../')
  git log --pretty="%an%n" -- "$dir" | sort | uniq > "${comp_dir}/${modulename}_contributors.txt"
done
