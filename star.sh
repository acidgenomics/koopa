if [ ! -d sam ]; then
    mkdir sam
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
        else
            echo "$base (single)"
        fi
        if [ ! -d ../sam/$base ]; then
            mkdir ../sam/$base
            bsub -q priority -W 1:00 -n 12 STAR --genomeDir=../../../genome/STAR --outFileNamePrefix=../sam/$base/ --readFilesCommand=zcat --readFilesIn=$file --runThreadN=12 --outFilterType=BySJout --outFilterMultimapNmax=20 --alignSJoverhangMin=8 --alignSJDBoverhangMin=1 --outFilterMismatchNmax=999 --alignIntronMin=20 --alignIntronMax=1000000 --alignMatesGapMax=1000000
        fi
    fi
done
cd ../
