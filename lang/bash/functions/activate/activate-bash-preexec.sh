#!/usr/bin/env bash

_koopa_activate_bash_preexec() {
    # """
    # Activate bash-preexec.
    # @note Updated 2026-06-18.
    #
    # bash-preexec must be sourced before any tool that registers into
    # preexec_functions[] or precmd_functions[] (e.g. starship, atuin). If
    # starship inits before bash-preexec is loaded, it falls back to installing
    # a raw DEBUG trap instead of appending to preexec_functions[], breaking
    # hook chaining for all subsequent tools.
    #
    # @seealso https://github.com/rcaloras/bash-preexec
    # """
    _koopa_is_root && return 0
    local bash_preexec
    bash_preexec="${KOOPA_PREFIX:?}/opt/bash-preexec/share/bash-preexec/bash-preexec.sh"
    [[ -f "$bash_preexec" ]] || return 0
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    # shellcheck source=/dev/null
    source "$bash_preexec"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}
