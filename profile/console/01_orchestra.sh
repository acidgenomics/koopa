if [[ $HOSTNAME =~ ".orchestra" ]] && [[ $(uname -s) = "Linux" ]] && [[ -d /n/data1/ ]]; then
    orchestra=true
    
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
