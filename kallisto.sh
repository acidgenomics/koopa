if [ ! -d kallisto ]; then
    mkdir kallisto
fi

cd fastq
for file in `ls *.fastq.gz`; do
    base=`basename $file .fastq.gz`
    # Skip second paired file in loop for simplicity
    if [[ ! $base == *"_2" ]]; then
        if [[ $base == *"_1" ]]; then
            base=`basename $base _1`
            echo "$base (paired)"
            file="${base}_1.fastq.gz ${base}_2.fastq.gz"
            custom=""
        else
            echo "$base (single)"
            custom="--single --fragment-length=200 -s 20"
        fi
        if [ ! -d ../kallisto/$base ]; then
            mkdir ../kallisto/$base
            kallisto quant --index=../../../genome/kallisto/transcripts.idx --output-dir=../kallisto/$base --bootstrap-samples=100 --threads=12 $custom $file
        fi
    fi
done
cd ../
