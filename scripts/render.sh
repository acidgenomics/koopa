# Note the use of double quotes in the Rscript command. Single quote usage,
# which is common in online examples, will not escape the bash variables
# properly.

# srun guide
# https://wiki.rc.hms.harvard.edu/display/O2/Using+Slurm+Basic#UsingSlurmBasic-Thesruncommand

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
    echo "Syntax: render <queue> <cores> <ram_gb> <file_name>"
    exit 1
fi

echo "Rendering ${file_name} with ${cores} core(s), ${ram_gb} GB RAM"
if [[ $HPC == "HMS RC O2" ]]; then
    srun -t 1-00:00 \
        -p "$queue" \
        -J "$file_name" \
        -n "$cores" \
        --mem-per-cpu="${ram_gb}G" \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" \
            -e "rmarkdown::render('$file_name')" &
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    bsub -W 24:00 \
        -q "$queue" \
        -J "$file_name" \
        -n "$cores" \
        -R rusage[mem="$ram_mb"] \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" \
            -e "rmarkdown::render('$file_name')" &
fi

unset -v cores file_name queue ram_gb ram_mb
