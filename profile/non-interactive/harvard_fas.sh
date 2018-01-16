# HPC environment variable
if [[ $HOSTNAME =~ ".rc.fas.harvard.edu" ]] || \
   [[ $(uname -s) = "Linux" ]] && \
   [[ -d /n/regal/ ]]
then
    export HPC="Harvard FAS Odyssey"
    export BCBIO_DIR="/n/regal/hsph_bioinfo/bcbio_nextgen/bin"
fi
