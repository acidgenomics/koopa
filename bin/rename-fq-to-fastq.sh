#!/usr/bin/env bash
set -Eeuxo pipefail

# Rename ".fq" to ".fastq"

for file in ./*.fq; do
    mv "$file" "${file/%.fq/.fastq}"
done
