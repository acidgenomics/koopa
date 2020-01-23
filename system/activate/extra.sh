#!/bin/sh



# Notes                                                                     {{{1
# ==============================================================================

# Run 'alias' in terminal to list current definitions.
#
# See also:
# - https://github.com/MikeMcQuaid/dotfiles
# - https://github.com/stephenturner/oneliners



# Dot files                                                                 {{{1
# ==============================================================================

dotfiles="$(_koopa_config_prefix)/dotfiles"
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



# History                                                                   {{{1
# ==============================================================================

# See bash(1) for more options.
# For setting history length, see HISTSIZE and HISTFILESIZE.

# Don't keep duplicate lines in the history.
# Alternatively, set "ignoreboth" to also ignore lines starting with space.
if [ -z "${HISTCONTROL:-}" ]
then
    export HISTCONTROL="ignoredups"
fi

# Standardize the history file name across shells.
if [ -z "${HISTFILE:-}" ]
then
    HISTFILE="${HOME}/.$(_koopa_shell)-history"
    export HISTFILE
fi

if [ -z "${HISTSIZE:-}" ]
then
    export HISTSIZE=100000
fi

if [ -z "${SAVEHIST:-}" ]
then
    export SAVEHIST=100000
fi

if [ -z "${HISTIGNORE:-}" ]
then
    export HISTIGNORE="&:ls:[bf]g:exit"
fi

# Add the date/time to 'history' command output.
# Note that on macOS bash will fail if 'set -e' is set and this isn't exported.
if [ -z "${HISTTIMEFORMAT:-}" ]
then
    export HISTTIMEFORMAT="%Y%m%d %T  "
fi

# For bash users, autojump keeps track of directories by modifying
# '$PROMPT_COMMAND'. Do not overwrite '$PROMPT_COMMAND' in this case.
# See also: https://github.com/wting/autojump
# > export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ;} history -a"
if [ -z "${PROMPT_COMMAND:-}" ]
then
    export PROMPT_COMMAND="history -a"
fi



# GNU coreutils                                                             {{{1
# ==============================================================================


if _koopa_is_installed dircolors
then
    # This will set the 'LD_COLORS' environment variable.
    dircolors_file="${KOOPA_PREFIX}/dotfiles/app/coreutils/dircolors"
    if [ -f "$dircolors_file" ]
    then
        eval "$(dircolors "$dircolors_file")"
    else
        eval "$(dircolors -b)"
    fi
    unset -v dircolors_file
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



# Docker                                                                    {{{1
# ==============================================================================

alias docker-prune='docker system prune --all --force'



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




# GCC                                                                       {{{1
# ==============================================================================

# Colored GCC warnings and errors.
if [ -z "${GCC_COLORS:-}" ]
then
    # SC1004: This backslash+linefeed is literal. Break outside single quotes if
    # you just want to break the line.
    export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:'\
'locus=01:quote=01'
fi



# Git                                                                       {{{1
# ==============================================================================

if [ -z "${GIT_MERGE_AUTOEDIT:-}" ]
then
    export GIT_MERGE_AUTOEDIT="no"
fi



# GnuPGP                                                                    {{{1
# ==============================================================================

# This is causing install to error out on minimal Docker images.
# Disabled until I can figure out how to handle this.

# > # Enable passphrase prompting in terminal.
# > if [ -z "${GPG_TTY:-}" ] &&
# >     [ -z "${KOOPA_PIPED_INSTALL:-}" ] &&
# >     _koopa_is_installed tty
# > then
# >     GPG_TTY="$(tty)"
# >     export GPG_TTY
# > fi



# lesspipe                                                                  {{{1
# ==============================================================================

# Preconfigured on some Linux systems at '/etc/profile.d/less.sh'.
#
# See also:
# - https://github.com/wofr06/lesspipe

if [ -n "${LESSOPEN:-}" ] &&
    _koopa_is_installed "lesspipe.sh"
then
    lesspipe_exe="$(_koopa_which_realpath "lesspipe.sh")"
    export LESSOPEN="|${lesspipe_exe} %s"
    export LESS_ADVANCED_PREPROCESSOR=1
fi



# Python                                                                    {{{1
# ==============================================================================

# Don't allow Python to change the prompt string by default.
if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
then
    export VIRTUAL_ENV_DISABLE_PROMPT=1
fi



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



# Activation functions                                                      {{{1
# ==============================================================================

_koopa_activate_autojump
_koopa_activate_broot
_koopa_activate_fzf



# Aliases                                                                   {{{1
# ==============================================================================

# Shortcuts                                                               # {{{2
# ------------------------------------------------------------------------------

alias k='cd $KOOPA_PREFIX'
alias ku='koopa update'

alias e='exit'
alias h='history'

if _koopa_is_installed exa
then
    alias l='exa -F'
    alias la='exa -Fal --group'
    alias ll='exa -Fl --group'
else
    alias l='ls -F'
    alias la='ls -Fahl'
    alias ll='ls -BFhl'
fi

alias l.='l -d .*'
alias l1='ls -1'

# Browse up and down.
alias u='clear; cd ../; pwd; l'
alias d='clear; cd -; l'

# Navigate up parent directories without 'cd'.
# These are also supported by autojump.
# > alias ..='cd ..'
# > alias ...='cd ../../'
# > alias ....='cd ../../../'
# > alias .....='cd ../../../../'
# > alias ......='cd ../../../../../'



# Improved app defaults                                                   # {{{2
# ------------------------------------------------------------------------------

# Note that macOS ships with a very old version of GNU coreutils.
# Update these using Homebrew.

alias R='R --no-restore --no-save --quiet'
# Note that 79 characters conforms to PEP8 (see flake8 for details).
alias black="black --line-length=79"
alias cp='cp --archive --interactive --verbose'
alias df='df -H'
alias du='du -sh'
alias less='less --ignore-case --raw-control-chars'
alias mkdir='mkdir --parents --verbose'
alias mv="mv --interactive --verbose"
alias rm='rm --dir --interactive="once" --preserve-root --verbose'

# App alternates                                                          # {{{2
# ------------------------------------------------------------------------------

alias cls='clear; ls'
alias df2='df --portability --print-type --si | sort'
alias lhead='l | head'
alias ltail='l | tail'
# Default mode that doesn't load user config.
alias nvim-default='nvim -u NONE'
alias reload='exec "$SHELL" -l'
alias sha256='shasum -a 256'
alias tardown='tar -xzvf'
alias tarup='tar -czvf'
# Default mode that doesn't load user config.
alias vim-default='vim -i NONE -u NONE -U NONE'

if _koopa_is_installed shiny-server
then
    alias shiny-restart="sudo systemctl restart shiny-server"
    alias shiny-start="sudo systemctl start shiny-server"
    alias shiny-status="sudo systemctl status shiny-server"
fi
