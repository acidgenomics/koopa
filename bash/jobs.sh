if [[ ! -z $SLURM_CONF ]]; then
    # Slurm
    squeue -u $USER
elif [[ ! -z $LSF_ENVDIR ]]; then
    # LSF    
    bjobs -u $USER
else
    echo "HPC required"
    exit 1
fi
