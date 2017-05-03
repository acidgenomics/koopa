mkdir -p logs
gzip -cd data-raw/fastq/*_R3.fastq.* | \
head -1000000 | \
awk 'NR == 2 || NR % 4 == 2' | \
grep -v N | \
sort | \
uniq -c | \
sort -nr | \
head -n 24 > logs/sample_barcodes.log
