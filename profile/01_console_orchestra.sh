if [ $(uname -s) = "Linux" ] && [ -d /groups/bcbio/ ] && [ -d /n/data1/ ] && [ -d /n/scratch2/ ]; then
    orchestra=true
    
    # If not running interactively, don't do anything
    [ -z "$PS1" ] && return
    
    # Prompt string
    # Set variable identifying the `chroot` you work in
    if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi
    # Check for color support
    case "$TERM" in
        xterm-color) color_prompt=yes;;
    esac
    if [ "$color_prompt" = yes ]; then
        PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
    else
        PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "
    fi
    unset color_prompt
fi
