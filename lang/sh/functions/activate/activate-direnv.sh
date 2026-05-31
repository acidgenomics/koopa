#!/bin/sh

_koopa_activate_direnv() {
    # """
    # Activate direnv.
    # @note Updated 2026-04-22.
    #
    # @seealso
    # - https://direnv.net/docs/hook.html
    # """
    __kvar_direnv="${KOOPA_PREFIX:?}/bin/direnv"
    if [ ! -x "$__kvar_direnv" ]
    then
        unset -v __kvar_direnv
        return 0
    fi
    __kvar_shell="${KOOPA_SHELL##*/}"
    __kvar_nounset=0
    case "$-" in *u*) __kvar_nounset=1 ;; esac
    [ "$__kvar_nounset" -eq 1 ] && set +u
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
    [ "$__kvar_nounset" -eq 1 ] && set -u
    unset -v \
        __kvar_direnv \
        __kvar_nounset \
        __kvar_shell
    return 0
}
