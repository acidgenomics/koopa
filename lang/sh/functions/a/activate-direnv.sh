#!/bin/sh

_koopa_activate_direnv() {
    # """
    # Activate direnv.
    # @note Updated 2026-04-22.
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
    # Harden against stale, transient values inherited from parent app process.
    unset -v \
        DIRENV_DIFF \
        DIRENV_DIR \
        DIRENV_FILE \
        DIRENV_WATCHES
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            eval "$("$__kvar_direnv" hook "$__kvar_shell")"
            eval "$("$__kvar_direnv" export "$__kvar_shell")"
            ;;
    esac
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_direnv \
        __kvar_nounset \
        __kvar_shell
    return 0
}
