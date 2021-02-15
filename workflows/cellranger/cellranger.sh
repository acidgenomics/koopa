#!/usr/bin/env bash

# """
# Run Cell Ranger.
# Harvard O2 cluster.
# Updated 2019-06-21.
#
# See also:
# - https://support.10xgenomics.com/single-cell-gene-expression/software/
#       pipelines/latest/using/mkfastq
# - https://support.10xgenomics.com/single-cell-gene-expression/software/
#       pipelines/latest/using/count
# """

module load bcl2fastq/2.20.0.422
module load cellranger/2.1.1

csv='mkfastq.csv'
localcores="$SLURM_CPUS_PER_TASK"
localmem=128
run='XXX'
transcriptome="${HOME}/refdata-cellranger-mm10-1.2.0"

samples=(
    'sample1'
    'sample2'
)
# Note that these need to be defined per sample.
fastqs=(
    'fastq1.fastq.gz'
    'fastq2.fastq.gz'
)

cellranger mkfastq \
    --csv "$csv" \
    --delete-undetermined \
    --localcores "$localcores" \
    --localmem "$localmem" \
    --run "$run"

for sample in "${samples[@]}"
do
    cellranger count \
        --fastqs "${fastqs[@]}" \
        --id "$sample" \
        --localcores "$localcores" \
        --localmem "$localmem" \
        --nosecondary \
        --sample "$sample" \
        --transcriptome "$transcriptome"
done
