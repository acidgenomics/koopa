#!/usr/bin/env bash
set -Eeuo pipefail

# Extract FASTQs files inside a TAR file.

file="$1"
if [[ ! -f "$file" ]]; then
    echo "${file} tar file does not exist."
    exit 1
fi
tar -xvf "$file" --wildcards "*.fastq.*"
