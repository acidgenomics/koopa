if [[ ! -z $SLURM_CONF ]]; then
    export SCHEDULER="slurm"
elif [[ ! -z $LSF_ENVDIR ]]; then
    export SCHEDULER="lsf"
fi
