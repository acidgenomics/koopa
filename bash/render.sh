# Note the use of double quotes in the Rscript command. Single quote usage,
# which is common in online examples, will not escape the bash variables
# properly.

# Exit on HPC detection failure
if [[ -z $HPC ]]; then
    echo "HPC required"
    exit 1
fi

if [[ "$#" -gt "0" ]]; then
    cores="$1"
    ram_gb="$2"
    ram_mb="$(($ram_gb * 1024))"
    file_name="$3"
else
    echo "Syntax: render <cores> <ram_gb> <file_name>"
    exit 1
fi

echo "Rendering ${file_name} with ${ram_gb} GB RAM"
if [[ $HPC == "HMS RC O2" ]]; then
    sbatch -t 1-00:00 \
        -p priority \
        -J "$file_name" \
        -n "$cores" \
        --mem-per-cpu="${ram_gb}G" \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" \
            -e "rmarkdown::render('$file_name')"
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    bsub -W 24:00 \
        -q priority \
        -J "$file_name" \
        -n "$cores" \
        -R rusage[mem="$ram_mb"] \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" \
            -e "rmarkdown::render('$file_name')"
fi

unset cores
unset file_name
unset ram_gb
unset ram_mb
