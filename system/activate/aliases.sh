#!/bin/sh

# Aliases.
# Modified 2019-06-20.

# Potentially useful:
# > alias be="noglob bundle exec"
# > alias gist="gist --open --copy"
# > alias ls="ls -Fhlo --color"
# > alias make="nice make"
# > alias rake="noglob rake"
# > alias rg="rg --colors 'match:style:nobold' --colors 'path:style:nobold'"
# > alias rsync="rsync --partial --progress --human-readable --compress"
# > alias zmv="noglob zmv -vW"



# Shortcuts                                                                 {{{1
# ==============================================================================

# Quick exit.
alias e="exit"



# Colors                                                                    {{{1
# ==============================================================================

# Enable colors using dircolors.
# Note that this is commonly installed on Linux but not macOS.
if _koopa_quiet_which dircolors
then
    eval "$(dircolors -b)"
    alias dir="dir --color=auto"
    alias egrep="egrep --color=auto"
    alias fgrep="fgrep --color=auto"
    alias grep="grep --color=auto"
    alias ls="ls --color=auto"
    alias vdir="vdir --color=auto"
fi



# File and folder manipulation                                              {{{1
# ==============================================================================

# Note that I'm improving the interactivity and verbosity here by default.

# Copy files.
# Allowing recursive by default via `-r` flag.
alias cp="cp -irv"

# Create directory.
# Allowing recursive here by default via `-p` flag.
alias mkdir="mkdir -vp"

# Move files.
alias mv="mv -iv"

# Remove (delete) files.
#
# Don't enable recursion here by default via `-r` flag.
# This helps protect against accidental directory deletion.
#
# The `-I` flag only prompts once, which is awesome.
# However this not on macOS, so use `-i` flag there instead.
if [ ! -z "$MACOS" ]
then
    alias rm="rm -iv"
else
    alias rm="rm -Iv"
fi



# File system navigation                                                    {{{1
# ==============================================================================

# Listing files.
alias la="ls -a"
alias lF="ls -F"
alias ll="ls -AFGlh"

# Set more sensible defaults for size commands.
alias df="df -H"
alias du="du -sh"

# Improve less defaults.
alias less="less --ignore-case --raw-control-chars"



# Programs                                                                  {{{1
# ==============================================================================

# Emacs.
# Use terminal (console) mode by default instead of window system.
# alias emacs="emacs -nw"
alias emacs="emacs --no-window-system"

# Easier checksum calculation.
alias sha256="shasum -a 256"

# R.
# Useful flags:
# - `--no-environ`
# - `--no-init`
# - `--no-restore`
# - `--no-save`
# - `--vanilla`
alias R="R --no-restore --no-save"

# R shiny server.
if [ ! -z "${LINUX:-}" ]
then
    alias shiny-status="sudo systemctl status shiny-server"
    alias shiny-start="sudo systemctl start shiny-server"
    alias shiny-restart="sudo systemctl restart shiny-server"
fi
