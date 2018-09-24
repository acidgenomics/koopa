# Detect HPC scheduler configuration.
# 2018-09-23

# Slurm and LSF are supported.
if [[ ! -z "$SLURM_CONF" ]] || [[ ! -z "$SQUEUE_USER" ]]; then
    export HPC_SCHEDULER="Slurm"
elif [[ ! -z "$LSF_ENVDIR" ]]; then
    export HPC_SCHEDULER="LSF"
else
    return 0
fi

# Harvard University ===========================================================
if   [[ $HMS_CLUSTER == "o2" ]] && \
     [[ $HOSTNAME =~ ".o2.rc.hms.harvard.edu" ]] && \
     [[ -d /n/data1/ ]]
then
    export HPC_NAME="Harvard HMS O2"
    # https://wiki.rc.hms.harvard.edu/display/O2/Using+Slurm+Basic
    # Automatically export bcbio into PATH, if necessary.
    if [[ ! -d "$BCBIO_DIR" ]]; then
        export BCBIO_DIR="/n/app/bcbio/tools/bin"
    fi
elif [[ $HOSTNAME =~ ".rc.fas.harvard.edu" ]] && \
     [[ -d /n/regal/ ]]
then
    export HPC_NAME="Harvard FAS Odyssey"
    # https://www.rc.fas.harvard.edu/resources/running-jobs/
    # Automatically export bcbio into PATH, if necessary.
    if [[ ! -d "$BCBIO_DIR" ]]; then
        export BCBIO_DIR="/n/regal/hsph_bioinfo/bcbio_nextgen/bin"
    fi
    # Change the default partitions, if necessary.
    if [[ -z "$HPC_PARTITION_DEFAULT" ]]; then
        export HPC_PARTITION_DEFAULT="shared"
    fi
    if [[ -z "$HPC_PARTITION_INTERACTIVE" ]]; then
        export HPC_PARTITION_INTERACTIVE="test"
    fi
fi

# Default configuration ========================================================
if [[ -z "$HPC_PARTITION_DEFAULT" ]]; then
    export HPC_PARTITION_DEFAULT="short"
fi

if [[ -z "$HPC_PARTITION_INTERACTIVE" ]]; then
    export HPC_PARTITION_INTERACTIVE="interactive"
fi

if [[ -z "$HPC_CORES" ]]; then
    export HPC_CORES=1
fi

if [[ -z "$HPC_MEMORY_GB" ]]; then
    export HPC_MEMORY_GB=8
fi

if [[ -z "$HPC_X11_FORWARDING" ]]; then
    # X11 will set `$DISPLAY` by default.
    if [[ -n "$DISPLAY" ]]; then
        export HPC_X11_FORWARDING=1
    fi
fi

if [[ "$HPC_SCHEDULER" == "Slurm" ]]; then
    alias j="squeue -u $USER"
    if [[ -z "$HPC_TIME" ]]; then
        export HPC_TIME="0-06:00"
    fi
elif [[ "$HPC_SCHEDULER" == "LSF" ]]; then
    alias j="bjobs"
    if [[ -z "$HPC_TIME" ]]; then
        export HPC_TIME="6:00"
    fi
fi
