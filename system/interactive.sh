#!/usr/bin/env bash

# TODO Add an X11 flag option.

# Schedule an interactive session.

# Using more modern "getopt" instead of "getopts" here, which supports long options.
# http://www.bahmanm.com/blogs/command-line-options-how-to-parse-in-bash-using-getopt

# Slurm and LSF are supported.
if [[ -n ${SLURM_CONF+x} ]] || [[ -n ${SQUEUE_USER+x} ]]; then
    export HPC_SCHEDULER="Slurm"
elif [[ -n ${LSF_ENVDIR+x} ]]; then
    export HPC_SCHEDULER="LSF"
else
    echo "Cannot start interactive session."
    echo "Failed to detect supported HPC scheduler (Slurm, LSF)."
    exit 1;
fi

# Default configuration ========================================================
if [[ -z ${HPC_PARTITION_DEFAULT+x} ]]; then
    export HPC_PARTITION_DEFAULT="short"
fi

if [[ -z ${HPC_PARTITION_INTERACTIVE+x} ]]; then
    export HPC_PARTITION_INTERACTIVE="interactive"
fi

if [[ -z ${HPC_CORES+x} ]]; then
    export HPC_CORES=1
fi

if [[ -z ${HPC_MEMORY_GB+x} ]]; then
    export HPC_MEMORY_GB=8
fi

# X11 forwarding. X11 will set `$DISPLAY` by default.
if [[ -z ${HPC_X11_FORWARDING+x} ]]; then
    if [[ -n ${DISPLAY+x} ]]; then
        export HPC_X11_FORWARDING=1
    fi
fi

# Use a default time of 6 hours.
if [[ "$HPC_SCHEDULER" == "Slurm" ]]; then
    alias j="squeue -u $USER"
    if [[ -z "$HPC_TIME" ]]; then
        export HPC_TIME="0-06:00"
    fi
elif [[ "$HPC_SCHEDULER" == "LSF" ]]; then
    alias j="bjobs"
    if [[ -z "$HPC_TIME" ]]; then
        export HPC_TIME="6:00"
    fi
fi

# Harvard University ===========================================================
if   [[ $HMS_CLUSTER == "o2" ]] && \
     [[ $HOSTNAME =~ ".o2.rc.hms.harvard.edu" ]] && \
     [[ -d /n/data1/ ]]
then
    # https://wiki.rc.hms.harvard.edu/display/O2/Using+Slurm+Basic
    export HPC_NAME="Harvard HMS O2"
elif [[ $HOSTNAME =~ ".rc.fas.harvard.edu" ]] && \
     [[ -d /n/regal/ ]]
then
    # https://www.rc.fas.harvard.edu/resources/running-jobs/
    export HPC_NAME="Harvard FAS Odyssey"
    # Odyssey uses "test" instead of "interactive" for partition name.
    if [[ -z "$HPC_PARTITION_INTERACTIVE" ]]; then
        export HPC_PARTITION_INTERACTIVE="test"
    fi
fi

# Read the options.
# Why do we need to set the name of the script with `-n` here?
TEMP=$( getopt -o c::hm::p::t:: --long cores::,help,mem::,partition::,time:: -n "interactive" -- "$@" )
eval set -- "$TEMP"

help () {
    echo "koopa interactive [--{c}ores=${cores} --{m}em=${mem} --{p}artition=${partition} --{t}ime=${time}]" 1>&2
}

# All arguments are optional for this script.
cores="$HPC_CORES"
mem="$HPC_MEMORY_GB"
partition="$HPC_PARTITION_INTERACTIVE"
time="$HPC_TIME"

# Extract options and their arguments into variables.
while true; do
    case "$1" in
        -c|--cores)
            case "$2" in
                "") cores="$cores"; shift 2;;
                *) cores="$2"; shift 2;;
            esac;;
        -h|--help) help; exit 1;;
        -m|--mem)
            case "$2" in
                "") mem="$mem"; shift 2;;
                *) mem="$2"; shift 2;;
            esac;;
        -p|--partition)
            case "$2" in
                "") partition="$partition"; shift 2;;
                *) partition="$2"; shift 2;;
            esac;;
        -t|--time)
            case "$2" in
                "") time="$time"; shift 2;;
                *) time="$2"; shift 2;;
            esac;;
        --) shift; break;;
        \?) echo "Unknown option: $1" >&2; exit 1;;
         :) echo "Missing argument for $1" >&2; exit 1;;
         *) echo "Unimplemented option: $1" >&2; exit 1;;
    esac
done

# Inform the user about the job.
echo "Launching interactive session"
echo "  - cores: ${cores}"
echo "  - memory: ${mem} GB"
echo "  - partition: ${partition}"
echo "  - time: ${time}"

export HPC_INTERACTIVE_JOB=1

# X11 requires `~/.ssh/config` on local machine.
if [[ $HPC_SCHEDULER == "Slurm" ]]; then
    srun --pty \
        --cpus-per-task="$cores" \
        --mem="${mem}"G \
        --partition="$partition" \
        --time="$time" \
        --x11=first \
        /bin/bash
elif [[ $HPC_SCHEDULER == "LSF" ]]; then
    mem_mb="$(( $mem * 1024 ))"
    bsub -Is \
        -n "$cores" \
        -q "$partition" \
        -R rhelp[mem="$mem_mb"] \
        -W "$time" \
        bash
    unset -v mem_mb
fi

unset -v cores mem partition time
