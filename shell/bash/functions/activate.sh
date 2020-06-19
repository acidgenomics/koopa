#!/usr/bin/env bash

_koopa_activate_bash_extras() {  # {{{1
    # """
    # Activate Bash shell extras.
    # @note Updated 2020-06-18.
    # """
    # Easier navigation (e.g. '**/qux' will enter './foo/bar/baz/qux').
    shopt -s autocd

    # Correct minor directory changing spelling mistakes (i.e. for 'cd').
    shopt -s cdspell

    # Check the window size after each command and if necessary, update the
    # values of LINES and COLUMNS.
    shopt -s checkwinsize

    # Save multiline commands.
    shopt -s cmdhist

    # Recursive globbing (e.g. 'echo **/*.txt'). If set, the pattern "**" used
    # in a pathname expansion context will match all files and zero or more
    # directories and subdirectories.
    shopt -s globstar

    # Append to the history file, don't overwrite it.
    shopt -s histappend

    # Case-insensitive globbing (used in pathname expansion).
    shopt -s nocaseglob

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

    # Make less more friendly for non-text input files, see lesspipe(1).
    [[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

    # Readline input options.
    if [[ -z "${INPUTRC:-}" ]] && [[ -r "${HOME}/.inputrc" ]]
    then
        export INPUTRC="${HOME}/.inputrc"
    fi

    # Prompt.
    PS1="$(_koopa_prompt)"
    export PS1

    # Alias definitions.
    # See /usr/share/doc/bash-doc/examples in the bash-doc package.
    if [[ -f ~/.bash_aliases ]]
    then
        # shellcheck source=/dev/null
        . ~/.bash_aliases
    fi

    return 0
}
