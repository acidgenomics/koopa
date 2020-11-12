#!/usr/bin/env bash

# """
# Bash/Zsh TAB completion.
# Updated 2020-11-12.
#
# Keep all of these commands in a single file.
# Sourcing multiple scripts doesn't work reliably.
#
# Multi-level bash completion:
# - https://stackoverflow.com/questions/17879322/
# - https://stackoverflow.com/questions/5302650/
# """

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
        if _koopa_is_linux
        then
            args+=(
                'delete-cache'
            )
        fi
        COMPREPLY=("$(compgen -W "${args[*]}" -- "$cur")")
    elif [ "$COMP_CWORD" -eq 2 ]
    then
        case "$prev" in
            header)
                args=(
                    'bash'
                    'posix'
                    'r'
                    'zsh'
                )
                COMPREPLY=("$(compgen -W "${args[*]}" -- "$cur")")
                ;;
            install)
                args=(
                    ## > 'mike'
                    'dotfiles'
                    'py-koopa'
                    'r-koopa'
                )
                COMPREPLY=("$(compgen -W "${args[*]}" -- "$cur")")
                ;;
            # FIXME REWORK THIS.
            # FIXME DROPPED TO SYSTEM.
            get-version)
                args=(
                    'emacs'
                    'vim'
                )
                COMPREPLY=("$(compgen -W "${args[*]}" -- "$cur")")
                ;;
            system)
                args=(
                    'log'
                    'pull'
                )
                COMPREPLY=("$(compgen -W "${args[*]}" -- "$cur")")
                ;;
            update)
                args=(
                    '--fast'
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
