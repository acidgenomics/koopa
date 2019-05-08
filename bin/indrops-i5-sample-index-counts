#!/usr/bin/env bash
set -Eeuxo pipefail

# inDrops sample barcode counts from i5 indexes.
# https://iccb.med.harvard.edu/single-cell-core
# Thanks @roryk for this script.

gzip -cd ./*_R3.fastq.gz | \
    head -1000000 | \
    awk 'NR == 2 || NR % 4 == 2' | \
    grep -v N | \
    sort | \
    uniq -c | \
    sort -nr | \
    head -n 24 > \
    sample_barcodes.log
