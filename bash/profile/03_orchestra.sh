if [ -d /groups/bcbio/ ] && [ -d /n/data1/ ] && [ -d /n/scratch2/ ]
then
    orchestra=true
    
    # If not running interactively, don't do anything
    [ -z "$PS1" ] && return

    # Set variable identifying the `chroot` you work in (used in the prompt below)
    if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]
    then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    # Set a fancy prompt (non-color, unless we know we "want" color)
    case "$TERM" in
        xterm-color) color_prompt=yes;;
    esac

    # We have color support; assume it's compliant with Ecma-48 (ISO/IEC-6429).
    # (Lack of such support is extremely rare, and such a case would tend to support
    # setf rather than setaf.)
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null
    then
        color_prompt=yes
    else
        color_prompt=
    fi
    if [ "$color_prompt" = yes ]
    then
        PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
    else
        PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "
    fi
    unset color_prompt
fi
