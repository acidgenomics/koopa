# Enable color support
if [ $(uname -s) = "Darwin" ]; then
    export CLICOLOR=1
    export LSCOLORS="Gxfxcxdxbxegedabagacad"
    export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
fi
