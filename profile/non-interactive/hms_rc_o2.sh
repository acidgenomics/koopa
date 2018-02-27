# HMS RC: Harvard Medical School Research Computing

# HPC environment variable
if [[ $HMS_CLUSTER = "o2" ]] && \
    [[ $HOSTNAME =~ ".o2.rc.hms.harvard.edu" ]] && \
    [[ $(uname -s) = "Linux" ]] && \
    [[ -d /n/data1/ ]]
then
    # O2
    export HPC="HMS RC O2"
    if [[ -z "$BCBIO_DIR" ]]; then
        export BCBIO_DIR="/n/app/bcbio/tools/bin"
    fi
fi

# Modules ======================================================================
# Check loaded modules
# `module list`
#
# Check available modules
# - `module avail`
# - `module avail stats/R`
#
# Purge modules
# - `module load null`
# - `module purge`
