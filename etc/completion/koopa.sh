#!/usr/bin/env bash

# Multi-level bash completion:
# - https://stackoverflow.com/questions/17879322/
# - https://stackoverflow.com/questions/5302650/

# koopa {{{1
# ==============================================================================

_koopa_complete() {
    local args cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    if [ "$COMP_CWORD" -eq 1 ]
    then
        args=(
            '--help'
            '--version'
            'check-system'
            'get-version'
            'header'
            'info'
            'install'
            'list'
            'prefix'
            'test'
            'uninstall'
            'update'
        )
        COMPREPLY=("$(compgen -W "${args[*]}" -- "$cur")")
    elif [ "$COMP_CWORD" -eq 2 ]
    then
        case "$prev" in
            'install')
                args=(
                    'dotfiles'
                    'py-koopa'
                    'r-koopa'
                )
                COMPREPLY=("$(compgen -W "${args[*]}" -- "$cur")")
                ;;
            'get-version')
                args=(
                    'emacs'
                    'vim'
                )
                COMPREPLY=("$(compgen -W "${args[*]}" -- "$cur")")
                ;;
            *)
                ;;
        esac
    fi
    return 0
}
complete -F _koopa_complete koopa

# syntactic {{{1
# ==============================================================================

words=(
    '--prefix'
    '--recursive'
    '--strict'
)
complete -W "${words[*]}" kebab-case snake-case
words+=('--strict')
complete -W "${words[*]}" camel-case

