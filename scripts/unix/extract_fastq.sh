file="$1"
if [[ ! -f "$file" ]]; then
    echo "${file} tar file does not exist"
    return 1
fi
tar -xvf "$file" --wildcards "*.fastq.*"
