# gzip FASTQ and SAM files
cd ~/data
find -type f -name "*.fastq" -o -name "*.sam" -print0 | xargs -0 -I {} gzip -fv {}
