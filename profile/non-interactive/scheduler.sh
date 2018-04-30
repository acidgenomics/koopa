if [[ ! -z "$SLURM_CONF" ]] || [[ ! -z "$SQUEUE_USER" ]]; then
    export SCHEDULER="slurm"
    alias j="squeue -u $USER"
elif [[ ! -z "$LSF_ENVDIR" ]]; then
    export SCHEDULER="lsf"
    alias j="bjobs"
fi
