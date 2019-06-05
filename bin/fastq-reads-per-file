#!/usr/bin/env bash
set -Eeuo pipefail

# Get the number of reads per FASTQ file.

# Divide by 4.
zcat ./*_R1.fastq.gz | wc -l | awk '{print $1/4}'
