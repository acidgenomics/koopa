#!/usr/bin/env bash
set -Eeuo pipefail

# Rename files using a CSV file.

# Check for CSV file.
file="$1"

if [[ ! -f "$file" ]]
then
    echo "${file} does not exist."
fi

if [[ ! "$file" =~ .csv ]]
then
    echo "${file} is not a CSV file."
fi

while read -r line
do          
    from=${line%,*}
    to=${line#*,}
    mv "$from" "$to"
done < "$file"
