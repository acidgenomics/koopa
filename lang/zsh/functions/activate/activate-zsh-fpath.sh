#!/usr/bin/env zsh

_koopa_activate_zsh_fpath() {
    local -A dict
    local -a prefixes
    dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    prefixes+=(
        "${dict['koopa_prefix']}/lang/zsh/functions"
    )
    _koopa_add_to_fpath_start "${prefixes[@]}"
    return 0
}
