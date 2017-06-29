# https://bcbio-nextgen.readthedocs.io
bcbio_dir="/opt/bcbio/centos/bin"
if [[ -d $bcbio_dir ]]; then
    export BCBIO_DIR="$bcbio_dir"
    export PATH="$BCBIO_DIR:$PATH"
    unset PYTHONHOME
    unset PYTHONPATH
fi
unset bcbio_dir
