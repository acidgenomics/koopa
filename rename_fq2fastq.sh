for file in *.fq; do
    mv "${file}" "${file/%.fq/.fastq}"
done
