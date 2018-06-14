# Note the use of double quotes in the Rscript command. Single quote usage,
# which is common in online examples, will not escape the bash variables
# properly.

usage() {
    echo "render -{f}ile file.Rmd [-{q}ueue medium -{c}ores 1 -{m}em 8 -{t}ime 1-00:00]" 1>&2
}

# Early return usage on empty call
if [[ $# -eq 0 ]]; then
    usage
    return
fi

# Early return on HPC detection failure
if [[ -z "$SCHEDULER" ]]; then
    echo "HPC scheduler required"
    return 1
fi

# Optional argument defaults
cores=1
mem=8
queue="medium"
# time
if [[ "$SCHEDULER" == "slurm" ]]; then
    time="1-00:00"
elif [[ "$SCHEDULER" == "lsf" ]]; then
    time="24:00"
fi

# Extract options and their arguments into variables
while getopts ":c:f:m:q:t:h" opt; do
    case $opt in
        c  ) cores=$OPTARG;;
        f  ) file=$OPTARG;;
        m  ) mem=$OPTARG;;
        q  ) queue=$OPTARG;;
        t  ) time=$OPTARG;;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
shift $((OPTIND - 1))

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
    # Note the inclusion of ampersand here
    # https://slurm.schedmd.com/srun.html
    srun -t "$time" \
        -p "$queue" \
        -J "$file" \
        -c "$cores" \
        --mem-per-cpu="${mem}G" \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" \
            -e "rmarkdown::render('$file')" &
elif [[ $SCHEDULER == "lsf" ]]; then
    mem_mb="$(($mem * 1024))"
    bsub -W "$time" \
        -q "$queue" \
        -J "$file" \
        -n "$cores" \
        -R rusage[mem="$mem_mb"] \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" \
            -e "rmarkdown::render('$file')"
        unset -v mem_mb
fi

unset -f usage
unset -v cores file mem queue time
