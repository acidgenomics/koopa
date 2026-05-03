#!/usr/bin/env zsh

_koopa_activate_completion() {
    # """
    # Activate koopa shell completion.
    # @note Updated 2026-05-03.
    #
    # Zsh uses bashcompinit to support bash-style 'complete' declarations,
    # so we source our completion file directly after bashcompinit is active.
    # """
    local koopa_prefix
    koopa_prefix="$(_koopa_koopa_prefix)"
    local koopa_completion
    koopa_completion="${koopa_prefix}/etc/completion/koopa.sh"
    [[ -f "$koopa_completion" ]] || return 0
    # shellcheck source=/dev/null
    source "$koopa_completion"
    return 0
}
