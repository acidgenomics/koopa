if [[ $SCHEDULER == "slurm" ]]; then
    command -v squeue >/dev/null 2>&1 || { echo >&2 "squeue missing"; return 1; }
    squeue -u $USER
elif [[ $SCHEDULER == "lsf" ]]; then
    command -v bjobs >/dev/null 2>&1 || { echo >&2 "bjobs missing"; return 1; }
    bjobs -u $USER
else
    echo "HPC scheduler required"
    return 1
fi
