#!/usr/bin/env bash

_koopa_is_set() {  # {{{1
    # """
    # Is the variable set and non-empty?
    # @note Updated 2020-03-27.
    #
    # Note that usage of 'declare' here is a bashism.
    # Can consider using 'type' instead for POSIX compliance.
    #
    # Passthrough of empty strings is bad practice in shell scripting.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3601515
    # - https://unix.stackexchange.com/questions/504082
    # - https://www.gnu.org/software/bash/manual/html_node/
    #       Shell-Parameter-Expansion.html
    # """
    local var
    var="${1:?}"

    # Check if variable is defined.
    local x
    x="$(declare -p "$var" 2>/dev/null || true)"
    [ -n "$x" ] || return 1

    # Check if variable contains non-empty value.
    local value
    case "$(_koopa_shell)" in
        bash)
            value="${!var}"
            ;;
        zsh)
            # shellcheck disable=SC2154
            value="${(P)var}"
            ;;
        *)
            _koopa_warning 'Unsupported shell.'
            return 1
            ;;
    esac
    [ -n "$value" ] || return 1

    return 0
}

