if [[ ! -z "$SLURM_CONF" ]] || [[ ! -z "$SQUEUE_USER" ]]; then
    export HPC_SCHEDULER="slurm"
    alias j="squeue -u $USER"
elif [[ ! -z "$LSF_ENVDIR" ]]; then
    export HPC_SCHEDULER="lsf"
    alias j="bjobs"
fi
