# Note the use of double quotes in the Rscript command. Single quote usage,
# which is common in online examples, will not escape the bash variables
# properly.

# Exit on HPC detection failure
if [[ -z $SCHEDULER ]]; then
    echo "HPC scheduler required"
    return 1
fi

usage() {
    echo "render: [<queue> <cores> <mem> <time> <file>]" 1>&2
    return 1
}

local OPTIND arg cores file mem queue time
while getopts "cores:file:mem:queue:time:" arg; do
    case ${arg} in
        queue) queue="${OPTARG}";;
        cores) cores="${OPTARG}";;
        mem) mem="${OPTARG}";;
        time) time="${OPTARG}";;
        file) file="${OPTARG}";;
        *) usage  # illegal option
    esac
done
shift $((OPTIND-1))



echo "Submitting ${file} to ${queue} queue with ${cores} core(s), ${mem} GB RAM, ${time} time"
return 0



if [[ $SCHEDULER == "slurm" ]]; then
    srun -t 1-00:00 \
        -p "$queue" \
        -J "$file" \
        -c "$cores" \
        --mem-per-cpu="${mem}G" \
        Rscript --default-packages="$R_DEFAULT_PACKAGES" \
            -e "rmarkdown::render('$file')"
elif [[ $SCHEDULER == "lsf" ]]; then
    mem_mb="$(($mem * 1024))"
    bsub -W 24:00 \
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
