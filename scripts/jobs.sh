if [[ $SCHEDULER == "slurm" ]]; then
    command -v squeue >/dev/null 2>&1 || { echo >&2 "squeue missing"; exit 1; }
    squeue -u $USER
elif [[ $SCHEDULER == "lsf" ]]; then
    command -v bjobs >/dev/null 2>&1 || { echo >&2 "bjobs missing"; exit 1; }
    bjobs -u $USER
else
    echo "HPC scheduler required"
    exit 1
fi
