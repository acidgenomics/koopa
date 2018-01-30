if [[ $HPC =~ "HMS RC" ]]; then 
    # Set variable identifying the `chroot` you work in
    if [[ -z "$debian_chroot" ]] && [[ -r /etc/debian_chroot ]]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi
    
    # Export prompt string
    if [[ $TERM = "xterm-256color" ]]; then
        PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\n\$ "
    else
        PS1="${debian_chroot:+($debian_chroot)}\u@\h:\W\n\$ "
    fi
fi
