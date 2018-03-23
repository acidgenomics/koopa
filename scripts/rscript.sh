# Note the use of double quotes in the Rscript command. Single quote usage,
# which is common in online examples, will not escape the bash variables
# properly.

# `R CMD BATCH` can be used in place of `Rscript`
# https://sph.umich.edu/biostat/computing/cluster/examples/r.html

usage() {
    echo "rscript: [-{f}ile file.R -{q}ueue medium -{c}ores 1 -{m}em 8 -{t}ime 2-00:00]" 1>&2
}

# Early return usage on empty call
if [[ $# -eq 0 ]]; then
    usage
    return 1
fi

# Early return on HPC detection failure
if [[ -z $SCHEDULER ]]; then
    echo "HPC scheduler required"
    return 1
fi

# Optional argument defaults
cores=1
mem=8
queue="medium"
# time
if [[ "$SCHEDULER" == "slurm" ]]; then
    time="4-00:00"
elif [[ "$SCHEDULER" == "lsf" ]]; then
    time="96:00"
fi

# Extract options and their arguments into variables
while getopts ":c:f:m:q:t:" opt; do
    case ${opt} in
        c ) cores="${OPTARG}";;
        f ) file="${OPTARG}";;
        m ) mem="${OPTARG}";;
        q ) queue="${OPTARG}";;
        t ) time="${OPTARG}";;
        \? ) echo "Invalid option: ${OPTARG}" 1>&2;;
        : ) echo "Invalid option: $OPTARG requires an argument" 1>&2;;
    esac
done
shift $((OPTIND -1))

# Required arguments
if [[ -z "$file" ]]; then
    echo "file is required"
    usage
    return 1
fi

# Inform the user about the job
echo "Submitting $SCHEDULER job"
echo "- file: ${file}"
echo "- queue: ${queue}"
echo "- cores: ${cores}"
echo "- memory per core: ${mem} GB"
echo "- time: ${time}"

if [[ $SCHEDULER == "slurm" ]]; then
    srun -t "$time" \
        -p "$queue" \
        -J "$file" \
        -c "$cores" \
        --mem-per-cpu="${mem}G" \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" -e "source('$file')"
elif [[ $SCHEDULER == "lsf" ]]; then
    mem_mb="$(($mem * 1024))"
    bsub -W "$time" \
        -q "$queue" \
        -J "$file" \
        -n "$cores" \
        -R rusage[mem="$mem_mb"] \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" -e "source('$file')"
        unset -v mem_mb
fi

unset -v cores file mem queue time
