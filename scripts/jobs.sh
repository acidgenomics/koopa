if [[ $SCHEDULER == "slurm" ]]; then
    squeue -u "$USER"
elif [[ $SCHEDULER == "lsf" ]]; then
    bjobs -u "$USER"
else
    echo "HPC scheduler required"
    return 1
fi
