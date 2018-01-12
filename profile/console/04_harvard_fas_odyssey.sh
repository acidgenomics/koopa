if [[ $HOSTNAME =~ ".rc.fas.harvard.edu" ]] || \
   [[ $(uname -s) = "Linux" ]] && \
   [[ -d /n/regal/ ]]
then
    export HPC="Harvard FAS Odyssey"
fi
