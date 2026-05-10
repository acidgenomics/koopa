#!/usr/bin/env zsh

_koopa_export_pager() {
    [[ -n "${PAGER:-}" ]] && return 0
    local less
    less="$(_koopa_bin_prefix)/less"
    if [[ -x "$less" ]]
    then
        export PAGER="${less} -R"
    fi
    return 0
}
