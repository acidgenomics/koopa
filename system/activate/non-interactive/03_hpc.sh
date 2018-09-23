# Detect HPC scheduler configuration.
# 2018-09-23

# Harvard O2 Cluster
# https://wiki.rc.hms.harvard.edu/display/O2/Using+Slurm+Basic

# Harvard Odyssey Cluster
# https://www.rc.fas.harvard.edu/resources/running-jobs/

if [[ ! -z "$SLURM_CONF" ]] || [[ ! -z "$SQUEUE_USER" ]]; then
    export HPC_SCHEDULER="slurm"
elif [[ ! -z "$LSF_ENVDIR" ]]; then
    export HPC_SCHEDULER="lsf"
else
    return 0
fi

export HPC_PARTITION_DEFAULT="short"
export HPC_PARTITION_INTERACTIVE="interactive"
export HPC_CORES=1
export HPC_MEMORY_GB=8
export HPC_X11_FORWARDING=1

# Odyssey
# export HPC_PARTITION_DEFAULT="shared"
# export HPC_PARTITION_INTERACTIVE="test"

if [[ "$HPC_SCHEDULER" == "slurm" ]]; then
    alias j="squeue -u $USER"
    export HPC_TIME="0-06:00"
elif [[ "$HPC_SCHEDULER" == "lsf" ]]; then
    alias j="bjobs"
    export HPC_TIME="6:00"
fi
