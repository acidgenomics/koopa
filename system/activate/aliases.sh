#!/bin/sh

# Aliases
# Updated 2019-09-18.

# See also:
# - https://github.com/MikeMcQuaid/dotfiles
# - https://github.com/stephenturner/oneliners

# Run `alias` in terminal to list current definitions.



# Potentially useful                                                        {{{1
# ==============================================================================

# > alias be='noglob bundle exec'
# > alias gist='gist --open --copy'
# > alias make='nice make'
# > alias rake='noglob rake'
# > alias rg='rg --colors "match:style:nobold" --colors "path:style:nobold"'
# > alias rsync='rsync --compress --human-readable --partial --progress'
# > alias zmv='noglob zmv -vW'



# Shortcuts                                                                 {{{1
# ==============================================================================

# Koopa home.
alias kh='cd $KOOPA_HOME'

# Quick exit.
alias e='exit'



# Colors                                                                    {{{1
# ==============================================================================

# Enable colors using dircolors.
# Note that this is commonly installed on Linux but not macOS.
if _koopa_quiet_which dircolors
then
    eval "$(dircolors -b)"
    alias dir='dir --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
    alias vdir='vdir --color=auto'
fi



# File and folder manipulation                                              {{{1
# ==============================================================================

# Note that I'm improving the interactivity and verbosity here by default.

# Copy files.
# Allowing recursive by default via `-r` flag.
alias cp='cp -irv'

# Create directory.
# Allowing recursive here by default via `-p` flag.
alias mkdir='mkdir -vp'

# Move files.
alias mv='mv -iv'

# Remove (delete) files.
# ## Don't enable recursion here by default via `-r` flag.
# This helps protect against accidental directory deletion.
# ## The `-I` flag only prompts once, which is awesome.
# However this not on macOS, so use `-i` flag there instead.
if _koopa_is_darwin
then
    alias rm='rm -iv'
else
    alias rm='rm -Iv'
fi



# File system navigation                                                    {{{1
# ==============================================================================

# Browse up and down.
alias u='clear; cd ../; pwd; ls'
alias d='clear; cd -; ls'

# Navigate up parent directories without `cd`.
# These are also supported by autojump.
# > alias ..='cd ..'
# > alias ...='cd ../../'
# > alias ....='cd ../../../'
# > alias .....='cd ../../../../'
# > alias ......='cd ../../../../../'

# Listing files.
alias ls='ls --color=auto'
alias l.='ls -Fd .*'
alias l1='ls -1p'
alias l='ls -AGghlo'
alias la='ls -Ahl'
alias ll='ls -hl'
alias cls='clear; ls'
alias lhead='l | head'
alias ltail='l | tail'

# Set more sensible defaults for size commands.
alias df='df -H'
alias du='du -sh'

# Improve less defaults.
alias less='less --ignore-case --raw-control-chars'



# File compression                                                          {{{1
# ==============================================================================

# Pack and unpack tar.gz files.
alias tarup='tar -czvf'
alias tardown='tar -xzvf'



# Programs                                                                  {{{1
# ==============================================================================

# R.
# Useful flags:
# - `--no-environ`
# - `--no-init`
# - `--no-restore`
# - `--no-save`
# - `--vanilla`
alias R='R --no-restore --no-save'

# Emacs.
# Use terminal (console) mode by default instead of window system.
alias emacs='emacs --no-window-system'
# Allow fast, default mode that skips '.emacs', '.emacs.d', etc.
alias emacs-default='emacs --no-init-file --no-window-system'

# Neovim.
# Allow fast, default mode that skips RC file.
alias nvim-default='nvim -u NONE'

# Easier checksum calculation.
alias sha256='shasum -a 256'

# Shiny server.
if _koopa_is_linux
then
    alias shiny-status='sudo systemctl status shiny-server'
    alias shiny-start='sudo systemctl start shiny-server'
    alias shiny-restart='sudo systemctl restart shiny-server'
fi

# Vim.
# Allow fast, default mode that skips RC file.
alias vim-default='vim -i NONE -u NONE -U NONE'
