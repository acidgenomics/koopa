# Launch an interactive session that lasts for 12 hours

# Exit on HPC detection failure
if [[ -z $HPC ]]; then
    echo "HPC required"
    exit 1
fi

if [[ "$#" -gt "0" ]]; then
    cores="$1"
    ram_gb="$2"
else
    cores="1"
    ram_gb="8"
fi

ram_mb="$(($ram_gb * 1024))"

echo "Launching interactive session with ${cores} core(s), ${ram_gb} GB RAM"

if [[ $HPC == "HMS RC O2" ]]; then
    srun -p interactive --pty --mem "$ram_mb" --time 0-12:00 /bin/bash
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    bsub -Is -W 12:00 -q interactive -n "$cores" -R rusage[mem="$ram_mb"] bash
else
    echo "HPC required"
    exit 1
fi
