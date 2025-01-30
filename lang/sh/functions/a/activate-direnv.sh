#!/bin/sh

_koopa_activate_direnv() {
    # """
    # Activate zoxide.
    # @note Updated 2025-01-30.
    #
    # @seealso
    # - https://direnv.net/docs/hook.html
    # """
    __kvar_direnv="$(_koopa_bin_prefix)/direnv"
    if [ ! -x "$__kvar_direnv" ]
    then
        unset -v __kvar_direnv
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            eval "$("$__kvar_direnv" hook "$__kvar_shell")"
            ;;
    esac
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_direnv \
        __kvar_nounset \
        __kvar_shell
    return 0
}
