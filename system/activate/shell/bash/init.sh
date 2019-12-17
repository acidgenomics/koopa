#!/usr/bin/env bash

# Bash shell options.
# Updated 2019-12-17.

# Readline input options.
if [ -z "${INPUTRC:-}" ] && [ -r "${HOME}/.inputrc" ]
then
    export INPUTRC="${HOME}/.inputrc"
fi

# Make less more friendly for non-text input files, see lesspipe(1).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options.
export HISTCONTROL="ignoreboth"

# For setting history length.
# See HISTSIZE and HISTFILESIZE in bash(1).
export HISTSIZE=1000
export HISTFILESIZE=2000

# Map key bindings to default editor.
# Note that Bash currently uses Emacs by default.
case "${EDITOR:-}" in
    emacs)
        set -o emacs
        ;;
    vi|vim)
        set -o vi
        ;;
esac

# Correct minor directory changing spelling mistakes.
shopt -s cdspell

# Check the window size after each command and if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

# Save multiline commands.
shopt -s cmdhist

# If set, the pattern "**" used in a pathname expansion context will match all
# files and zero or more directories and subdirectories.
shopt -s globstar

# Append to the history file, don't overwrite it.
shopt -s histappend

# Prompt.
PS1="$(_koopa_prompt)"
export PS1

# Enable programmable completion features. You don't need to enable this if it's
# already enabled in '/etc/bash.bashrc' and '/etc/profile' sources
# '/etc/bash.bashrc'.
if ! shopt -oq posix
then
    if [ -f /usr/share/bash-completion/bash_completion ]
    then
        # shellcheck source=/dev/null
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]
    then
        # shellcheck source=/dev/null
        . /etc/bash_completion
    fi
fi

# Alias definitions.
# You may want to put all your additions into a separate file, instead of adding
# them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]
then
    # shellcheck source=/dev/null
    . ~/.bash_aliases
fi
