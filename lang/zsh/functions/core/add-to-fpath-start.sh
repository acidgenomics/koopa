#!/usr/bin/env zsh

_koopa_add_to_fpath_start() {
    local dir
    FPATH="${FPATH:-}"
    for dir in "$@"
    do
        [ -d "$dir" ] || continue
        FPATH="$(_koopa_add_to_path_string_start "$FPATH" "$dir")"
    done
    export FPATH
    return 0
}
