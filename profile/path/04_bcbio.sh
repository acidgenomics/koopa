# https://bcbio-nextgen.readthedocs.io

if [[ $HPC == "HMS RC O2" ]]; then
    bcbio_path="/n/app/bcbio/tools/bin"
    bcbio_dir="/n/groups/bcbio"
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    bcbio_path="/opt/bcbio/centos/bin"
    bcbio_dir="/groups/bcbio"
elif [[ $HPC == "Harvard FAS Odyssey" ]]; then
    bcbio_path="/n/regal/hsph_bioinfo/bcbio_nextgen/bin"
fi

# Update PATH
if [[ ! -z $bcbio_path ]]; then
    if [[ ! -d $bcbio_path ]]; then
        echo "$bcbio_path missing"
        exit 1
    fi
    export PATH="$bcbio_path:$PATH"
    unset -v PYTHONHOME PYTHONPATH
    unset -v bcbio_path
fi

# Check for bcbio groups directory
if [[ ! -z $bcbio_dir ]]; then
    if [[ ! -d $bcbio_dir ]]; then
        echo "$bcbio_dir missing"
        exit 1
    fi
    export BCBIO_DIR="$bcbio_dir"
    unset -v bcbio_dir
fi
