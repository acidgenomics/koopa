#!/bin/sh

_koopa_activate_path_helper() {
    # """
    # Activate 'path_helper'.
    # @note Updated 2023-03-10.
    #
    # This will source '/etc/paths.d' on supported platforms (e.g. BSD/macOS).
    # """
    __kvar_path_helper='/usr/libexec/path_helper'
    if [ ! -x "$__kvar_path_helper" ]
    then
        unset -v __kvar_path_helper
        return 0
    fi
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$("$__kvar_path_helper" -s)"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_path_helper
    return 0
}
