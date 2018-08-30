# Harvard University =====================================================================

# HMS Orchestra (O2)
if [[ $HMS_CLUSTER == "o2" ]] && \
    [[ $HOSTNAME =~ ".o2.rc.hms.harvard.edu" ]] && \
    [[ $(uname -s) == "Linux" ]] && \
    [[ -d /n/data1/ ]]
then
    export HPC="HMS RC O2"
    if [[ -z "$BCBIO_DIR" ]]; then
        export BCBIO_DIR="/n/app/bcbio/tools/bin"
    fi
fi

# FAS Odyssey (O3)
if [[ $HOSTNAME =~ ".rc.fas.harvard.edu" ]] || \
    [[ $(uname -s) == "Linux" ]] && \
    [[ -d /n/regal/ ]]
then
    export HPC="Harvard FAS Odyssey"
    if [[ -z "$BCBIO_DIR" ]]; then
        export BCBIO_DIR="/n/regal/hsph_bioinfo/bcbio_nextgen/bin"
    fi
fi
