#!/bin/sh



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



# dircolors                                                                 {{{1
# ==============================================================================

if _koopa_is_installed dircolors
then
    # Use the custom colors defined in dotfiles, if possible.
    if [ -f "${KOOPA_HOME}/dotfiles/dircolors" ]
    then
        eval "$(dircolors "${KOOPA_HOME}/dotfiles/dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi



# exa                                                                    {{{1
# ==============================================================================

# Use exa instead of ls, if installed.
# It has better color support than dircolors.
# See also: https://the.exa.website/
if _koopa_is_installed exa
then
    alias ls="exa -Fg"
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

if [ -n "${LESSOPEN:-}" ] && _koopa_is_installed "lesspipe.sh"
then
    lesspipe_exe="$(_koopa_realpath "lesspipe.sh")"
    export LESSOPEN="|${lesspipe_exe} %s"
    export LESS_ADVANCED_PREPROCESSOR=1
fi



# LLVM                                                                      {{{1
# ==============================================================================

# Note that LLVM 7+ is now required to install umap-learn.
if _koopa_is_rhel7 && [ -x "/usr/bin/llvm-config-7.0-64" ]
then
    export LLVM_CONFIG="/usr/bin/llvm-config-7.0-64"
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
