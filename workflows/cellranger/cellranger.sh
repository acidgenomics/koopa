# Cell Ranger
# 2018-06-19

module load bcl2fastq/2.20.0.422
module load cellranger/2.1.1

localcores=$SLURM_CPUS_PER_TASK
localmem=128



# mkfastq ======================================================================
# https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/mkfastq
# Point to the Illumina BCL run directory
# Use a CSV file to specify the samples (see 10X website for examples)
# cellranger mkfastq --help
# If you want to remove the Undetermined FASTQs from the output to save space, you can run mkfastq with the --delete-undetermined
cellranger mkfastq \
    --run=XXXXXXXXX \
    --csv=mkfastq.csv \
    --localcores=$localcores \
    --localmem=$localmem



# count ========================================================================
# https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/count
fastqs="XXXXXXXXX"
transcriptome="~/refdata-cellranger-mm10-1.2.0"

cellranger count \
    --id=sample1 \
    --sample=sample1 \
    --fastqs=$fastqs  \
    --transcriptome=$transcriptome \
    --localcores=$localcores \
    --localmem=$localmem \
    --nosecondary
