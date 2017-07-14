if [[ $CDC_JOINED_DC =~ ".med.harvard.edu" ]] && \
   [[ $CDC_JOINED_DOMAIN == "med.harvard.edu" ]] && \
   [[ $CDC_LOCALHOST =~ ".med.harvard.edu" ]] && \
   [[ $HOSTNAME =~ ".orchestra" ]] && \
   [[ $LSB_QUEUE == "interactive" ]] && \
   [[ $USER_PRINCIPAL_NAME =~ "@MED.HARVARD.EDU" ]] && \
   [[ $(uname -s) = "Linux" ]] && \
   [[ -d /n/data1/ ]]
then
    export HPC="HMS RC Orchestra"
elif [[ $HOSTNAME =~ ".o2.rc.hms.harvard.edu" ]] && \
     [[ $SLURM_JOB_PARTITION == "interactive" ]] && \
     [[ $SLURM_SUBMIT_HOST =~ ".o2.rc.hms.harvard.edu" ]]
then
    export HPC="HMS RC O2"
fi

# HMS RC: Harvard Medical School Research Computing
if [[ $HPC =~ "HMS RC" ]]; then 
    # If not running interactively, don't do anything
    [ -z "$PS1" ] && return
    
    # Prompt string
    # Set variable identifying the `chroot` you work in
    if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi
    # Check for color support
    if [[ $TERM = "xterm-256color" ]]; then
        PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ "
    else
        PS1="${debian_chroot:+($debian_chroot)}\u@\h:\W\$ "
    fi
fi
