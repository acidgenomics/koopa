#!/usr/bin/env bash

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
    local plugins_file
    plugins_file="${OP_CONFIG_DIR:-${XDG_CONFIG_HOME:?}/op}/plugins.sh"
    [[ -f "$plugins_file" ]] || return 0
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$plugins_file"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
