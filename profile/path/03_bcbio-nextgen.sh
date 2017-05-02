# https://bcbio-nextgen.readthedocs.io
if [[ -d /opt/bcbio/centos/bin ]]; then
    echo "    [x] bcbio-nextgen"
    export PATH=/opt/bcbio/centos/bin:$PATH
    unset PYTHONHOME
    unset PYTHONPATH
fi
