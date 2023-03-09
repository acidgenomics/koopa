#!/bin/sh

_koopa_activate_asdf() {
    # """
    # Activate asdf.
    # @note Updated 2022-08-31.
    # """
    local nounset prefix
    prefix="${1:-}"
    [ -z "$prefix" ] && prefix="$(koopa_asdf_prefix)"
    [ -d "$prefix" ] || return 0
    # NOTE Use 'asdf.fish' for Fish shell.
    script="${prefix}/libexec/asdf.sh"
    [ -r "$script" ] || return 0
    _koopa_is_alias 'asdf' && unalias 'asdf'
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    # shellcheck source=/dev/null
    . "$script"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}
