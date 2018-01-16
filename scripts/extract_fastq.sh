tar="$1"
if [[ -z $tar ]]; then
    echo "tarball missing"
    exit 1
fi
tar -xvf "$tar" --wildcards "*.fastq.gz"
