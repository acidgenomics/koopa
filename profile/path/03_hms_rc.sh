# HMS RC modules
# 2017-09-18
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
    module purge
    module load bcl2fastq/2.18.0.12
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    module purge
    module load seq/bcl2fastq/2.17.1.14
fi
