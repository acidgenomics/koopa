# O2 modules
# 2017-06-29
#
# Check loaded modules:
# `module list`
#
# Unload everything:
# `module load null`
#
# Check available modules:
# - `module avail`
# - `module avail stats/R`

if [[ $HPC == "HMS RC O2" ]]; then
    module load bcl2fastq/2.18.0.12
    module load gcc/6.2.0
    module load intel/2016
    module load R/3.3.3
    module load samtools/1.3.1
    module load xz/5.2.3
fi
