# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias dir="dir --color=auto"
    alias egrep="egrep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias grep="grep --color=auto"
    alias ls="ls --color=auto"
    alias vdir="vdir --color=auto"
fi

# Make `less` more friendly for non-text input files, see `lesspipe(1)`
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
