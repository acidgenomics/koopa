#!/bin/sh



# Notes  {{{1
# ==============================================================================

# Run 'alias' in terminal to list current definitions.
#
# See also:
# - https://github.com/MikeMcQuaid/dotfiles
# - https://github.com/stephenturner/oneliners



# umask  {{{1
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



# Default text editor  {{{1
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



# Default pager  {{{1
# ==============================================================================

if [ -z "${PAGER:-}" ]
then
    export PAGER="less"
fi



# Git  {{{1
# ==============================================================================

if [ -z "${GIT_MERGE_AUTOEDIT:-}" ]
then
    export GIT_MERGE_AUTOEDIT="no"
fi



# GnuPGP  {{{1
# ==============================================================================

# Enable passphrase prompting in terminal.
# Useful for getting Docker credential store to work.
# https://github.com/docker/docker-credential-helpers/issues/118
if [ -z "${GPG_TTY:-}" ] && _koopa_is_tty
then
    GPG_TTY="$(tty || true)"
    export GPG_TTY
fi



# lesspipe  {{{1
# ==============================================================================

# Preconfigured on some Linux systems at '/etc/profile.d/less.sh'.
#
# On some older Linux distros:
# > eval $(/usr/bin/lesspipe)
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



# Python  {{{1
# ==============================================================================

# Don't allow Python to change the prompt string by default.
if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
then
    export VIRTUAL_ENV_DISABLE_PROMPT=1
fi



# rsync  {{{1
# ==============================================================================

if [ -z "${RSYNC_FLAGS:-}" ]
then
    RSYNC_FLAGS="$(_koopa_rsync_flags)"
    export RSYNC_FLAGS
fi



# Activation functions  {{{1
# ==============================================================================

_koopa_activate_autojump
_koopa_activate_broot
_koopa_activate_fzf



# Aliases  {{{1
# ==============================================================================

# Improve defaults  {{{2
# ------------------------------------------------------------------------------

# Note that macOS ships with a very old version of GNU coreutils.
# Update these using Homebrew.

# Note that this doesn't work well on Alpine.
# > alias less='less --ignore-case --raw-control-chars'

make_prefix="$(_koopa_make_prefix)"

if _koopa_is_matching_fixed "$(_koopa_which_realpath cp)" "$make_prefix"
then
    alias cp='cp --archive --interactive --verbose'
fi

if _koopa_is_matching_fixed "$(_koopa_which_realpath mkdir)" "$make_prefix"
then
    alias mkdir='mkdir --parents --verbose'
fi

if _koopa_is_matching_fixed "$(_koopa_which_realpath mv)" "$make_prefix"
then
    alias mv="mv --interactive --verbose"
fi

if _koopa_is_matching_fixed "$(_koopa_which_realpath rm)" "$make_prefix"
then
    alias rm='rm --dir --interactive="once" --preserve-root --verbose'
fi

unset -v make_prefix

# Shortcuts  {{{2
# ------------------------------------------------------------------------------

alias c='clear'
alias e='exit'
alias h='history'
alias k='cd "${KOOPA_PREFIX:?}"'
alias ku='koopa update'

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

alias cls='clear; ls'
alias df2='df --portability --print-type --si | sort'
alias lhead='l | head'
alias ltail='l | tail'
alias reload='exec "$SHELL" -l'
alias sha256='shasum -a 256'
alias tardown='tar -xzvf'
alias tarup='tar -czvf'

# Navigate up parent directories without 'cd'.
# These are also supported by autojump.
# > alias ..='cd ..'
# > alias ...='cd ../../'
# > alias ....='cd ../../../'
# > alias .....='cd ../../../../'
# > alias ......='cd ../../../../../'

# Non-standard programs  {{{2
# ------------------------------------------------------------------------------

if _koopa_is_installed R
then
    alias R='R --no-restore --no-save --quiet'
fi

if _koopa_is_installed black
then
    # Note that 79 characters conforms to PEP8 (see flake8 for details).
    alias black="black --line-length=79"
fi

if _koopa_is_installed docker
then
    alias docker-prune='docker system prune --all --force'
fi

if _koopa_is_installed emacs
then
    alias emacs='emacs --no-window-system'

    # Use terminal (console) mode by default instead of window system.
    # Allow fast, default mode that skips '.emacs', '.emacs.d', etc.
    alias emacs-default='emacs --no-init-file --no-window-system'

    # Run with 24-bit true color support.
    alias emacs24='TERM=xterm-24bit emacs --no-window-system'
fi

if _koopa_is_installed gpg
then
    alias gpg-prompt='printf '' | gpg -s'
    alias gpg-reload='gpg-connect-agent reloadagent /bye'
    alias gpg-restart='gpgconf --kill gpg-agent'
fi

if _koopa_is_installed nvim
then
    # Default mode that doesn't load user config.
    alias nvim-default='nvim -u NONE'
fi

if _koopa_is_installed shiny-server
then
    alias shiny-restart="sudo systemctl restart shiny-server"
    alias shiny-start="sudo systemctl start shiny-server"
    alias shiny-status="sudo systemctl status shiny-server"
fi

if _koopa_is_installed vim
then
    # Default mode that doesn't load user config.
    alias vim-default='vim -i NONE -u NONE -U NONE'
fi
