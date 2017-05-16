# https://bcbio-nextgen.readthedocs.io
if [[ -d /opt/bcbio/centos/bin ]]; then
    bcbio_dir="/opt/bcbio/centos/bin"
    export PATH=/opt/bcbio/centos/bin:$PATH
    unset PYTHONHOME
    unset PYTHONPATH
fi
