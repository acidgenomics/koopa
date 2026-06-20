#!/bin/sh

_koopa_activate_op() {
    # """
    # Activate 1Password CLI ('op') shell plugins.
    # @note Updated 2026-06-13.
    #
    # Sources the POSIX alias definitions written by 'op plugin init <cli>'.
    # koopa never runs 'op plugin init' (interactive, user-specific); it only
    # auto-sources the generated file when present.
    #
    # @seealso
    # - https://developer.1password.com/docs/cli/shell-plugins/
    # """
    __kvar_plugins_file="${OP_CONFIG_DIR:-${XDG_CONFIG_HOME:?}/op}/plugins.sh"
    if [ ! -f "$__kvar_plugins_file" ]
    then
        unset -v __kvar_plugins_file
        return 0
    fi
    __kvar_nounset=0
    case "$-" in *u*) __kvar_nounset=1 ;; esac
    [ "$__kvar_nounset" -eq 1 ] && set +u
    # shellcheck source=/dev/null
    . "$__kvar_plugins_file"
    [ "$__kvar_nounset" -eq 1 ] && set -u
    unset -v __kvar_plugins_file __kvar_nounset
    return 0
}
