#!/usr/bin/env bash

# Bash shell options.
# Updated 2019-10-31.

# Readline input options.
if [ -z "${INPUTRC:-}" ] && [ -r "${HOME}/.inputrc" ]
then
    export INPUTRC="${HOME}/.inputrc"
fi

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

# Check the window size after each command.
# If necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Save multiline commands.
shopt -s cmdhist

# Enable history appending instead of overwriting.
shopt -s histappend

# Prompt.
PS1="$(_koopa_prompt)"
export PS1
