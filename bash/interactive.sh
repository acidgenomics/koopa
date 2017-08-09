# Launch an interactive session
if [[ "$#" -gt "0" ]]; then
    cores="$1"
    ram_gb="$2"
    ram_mb="$(($ram_gb * 1024))"
else
    echo "Syntax: interactive CORES RAM_GB"
fi

# Pass commands to HPC scheduler
echo "Starting interactive session with $cores cores and $ram_gb GB RAM..."
if [[ ! -z $SLURM_CONF ]]; then
    # Slurm
    srun -p interactive --pty --mem "$ram_mb" -t 20 /bin/bash
elif [[ ! -z $LSF_ENVDIR ]]; then
    # LSF    
    bsub -Is -W 12:00 -q interactive -n "$cores" -R rusage[mem="$ram_mb"] bash
else
    echo "HPC required"
    exit 1
fi
