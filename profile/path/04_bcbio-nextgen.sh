# https://bcbio-nextgen.readthedocs.io

if [[ $HPC == "HMS RC O2" ]]; then
    bcbio_dir="/n/groups/bcbio"
    bcbio_path="/n/app/bcbio/tools/bin"
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    bcbio_dir="/groups/bcbio"
    bcbio_path="/opt/bcbio/centos/bin"
fi

# Check for bcbio groups directory
if [[ ! -z $bcbio_dir ]]; then
    if [[ ! -d $bcbio_dir ]]; then
        echo "$bcbio_dir missing"
        exit 1
    fi
    export BCBIO_DIR="$bcbio_dir"
fi

# Update PATH
if [[ ! -z $bcbio_path ]]; then
    if [[ ! -d $bcbio_path ]]; then
        echo "$bcbio_path missing"
        exit 1
    fi
    export PATH="$bcbio_path:$PATH"
    unset PYTHONHOME
    unset PYTHONPATH
fi

unset bcbio_dir
unset bcbio_path
