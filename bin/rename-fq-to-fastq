#!/usr/bin/env bash
set -Eeuo pipefail

# Rename ".fq" to ".fastq"

for file in ./*.fq; do
    mv "$file" "${file/%.fq/.fastq}"
done
