# Launch an interactive session that lasts for 12 hours

# Exit on HPC detection failure
if [[ -z $HPC ]]; then
    echo "HPC required"
    return 1
fi

if [[ "$#" -gt "0" ]]; then
    cores="$1"
    ram_gb="$2"
else
    cores="1"
    ram_gb="16"
fi

ram_mb="$(($ram_gb * 1024))"

echo "Launching interactive session with ${cores} core(s), ${ram_gb} GB RAM"
export INTERACTIVE_QUEUE=true

if [[ $SCHEDULER == "slurm" ]]; then
    command -v srun >/dev/null 2>&1 || { echo >&2 "srun missing"; return 1; }
    if [[ $HPC == "Harvard FAS Odyssey" ]]; then
        partition="test"
    else
        partition="interactive"
    fi
    # `--x11` flag before `/bin/bash` requires `~/.ssh/config` on local machine
    srun -p "$partition" --pty -c "$cores" --mem "${ram_gb}"G --time 0-8:00 --x11=first /bin/bash
    unset -v partition
elif [[ $SCHEDULER == "lsf" ]]; then
    command -v bsub >/dev/null 2>&1 || { echo >&2 "bsub missing"; return 1; }
    bsub -Is -W 8:00 -q interactive -n "$cores" -R rusage[mem="$ram_mb"] bash
else
    echo "HPC scheduler required"
    return 1
fi

unset -v cores ram_gb
