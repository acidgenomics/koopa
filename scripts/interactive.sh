# Launch an interactive session that lasts for 12 hours

usage () {
    echo "interactive: [-{c}ores 1 -{m}em 8 -{t}ime 0-06:00]" 1>&2
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

# All arguments are optional
cores=1
mem=1
if [[ "$SCHEDULER" == "slurm" ]]; then
    time="0-06:00"
elif [[ "$SCHEDULER" == "lsf" ]]; then
    time="6:00"
fi

# Extract options and their arguments into variables
while getopts ":c:m:t:" opt; do
    case ${opt} in
        c) cores="${OPTARG}";;
        m) mem="${OPTARG}";;
        t) time="${OPTARG}";;
        \?) echo "Invalid option: ${OPTARG}" 1>&2;;
        :) echo "Invalid option: $OPTARG requires an argument" 1>&2;;
    esac
done
shift $((OPTIND -1))

# Inform the user about the job
echo "Launching interactive session"
echo "- cores: ${cores}"
echo "- memory per core: ${mem} GB"
echo "- time: ${time}"

export INTERACTIVE_QUEUE=true

if [[ $SCHEDULER == "slurm" ]]; then
    if [[ $HPC == "Harvard FAS Odyssey" ]]; then
        partition="test"
    else
        partition="interactive"
    fi
    # x11 requires `~/.ssh/config` on local machine
    srun -p "$partition" --pty \
        -c "$cores" \
        --mem "${ram_gb}"G \
        --time "$time" \
        --x11=first \
        /bin/bash
    unset -v partition
elif [[ $SCHEDULER == "lsf" ]]; then
    mem_mb="$(($mem * 1024))"
    bsub -Is -W "$time" \
        -q interactive \
        -n "$cores" \
        -R rusage[mem="$mem_mb"] \
        bash
    unset -v mem_mb
fi

unset -v cores mem time
