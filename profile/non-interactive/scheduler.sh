if [[ ! -z "$SLURM_CONF" ]] || [[ ! -z "$SQUEUE_USER" ]]; then
    export SCHEDULER="slurm"
elif [[ ! -z "$LSF_ENVDIR" ]]; then
    export SCHEDULER="lsf"
fi
