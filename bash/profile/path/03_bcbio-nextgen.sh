# https://bcbio-nextgen.readthedocs.io
if [ -d /opt/bcbio/centos/bin ]
then
    export PATH=/opt/bcbio/centos/bin:$PATH
    unset PYTHONHOME
    unset PYTHONPATH
fi
