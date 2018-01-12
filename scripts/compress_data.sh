# gzip FASTQ and SAM files
find . -type f -name "*.fastq" -o -name "*.sam" -print0 | xargs -0 -I {} gzip -fv {}
