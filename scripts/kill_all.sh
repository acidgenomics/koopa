if [[ $SCHEDULER == "slurm" ]]; then
    scancel -u "$USER"
elif [[ $SCHEDULER == "lsf" ]]; then
    bkill 0
fi
