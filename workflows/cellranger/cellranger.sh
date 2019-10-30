#!/bin/sh

## Run Cell Ranger.
## Harvard O2 cluster.
## Updated 2019-06-21.

## See also:
## - https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/mkfastq
## - https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/count

module load bcl2fastq/2.20.0.422
module load cellranger/2.1.1

localcores="$SLURM_CPUS_PER_TASK"
localmem=128

cellranger mkfastq \
    --run="XXXXXXXXX" \
    --csv="mkfastq.csv" \
    --localcores="$localcores" \
    --localmem=$localmem \
    --delete-undetermined

fastqs="XXXXXXXXX"
transcriptome="${HOME}/refdata-cellranger-mm10-1.2.0"

cellranger count \
    --id="sample1" \
    --sample="sample1" \
    --fastqs="$fastqs" \
    --transcriptome="$transcriptome" \
    --localcores="$localcores" \
    --localmem="$localmem" \
    --nosecondary
