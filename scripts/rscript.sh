# Note the use of double quotes in the Rscript command. Single quote usage,
# which is common in online examples, will not escape the bash variables
# properly.

# Exit on HPC detection failure
if [[ -z $HPC ]]; then
    echo "HPC required"
    exit 1
fi

if [[ "$#" -gt "0" ]]; then
    queue="$1"
    cores="$2"
    ram_gb="$3"
    ram_mb="$(($ram_gb * 1024))"
    file_name="$4"
else
    echo "Syntax: rscript <queue> <cores> <ram_gb> <file_name>"
    exit 1
fi

# Set the queue (a.k.a. partition for SLURM)
# https://wiki.rc.hms.harvard.edu/display/O2/Using+Slurm+Basic#UsingSlurmBasic-Partitions(akaQueuesinLSF)
# medium queue is recommended by default at HMS

# `R CMD BATCH` can be used in place of `Rscript`
# https://sph.umich.edu/biostat/computing/cluster/examples/r.html

echo "Submitting ${file_name} to ${queue} queue with ${cores} core(s), ${ram_gb} GB RAM"
if [[ $SCHEDULER == "slurm" ]]; then
    srun -t 4-00:00 \
        -p "$queue" \
        -J "$file_name" \
        -c "$cores" \
        --mem-per-cpu="${ram_gb}G" \
        --wrap Rscript --default-packages="$R_DEFAULT_PACKAGES" \
            -e "source('$file_name')"
elif [[ $SCHEDULER == "lsf" ]]; then
    bsub -W 96:00 \
        -q "$queue" \
        -J "$file_name" \
        -n "$cores" \
        -R rusage[mem="$ram_mb"] \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" \
            -e "source('$file_name')"
fi

unset -v cores file_name queue ram_gb ram_mb
