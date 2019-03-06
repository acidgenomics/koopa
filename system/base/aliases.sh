#!/bin/sh

# alias be="noglob bundle exec"
# alias gist="gist --open --copy"
# alias ls="ls -Fhlo --color"
# alias make="nice make"
# alias rake="noglob rake"
# alias rg="rg --colors 'match:style:nobold' --colors 'path:style:nobold'"
# alias rsync="rsync --partial --progress --human-readable --compress"
# alias zmv="noglob zmv -vW"

# Enable colors using dircolors.
# Note that this is commonly installed on Linux but not macOS.
if quiet_which dircolors
then
    eval "$(dircolors -b)"
    alias dir="dir --color=auto"
    alias egrep="egrep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias grep="grep --color=auto"
    alias ls="ls --color=auto"
    alias vdir="vdir --color=auto"
fi

# Quick exit.
alias e="exit"

# Improve common file system command defaults.
alias cp="cp -irv"
alias mkdir="mkdir -vp"
alias mv="mv -iv"
# Note that `-I` flag only prompts once, which is awesome.
alias rm="rm -Iv"
alias scp="scp -r"

# Listing files.
alias la="ls -a"
alias lF="ls -F"
alias ll="ls -AFGlh"

# Shortcut for listing tmux sessions.
alias tls="tmux ls"

# Set more sensible defaults for size commands.
alias df="df -H"
alias du="du -sh"

# Improve less defaults.
alias less="less --ignore-case --raw-control-chars"

# Easier checksum calculation.
alias sha256="shasum -a 256"

# Emacs.
# Use terminal (console) mode by default instead of window system.
# alias emacs="emacs -nw"
alias emacs="emacs --no-window-system"

# Disable R prompt to save workspace.
# --no-environ
# --no-init
# --no-restore
# --no-save
# --vanilla
alias R="R --no-restore --no-save"

# Fake realpath support, if necessary.
if ! quiet_which realpath
then
    alias realpath="readlink -f"
fi
