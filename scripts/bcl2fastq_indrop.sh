command -v bcl2fastq >/dev/null 2>&1 || {
    echo >&2 "bcl2fastq missing"
    return 1
}
bcl2fastq \
    --use-bases-mask y*,y*,y*,y* \
    --mask-short-adapter-reads 0 \
    --minimum-trimmed-read-length 0 > \
    bcl2fastq.log
