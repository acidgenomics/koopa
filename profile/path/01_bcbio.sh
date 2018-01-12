# https://bcbio-nextgen.readthedocs.io

if [[ $HPC == "HMS RC O2" ]]; then
    export BCBIO_DIR="/n/app/bcbio/tools/bin"
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    export BCBIO_DIR="/opt/bcbio/centos/bin"
elif [[ $HPC == "Harvard FAS Odyssey" ]]; then
    export BCBIO_DIR="/n/regal/hsph_bioinfo/bcbio_nextgen/bin"
fi

# Update PATH
if [[ ! -z $BCBIO_DIR ]]; then
    if [[ ! -d $BCBIO_DIR ]]; then
        echo "$BCBIO_DIR missing"
        exit 1
    fi
    export PATH="$BCBIO_DIR:$PATH"
    unset -v PYTHONHOME PYTHONPATH
fi
