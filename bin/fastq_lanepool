#!/usr/bin/env bash
set -Eeuo pipefail

# Pool lane-split FASTQ files.

# Set the file stem. Defaults to "lanepool".
if [[ "$#" -gt "0" ]]; then
    filestem="$1"
else
    filestem="lanepool"
fi

# Exit if lanesplit replicates (L001-4) don't exist.
if test -z "$(find . -maxdepth 1 -name '*_L00[1-4]_*.fastq.gz' -print -quit)"; then
    echo "No lanesplit samples detected."
    exit 1
fi

# SC2035: Use ./*glob* or -- *glob* so names with dashes won't become options.
cat ./*_L00[1-4]_R1_001.fastq.gz > "${filestem}_R1.fastq.gz"
cat ./*_L00[1-4]_R2_001.fastq.gz > "${filestem}_R2.fastq.gz"
cat ./*_L00[1-4]_R3_001.fastq.gz > "${filestem}_R3.fastq.gz"
cat ./*_L00[1-4]_R4_001.fastq.gz > "${filestem}_R4.fastq.gz"
