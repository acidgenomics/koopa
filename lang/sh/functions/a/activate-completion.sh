#!/bin/sh

_koopa_activate_completion() {
    # """
    # Activate completion (with TAB key).
    # @note Updated 2023-03-09.
    # """
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            unset -v __kvar_shell
            return 0
            ;;
    esac
    __kvar_koopa_prefix="$(_koopa_koopa_prefix)"
    for __kvar_file in "${__kvar_koopa_prefix}/etc/completion/"*'.sh'
    do
        # shellcheck source=/dev/null
        [ -f "$__kvar_file" ] && . "$__kvar_file"
    done
    unset -v \
        __kvar_file \
        __kvar_koopa_prefix \
        __kvar_shell
    return 0
}
