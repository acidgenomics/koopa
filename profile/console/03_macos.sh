# Enable color support
if [[ $(uname -s) = "Darwin" ]]; then
    export CLICOLOR=1
    export LSCOLORS="Gxfxcxdxbxegedabagacad"
    export PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ "
fi
