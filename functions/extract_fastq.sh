tar="$1"
if [[ -z $tar ]]; then
    echo "tar file missing"
    return 1
fi
tar -xvf "$tar" --wildcards "*.fastq.gz"
