#!/usr/bin/env bash

_koopa_list_internal_functions() { # {{{1
    # """
    # List all functions defined by koopa.
    # @note Updated 2020-06-30.
    #
    # Currently only supported in Bash and Zsh.
    # """
    [[ "$#" -eq 0 ]] || return 1
    local x
    case "$(_koopa_shell)" in
        bash)
            x="$( \
                declare -F \
                | sed "s/^declare -f //g" \
            )"
            ;;
        zsh)
            # shellcheck disable=SC2086,SC2154
            x="$(print -l ${(ok)functions})"
            ;;
        *)
            _koopa_warning 'Unsupported shell.'
            return 1
            ;;
    esac
    x="$(_koopa_print "$x" | grep -E "^_koopa_")"
    _koopa_print "$x"
    return 0
}

_koopa_unset_internal_functions() { # {{{1
    # """
    # Unset all of koopa's internal functions.
    # @note Updated 2020-06-30.
    #
    # Currently only supported in Bash and Zsh.
    #
    # Potentially useful as a final clean-up step for activation.
    # Note that this will nuke functions currently required for interactive
    # prompt, so don't do this yet.
    # """
    [[ "$#" -eq 0 ]] || return 1
    local funs
    case "$(_koopa_shell)" in
        bash)
            # shellcheck disable=SC2119
            readarray -t funs <<< "$(_koopa_list_internal_functions)"
            ;;
        zsh)
            # shellcheck disable=SC2119
            funs=("${(@f)$(_koopa_list_internal_functions)}")
            ;;
        *)
            _koopa_warning 'Unsupported shell.'
            return 1
            ;;
    esac
    unset -f "${funs[@]}"
    return 0
}
