#!/bin/sh



# umask {{{1
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



# Default text editor {{{1
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



# Default pager {{{1
# ==============================================================================

if [ -z "${PAGER:-}" ]
then
    export PAGER="less"
fi



# Git {{{1
# ==============================================================================

if [ -z "${GIT_MERGE_AUTOEDIT:-}" ]
then
    export GIT_MERGE_AUTOEDIT="no"
fi



# GnuPGP {{{1
# ==============================================================================

# Enable passphrase prompting in terminal.
# Useful for getting Docker credential store to work.
# https://github.com/docker/docker-credential-helpers/issues/118
if [ -z "${GPG_TTY:-}" ] && _koopa_is_tty
then
    GPG_TTY="$(tty || true)"
    export GPG_TTY
fi



# lesspipe {{{1
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



# Python {{{1
# ==============================================================================

# Don't allow Python to change the prompt string by default.
if [ -z "${VIRTUAL_ENV_DISABLE_PROMPT:-}" ]
then
    export VIRTUAL_ENV_DISABLE_PROMPT=1
fi



# rsync {{{1
# ==============================================================================

if [ -z "${RSYNC_FLAGS:-}" ]
then
    RSYNC_FLAGS="$(_koopa_rsync_flags)"
    export RSYNC_FLAGS
fi



# Activation functions {{{1
# ==============================================================================

_koopa_activate_autojump
_koopa_activate_broot
# This has been observed to cause shell lockout.
_koopa_activate_fzf



# Aliases {{{1
# ==============================================================================

# Improve defaults {{{2
# ------------------------------------------------------------------------------

# Note that macOS ships with a very old version of GNU coreutils.
# Update these using Homebrew.

# Note that this doesn't work well on Alpine.
# > alias less='less --ignore-case --raw-control-chars'

KOOPA_MAKE_PREFIX="$(_koopa_make_prefix)"

if _koopa_str_match \
    "$(_koopa_which_realpath cp)" \
    "$KOOPA_MAKE_PREFIX"
then
    alias cp='cp --archive --interactive --verbose'
fi

if _koopa_str_match \
    "$(_koopa_which_realpath mkdir)" \
    "$KOOPA_MAKE_PREFIX"
then
    alias mkdir='mkdir --parents --verbose'
fi

if _koopa_str_match \
    "$(_koopa_which_realpath mv)" \
    "$KOOPA_MAKE_PREFIX"
then
    alias mv="mv --interactive --verbose"
fi

if _koopa_str_match \
    "$(_koopa_which_realpath rm)" \
    "$KOOPA_MAKE_PREFIX"
then
    alias rm='rm --dir --interactive="once" --preserve-root --verbose'
fi

unset -v KOOPA_MAKE_PREFIX

# Shortcuts {{{2
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

# List head or tail.
alias lh='l | head'
alias lt='l | tail'

# Clear then list.
alias cls='clear; l'

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

# Improve program defaults {{{2
# ------------------------------------------------------------------------------

if _koopa_is_installed R
then
    alias R="R --no-restore --no-save --quiet"
fi

if _koopa_is_installed black
then
    # Note that 79 characters conforms to PEP8 (see flake8 for details).
    alias black="black --line-length=79"
fi

if _koopa_is_installed emacs
then
    alias emacs="emacs --no-window-system"
fi
