#!/bin/sh



# Notes                                                                     {{{1
# ==============================================================================

# Run 'alias' in terminal to list current definitions.

# See also:
# - https://github.com/MikeMcQuaid/dotfiles
# - https://github.com/stephenturner/oneliners



# Dot files                                                                 {{{1
# ==============================================================================

dotfiles="$(_koopa_config_dir)/dotfiles"
if [ -d "$dotfiles" ]
then
    export DOTFILES="$dotfiles"
fi
unset -v dotfiles



# umask                                                                     {{{1
# ==============================================================================

# Set default file permissions.
#
# - 'umask': Files and directories.
# - 'fmask': Only files.
# - 'dmask': Only directories.
#
# Use 'umask -S' to return 'u,g,o' values.
#
# - 0022: u=rwx,g=rx,o=rx
#         User can write, others can read. Usually default.
# - 0002: u=rwx,g=rwx,o=rx
#         User and group can write, others can read.
#         Recommended setting in a shared coding environment.
# - 0077: u=rwx,g=,o=
#         User alone can read/write. More secure.
#
# Access control lists (ACLs) are sometimes preferable to umask.
#
# Here's how to use ACLs with setfacl.
# > setfacl -d -m group:name:rwx /dir
#
# See also:
# - https://stackoverflow.com/questions/13268796
# - https://askubuntu.com/questions/44534

# > umask 0002



# Core                                                                      {{{1
# ==============================================================================

alias df='df -H'
alias df2='df --portability --print-type --si | sort'
alias du='du -sh'
alias h='history'
alias less='less --ignore-case --raw-control-chars'
alias sha256='shasum -a 256'
alias tarup='tar -czvf'
alias tardown='tar -xzvf'



# File system navigation                                                    {{{1
# ==============================================================================

alias e='exit'
alias kh='cd $KOOPA_HOME'
alias reload='exec "$SHELL" -l'

# Navigate up parent directories without 'cd'.
# These are also supported by autojump.
# > alias ..='cd ..'
# > alias ...='cd ../../'
# > alias ....='cd ../../../'
# > alias .....='cd ../../../../'
# > alias ......='cd ../../../../../'

alias l.='ls -Fd .*'
alias l1='ls -1p'
alias l='ls -AGghlo'
alias la='ls -Ahl'
alias ll='ls -hl'

alias cls='clear; ls'
alias lhead='l | head'
alias ltail='l | tail'

# Browse up and down.
alias u='clear; cd ../; pwd; ls'
alias d='clear; cd -; ls'



# GNU coreutils                                                             {{{1
# ==============================================================================

# Note: macOS doesn't bundle GNU coreutils, so be sure to install via Homebrew.

alias cp='cp --archive --interactive --verbose'
alias mkdir='mkdir --parents --verbose'
alias mv="mv --interactive --verbose"
alias rm='rm --dir --interactive="once" --preserve-root --verbose'

if _koopa_is_installed dircolors
then
    # This will set the 'LD_COLORS' environment variable.
    dircolors_file="${KOOPA_HOME}/dotfiles/app/coreutils/dircolors"
    if [ -f "$dircolors_file" ]
    then
        eval "$(dircolors "$dircolors_file")"
    else
        eval "$(dircolors -b)"
    fi
    alias dir='dir --color=auto'
    alias egrep='egrep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
    alias vdir='vdir --color=auto'
fi



# Default text editor                                                       {{{1
# ==============================================================================

# Set text editor, if unset.
# Recommending vim by default.
if [ -z "${EDITOR:-}" ]
then
    export EDITOR="vim"
fi

# Ensure VISUAL matches EDITOR.
if [ -n "${EDITOR:-}" ]
then
    export VISUAL="$EDITOR"
fi



# Default pager                                                             {{{1
# ==============================================================================

if [ -z "${PAGER:-}" ]
then
    export PAGER="less"
fi



# Emacs                                                                     {{{1
# ==============================================================================

_koopa_add_to_path_start "${HOME}/.emacs.d/bin"

alias emacs='emacs --no-window-system'

# Use terminal (console) mode by default instead of window system.
# Allow fast, default mode that skips '.emacs', '.emacs.d', etc.
alias emacs-default='emacs --no-init-file --no-window-system'

# Run with 24-bit true color support.
alias emacs24='TERM=xterm-24bit emacs --no-window-system'



# exa                                                                    {{{1
# ==============================================================================

# Use exa instead of ls, if installed.
# It has better color support than dircolors.
# See also: https://the.exa.website/
if _koopa_is_installed exa
then
    alias l='exa -Fg'
fi



# Git                                                                       {{{1
# ==============================================================================

export GIT_MERGE_AUTOEDIT="no"



# GnuPGP                                                                    {{{1
# ==============================================================================

# Enable passphrase prompting in terminal.
if [ -z "${GPG_TTY:-}" ] &&
    [ -z "${KOOPA_PIPED_INSTALL:-}" ] &&
    _koopa_is_installed tty
then
    GPG_TTY="$(tty)"
    export GPG_TTY
fi



# lesspipe                                                                  {{{1
# ==============================================================================

# Preconfigured on some Linux systems at '/etc/profile.d/less.sh'.
#
# See also:
# - https://github.com/wofr06/lesspipe

if [ -n "${LESSOPEN:-}" ] &&
    _koopa_is_installed "lesspipe.sh"
then
    lesspipe_exe="$(_koopa_realpath "lesspipe.sh")"
    export LESSOPEN="|${lesspipe_exe} %s"
    export LESS_ADVANCED_PREPROCESSOR=1
fi



# Neovim                                                                    {{{1
# ==============================================================================

alias nvim-default='nvim -u NONE'



# Python                                                                    {{{1
# ==============================================================================

# Note that 79 characters conforms to PEP8 (see flake8 for details).
alias black="black --line-length=79"

# Don't allow Python to change the prompt string by default.
if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
then
    export VIRTUAL_ENV_DISABLE_PROMPT=1
fi



# R                                                                         {{{1
# ==============================================================================

alias R='R --no-restore --no-save --quiet'



# Ruby                                                                      {{{1
# ==============================================================================

if [ -d "${HOME}/.gem" ]
then
    export GEM_HOME="${HOME}/.gem"
fi



# rsync                                                                     {{{1
# ==============================================================================

if [ -z "${RSYNC_FLAGS:-}" ]
then
    RSYNC_FLAGS="$(_koopa_rsync_flags)"
    export RSYNC_FLAGS
fi



# Shiny Server                                                              {{{1
# ==============================================================================

if _koopa_is_linux
then
    alias shiny-status='sudo systemctl status shiny-server'
    alias shiny-start='sudo systemctl start shiny-server'
    alias shiny-restart='sudo systemctl restart shiny-server'
fi



# Vim                                                                      {{{1
# ==============================================================================

# Allow fast, default mode that skips RC file.
alias vim-default='vim -i NONE -u NONE -U NONE'
