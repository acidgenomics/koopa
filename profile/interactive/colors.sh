# dircolors
if command -v dircolors &> /dev/null
then
    test -r ~/.dircolors && \
        eval "$(dircolors -b ~/.dircolors)" || \
        eval "$(dircolors -b)"
    alias dir="dir --color=auto"
    alias egrep="egrep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias grep="grep --color=auto"
    alias ls="ls --color=auto"
    alias vdir="vdir --color=auto"
fi

# macOS shell uses LSCOLORS instead
if [[ $(uname -s) = "Darwin" ]]; then
    # `man ls`: see LSCOLORS section for color designators
    export CLICOLOR=1
    export LSCOLORS="Gxfxcxdxbxegedabagacad"
fi
