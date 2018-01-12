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
    ram_gb="16"
fi

ram_mb="$(($ram_gb * 1024))"

echo "Launching interactive session with ${cores} core(s), ${ram_gb} GB RAM"

if [[ $HPC == "HMS RC O2" ]]; then
    command -v srun >/dev/null 2>&1 || { echo >&2 "srun missing"; exit 1; }
    # `--x11` flag before `/bin/bash` requires `~/.ssh/config` set on local machine
    srun -p interactive --pty --mem "$ram_gb"G --time 0-12:00 --x11 /bin/bash
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    command -v bsub >/dev/null 2>&1 || { echo >&2 "bsub missing"; exit 1; }
    bsub -Is -W 12:00 -q interactive -n "$cores" -R rusage[mem="$ram_mb"] bash
elif [[ $HPC == "Harvard FAS Odyssey" ]]; then
    # https://www.rc.fas.harvard.edu/resources/running-jobs/#Interactive_jobs_and_srun
    # https://www.rc.fas.harvard.edu/resources/faq/category/slurm-2/
    command -v srun >/dev/null 2>&1 || { echo >&2 "srun missing"; exit 1; }
    # `--x11` flag before `/bin/bash` requires `~/.ssh/config` set on local machine
    srun -p test --pty --mem "$ram_gb"G --time 0-8:00 --x11=first /bin/bash
else
    echo "HPC required"
    exit 1
fi
