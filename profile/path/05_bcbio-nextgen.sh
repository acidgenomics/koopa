# https://bcbio-nextgen.readthedocs.io

if [[ $HPC == "HMS RC O2" ]]; then
    bcbio_dir="/n/groups/bcbio"
    bcbio_path="/n/app/bcbio/tools/bin"
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    bcbio_dir="/groups/bcbio"
    bcbio_path="/opt/bcbio/centos/bin"
fi

# Update paths
if [[ -d $bcbio_dir ]]; then
    # Check that directory exists
    if [[ ! -d $bcbio_dir ]]; then
        echo "bcbio_dir missing"
        exit 1
    fi
    export BCBIO_DIR="$bcbio_dir"
    export PATH="$BCBIO_DIR:$PATH"
    unset PYTHONHOME
    unset PYTHONPATH
    unset bcbio_dir
fi
