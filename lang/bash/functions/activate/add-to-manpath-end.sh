#!/usr/bin/env bash

_koopa_add_to_manpath_end() {
    MANPATH="${MANPATH:-}"
    local dir
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        MANPATH="$(_koopa_add_to_path_string_end "$MANPATH" "$dir")"
    done
    export MANPATH
    return 0
}
